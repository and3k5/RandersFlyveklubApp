//
//  randersflyveklubMapSettingsViewController.h
//  randersflyveklub
//
//  Created by Mercantec on 9/27/13.
//  Copyright (c) 2013 and3k5. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface randersflyveklubMapSettingsViewController : UIViewController
@property (weak, nonatomic) IBOutlet UISwitch *updateSwitch;
- (IBAction)updateSwitchValueChanged:(id)sender;

@end
