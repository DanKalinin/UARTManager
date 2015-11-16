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

## Usage

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
