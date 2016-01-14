//
//  BTScanner.m
//  UART
//
//  Created by Dan Kalinin on 13.09.15.
//  Copyright (c) 2015 Dan Kalinin. All rights reserved.
//

#import "UARTManager.h"



@interface UARTManager () <CBCentralManagerDelegate>

@property id <CBCentralManagerDelegate> cmDelegate;
@property NSMutableDictionary *peripheralData;
@property BOOL scanning;

@end



@interface UARTPeripheralData : NSObject

+ (instancetype)data:(CBPeripheral *)peripheral;
@property (weak) CBPeripheral *peripheral;
@property NSDictionary *advertisementData;
@property NSNumber *RSSI;
@property CBUUID *serviceUUID;
@property CBUUID *TXCharacteristicUUID;
@property CBUUID *RXCharacteristicUUID;
@property NSInteger maxPacketSize;
@property BOOL connecting;
@property BOOL reconnecting;
@property BOOL connected;
@property NSError *error;
@property (copy) UARTPeripheralHandler success;
@property (copy) UARTPeripheralHandler failure;
@property (copy) UARTPeripheralHandler completion;
@property NSTimer *timer;
@property (copy) UARTPacketHandler onPacketReceived;
@property NSMutableArray *queue;

@end



@interface CBPeripheral (_UART) <CBPeripheralDelegate>

@property (readonly) UARTPeripheralData *data;
- (void)connect;
- (void)finishWithSuccess:(BOOL)success;

@end



@interface UARTPacket ()

@property NSData *data;
@property NSError *error;

@end



@implementation UARTManager

+ (instancetype)manager {
    static UARTManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [self new];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.peripheralData = [NSMutableDictionary dictionary];
    }
    return self;
}

#pragma mark - Accessors

- (void)setCm:(CBCentralManager *)cm {
    self.cmDelegate = cm.delegate;
    cm.delegate = self;
    _cm = cm;
}

#pragma mark - Central manager delegate

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    peripheral.delegate = peripheral;
    [peripheral connect];
    
    if ([self.cmDelegate respondsToSelector:@selector(centralManager:didConnectPeripheral:)]) {
        [self.cmDelegate centralManager:central didConnectPeripheral:peripheral];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:UARTManagerDidConnectPeripheralNotification object:self userInfo:@{UARTPeripheralKey : peripheral}];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    [peripheral finishWithSuccess:NO];
    
    if ([self.cmDelegate respondsToSelector:@selector(centralManager:didDisconnectPeripheral:error:)]) {
        [self.cmDelegate centralManager:central didDisconnectPeripheral:peripheral error:error];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:UARTManagerDidDisconnectPeripheralNotification object:self userInfo:@{UARTPeripheralKey : peripheral}];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    peripheral.data.error = error;
    [peripheral finishWithSuccess:NO];
    
    if ([self.cmDelegate respondsToSelector:@selector(centralManager:didFailToConnectPeripheral:error:)]) {
        [self.cmDelegate centralManager:central didFailToConnectPeripheral:peripheral error:error];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:UARTManagerDidFailToConnectPeripheralNotification object:self userInfo:@{UARTPeripheralKey : peripheral}];
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    peripheral.data.advertisementData = advertisementData;
    peripheral.data.RSSI = RSSI;
    if (peripheral.data.reconnecting) {
        peripheral.data.reconnecting = NO;
        [peripheral connect];
    }
    
    if ([self.cmDelegate respondsToSelector:@selector(centralManager:didDiscoverPeripheral:advertisementData:RSSI:)]) {
        [self.cmDelegate centralManager:central didDiscoverPeripheral:peripheral advertisementData:advertisementData RSSI:RSSI];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:UARTManagerDidDiscoverPeripheralNotification object:self userInfo:@{UARTPeripheralKey : peripheral}];
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    
    if (central.state != CBCentralManagerStatePoweredOn) {
        for (CBPeripheral *peripheral in self.peripheralData.allKeys) {
            peripheral.data.error = [NSError UARTCentralManagerStateError];
            [peripheral finishWithSuccess:NO];
        }
    }
    
    [self.cmDelegate centralManagerDidUpdateState:central];
    [[NSNotificationCenter defaultCenter] postNotificationName:UARTManagerDidUpdateStateNotification object:self];
}

- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary *)dict {
    if ([self.cmDelegate respondsToSelector:@selector(centralManager:willRestoreState:)]) {
        [self.cmDelegate centralManager:central willRestoreState:dict];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:UARTManagerWillRestoreStateNotification object:self userInfo:@{UARTCentralManagerStateInfoKey : dict}];
}

