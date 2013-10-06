//
//  randersflyveklubSecondViewController.h
//  randersflyveklub
//
//  Created by Mercantec on 9/25/13.
//  Copyright (c) 2013 and3k5. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface randersflyveklubSecondViewController : UITableViewController {
        NSMutableData *_responseData;
}
@property (strong, nonatomic) NSArray *content;
@property (strong, nonatomic) IBOutlet UITableView *tableViewObj;

@end
