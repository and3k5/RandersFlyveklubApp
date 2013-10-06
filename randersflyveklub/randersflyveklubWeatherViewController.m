//
//  randersflyveklubWeatherViewController.m
//  randersflyveklub
//
//  Created by Mercantec on 9/30/13.
//  Copyright (c) 2013 and3k5. All rights reserved.
//

#import "randersflyveklubWeatherViewController.h"
#import <math.h>
#import <QuartzCore/QuartzCore.h>

@interface randersflyveklubWeatherViewController ()

@end

#pragma mark - Variables

@implementation randersflyveklubWeatherViewController {
    double runway7crosswind;
    double runway7headwind;
    double runway25crosswind;
    double runway25headwind;
    bool isRunway7;
    bool useInternet;
    NSTimer *updateTimer;
    NSDate *lastUpdate;
    NSDateFormatter *df;
    int updateInterval;
}

@synthesize wndSpeed;
@synthesize wndDir;
@synthesize wndGust;
@synthesize atmosPressure;
@synthesize temp;
@synthesize forecastDesc;
@synthesize frontWind;
@synthesize rearWind;
@synthesize leftWind;
@synthesize rightWind;
@synthesize segmentRunway;
@synthesize timerProgressView;
@synthesize updateSwitch;
@synthesize updateInfoBtn;

#pragma mark - UIView actions
- (void) loadView {
    [super loadView];
    useInternet=[[[NSUserDefaults standardUserDefaults] stringForKey:@"useinternet"]isEqualToString:@"1"];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Boolean to indicate which runway details we're looking at
    isRunway7 = YES;
    
    // Date object for the latest update
    df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    lastUpdate = [df dateFromString:@"1970-01-01 00:00:01"]; // just update immediately
    
    // Initialize the update switch and the interval
    // Interval is set in settings
    updateSwitch.on = [[[NSUserDefaults standardUserDefaults] stringForKey:@"weatherAutoupdate"]isEqualToString:@"1"];
    
    int updateIntervalIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"updateInterval"];
    
    switch (updateIntervalIndex) {
        case 0:
            updateInterval = 15;
            break;
        case 1:
            updateInterval = 30;
            break;
        case 2:
            updateInterval = 60;
            break;
        case 3:
            updateInterval = 120;
            break;
        case 4:
            updateInterval = 300;
            break;
    }
    
    // If the updateTimer isn't on, get the information at start
    if (!updateSwitch.on) {
        [self requestForInformation];
    }
    
    // Button to update information if the timer isn't activated
    [updateInfoBtn setTarget:self];
    [updateInfoBtn setAction:@selector(updateInfoBtnClicked:)];
}

