//
//  PeripheralVC.m
//  UART
//
//  Created by Dan Kalinin on 13.09.15.
//  Copyright (c) 2015 Dan Kalinin. All rights reserved.
//

#import "PeripheralVC.h"
#import "ResultsVC.h"
#import "CommandCell.h"
#import "UARTManager.h"
#import "CBPeripheral+UART.h"
#import "UARTPacket.h"
#import "Settings.h"
#import "Command.h"
#import "MBProgressHUD.h"
NSString *const CommandsKey = @"CommandsKey";



@interface PeripheralVC () <UIActionSheetDelegate>

@property (strong, nonatomic) IBOutlet UIBarButtonItem *sendItem;
@property (nonatomic) UIAlertController *alertController;
@property (nonatomic) UIAlertController *actionController;
@property NSMutableArray *commands;
@property (readonly) NSArray *selectedCommands;
@property (nonatomic) MBProgressHUD *HUD;
@property BOOL processing;

@end



@implementation PeripheralVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // BT
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onError) name:UARTManagerDidDisconnectPeripheralNotification object:nil];
    
    // UI
    self.navigationItem.title = self.peripheral.name;
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.editButtonItem.target = self;
    self.editButtonItem.action = @selector(onEdit:);
    self.commands = [NSMutableArray array];
    for (NSDictionary *dictionary in [[NSUserDefaults standardUserDefaults] arrayForKey:CommandsKey]) {
        [self.commands addObject:[Command fromDictionary:dictionary]];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UARTManager manager].cm cancelPeripheralConnection:self.peripheral];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    ResultsVC *vc = segue.destinationViewController;
    vc.commands = self.selectedCommands;
}

#pragma mark - Accessors

- (UIAlertController *)alertController {
    if (!_alertController) {
        _alertController = [UIAlertController alertControllerWithTitle:@"Add command" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [_alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = @"Name";
            textField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
        }];
        [_alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = @"Comma-separated bytes";
            textField.keyboardType = UIKeyboardTypeDecimalPad;
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        }];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            UITextField *nameTextField = _alertController.textFields[0];
            UITextField *valueTextField = _alertController.textFields[1];
            
            BOOL isError = NO;
            
            if (!nameTextField.text.length) {
                isError = YES;
                self.invalidHUD.detailsLabelText = @"No name specified";
            }
            
            if (!valueTextField.text.length) {
                isError = YES;
                self.invalidHUD.detailsLabelText = @"No packet specified";
            } else {
                NSString *pattern = [NSString stringWithFormat:@"^\\d{1,3}(?:,\\d{1,3}){0,%ld}$", (long)[Settings settings].maxPacketSize - 1];
                NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:nil];
                if ([regex numberOfMatchesInString:valueTextField.text options:0 range:NSMakeRange(0, valueTextField.text.length)]) {
                    NSArray *exceedingBytes = [[valueTextField.text componentsSeparatedByCharactersInSet:[NSCharacterSet punctuationCharacterSet]] valueForKey:@"intValue"];
                    exceedingBytes = [exceedingBytes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self < 0 OR self > 255"]];
                    if (exceedingBytes.count) {
                        isError = YES;
                        self.invalidHUD.detailsLabelText = @"Packet byte overflow";
                    }
                } else {
                    isError = YES;
                    self.invalidHUD.detailsLabelText = @"Invalid packet format";
                }
            }
            
            if (isError) {
                [self.invalidHUD show:YES];
                [self.invalidHUD hide:YES afterDelay:2.0];
            } else {
                Command *command = [Command new];
                command.name = nameTextField.text;
                command.value = valueTextField.text;
                [self.commands addObject:command];
                [self saveCommands];
                [self.tableView reloadData];
                nameTextField.text = nil;
                valueTextField.text = nil;
            }
        }];
        [_alertController addAction:cancelAction];
        [_alertController addAction:okAction];
    }
    return _alertController;
}

