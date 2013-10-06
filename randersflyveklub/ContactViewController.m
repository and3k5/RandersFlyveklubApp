//
//  ContactViewController.m
//  randersflyveklub
//
//  Created by Mercantec on 9/25/13.
//  Copyright (c) 2013 and3k5. All rights reserved.
//

#import "ContactViewController.h"
#import "randersflyveklubSecondViewController.h"
#import <MessageUI/MessageUI.h>

@interface ContactViewController () <MFMailComposeViewControllerDelegate> {
    NSString *contactNameV;
    NSString *contactEmailV;
    NSString *contactTitleV;
} 

@end

@implementation ContactViewController
@synthesize contactnametxt;
@synthesize contacttitletxt;
@synthesize contactemailtxt;

- (IBAction)sendMailBtn:(id)sender {
    // "Send mail" button is clicked
    
    if ([MFMailComposeViewController canSendMail]) {
        // The user has set up a mail account
        // Make a mail dialog
        MFMailComposeViewController *mailDialog = [[MFMailComposeViewController alloc]init];
        
        [mailDialog setToRecipients:[[NSArray alloc]initWithObjects:contactEmailV, nil]];
        [mailDialog setTitle:@"Send an email"];
        [mailDialog setMessageBody:@"" isHTML:NO];
        mailDialog.mailComposeDelegate = self;
        
        [self presentViewController:mailDialog animated:YES completion:NULL];
    }else{
        // The user has not set up any mail account
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You need to configure your mail account before you can send mails!" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
              contact:(NSMutableDictionary *)tmpContact
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Get values which is passed over to this view from the tableView
        contactNameV = [tmpContact valueForKey:@"Name"];
        contactEmailV = [tmpContact valueForKey:@"Email"];
        contactTitleV = [tmpContact valueForKey:@"Title"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    // Show the contact information
    contactnametxt.text = contactNameV;
    contactemailtxt.text = contactEmailV;
    contacttitletxt.text = contactTitleV;
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    // When user closes the dialog
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
