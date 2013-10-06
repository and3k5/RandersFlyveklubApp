//
//  randersflyveklubWeatherViewController.h
//  randersflyveklub
//
//  Created by Mercantec on 9/30/13.
//  Copyright (c) 2013 and3k5. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

@interface randersflyveklubWeatherViewController : UIViewController {
    NSMutableData *_responseData;
}

// Value labels
@property (weak, nonatomic) IBOutlet UILabel *wndSpeed;
@property (weak, nonatomic) IBOutlet UILabel *wndDir;
@property (weak, nonatomic) IBOutlet UILabel *wndGust;
@property (weak, nonatomic) IBOutlet UILabel *atmosPressure;
@property (weak, nonatomic) IBOutlet UILabel *temp;
@property (weak, nonatomic) IBOutlet UILabel *forecastDesc;
@property (weak, nonatomic) IBOutlet UILabel *rightWind;
@property (weak, nonatomic) IBOutlet UILabel *leftWind;
@property (weak, nonatomic) IBOutlet UILabel *rearWind;
@property (weak, nonatomic) IBOutlet UILabel *frontWind;

// Runway segmented controller
- (IBAction)segmentRunwayValueChanged:(id)sender;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentRunway;

// Manual update information button
@property (weak, nonatomic) IBOutlet UIBarButtonItem *updateInfoBtn;

// Timer
@property (weak, nonatomic) IBOutlet UIProgressView *timerProgressView;
@property (weak, nonatomic) IBOutlet UISwitch *updateSwitch;
- (IBAction)updateSwitchValueChanged:(id)sender;


@end
