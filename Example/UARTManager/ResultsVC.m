//
//  ResultsVC.m
//  UART
//
//  Created by Dan Kalinin on 20.09.15.
//  Copyright © 2015 Dan Kalinin. All rights reserved.
//

#import "ResultsVC.h"
#import "ResultCell.h"
#import "MBProgressHUD.h"



@interface ResultsVC ()

@end



@implementation ResultsVC

#pragma mark - Table view

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.commands.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ResultCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Result Cell" forIndexPath:indexPath];
    cell.command = self.commands[indexPath.row];
    return cell;
}

@end
