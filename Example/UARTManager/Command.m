//
//  Command.m
//  UART
//
//  Created by Dan Kalinin on 14.09.15.
//  Copyright (c) 2015 Dan Kalinin. All rights reserved.
//

#import "Command.h"



@interface Command ()

@end



@implementation Command

+ (instancetype)fromDictionary:(NSDictionary *)dictionary {
    Command *command = [self new];
    command.name = dictionary[@"name"];
    command.value = dictionary[@"value"];
    return command;
}

- (NSDictionary *)toDictionary {
    return @{@"name"  : self.name ? self.name : @"",
             @"value" : self.value ? self.value : @""};
}

- (BOOL)isRXPacket:(UARTPacket *)RXPacket responseToTXPacket:(UARTPacket *)TXPacket {
    return [RXPacket.array[1] isEqualToNumber:TXPacket.array[1]] && [RXPacket.array[2] isEqualToNumber:TXPacket.array[2]];
}

#pragma mark - Accessors

- (void)setValue:(NSString *)value {
    _value = value;
    self.TXPacket = [UARTPacket packetWithArray:[[value componentsSeparatedByCharactersInSet:[NSCharacterSet punctuationCharacterSet]] valueForKey:@"intValue"]];
}

@end
