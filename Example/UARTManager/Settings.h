//
//  Settings.h
//  UART
//
//  Created by Dan Kalinin on 21.09.15.
//  Copyright © 2015 Dan Kalinin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UARTManager.h"



@interface Settings : NSObject

+ (instancetype)settings;
@property CBUUID *serviceUUID;
@property CBUUID *TXCharacteristicUUID;
@property CBUUID *RXCharacteristicUUID;
@property NSTimeInterval connectionTimeout;
@property NSTimeInterval commandTimeout;
@property NSInteger maxPacketSize;

@end
