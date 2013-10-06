//
//  randersflyveklubCalcSpeedViewController.m
//  randersflyveklub
//
//  Created by Mercantec on 10/2/13.
//  Copyright (c) 2013 and3k5. All rights reserved.
//

#import "randersflyveklubCalcSpeedViewController.h"
#import <math.h>

#define PI M_PI
#define g 9.81
#define R 287
#define lambda 0.00198
#define T0 288
#define TropT 216.5
#define ftm 3.28126
#define P0 1013.25
#define TropP 226

@interface randersflyveklubCalcSpeedViewController () {
    
}

@end

#pragma marks - Maths

double deg2rad(int deg) {
    return deg * M_PI / 180;
}

int rad2deg(double rad) {
    return rad / M_PI * 180;
}

double Pressure(double Height) {
    if (Height<36090) {
        return P0 * pow((1 - (lambda * Height / T0)) , (g / (R * lambda * ftm)));
    }else{
        return TropP * exp(-g * ((Height - 36090) / ftm) / (R * TropT));
    }
}

double Temperature(double Height) {
    if (Height<36090) {
        return 288 - ((Height / 1000) * 1.98);
    }else{
        return 216.5;
    }
}

double RelDensity(double Height) {
    return (3.51823 / (Pressure(Height) / Temperature(Height)));
}

double TAS(double Height,double IAS) {
    return sqrt(RelDensity(Height)) * IAS;
}

double MACH1(double Height) {
    return 38.9 * sqrt(Temperature(Height));
}

double GroundSpeed(double TrueAS, double Hdg, double WDir,double WSpd) {
    double WindAngle = deg2rad(Hdg-WDir);
    return TrueAS - WSpd * cos(WindAngle);
}

double Heading(double TrueAS, double Trk, double WDir, double WSpd) {
    double WindAngle = deg2rad(Trk-WDir);
    double WindComp = sin(WindAngle)*WSpd/TrueAS;
    double Drift = rad2deg(asin(WindComp));
    return fmod((360 + Trk - Drift),360);
}

// Input to calculate GroundSpeed
// - TAS        (calculated from inputs)
// - Winddir    (user input)
// - heading    (user input)
// - windspeed  (user input)

// Input to calculate True Airspeed
// - IAS        (user input)
// - Height     (user input)


@implementation randersflyveklubCalcSpeedViewController {
    double tas; // true airspeed
}

// Text fields
@synthesize inputHeading;
@synthesize inputHeight;
@synthesize inputIAS;
@synthesize inputWindDir;
@synthesize inputWindSpeed;
@synthesize outputGroundspeed;
@synthesize outputTAS;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // For every touch (on anything), resignFirstResponder (hide keyboard
    // on every single textfield)
    [inputHeading resignFirstResponder];
    [inputHeight resignFirstResponder];
    [inputIAS resignFirstResponder];
    [inputWindDir resignFirstResponder];
    [inputWindSpeed resignFirstResponder];
    [outputTAS resignFirstResponder];
}

- (IBAction)calcTASbtnClick:(id)sender {
    // "Calculate True Airspeed" button pressed - calculate TAS
    // Surrounded by try catch, just for safety
    @try {
        tas = TAS([inputHeight.text doubleValue],[inputIAS.text doubleValue]);
        outputTAS.text = [NSString stringWithFormat:@"%lf",tas,nil];
    }
    @catch (NSException *e) {
        NSLog(@"Error");
    }
}

- (IBAction)calcGroundspdBtnClick:(id)sender {
    // "Calculate Groundspeed" button pressed - calculate GroundSpeed
    // Surrounded by try catch, just for safety
    @try {
        double groundSpeed = GroundSpeed(tas, [inputHeading.text doubleValue], [inputWindDir.text doubleValue], [inputWindSpeed.text doubleValue]);
        outputGroundspeed.text = [NSString stringWithFormat:@"%lf",groundSpeed,nil];
    }
    @catch (NSException *e) {
        NSLog(@"Error");
    }
}
@end
