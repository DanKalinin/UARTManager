//
//  NSError+UART.m
//  UART
//
//  Created by Dan Kalinin on 21.09.15.
//  Copyright © 2015 Dan Kalinin. All rights reserved.
//

#import "NSError+UART.h"



@implementation NSError (UART)

+ (instancetype)UARTCentralManagerStateError {
    return [self errorWithDomain:UARTErrorDomain code:UARTCentralManagerStateError userInfo:@{NSLocalizedDescriptionKey : @"Bluetooth is not on"}];
}

+ (instancetype)UARTConnectionTimeoutExpirationError {
    return [self errorWithDomain:UARTErrorDomain code:UARTConnectionTimeoutExpirationError userInfo:@{NSLocalizedDescriptionKey : @"Connection timeout expired"}];
}

+ (instancetype)UARTServiceCharacteristicsError {
    return [self errorWithDomain:UARTErrorDomain code:UARTServiceCharacteristicsError userInfo:@{NSLocalizedDescriptionKey : @"Invalid UART configuration"}];
}

+ (instancetype)UARTMaxPacketSizeExceedingError {
    return [self errorWithDomain:UARTErrorDomain code:UARTMaxPacketSizeExceedingError userInfo:@{NSLocalizedDescriptionKey : @"Large packet size"}];
}

+ (instancetype)UARTPeripheralDisconnectedError {
    return [self errorWithDomain:UARTErrorDomain code:UARTPeripheralDisconnectedError userInfo:@{NSLocalizedDescriptionKey : @"Peripheral is disconnected"}];
}

+ (instancetype)UARTCommandTimeoutExpirationError {
    return [self errorWithDomain:UARTErrorDomain code:UARTCommandTimeoutExpirationError userInfo:@{NSLocalizedDescriptionKey : @"Command timeout expired"}];
}

+ (instancetype)UARTCommandRXTXPacketsMismatchError {
    return [self errorWithDomain:UARTErrorDomain code:UARTCommandRXTXPacketsMismatchError userInfo:@{NSLocalizedDescriptionKey : @"Invalid response"}];
}

@end
