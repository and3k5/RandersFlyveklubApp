//
//  InfoWindow.h
//  randersflyveklub
//
//  Created by Mercantec on 10/2/13.
//  Copyright (c) 2013 and3k5. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InfoWindow : UIView
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *country;
@property (weak, nonatomic) IBOutlet UILabel *winddirection;
@property (weak, nonatomic) IBOutlet UILabel *windspeed;
@property (weak, nonatomic) IBOutlet UILabel *temperature;
@end
