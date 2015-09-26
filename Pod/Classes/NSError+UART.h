//
//  NSError+UART.h
//  UART
//
//  Created by Dan Kalinin on 21.09.15.
//  Copyright © 2015 Dan Kalinin. All rights reserved.
//

#import "UARTManager.h"



NS_ASSUME_NONNULL_BEGIN

@interface NSError (UART)

+ (instancetype)UARTCentralManagerStateError;
+ (instancetype)UARTConnectionTimeoutExpirationError;
+ (instancetype)UARTServiceCharacteristicsError;
+ (instancetype)UARTMaxPacketSizeExceedingError;
+ (instancetype)UARTPeripheralDisconnectedError;
+ (instancetype)UARTCommandTimeoutExpirationError;
+ (instancetype)UARTCommandRXTXPacketsMismatchError;

@end

NS_ASSUME_NONNULL_END
