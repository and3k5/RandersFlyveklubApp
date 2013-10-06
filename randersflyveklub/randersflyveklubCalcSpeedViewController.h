//
//  randersflyveklubCalcSpeedViewController.h
//  randersflyveklub
//
//  Created by Mercantec on 10/2/13.
//  Copyright (c) 2013 and3k5. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface randersflyveklubCalcSpeedViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *inputIAS;
@property (weak, nonatomic) IBOutlet UITextField *inputHeight;
@property (weak, nonatomic) IBOutlet UITextField *outputTAS;
@property (weak, nonatomic) IBOutlet UITextField *inputWindDir;
@property (weak, nonatomic) IBOutlet UITextField *inputWindSpeed;
@property (weak, nonatomic) IBOutlet UITextField *inputHeading;
@property (weak, nonatomic) IBOutlet UITextField *outputGroundspeed;
- (IBAction)calcTASbtnClick:(id)sender;
- (IBAction)calcGroundspdBtnClick:(id)sender;
@end
