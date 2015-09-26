//
//  BTScanner.h
//  UART
//
//  Created by Dan Kalinin on 13.09.15.
//  Copyright (c) 2015 Dan Kalinin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "UARTConstants.h"
#import "NSError+UART.h"
#import "UARTPacket.h"
#import "UARTCommand.h"
#import "CBPeripheral+UART.h"



NS_ASSUME_NONNULL_BEGIN

@interface UARTManager : NSObject

+ (instancetype)manager NS_SWIFT_NAME(init());
@property (nonatomic) CBCentralManager *cm;

@end

NS_ASSUME_NONNULL_END
