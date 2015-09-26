//
//  Command.h
//  UART
//
//  Created by Dan Kalinin on 14.09.15.
//  Copyright (c) 2015 Dan Kalinin. All rights reserved.
//

#import "UARTCommand.h"



@interface Command : UARTCommand

+ (instancetype)fromDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)toDictionary;
@property NSString *name;
@property (nonatomic) NSString *value;
@property BOOL selected;

@end