@end



@implementation UARTPeripheralData

+ (instancetype)data:(CBPeripheral *)peripheral {
    UARTPeripheralData *peripheralData = [UARTManager manager].peripheralData[peripheral];
    if (!peripheralData) {
        peripheralData = [self new];
        [UARTManager manager].peripheralData[peripheral] = peripheralData;
    }
    return peripheralData;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.serviceUUID = [CBUUID UUIDWithString:UARTServiceUUID];
        self.TXCharacteristicUUID = [CBUUID UUIDWithString:UARTTXCharacteristicUUID];
        self.RXCharacteristicUUID = [CBUUID UUIDWithString:UARTRXCharacteristicUUID];
        self.maxPacketSize = UARTMaxPacketSize;
        self.queue = [NSMutableArray array];
    }
    return self;
}

@end



@implementation CBPeripheral (UART)

#pragma mark - Public

- (void)connectWithSuccess:(UARTPeripheralHandler)success failure:(UARTPeripheralHandler)failure completion:(UARTPeripheralHandler)completion timeout:(NSTimeInterval)timeout {
    self.data.success = success;
    self.data.failure = failure;
    self.data.completion = completion;
    
    self.data.timer = [NSTimer scheduledTimerWithTimeInterval:timeout target:self selector:@selector(timeoutExpired) userInfo:nil repeats:NO];
    
    if (self.data.connected) {
        [self finishWithSuccess:YES];
    } else {
        if (self.data.connecting) {
            return;
        } else {
            [self connect];
        }
    }
}

- (BOOL)writePacket:(UARTPacket *)packet {
    if (self.data.connected) {
        if (packet.data.length <= self.data.maxPacketSize) {
            [self writeValue:packet.data forCharacteristic:self.RXCharacteristic type:CBCharacteristicWriteWithoutResponse];
            return YES;
        } else {
            packet.error = [NSError UARTMaxPacketSizeExceedingError];
            return NO;
        }
    } else {
        packet.error = [NSError UARTPeripheralDisconnectedError];
        return NO;
    }
}

#pragma mark - Accessors

- (UARTPeripheralData *)data {
    return [UARTPeripheralData data:self];
}

- (CBUUID *)serviceUUID {
    return self.data.serviceUUID;
}

- (CBUUID *)TXCharacteristicUUID {
    return self.data.TXCharacteristicUUID;
}

- (CBUUID *)RXCharacteristicUUID {
    return self.data.RXCharacteristicUUID;
}

- (NSInteger)maxPacketSize {
    return self.data.maxPacketSize;
}

- (void)setServiceUUID:(CBUUID *)serviceUUID {
    if (serviceUUID) {
        self.data.serviceUUID = serviceUUID;
    }
}

- (void)setTXCharacteristicUUID:(CBUUID *)TXCharacteristicUUID {
    if (TXCharacteristicUUID) {
        self.data.TXCharacteristicUUID = TXCharacteristicUUID;
    }
}

- (void)setRXCharacteristicUUID:(CBUUID *)RXCharacteristicUUID {
    if (RXCharacteristicUUID) {
        self.data.RXCharacteristicUUID = RXCharacteristicUUID;
    }
}

- (void)setMaxPacketSize:(NSInteger)maxPacketSize {
    self.data.maxPacketSize = maxPacketSize;
}

- (CBService *)service {
    return [self.services filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"UUID = %@", self.data.serviceUUID]].firstObject;
}

- (CBCharacteristic *)TXCharacteristic {
    return [self.service.characteristics filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"UUID = %@", self.data.TXCharacteristicUUID]].firstObject;
}

- (CBCharacteristic *)RXCharacteristic {
    return [self.service.characteristics filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"UUID = %@", self.data.RXCharacteristicUUID]].firstObject;
}

- (UARTPacketHandler)onPacketReceived {
    return self.data.onPacketReceived;
}

- (void)setOnPacketReceived:(UARTPacketHandler)onPacketReceived {
    self.data.onPacketReceived = onPacketReceived;
}

- (NSMutableArray *)queue {
    return self.data.queue;
}

- (NSError *)error {
    return self.data.error;
}

#pragma mark - Private

