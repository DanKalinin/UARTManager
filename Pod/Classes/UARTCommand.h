//
//  UARTCommand.h
//  UART
//
//  Created by Dan Kalinin on 14.09.15.
//  Copyright (c) 2015 Dan Kalinin. All rights reserved.
//

#import "UARTManager.h"



NS_ASSUME_NONNULL_BEGIN

@interface UARTCommand : NSObject

typedef void (^UARTCommandHandler)(__kindof UARTCommand *);

@property (readonly, nullable) UARTPacket *RXPacket;
@property UARTPacket *TXPacket;
@property (readonly, nullable) NSError *error;
@property (readonly) uint64_t time;
- (BOOL)isRXPacket:(UARTPacket *)RXPacket responseToTXPacket:(UARTPacket *)TXPacket;
- (void)sendToPeripheral:(CBPeripheral *)peripheral success:(nullable UARTCommandHandler)success failure:(nullable UARTCommandHandler)failure completion:(nullable UARTCommandHandler)completion timeout:(NSTimeInterval)timeout;

@end

NS_ASSUME_NONNULL_END
