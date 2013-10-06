//
//  SiteViewController.h
//  randersflyveklub
//
//  Created by Mercantec on 9/30/13.
//  Copyright (c) 2013 and3k5. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SiteViewController : UIViewController
@property (weak,nonatomic) NSString *urllocation;
- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
              location:(NSMutableDictionary *)url;
@end
