//
//  randersflyveklubWebViewTableControllerViewController.m
//  randersflyveklub
//
//  Created by Mercantec on 9/30/13.
//  Copyright (c) 2013 and3k5. All rights reserved.
//

#import "randersflyveklubWebViewTableControllerViewController.h"
#import "SiteViewController.h"

@interface randersflyveklubWebViewTableControllerViewController () {
    BOOL useInternet;
}

@end

@implementation randersflyveklubWebViewTableControllerViewController

@synthesize content = _content;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}




#pragma mark - View function

- (void) loadView {
    [super loadView];
    // Get useInternet option value
    useInternet=[[[NSUserDefaults standardUserDefaults] stringForKey:@"useinternet"]isEqualToString:@"1"];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Load the list of links from the plist
    NSString *plistPath = [[NSBundle mainBundle]pathForResource:@"weblinks" ofType:@"plist"];
    NSArray *data = [[NSArray alloc]initWithContentsOfFile:plistPath];
    // This line makes self.content return the array of links
    _content = data;
    // tell the tableView to reload
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data

- (NSArray *) content {
    // Returns the list of links (when it's loaded from the plist)
    return _content;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.content count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    NSDictionary *site = [[NSDictionary alloc]initWithDictionary:[self.content objectAtIndex:indexPath.row]];
    
    // Customize cell text
    cell.textLabel.text = [site objectForKey:@"Name"];
    cell.detailTextLabel.text = [site objectForKey:@"URL"];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (useInternet) {
        // Internet option is enabled, so the user may browse the web
        NSString *url = 
        [[[NSDictionary alloc]initWithDictionary:[self.content objectAtIndex:indexPath.row]] objectForKey:@"URL"];
        NSLog(@"%@",url);
        NSLog(@"%@",url);
        SiteViewController *dialog = [[SiteViewController alloc] initWithNibName:@"SiteViewController" bundle:nil location:url];
    
        [self.navigationController pushViewController:dialog animated:YES];
    }else{
        // If internet option is disabled, the user can't browse the web..
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You can't use Web Links when the Use internet option is disabled. Go to settings and enable it to use Web Links" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
    }
}

@end