- (void)viewDidAppear:(BOOL)animated {
    // Hides the progress indicator and enables the
    // update information button (for manual request)
    // The progress indicator hidden property and the
    // update info button enabled property is set
    // to NO in [self startTimer] (if the updateSwitch is on)
    if (!useInternet) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You can't use Weather Cast when the Use internet option is disabled. Go to settings and enable it to use Weather Cast" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
    }
    timerProgressView.hidden = YES;
    updateInfoBtn.enabled = YES;
    if (updateSwitch.on) {
        if (useInternet) {
            [self startTimer];
        }else{
            [updateSwitch setOn:NO animated:NO];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    // When the user navigates away from this view,
    // kill the timer if it is running
    if (updateTimer.isValid) {
        [updateTimer invalidate];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    // If running low on memory, turn the updateSwitch off
    [updateSwitch setOn:NO animated:NO];
}

#pragma mark - Timer functions

- (void) updateTimerAction {
    // When the update timer is fired, check if the last update is older
    // than the update interval.
    // If it is, then request for an update
    double now = [[NSDate date] timeIntervalSinceDate:lastUpdate];
    if (now>updateInterval) {
        lastUpdate = [NSDate date];
        [self requestForInformation];
    }else{
        [timerProgressView setProgress:(now/updateInterval)];
    }
}

- (void) startTimer {
    // Start the timer
    // Makes progress indicator visible and starts the NSTimer
    timerProgressView.hidden = NO;
    updateInfoBtn.enabled = NO;
    updateTimer = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(updateTimerAction) userInfo:nil repeats:YES];
}

- (IBAction)updateSwitchValueChanged:(id)sender {
    // When the update switch is clicked:
    // - Sync the settings
    // - If the switch is on, start the timer but
    //   if not then kill it
    [[NSUserDefaults standardUserDefaults] setBool:updateSwitch.on forKey:@"weatherAutoupdate"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    if (updateSwitch.on) {
        if (useInternet) {
            [self startTimer];
        }else{
            [updateSwitch setOn:NO animated:YES];
        }
    }else{
        if (updateTimer.isValid) {
            [updateTimer invalidate];
        }
        timerProgressView.hidden = YES;
        updateInfoBtn.enabled = YES;
    }
}

- (void) updateInfoBtnClicked:(id)sender {
    if (!updateSwitch.on) {
        [self requestForInformation];
    }
}

#pragma mark - Handle recieved data
// My selfwritten math functions:

// Converts degrees to radians 
- (double)deg2rad:(int)deg {
    return deg * M_PI / 180;
}

// Converts radians to degrees
- (int)rad2deg:(double)rad {
    return rad / M_PI * 180;
}

// Handle recieved data from the NSURLConnection
- (void)handleData:(NSArray *)data {
    // Header
    // Must be 12345
    
    // If this isn't 12345 then the data might be unusable..
    if (![[data objectAtIndex:0]isEqual:@"12345"]) {
        NSLog(@"Data was not right.. Header not recognized!");
        return ;
    }
    
    // Wind avg speed
    // fx: 2.8
    // Type: knots
    wndSpeed.text = [data objectAtIndex:1];
    
    // wind direction
    // fx: 270
    // Type: degrees (0-359)
    wndDir.text = [data objectAtIndex:3];
    
    // Wind gust
    // fx: 2.8
    // Type: knots
    wndGust.text = [data objectAtIndex:2];
    
    // atmospheric pressure
    // fx: 1021.0
    // Type: hPa 
    atmosPressure.text = [data objectAtIndex:6];
    
    // temperature
    // fx: 16
    // Type: celsius
    temp.text = [data objectAtIndex:4];
    
    // Forecast description
    // fx: 4 (Cloudy Night)
    // from 0 to 34
    NSArray *forecasts = [[NSArray alloc]initWithObjects:
        @"Sunny",
        @"Clear Night",
        @"Cloudy",
        @"Cloudy",
        @"Cloudy Night",
        @"Dry Clear",
        @"Fog",
        @"Hazy",
        @"Heavy Rain",
        @"Mainly Fine",
        @"Misty",
        @"Night Fog",
        @"Night Heavy Rain",
        @"Night Overcast",
        @"Night Rain",
        @"Night Showers",
        @"Night Snow",
        @"Night Thunder",
        @"Overcast",
        @"Partly Cloudy",
        @"Rain",
        @"Hard Rain",
        @"Showers",
        @"Sleet",
        @"Sleet Showers",
        @"Snowing",
        @"Snow Melt",
        @"Snow Showers",
        @"Sunny",
        @"Thunder Showers",
        @"Thunder Showers",
        @"Thunderstorms",
        @"Tornado Warning",
        @"Windy",
        @"Stopped Raining",nil];
    forecastDesc.text = [forecasts objectAtIndex:[[data objectAtIndex:15] integerValue]];
   
    // Wind direction
    // Runway 7's direction is 70 degrees (from N)
    // Runway 25's direction is 250 degrees (from N)
    // (exactly opposite directions)
    
    // Getting wind direction angle, runway 7 and 25's direction angle
    double winddirection = [self deg2rad:[[data objectAtIndex:3] integerValue]];
    double runway7direction = [self deg2rad:70];
    double runway25direction = [self deg2rad:250];
    
    // Wind avg speed
    double windAvgSpeed = [[data objectAtIndex:1] doubleValue];
    
    // Calculating the cross and headwind (measured in knots/hour)
    runway7crosswind = sin(winddirection-runway7direction)*windAvgSpeed;
    runway7headwind = cos(winddirection-runway7direction)*windAvgSpeed;
    runway25crosswind = sin(winddirection-runway25direction)*windAvgSpeed;
    runway25headwind = cos(winddirection-runway25direction)*windAvgSpeed;
    
    // Call the function which deals with runway details
    [self runwayUpdate];
}

- (IBAction)segmentRunwayValueChanged:(id)sender {
    // If the segment controller (runway selection) has changed value
    if (segmentRunway.selectedSegmentIndex==0) {
        isRunway7 = YES;
    }else{
        isRunway7 = NO;
    }
    // Call the function which deals with runway details
    [self runwayUpdate];
}

- (void) runwayUpdate {
    // Show details about runway cross/headwind depending on which one is selected
    NSString *format = @"%2.2lf";
    if (isRunway7) {
        frontWind.text = [NSString stringWithFormat:format,runway7headwind];
        rearWind.text = [NSString stringWithFormat:format,runway7headwind*-1];
        rightWind.text = [NSString stringWithFormat:format,runway7crosswind];
        leftWind.text = [NSString stringWithFormat:format,runway7crosswind*-1];
    }else{
        frontWind.text = [NSString stringWithFormat:format,runway25headwind];
        rearWind.text = [NSString stringWithFormat:format,runway25headwind*-1];
        rightWind.text = [NSString stringWithFormat:format,runway25crosswind];
        leftWind.text = [NSString stringWithFormat:format,runway25crosswind*-1];
    }
}

#pragma mark - Network request

- (void)requestForInformation {
    if (!useInternet) return ;
    // Start a request to collect information
    NSMutableURLRequest *urlrequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://randersflyveklub.dk/vejr/clientraw.txt"]];
    
    // HTTP Get method
    urlrequest.HTTPMethod = @"GET";
    
    // We dont want to use cache storage
    urlrequest.cachePolicy = NSURLCacheStorageNotAllowed;
    
    // Start the NSURLConnection
    // I added a "(void)" to avoid the warning message in Xcode!
    (void) [[NSURLConnection alloc]initWithRequest:urlrequest delegate:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // Did get a response from the server
    // Prepare the NSMutableData to receive the goodies
    _responseData = [[NSMutableData alloc]init];
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Receiving data
    // Is called for every part received
    [_responseData appendData:data];
    
}
- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    // No cache, please
    return nil;
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // When the connection is done receiving data
    
    // Split up the data by " " (space character)
    NSString *strdata = [[NSString alloc]initWithData:_responseData encoding:NSUTF8StringEncoding];
    NSArray *data = [strdata componentsSeparatedByString:@" "];
    
    // Handle the received data
    [self handleData:data];
    
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // Error occurred at connection request
    NSString *err=[NSString stringWithFormat:@"Error during connection request:\n%@",error.localizedDescription,nil];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                    message:err delegate:self cancelButtonTitle:@"Allright" otherButtonTitles:nil];
    // The connection did not succeed,
    // so disable the updateSwitch and
    // show a alertview to notify the user
    [updateSwitch setOn:NO animated:YES];
    if (updateTimer.isValid) {
        [updateTimer invalidate];
    }
    [alert show];
}

@end
