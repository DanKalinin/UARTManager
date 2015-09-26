//
//  UARTConstants.m
//  UART
//
//  Created by Dan on 15.09.15.
//  Copyright (c) 2015 Dan Kalinin. All rights reserved.
//

#import "UARTConstants.h"



NSString *const UARTServiceUUID                                     = @"6E400001-B5A3-F393-E0A9-E50E24DCCA9E";
NSString *const UARTTXCharacteristicUUID                            = @"6E400003-B5A3-F393-E0A9-E50E24DCCA9E";
NSString *const UARTRXCharacteristicUUID                            = @"6E400002-B5A3-F393-E0A9-E50E24DCCA9E";
const NSInteger UARTMaxPacketSize                                   = 20;

NSString *const UARTManagerDidConnectPeripheralNotification         = @"UARTManagerDidConnectPeripheralNotification";
NSString *const UARTManagerDidDisconnectPeripheralNotification      = @"UARTManagerDidDisconnectPeripheralNotification";
NSString *const UARTManagerDidFailToConnectPeripheralNotification   = @"UARTManagerDidFailToConnectPeripheralNotification";
NSString *const UARTManagerDidDiscoverPeripheralNotification        = @"UARTManagerDidDiscoverPeripheralNotification";
NSString *const UARTManagerDidUpdateStateNotification               = @"UARTManagerDidUpdateStateNotification";
NSString *const UARTManagerWillRestoreStateNotification             = @"UARTManagerWillRestoreStateNotification";

NSString *const UARTCentralManagerStateInfoKey                      = @"UARTCentralManagerStateInfoKey";
NSString *const UARTPeripheralKey                                   = @"UARTPeripheralKey";

NSString *const UARTErrorDomain                                     = @"UARTErrorDomain";