- (void)connect {
    switch ([UARTManager manager].cm.state) {
        case CBCentralManagerStatePoweredOn:
            self.data.connecting = YES;
            switch (self.state) {
                case CBPeripheralStateConnected:
                    if (self.service) {
                        if (self.TXCharacteristic && self.RXCharacteristic) {
                            if ((self.TXCharacteristic.properties & CBCharacteristicPropertyNotify) && (self.RXCharacteristic.properties & CBCharacteristicPropertyWrite)) {
                                if (self.TXCharacteristic.isNotifying) {
                                    self.data.connecting = NO;
                                    self.data.connected = YES;
                                    [self finishWithSuccess:YES];
                                } else {
                                    [self setNotifyValue:YES forCharacteristic:self.TXCharacteristic];
                                }
                            } else {
                                self.data.error = [NSError UARTServiceCharacteristicsError];
                                [self finishWithSuccess:NO];
                            }
                        } else {
                            [self discoverCharacteristics:@[self.data.TXCharacteristicUUID, self.data.RXCharacteristicUUID] forService:self.service];
                        }
                    } else {
                        [self discoverServices:@[self.data.serviceUUID]];
                    }
                    break;
                case CBPeripheralStateDisconnected:
#ifdef __IPHONE_9_0
                case CBPeripheralStateDisconnecting:
#endif
                    if ([[[UARTManager manager].cm retrievePeripheralsWithIdentifiers:@[self.identifier]] containsObject:self]) {
                        [[UARTManager manager].cm connectPeripheral:self options:nil];
                    } else if ([[[UARTManager manager].cm retrieveConnectedPeripheralsWithServices:@[self.data.serviceUUID]] containsObject:self]) {
                        [[UARTManager manager].cm connectPeripheral:self options:nil];
                    } else {
                        self.data.reconnecting = YES;
                        [[UARTManager manager].cm scanForPeripheralsWithServices:@[self.data.serviceUUID] options:nil];
                    }
                    break;
                case CBPeripheralStateConnecting:
                    break;
                default:
                    break;
            }
            break;
        default:
            self.data.error = [NSError UARTCentralManagerStateError];
            [self finishWithSuccess:NO];
            break;
    }
}

- (void)timeoutExpired {
    self.data.error = [NSError UARTConnectionTimeoutExpirationError];
    [self finishWithSuccess:NO];
}

- (void)finishWithSuccess:(BOOL)success {
    [self.data.timer invalidate];
    
    if (success) {
        self.data.error = nil;
        !self.data.success ? : self.data.success(self);
    } else {
        self.data.connecting = NO;
        self.data.reconnecting = NO;
        self.data.connected = NO;
        self.data.onPacketReceived = nil;
        [self.queue removeAllObjects];
        if (self.TXCharacteristic) {
            [self setNotifyValue:NO forCharacteristic:self.TXCharacteristic];
        }
        [[UARTManager manager].cm cancelPeripheralConnection:self];
        !self.data.failure ? : self.data.failure(self);
    }
    !self.data.completion ? : self.data.completion(self);
    
    self.data.success = nil;
    self.data.failure = nil;
    self.data.completion = nil;
}

#pragma mark - Peripheral delegate

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    if (error) {
        self.data.error = error;
        [self finishWithSuccess:NO];
    } else {
        [self connect];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    if (error) {
        self.data.error = error;
        [self finishWithSuccess:NO];
    } else {
        [self connect];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
        self.data.error = error;
        [self finishWithSuccess:NO];
    } else {
        [self connect];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    UARTPacket *packet = [UARTPacket new];
    if (error) {
        packet.error = error;
    } else {
        packet.data = characteristic.value;
    }
    !self.data.onPacketReceived ? : self.data.onPacketReceived(packet);
}

- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error {
    if (!error) {
        self.data.RSSI = RSSI;
    }
}

@end



@implementation UARTPacket

+ (instancetype)packetWithData:(NSData *)data {
    UARTPacket *packet = [UARTPacket new];
    packet.data = data;
    return packet;
}

+ (instancetype)packetWithArray:(NSArray<NSNumber *> *)numbers {
    Byte bytes[numbers.count];
    for (NSUInteger i = 0; i < numbers.count; i++) {
        bytes[i] = numbers[i].charValue;
    }
    return [self packetWithData:[NSData dataWithBytes:bytes length:sizeof(bytes)]];
}

- (NSArray *)array {
    Byte bytes[self.data.length];
    [self.data getBytes:&bytes length:self.data.length];
    NSMutableArray *array = [NSMutableArray array];
    for (NSUInteger i = 0; i < self.data.length; i++) {
        [array addObject:@(bytes[i])];
    }
    return array;
}

@end
