//
//  PeripheralCell.m
//  UART
//
//  Created by Dan on 11.09.15.
//  Copyright (c) 2015 Dan. All rights reserved.
//

#import "PeripheralCell.h"



@implementation PeripheralCell

- (void)setPeripheral:(CBPeripheral *)peripheral {
    _peripheral = peripheral;
    self.textLabel.text = peripheral.name;
    self.detailTextLabel.text = peripheral.identifier.UUIDString;
}

@end
