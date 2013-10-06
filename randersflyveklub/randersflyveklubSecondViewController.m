//
//  randersflyveklubSecondViewController.m
//  randersflyveklub
//
//  Created by Mercantec on 9/25/13.
//  Copyright (c) 2013 and3k5. All rights reserved.
//

#import "randersflyveklubSecondViewController.h"
#import "ContactViewController.h"

@interface randersflyveklubSecondViewController () {
    NSURLConnection *connection;
    BOOL useInternet;
    UIActivityIndicatorView *activityIndicator;
    NSString *plistPath;
    int updateInterval;
}

@end

@implementation randersflyveklubSecondViewController
@synthesize content = _content;
@synthesize tableViewObj;

#pragma marks - view functions

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        
    }
    return self;
}


- (void)loadView {
    // makes an empty array for content so that tableview wouldn't complain
    _content = [[NSArray alloc]init];
    
    // Get use internet option
    useInternet=[[[NSUserDefaults standardUserDefaults] stringForKey:@"useinternet"]isEqualToString:@"1"];
    
    // gets the documentdirectory path
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    // compose a path for our plist containing contact information
    plistPath = [NSString stringWithFormat:@"%@/contactinfo.plist", [paths objectAtIndex:0]];
    
    // Create it if it doesn't exist
    if ([[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        NSLog(@"Files exist - all good");
    }else{
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
        NSDate *lastUpdate = [df dateFromString:@"1970-01-01 00:00:01"];
        NSLog(@"File doesn't exist - create!");
        NSDictionary *data = [[NSDictionary alloc] initWithObjectsAndKeys:lastUpdate,@"lastUpdate",[[NSArray alloc]init],@"contacts", nil];
        [[NSFileManager defaultManager] createFileAtPath:plistPath contents:nil attributes:nil];
        if([data writeToFile:plistPath atomically:YES]){
            NSLog(@"File created!");
        }else{
            NSLog(@"Failed!");
        }
    }
    
    int updateIntervalIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"updateInterval"];
    
    switch (updateIntervalIndex) {
        case 0:
            updateInterval = 0;
            break;
        case 1:
            updateInterval = 60*60*24*1;
            break;
        case 2:
            updateInterval = 60*60*24*7;
            break;
        case 3:
            updateInterval = 60*60*24*14;
            break;
        case 4:
            updateInterval = 60*60*24*28;
            break;
    }
    
    [super loadView];
}

- (void)viewDidAppear:(BOOL)animated {
    // every time this view did appear, update table view
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // An activity indicator might satisfy the user for a few seconds
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicator.hidesWhenStopped = YES;
    [activityIndicator setCenter:CGPointMake(30, 30)];
    UIColor *color = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    [activityIndicator setColor:color];
    [activityIndicator startAnimating];
    [self.view addSubview:activityIndicator];
    
    // Now check for contacts
    [self checkContacts];
}

#pragma mark - Table view data source

-(NSArray *)content
{
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
    cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    cell.textLabel.text = [[self.content objectAtIndex:indexPath.row] valueForKey:@"Name"];
    cell.detailTextLabel.text = [[self.content objectAtIndex:indexPath.row] valueForKey:@"Email"];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // If a contact is selected, show another view with details about the contact
    NSMutableDictionary *tmpContact = [[NSMutableDictionary alloc]initWithCapacity:3];
    tmpContact = [_content objectAtIndex:indexPath.row];
    
    // Data from this cell is passed over to the ContactViewController
    ContactViewController *dialog = [[ContactViewController alloc] initWithNibName:@"ContactViewController" bundle:nil contact:tmpContact];
    [self.navigationController pushViewController:dialog animated:YES];
}



- (void) checkContacts {
    // Check if contact should be updated
    // If older than option in settings,
    // it would look up the Google Spreadsheet (if available)
    NSDictionary *data = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    
    NSDate *date = [data objectForKey:@"lastUpdate"];
    if ([[NSDate date]timeIntervalSinceDate:date]>updateInterval) {
        NSLog(@"Data is old");
        if (useInternet) {
            [self updateContacts];
        }else{
            NSLog(@"Internet is disabled");
            [self loadContacts];
        }
    }else{
        NSLog(@"Data is recent");
        [self loadContacts];
    }
    

}
- (void) loadContacts {
    // load contacts from the local plist
    NSDictionary *data = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    NSArray *contacts=[data objectForKey:@"contacts"];
    _content = contacts;
    
    // hide activity indicator and reload the tableView
    [activityIndicator stopAnimating];
    [tableViewObj reloadData];
    NSLog(@"Data is now loaded into tableview");
}

# pragma mark - Network connection

- (void) updateContacts {
    // Connect to the Google Spreadsheet and get contact
    // information
    NSMutableURLRequest *urlrequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://docs.google.com/spreadsheet/pub?key=0AhydjcQRIqeQdFpZNVRNd3ZBQTVQcmZvX3NIR1dVLXc&single=true&gid=0&output=csv"]];
    
    urlrequest.HTTPMethod = @"GET";
    // We don't want to use cache
    urlrequest.cachePolicy = NSURLCacheStorageNotAllowed;
    // (void) is to avoid warning
    (void) [[NSURLConnection alloc]initWithRequest:urlrequest delegate:self];
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // Server did accept request.
    // Init the data container
    _responseData = [[NSMutableData alloc]init];
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    //Receives a part of the data
    NSLog(@"Receiving");
    [_responseData appendData:data];
    
}
- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    // No cache
    return nil;
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // Data request is complete
    // Now put it into the plist
    NSString *strdata = [[NSString alloc]initWithData:_responseData encoding:NSUTF8StringEncoding];
    
    NSArray *array01 = [strdata componentsSeparatedByString:@"\n"];
    
    NSMutableArray *array02 = [[NSMutableArray alloc] init];
    
    for (NSString *tmp in array01) {
        NSArray *splitted = [tmp componentsSeparatedByString:@","];
        
        NSMutableDictionary *tmpContact = [[NSMutableDictionary alloc]initWithCapacity:3];
        
        [tmpContact setObject:[splitted objectAtIndex:0] forKey:@"Name" ];
        [tmpContact setObject:[splitted objectAtIndex:1] forKey:@"Email" ];
        [tmpContact setObject:[splitted objectAtIndex:2] forKey:@"Title" ];
        
        [array02 addObject:tmpContact];
    }
    
    // Prepare the data to be written into plist
    NSString *errorDesc = nil;
    
    NSMutableDictionary *plistData = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    
    [plistData setObject:array02 forKey:@"contacts"];
    [plistData setObject:[NSDate date] forKey:@"lastUpdate"];
    
    if (plistData)
    {
        [plistData writeToFile:plistPath atomically:YES];
    }else
    {
        NSLog(@"[Error] Application Did Enter Background {saving file error}: %@", errorDesc);
    }
    
    NSLog(@"Content from google spreadsheet is now loaded into plist!");
    
    // Now that we have the recent contact information
    // in the plist, we can load it
    [self loadContacts];
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // Error during web request
    NSString *err=[NSString stringWithFormat:@"Error during connection request:\n%@",error.localizedDescription,nil];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                    message:err delegate:self cancelButtonTitle:@"Allright" otherButtonTitles:nil];
    [alert show];
    
    // now that we don't have any recent information,
    // just show the old information
    [self loadContacts];
    
}
@end
