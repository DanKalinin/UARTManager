//
//  PeripheralCell.h
//  UART
//
//  Created by Dan on 11.09.15.
//  Copyright (c) 2015 Dan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>



@interface PeripheralCell : UITableViewCell

@property (nonatomic) CBPeripheral *peripheral;

@end
