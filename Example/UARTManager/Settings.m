//
//  Settings.m
//  UART
//
//  Created by Dan Kalinin on 21.09.15.
//  Copyright © 2015 Dan Kalinin. All rights reserved.
//

#import "Settings.h"
NSString *const ServiceUUIDKey          = @"ServiceUUIDKey";
NSString *const TXCharacteristicUUIDKey = @"TXCharacteristicUUIDKey";
NSString *const RXCharacteristicUUIDKey = @"RXCharacteristicUUIDKey";
NSString *const ConnectionTimeoutKey    = @"ConnectionTimeoutKey";
NSString *const CommandTimeoutKey       = @"CommandTimeoutKey";
NSString *const MaxPacketSizeKey        = @"MaxPacketSizeKey";



@implementation Settings

+ (instancetype)settings {
    static Settings *settings = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        settings = [self new];
    });
    return settings;
}

- (void)setServiceUUID:(CBUUID *)serviceUUID {
    [[NSUserDefaults standardUserDefaults] setObject:serviceUUID.UUIDString forKey:ServiceUUIDKey];
}

- (void)setTXCharacteristicUUID:(CBUUID *)TXCharacteristicUUID {
    [[NSUserDefaults standardUserDefaults] setObject:TXCharacteristicUUID.UUIDString forKey:TXCharacteristicUUIDKey];
}

- (void)setRXCharacteristicUUID:(CBUUID *)RXCharacteristicUUID {
    [[NSUserDefaults standardUserDefaults] setObject:RXCharacteristicUUID.UUIDString forKey:RXCharacteristicUUIDKey];
}

- (void)setConnectionTimeout:(NSTimeInterval)connectionTimeout {
    [[NSUserDefaults standardUserDefaults] setDouble:connectionTimeout forKey:ConnectionTimeoutKey];
}

- (void)setCommandTimeout:(NSTimeInterval)commandTimeout {
    [[NSUserDefaults standardUserDefaults] setDouble:commandTimeout forKey:CommandTimeoutKey];
}

- (void)setMaxPacketSize:(NSInteger)maxPacketSize {
    [[NSUserDefaults standardUserDefaults] setInteger:maxPacketSize forKey:MaxPacketSizeKey];
}

- (CBUUID *)serviceUUID {
    NSString *UUIDString = [[NSUserDefaults standardUserDefaults] stringForKey:ServiceUUIDKey];
    return UUIDString ? [CBUUID UUIDWithString:UUIDString] : [CBUUID UUIDWithString:UARTServiceUUID];
}

- (CBUUID *)TXCharacteristicUUID {
    NSString *UUIDString = [[NSUserDefaults standardUserDefaults] stringForKey:TXCharacteristicUUIDKey];
    return UUIDString ? [CBUUID UUIDWithString:UUIDString] : [CBUUID UUIDWithString:UARTTXCharacteristicUUID];
}

- (CBUUID *)RXCharacteristicUUID {
    NSString *UUIDString = [[NSUserDefaults standardUserDefaults] stringForKey:RXCharacteristicUUIDKey];
    return UUIDString ? [CBUUID UUIDWithString:UUIDString] : [CBUUID UUIDWithString:UARTRXCharacteristicUUID];
}

- (NSTimeInterval)connectionTimeout {
    NSNumber *timeout = [[NSUserDefaults standardUserDefaults] objectForKey:ConnectionTimeoutKey];
    return timeout ? timeout.doubleValue : 1.0;
}

- (NSTimeInterval)commandTimeout {
    NSNumber *timeout = [[NSUserDefaults standardUserDefaults] objectForKey:CommandTimeoutKey];
    return timeout ? timeout.doubleValue : 0.5;
}

- (NSInteger)maxPacketSize {
    NSNumber *size = [[NSUserDefaults standardUserDefaults] objectForKey:MaxPacketSizeKey];
    return size ? size.integerValue : UARTMaxPacketSize;
}

@end
