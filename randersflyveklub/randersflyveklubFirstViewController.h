//
//  randersflyveklubFirstViewController.h
//  randersflyveklub
//
//  Created by Mercantec on 9/24/13.
//  Copyright (c) 2013 and3k5. All rights reserved.
//

// Map View

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>

@interface randersflyveklubFirstViewController : UIViewController<GMSMapViewDelegate> {
    NSMutableData *_responseData;
}
@property (weak, nonatomic) IBOutlet UIBarButtonItem *getAirfieldsBtn;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *settingsBtn;
- (IBAction)clearMapBtnClick:(id)sender;


@end
