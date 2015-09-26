//
//  CommandCell.m
//  UART
//
//  Created by Dan Kalinin on 14.09.15.
//  Copyright (c) 2015 Dan Kalinin. All rights reserved.
//

#import "CommandCell.h"
#import "Command.h"



@implementation CommandCell

- (void)setCommand:(Command *)command {
    _command = command;
    self.textLabel.text = command.name;
    self.detailTextLabel.text = command.value;
}

@end
