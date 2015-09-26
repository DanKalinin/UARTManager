//
//  UARTPacket.h
//  UART
//
//  Created by Dan on 15.09.15.
//  Copyright (c) 2015 Dan Kalinin. All rights reserved.
//

#import "UARTManager.h"



NS_ASSUME_NONNULL_BEGIN

@interface UARTPacket : NSObject

typedef void (^UARTPacketHandler)(__kindof UARTPacket *);

+ (instancetype)packetWithData:(NSData *)data NS_SWIFT_NAME(init(data:));
+ (instancetype)packetWithArray:(NSArray<NSNumber *> *)numbers NS_SWIFT_NAME(init(array:));
@property (readonly) NSError *error;
@property (readonly) NSData *data;
@property (readonly) NSArray<NSNumber *> *array;

@end

NS_ASSUME_NONNULL_END
