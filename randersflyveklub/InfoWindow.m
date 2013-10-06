//
//  InfoWindow.m
//  randersflyveklub
//
//  Created by Mercantec on 10/2/13.
//  Copyright (c) 2013 and3k5. All rights reserved.
//

#import "InfoWindow.h"

@implementation InfoWindow
@synthesize name;
@synthesize country;
@synthesize winddirection;
@synthesize windspeed;
@synthesize temperature;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

@end
