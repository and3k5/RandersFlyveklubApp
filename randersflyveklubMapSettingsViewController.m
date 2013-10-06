//
//  randersflyveklubMapSettingsViewController.m
//  randersflyveklub
//
//  Created by Mercantec on 9/27/13.
//  Copyright (c) 2013 and3k5. All rights reserved.
//

#import "randersflyveklubMapSettingsViewController.h"

@interface randersflyveklubMapSettingsViewController ()

@end

@implementation randersflyveklubMapSettingsViewController

@synthesize updateSwitch;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    // Update the switch every time the view is appearing
    updateSwitch.on = [[[NSUserDefaults standardUserDefaults] stringForKey:@"dragAutoupdate"]isEqualToString:@"1"];
}

- (IBAction)updateSwitchValueChanged:(id)sender {
    // When the switch is switchen on/off, update Settings
    [[NSUserDefaults standardUserDefaults] setBool:updateSwitch.on forKey:@"dragAutoupdate"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end
