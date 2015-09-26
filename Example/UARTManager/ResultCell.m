//
//  CommandResultCell.m
//  UART
//
//  Created by Dan Kalinin on 20.09.15.
//  Copyright © 2015 Dan Kalinin. All rights reserved.
//

#import "ResultCell.h"
#import "MBProgressHUD.h"



@interface ResultCell ()

@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblTX;
@property (weak, nonatomic) IBOutlet UILabel *lblRX;
@property (weak, nonatomic) IBOutlet UIButton *btnTime;
@property (nonatomic) MBProgressHUD *HUD;

@end



@implementation ResultCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.btnTime.layer.cornerRadius = 5.0;
}

#pragma mark - Accessors

- (MBProgressHUD *)HUD {
    if (!_HUD) {
        _HUD = [[MBProgressHUD alloc] initWithWindow:[UIApplication sharedApplication].keyWindow];
        [[UIApplication sharedApplication].keyWindow addSubview:_HUD];
    }
    return _HUD;
}

- (void)setCommand:(Command *)command {
    _command = command;
    self.lblName.text = command.name;
    self.lblTX.text = [command.TXPacket.array componentsJoinedByString:@","];
    self.lblRX.text = [command.RXPacket.array componentsJoinedByString:@","];
    NSString *milliseconds = [NSString stringWithFormat:@"%i ms", (int)(self.command.time * 1e-6)];
    [self.btnTime setTitle:milliseconds forState:UIControlStateNormal];
    if (self.command.error) {
        self.btnTime.backgroundColor = [UIColor colorWithRed:251.0/255 green:32.0/255 blue:37.0/255 alpha:1.0];
    } else {
        self.btnTime.backgroundColor = [UIColor colorWithRed:67.0/255 green:213.0/255 blue:81.0/255 alpha:1.0];
    }
}

#pragma mark - Actions

- (IBAction)onTimeButton {
    if (self.command.error) {
        self.HUD.mode = MBProgressHUDModeText;
        self.HUD.labelText = self.command.error.localizedDescription;
        [self.HUD show:YES];
        [self.HUD hide:YES afterDelay:1.0];
    }
}

@end
