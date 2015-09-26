//
//  UARTConstants.h
//  UART
//
//  Created by Dan on 15.09.15.
//  Copyright (c) 2015 Dan Kalinin. All rights reserved.
//

#import <Foundation/Foundation.h>



extern NSString *const UARTServiceUUID;
extern NSString *const UARTTXCharacteristicUUID;
extern NSString *const UARTRXCharacteristicUUID;
extern const NSInteger UARTMaxPacketSize;

extern NSString *const UARTManagerDidConnectPeripheralNotification;
extern NSString *const UARTManagerDidDisconnectPeripheralNotification;
extern NSString *const UARTManagerDidFailToConnectPeripheralNotification;
extern NSString *const UARTManagerDidDiscoverPeripheralNotification;
extern NSString *const UARTManagerDidUpdateStateNotification;
extern NSString *const UARTManagerWillRestoreStateNotification;

extern NSString *const UARTCentralManagerStateInfoKey;
extern NSString *const UARTPeripheralKey;

extern NSString *const UARTErrorDomain;

typedef NS_ENUM(NSInteger, UARTErrorCode) {
    UARTCentralManagerStateError = 0,
    UARTConnectionTimeoutExpirationError,
    UARTServiceCharacteristicsError,
    UARTMaxPacketSizeExceedingError,
    UARTPeripheralDisconnectedError,
    UARTCommandTimeoutExpirationError,
    UARTCommandRXTXPacketsMismatchError
};
