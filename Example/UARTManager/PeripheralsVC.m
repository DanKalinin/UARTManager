//
//  PeripheralsVC.m
//  UART
//
//  Created by Dan on 11.09.15.
//  Copyright (c) 2015 Dan. All rights reserved.
//

#import "PeripheralsVC.h"
#import "PeripheralCell.h"
#import "PeripheralVC.h"
#import "UARTManager.h"
#import "Settings.h"



@interface PeripheralsVC () <UITableViewDataSource>

@property NSMutableArray *peripherals;

@end



@implementation PeripheralsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.peripherals = [NSMutableArray array];
    [[NSNotificationCenter defaultCenter] addObserverForName:UARTManagerDidDiscoverPeripheralNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        CBPeripheral *peripheral = note.userInfo[UARTPeripheralKey];
        if (![self.peripherals containsObject:peripheral]) {
            [self.peripherals addObject:peripheral];
            [self.tableView reloadData];
        }
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:UARTManagerDidUpdateStateNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        if ([UARTManager manager].cm.state != CBCentralManagerStatePoweredOn) {
            [self.peripherals removeAllObjects];
            [self.tableView reloadData];
        }
    }];
}

#pragma mark - Accessors

#pragma mark - Actions

- (IBAction)onRefresh {
    [self.peripherals removeAllObjects];
    [self.tableView reloadData];
    [[UARTManager manager].cm scanForPeripheralsWithServices:@[[Settings settings].serviceUUID] options:nil];
}

#pragma mark - Table view

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.peripherals.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PeripheralCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Peripheral Cell" forIndexPath:indexPath];
    cell.peripheral = self.peripherals[indexPath.row];
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(PeripheralCell *)cell {
    if ([@"Peripheral" isEqualToString:segue.identifier]) {
        PeripheralVC *vc = segue.destinationViewController;
        vc.peripheral = cell.peripheral;
    }
}

@end
