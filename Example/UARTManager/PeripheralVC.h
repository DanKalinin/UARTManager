//
//  PeripheralVC.h
//  UART
//
//  Created by Dan Kalinin on 13.09.15.
//  Copyright (c) 2015 Dan Kalinin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CBPeripheral+UART.h"



@interface PeripheralVC : UITableViewController

@property CBPeripheral *peripheral;

@end
