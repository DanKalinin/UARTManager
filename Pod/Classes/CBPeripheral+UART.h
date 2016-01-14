//
//  CBPeripheral+UART.h
//  UART
//
//  Created by Dan Kalinin on 13.09.15.
//  Copyright (c) 2015 Dan Kalinin. All rights reserved.
//

#import "UARTManager.h"
@class UARTCommand;



NS_ASSUME_NONNULL_BEGIN

@interface CBPeripheral (UART)

typedef void (^UARTPeripheralHandler)(__kindof CBPeripheral *);

@property CBUUID *serviceUUID;
@property CBUUID *TXCharacteristicUUID;
@property CBUUID *RXCharacteristicUUID;
@property (readonly, nullable) NSError *error;
@property NSInteger maxPacketSize;
- (void)connectWithSuccess:(nullable UARTPeripheralHandler)success failure:(nullable UARTPeripheralHandler)failure completion:(nullable UARTPeripheralHandler)completion timeout:(NSTimeInterval)timeout;
- (BOOL)writePacket:(UARTPacket *)packet;
@property (nullable) UARTPacketHandler onPacketReceived;
@property (readonly) NSMutableArray<__kindof UARTCommand *> *queue;

@end

NS_ASSUME_NONNULL_END
