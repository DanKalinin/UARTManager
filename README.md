# UARTManager

[![CI Status](http://img.shields.io/travis/DanKalinin/UARTManager.svg?style=flat)](https://travis-ci.org/DanKalinin/UARTManager)
[![Version](https://img.shields.io/cocoapods/v/UARTManager.svg?style=flat)](http://cocoapods.org/pods/UARTManager)
[![License](https://img.shields.io/cocoapods/l/UARTManager.svg?style=flat)](http://cocoapods.org/pods/UARTManager)
[![Platform](https://img.shields.io/cocoapods/p/UARTManager.svg?style=flat)](http://cocoapods.org/pods/UARTManager)

## Description

UARTManager presents the UART-communication library over Bluetooth. Some BLE SoCs, such as nRF51 series from Nordic Semiconductor include on-board UART profile which allows to use BLE as UART bus. This profile is presented by UART service and by TX and RX characteristics.

Features:
* Library provides a complete solution to communicate with Nordic BLE chips over UART.
* Vendors can implement their own protocol over UART profile using the system of commands and responses to them.
* Library provides `UARTCommand` class allowing to easy implement own command system by overriding `- isRXPacket:responseToTXPacket:` method.
* Command roundtrip time measurement with up to nanosecond accuracy. Precise system timing functions are used for that.
* Modern API providing flexible mechanism of callbacks based on blocks, notifications and delegates. It's up to you which pattern to use.
* Up to 10 concurrent peripheral connections are supported.

## Usage

First set up the central manager object which `UARTManager` will be use to communicate with peripherals. Add the next line to `- application:didFinishLaunchingWithOptions:` method of `AppDelegate`:

```objc
[UARTManager manager].cm = [[CBCentralManager alloc] initWithDelegate:nil queue:dispatch_get_main_queue() options:@{CBCentralManagerOptionRestoreIdentifierKey : @"My Central Manager"}];
```

Next start scan for peripherals from any application's view controller:

```objc
- (void)viewDidLoad {
    [super viewDidLoad];
    self.peripherals = [NSMutableSet set];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didDiscoverPeripheral:) name:UARTManagerDidDiscoverPeripheralNotification object:nil];
    [[UARTManager manager].cm scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:UARTServiceUUID]] options:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UARTManagerDidDiscoverPeripheralNotification object:nil];
    [[UARTManager manager].cm stopScan];
}

- (void)didDiscoverPeripheral:(NSNotification *)note {
    CBPeripheral *peripheral = note.userInfo[UARTPeripheralKey];
    [self.peripherals addObject:peripheral];
}
```

When needed peripheral is discovered - connect to it. The connection process includes discovering of UART service and TX, RX characteristics, so you don't need to write extra code to discover them. Connection timeout can be also specified.

```objc
[peripheral connectWithSuccess:^(CBPeripheral *peripheral) {
    // Peripheral is ready to receive packets   
} failure:^(CBPeripheral *peripheral) {
    // Error while connecting, discovering TX, RX characheristics or specified timeout expiration
    NSLog(@"Error connecting to peripheral - %@", peripheral.error);
} completion:^(CBPeripheral *peripheral) {
    // Called anyway if connection is either established or failed
} timeout:1.0];
```

Optionally you can configure UART service and TX, RX characteristics UUIDs before connecting to peripheral. By default these values equal to `UARTServiceUUID`, `UARTTXCharacteristicUUID` and `UARTRXCharacteristicUUID` which corresponds to Nordic standard UART profile configuration.

```objc
peripheral.serviceUUID = [CBUUID UUIDWithString:@"6E400001-B5A3-F393-E0A9-E50E24DCCA9E"];
peripheral.TXCharacteristicUUID = [CBUUID UUIDWithString:@"6E400003-B5A3-F393-E0A9-E50E24DCCA9E"];
peripheral.RXCharacteristicUUID = [CBUUID UUIDWithString:@"6E400002-B5A3-F393-E0A9-E50E24DCCA9E"];
```

Next prepare the packet for sending to connected peripheral. They can be created either with raw data or with array of bytes (0-255).

```objc
NSData *data = [@"Hello World" dataUsingEncoding:NSASCIIStringEncoding];
UARTPacket *packet = [UARTPacket packetWithData:data];
```

```objc
NSArray *array = @[@2, @4, @8, @16, @32, @64, @128, @255];
UARTPacket *packet = [UARTPacket packetWithArray:array];
```

To write created packet to peripheral's RX characteristic without response add the following line of code:

```objc
[peripheral writePacket:packet];
```

If you need to receive the answer to sent packet just incapsulate `UARTPacket` to `UARTCommand` object and send it to peripheral:

```objc
UARTCommand *command = [UARTCommand new];
command.TXPacket = packet;

[command sendToPeripheral:peripheral success:^(UARTCommand *command) {
    NSLog(@"Received packet - %@", command.RXPacket.array);
    NSLog(@"Roundtrip time - %llu", command.time);
} failure:^(UARTCommand *command) {
    NSLog(@"Error sending command - %@", command.error);
} completion:^(UARTCommand *command) {
    
} timeout:1.0];
```

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

UARTManager is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "UARTManager"
```

## Author

DanKalinin, daniil5511@gmail.com

## License

UARTManager is available under the MIT license. See the LICENSE file for more info.
