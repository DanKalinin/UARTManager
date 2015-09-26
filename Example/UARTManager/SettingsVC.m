//
//  SettingsVC.m
//  UART
//
//  Created by Dan Kalinin on 21.09.15.
//  Copyright © 2015 Dan Kalinin. All rights reserved.
//

#import "SettingsVC.h"
#import "Settings.h"
#import "MBProgressHUD.h"



@interface SettingsVC ()

@property (weak, nonatomic) IBOutlet UITextField *tfService;
@property (weak, nonatomic) IBOutlet UITextField *tfTXCharacteristic;
@property (weak, nonatomic) IBOutlet UITextField *tfRXCharacteristic;
@property (weak, nonatomic) IBOutlet UITextField *tfConnectionTimeout;
@property (weak, nonatomic) IBOutlet UITextField *tfCommandTimeout;
@property (weak, nonatomic) IBOutlet UITextField *tfMaxPacketSize;
@property (nonatomic) MBProgressHUD *HUD;
@property (nonatomic) NSNumberFormatter *cnTimeoutFmt;
@property (nonatomic) NSNumberFormatter *cmdTimeoutFmt;
@property (nonatomic) NSNumberFormatter *maxPacketSizeFmt;

@end



@implementation SettingsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self updateFields];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.editButtonItem.target = self;
    self.editButtonItem.action = @selector(onEdit);
    self.fieldsEnabled = NO;
}

#pragma mark - Accessors

- (MBProgressHUD *)HUD {
    if (!_HUD) {
        _HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        _HUD.mode = MBProgressHUDModeText;
        [self.navigationController.view addSubview:_HUD];
    }
    return _HUD;
}

- (NSNumberFormatter *)cnTimeoutFmt {
    if (!_cnTimeoutFmt) {
        _cnTimeoutFmt = [NSNumberFormatter new];
        _cnTimeoutFmt.numberStyle = NSNumberFormatterDecimalStyle;
        _cnTimeoutFmt.minimum = @(1.0);
        _cnTimeoutFmt.maximum = @(10.0);
    }
    return _cnTimeoutFmt;
}

- (NSNumberFormatter *)cmdTimeoutFmt {
    if (!_cmdTimeoutFmt) {
        _cmdTimeoutFmt = [NSNumberFormatter new];
        _cmdTimeoutFmt.numberStyle = NSNumberFormatterDecimalStyle;
        _cmdTimeoutFmt.minimum = @(0.1);
        _cmdTimeoutFmt.maximum = @(10.0);
    }
    return _cmdTimeoutFmt;
}

- (NSNumberFormatter *)maxPacketSizeFmt {
    if (!_maxPacketSizeFmt) {
        _maxPacketSizeFmt = [NSNumberFormatter new];
        _maxPacketSizeFmt.numberStyle = NSNumberFormatterDecimalStyle;
        _maxPacketSizeFmt.minimum = @(1);
        _maxPacketSizeFmt.maximum = @(20);
    }
    return _maxPacketSizeFmt;
}

#pragma mark - Table view

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

#pragma mark - Actions

- (IBAction)onTap {
    [self.tableView endEditing:YES];
}

- (void)onEdit {
    if (self.editing) {
        [self setEditing:NO animated:YES];
        
        BOOL hasErrors = NO;
        
        NSUUID *UUID = [[NSUUID alloc] initWithUUIDString:self.tfService.text];
        if (UUID) {
            [Settings settings].serviceUUID = [CBUUID UUIDWithNSUUID:UUID];
        } else {
            self.HUD.labelText = @"Invalid service UUID";
            self.HUD.detailsLabelText = nil;
            hasErrors = YES;
        }
        
        UUID = [[NSUUID alloc] initWithUUIDString:self.tfTXCharacteristic.text];
        if (UUID) {
            [Settings settings].TXCharacteristicUUID = [CBUUID UUIDWithNSUUID:UUID];
        } else {
            self.HUD.labelText = @"Invalid TX characteristic UUID";
            self.HUD.detailsLabelText = nil;
            hasErrors = YES;
        }
        
        UUID = [[NSUUID alloc] initWithUUIDString:self.tfRXCharacteristic.text];
        if (UUID) {
            [Settings settings].RXCharacteristicUUID = [CBUUID UUIDWithNSUUID:UUID];
        } else {
            self.HUD.labelText = @"Invalid RX characteristic UUID";
            self.HUD.detailsLabelText = nil;
            hasErrors = YES;
        }
        
        NSNumber *number = [self.cnTimeoutFmt numberFromString:self.tfConnectionTimeout.text];
        if (number) {
            [Settings settings].connectionTimeout = number.doubleValue;
        } else {
            self.HUD.labelText = @"Invalid connection timeout";
            self.HUD.detailsLabelText = @"1.0 - 10.0 s";
            hasErrors = YES;
        }
        
        number = [self.cmdTimeoutFmt numberFromString:self.tfCommandTimeout.text];
        if (number) {
            [Settings settings].commandTimeout = number.doubleValue;
        } else {
            self.HUD.labelText = @"Invalid command timeout";
            self.HUD.detailsLabelText = @"0.1 - 10.0 s";
            hasErrors = YES;
        }
        
        number = [self.maxPacketSizeFmt numberFromString:self.tfMaxPacketSize.text];
        if (number) {
            [Settings settings].maxPacketSize = number.integerValue;
        } else {
            self.HUD.labelText = @"Invalid packet size";
            self.HUD.detailsLabelText = @"1 - 20 bytes";
            hasErrors = YES;
        }
        
        if (!hasErrors) {
            self.HUD.labelText = @"Settings saved";
            self.HUD.detailsLabelText = nil;
        }
        
        [self.HUD show:YES];
        [self.HUD hide:YES afterDelay:1.5];
        
        self.fieldsEnabled = NO;
        [self updateFields];
    } else {
        [self setEditing:YES animated:YES];
        self.fieldsEnabled = YES;
        [self.tfService becomeFirstResponder];
    }
}

#pragma mark - Helpers

- (void)updateFields {
    self.tfService.text = [Settings settings].serviceUUID.UUIDString;
    self.tfTXCharacteristic.text = [Settings settings].TXCharacteristicUUID.UUIDString;
    self.tfRXCharacteristic.text = [Settings settings].RXCharacteristicUUID.UUIDString;
    self.tfConnectionTimeout.text = [self.cnTimeoutFmt stringFromNumber:@([Settings settings].connectionTimeout)];
    self.tfCommandTimeout.text = [self.cmdTimeoutFmt stringFromNumber:@([Settings settings].commandTimeout)];
    self.tfMaxPacketSize.text = [NSString stringWithFormat:@"%ld", (long)[Settings settings].maxPacketSize];
}

- (void)setFieldsEnabled:(BOOL)enabled {
    self.tfService.enabled = enabled;
    self.tfTXCharacteristic.enabled = enabled;
    self.tfRXCharacteristic.enabled = enabled;
    self.tfConnectionTimeout.enabled = enabled;
    self.tfCommandTimeout.enabled = enabled;
    self.tfMaxPacketSize.enabled = enabled;
}

@end