- (UIAlertController *)actionController {
    if (!_actionController) {
        _actionController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *editAction = [UIAlertAction actionWithTitle:@"Edit" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self setEditing:YES animated:YES];
        }];
        UIAlertAction *addAction = [UIAlertAction actionWithTitle:@"Add" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            self.alertController.textFields[0].text = nil;
            self.alertController.textFields[1].text = nil;
            [self presentViewController:self.alertController animated:YES completion:nil];
        }];
        UIAlertAction *removeAction = [UIAlertAction actionWithTitle:@"Remove all" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            [self.commands removeAllObjects];
            [self saveCommands];
            [self updateUI];
            [self.tableView reloadData];
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        [_actionController addAction:editAction];
        [_actionController addAction:addAction];
        [_actionController addAction:removeAction];
        [_actionController addAction:cancelAction];
    }
    return _actionController;
}

- (MBProgressHUD *)HUD {
    if (!_HUD) {
        _HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
        [self.navigationController.view addSubview:_HUD];
    }
    return _HUD;
}

- (MBProgressHUD *)processHUD {
    self.HUD.mode = MBProgressHUDModeIndeterminate;
    self.HUD.labelText = nil;
    self.HUD.detailsLabelText = nil;
    return self.HUD;
}

- (MBProgressHUD *)errorHUD {
    self.HUD.mode = MBProgressHUDModeText;
    self.HUD.labelText = @"Connection error";
    self.HUD.detailsLabelText = self.peripheral.error.localizedDescription;
    return self.HUD;
}

- (MBProgressHUD *)invalidHUD {
    self.HUD.mode = MBProgressHUDModeText;
    self.HUD.labelText = @"Invalid command";
    return self.HUD;
}

- (NSArray *)selectedCommands {
    return [self.commands filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"selected = YES"]];
}

#pragma mark - Actions

- (void)onEdit:(UIBarButtonItem *)sender {
    if (self.editing) {
        [self setEditing:NO animated:YES];
    } else {
        [self presentViewController:self.actionController animated:YES completion:nil];
    }
}

- (IBAction)onSend:(UIBarButtonItem *)sender {
    self.processing = YES;
    [self.processHUD show:YES];
    self.peripheral.serviceUUID = [Settings settings].serviceUUID;
    self.peripheral.TXCharacteristicUUID = [Settings settings].TXCharacteristicUUID;
    self.peripheral.RXCharacteristicUUID = [Settings settings].RXCharacteristicUUID;
    [self.peripheral connectWithSuccess:^(CBPeripheral *peripheral) {
        for (Command *command in self.selectedCommands) {
            [command sendToPeripheral:self.peripheral success:nil failure:nil completion:^(UARTCommand *command) {
                if ([command isEqual:self.selectedCommands.lastObject]) {
                    self.processing = NO;
                    [self.processHUD hide:YES];
                    [self performSegueWithIdentifier:@"Results Segue" sender:self];
                }
            } timeout:[Settings settings].commandTimeout];
        }
    } failure:^(CBPeripheral *peripheral) {
        [self onError];
    } completion:nil timeout:[Settings settings].connectionTimeout];
}

- (void)onError {
    if (self.processing) {
        [self.errorHUD show:YES];
        [self.errorHUD hide:YES afterDelay:1.0];
        self.processing = NO;
    }
}

#pragma mark - Helpers

- (void)saveCommands {
    [[NSUserDefaults standardUserDefaults] setObject:[self.commands valueForKey:@"toDictionary"] forKey:CommandsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)updateUI {
    self.navigationItem.rightBarButtonItem = self.selectedCommands.count ? self.sendItem : self.editButtonItem;
}

#pragma mark - Table view

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.commands.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CommandCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Command Cell" forIndexPath:indexPath];
    cell.command = self.commands[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CommandCell *cell = (CommandCell *)[tableView cellForRowAtIndexPath:indexPath];
    cell.command.selected = !cell.command.selected;
    cell.accessoryType = cell.command.selected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    [self updateUI];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
    return proposedDestinationIndexPath;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.commands removeObjectAtIndex:indexPath.row];
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self saveCommands];
    [self updateUI];
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    Command *sourceCommand = self.commands[sourceIndexPath.row];
    [self.commands removeObjectAtIndex:sourceIndexPath.row];
    [self.commands insertObject:sourceCommand atIndex:destinationIndexPath.row];
    [self saveCommands];
}

@end
