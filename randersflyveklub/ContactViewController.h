//
//  ContactViewController.h
//  randersflyveklub
//
//  Created by Mercantec on 9/25/13.
//  Copyright (c) 2013 and3k5. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *contactnametxt;
@property (weak, nonatomic) IBOutlet UILabel *contacttitletxt;
@property (weak, nonatomic) IBOutlet UILabel *contactemailtxt;
- (IBAction)sendMailBtn:(id)sender;
- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
              contact:(NSMutableDictionary *)tmpContact;
@end
