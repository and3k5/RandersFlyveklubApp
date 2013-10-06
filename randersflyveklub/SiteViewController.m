//
//  SiteViewController.m
//  randersflyveklub
//
//  Created by Mercantec on 9/30/13.
//  Copyright (c) 2013 and3k5. All rights reserved.
//

#import "SiteViewController.h"

@interface SiteViewController ()

@end

@implementation SiteViewController
@synthesize urllocation;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil location:(NSString *)url
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Get's the url passed over to this view
        urllocation = url;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // Makes the webview and make it visible
    UIWebView *webView = [[UIWebView alloc]initWithFrame:self.view.bounds];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urllocation]];
    [webView loadRequest:request];
    [self.view addSubview:webView];
}

@end
