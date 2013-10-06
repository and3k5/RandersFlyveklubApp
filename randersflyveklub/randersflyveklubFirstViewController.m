//
//  randersflyveklubFirstViewController.m
//  randersflyveklub
//
//  Created by mercantec on 9/24/13.
//  Copyright (c) 2013 and3k5. All rights reserved.
//

// Map View

#import "randersflyveklubFirstViewController.h"
#import "InfoWindow.h"
#import <sqlite3.h>



@interface randersflyveklubFirstViewController ()

@end

@implementation randersflyveklubFirstViewController {
    GMSMapView *mapView; // Google Maps View
    sqlite3 *db; // the database containing airfields
    sqlite3_stmt *db_query; // query "statement"
    NSMutableArray *loadedAirfields; // loaded airfields
    NSMutableArray *airfields; // airfields
    NSMutableArray *airfieldIndex; // index of airfields 
    BOOL autoUpdate; 
    BOOL useInternet;
}
@synthesize getAirfieldsBtn;
@synthesize settingsBtn;

# pragma mark - View functions

- (void)viewWillAppear:(BOOL)animated {
    // For every time the view will appear,
    // find out if the autoupdate feature should be enabled
    autoUpdate =[[[NSUserDefaults standardUserDefaults] stringForKey:@"dragAutoupdate"]isEqualToString:@"1"];
    if (autoUpdate) {
        getAirfieldsBtn.enabled = NO;
    }else{
        getAirfieldsBtn.enabled = YES;
    }
}
- (void) loadView {
    [super loadView];
    // When view is loaded once, find out if
    // it is allowed to use internet
    // (Settings property)
    useInternet=[[[NSUserDefaults standardUserDefaults] stringForKey:@"useinternet"]isEqualToString:@"1"];
}
- (void)viewDidLoad
{
    // Move and load database
    db = [self openDB:@"airfields" type:@"rdb"];
    
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // Usage of arrays
    
    // airfields is details from the database, stored in memory
    // airfieldIndex is containing index numbers of airfield locations in airfields(the array) by ICAO code
    // loaded airfields is an array of the loaded, so we dont make markers twice or more
    airfields = [[NSMutableArray alloc] initWithCapacity:3969];
    airfieldIndex = [[NSMutableArray alloc] initWithCapacity:3969];
    loadedAirfields = [[NSMutableArray alloc]initWithCapacity:3969];
    
    // Randers airport latitude og longitude: 56.505124,10.034514
    // Used for center
    GMSCameraPosition *randers = [GMSCameraPosition cameraWithLatitude:56.505124 longitude:10.034514 zoom:7];
    
    // Google MapView
    mapView = [GMSMapView mapWithFrame:CGRectZero camera:randers];
    
    mapView.myLocationEnabled = YES;
    mapView.mapType = kGMSTypeTerrain;
    mapView.settings.rotateGestures = NO;
    mapView.settings.tiltGestures = NO;
    
    // Bind actions to this viewcontroller
    mapView.delegate = self;
    
    // The viewcontrollers view will be the mapview
    self.view = mapView;
    
    // We can't make actions directly for UIBarButtonItem's so we use delegate
    [getAirfieldsBtn setTarget:self];
    [getAirfieldsBtn setAction:@selector(getAirfieldsBtnClick:)];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    // If low on memory, remove all airfields..
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"dragAutoupdate"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    autoUpdate = NO;
    getAirfieldsBtn.enabled = YES;
    [mapView clear];
    [loadedAirfields removeAllObjects];
    [airfieldIndex removeAllObjects];
}

# pragma mark - Map functions

- (void) getAirfieldsInFOV:(GMSMapView *)mView {
    
    // Get the visible region of the mapview
    GMSVisibleRegion region = [mView.projection visibleRegion];
    double topLeftX = region.farLeft.latitude;
    double topLeftY = region.farLeft.longitude;

    double bottomRightX = region.nearRight.latitude;
    double bottomRightY = region.nearRight.longitude;
    
    // The query to be executed
    NSString *sql = [NSString stringWithFormat:@"SELECT name, icao, country, latitude, longitude FROM airfields WHERE latitude<%lf AND latitude>%lf AND longitude>%lf AND longitude<%lf",topLeftX,bottomRightX,topLeftY,bottomRightY,nil];
    
    // Execute the query
    if (db != nil) {
        db_query=nil;
        if (!db_query) {
			if (sqlite3_prepare_v2(db, [sql UTF8String], -1, &db_query, nil) != SQLITE_OK)
			{
				int errmsg = sqlite3_prepare_v2(db, [sql UTF8String], -1, &db_query, nil);
				NSLog(@"Error preparing SQL query. ERROR %d", errmsg);
			}
        }
        sqlite3_reset(db_query);
        while (sqlite3_step(db_query) == SQLITE_ROW) {
            // if the airfield isn't already loaded into the map
            if ([loadedAirfields indexOfObject:[[NSString alloc]initWithUTF8String:(char *)sqlite3_column_text(db_query, 1)]]==NSNotFound) {
                NSMutableDictionary *airfield = [[NSMutableDictionary alloc]initWithCapacity:5];
                [airfield setObject:[[NSString alloc]initWithUTF8String:(char *)sqlite3_column_text(db_query, 0)] forKey:@"name"];
                [airfield setObject:[[NSString alloc]initWithUTF8String:(char *)sqlite3_column_text(db_query, 1)] forKey:@"icao"];
                [airfield setObject:[[NSString alloc]initWithUTF8String:(char *)sqlite3_column_text(db_query, 2)] forKey:@"country"];
                
                // NSNumber? Really, Apple?...
                NSNumber *_lat = [[NSNumber alloc] initWithDouble:sqlite3_column_double(db_query,3)];
                NSNumber *_long = [[NSNumber alloc] initWithDouble:sqlite3_column_double(db_query,4)];
                
                [airfield setObject:_lat forKey:@"latitude"];
                [airfield setObject:_long forKey:@"longitude"];
            
                [airfields addObject:airfield];
            }
        }
    }
    // For every found airfield, put it to the map (if it doesn't exist)
    for (NSMutableDictionary* airfield in airfields) {
        if ([loadedAirfields indexOfObject:[airfield objectForKey:@"icao"]]==NSNotFound) {
            CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([[airfield objectForKey:@"latitude"] doubleValue],[[airfield objectForKey:@"longitude"] doubleValue]);
            GMSMarker *marker = [GMSMarker markerWithPosition:coord];
            marker.snippet = [airfield objectForKey:@"icao"];
            marker.icon = [[UIImage alloc]initWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"airfield15px" ofType:@"png"]];
            
            marker.map = mapView;
            [loadedAirfields addObject:[airfield objectForKey:@"icao"]];
            [airfieldIndex addObject:[NSNumber numberWithInt:[airfields indexOfObject:airfield]]];
        }
    }
}

- (UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker {
    // My own custom infoWindow for markers
    // The stupid thing about this is that the only way to get information
    // from internet to this dialog is by using syncronous web request..
    InfoWindow *infoWindow;
    infoWindow = [[[NSBundle mainBundle] loadNibNamed:@"InfoWindow" owner:self options:nil] objectAtIndex:0];
    int index = [[airfieldIndex objectAtIndex:[loadedAirfields indexOfObject:marker.snippet]] intValue];
    NSMutableDictionary *airfield = [airfields objectAtIndex:index];
    infoWindow.name.text = [airfield objectForKey:@"name"];
    infoWindow.country.text = [airfield objectForKey:@"country"];
    
    if (useInternet) {
        NSString *urlstring = [NSString stringWithFormat:@"http://api.geonames.org/weatherIcaoJSON?ICAO=%@&username=ande7353",[airfield objectForKey:@"icao"],nil];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:urlstring]];
        [request setHTTPMethod:@"GET"];
        NSURLResponse* response;
        NSError* error = nil;
        
        NSData* data = [NSURLConnection sendSynchronousRequest:request  returningResponse:&response error:&error];
        
        if (error.code==0) {
            NSError *error2;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error2];
            
            if (error2.code==0) {
                NSLog(@"succes");
                if ([json objectForKey:@"weatherObservation"]) {
                    // success
                    NSDictionary *obj = [json objectForKey:@"weatherObservation"];
                    infoWindow.winddirection.text = [NSString stringWithFormat:@"%d",[[obj valueForKey:@"windDirection"]intValue],nil];
                    infoWindow.windspeed.text = [NSString stringWithFormat:@"%@",[obj objectForKey:@"windSpeed"],nil];
                    infoWindow.temperature.text = [NSString stringWithFormat:@"%@",[obj objectForKey:@"temperature"],nil];
                }else{
                    // Server did not send any details about the weather..
                    NSLog(@"No info");
                    NSString *errorstring = @"Information not available";
                    infoWindow.winddirection.text = errorstring;
                    infoWindow.windspeed.text = errorstring;
                    infoWindow.temperature.text = errorstring;
                }
            }else{
                // error in web request..
                NSLog(@"Error in web request");
                NSString *errorstring = @"No connection to server";
                infoWindow.winddirection.text = errorstring;
                infoWindow.windspeed.text = errorstring;
                infoWindow.temperature.text = errorstring;
            }
        }
    }else{
        // the useInternet option is disabled
        NSString *errorstring = @"Use Internet disabled";
        infoWindow.winddirection.text = errorstring;
        infoWindow.windspeed.text = errorstring;
        infoWindow.temperature.text = errorstring;
    }
    
    return infoWindow;
}

- (void) mapView:(GMSMapView *)mView idleAtCameraPosition:(GMSCameraPosition *)position {
    // if autoUpdate is enabled, find airfields in visible area
    if (autoUpdate) {
        [self getAirfieldsInFOV:mapView];
    }
}

- (sqlite3 *) openDB:(NSString *)fName type:(NSString *)fType
{
    // File source
    NSString *fileSrc = [[NSBundle mainBundle] pathForResource:fName ofType:fType];
    // File destination
    NSString *fileDest = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    fileDest = [fileDest stringByAppendingPathComponent:@"Data"];
    // file destination + filename
    NSString *fNameDest = [[fileDest stringByAppendingPathComponent:fName] stringByAppendingPathExtension:fType];
    NSError *err;
    // check if filedestination exists
    if (![[NSFileManager defaultManager] fileExistsAtPath:fileDest]) {
        NSLog(@"DB folder doesn't exist in sandbox!");
        if (![[NSFileManager defaultManager] createDirectoryAtPath:fileDest withIntermediateDirectories:YES attributes:nil error:&err]) {
            NSLog(@"Directory was not created: %@",[err localizedDescription]);
        }else{
            NSLog(@"Folder is now created");
        }
    }else{
      //  NSLog(@"Path already exist: %@ ",fileDest);
    }
    
    // check if database already is there
    if (![[NSFileManager defaultManager] fileExistsAtPath:fNameDest]) {
        NSLog(@"File doesn't exist: %@",fNameDest);
        if (![[NSFileManager defaultManager] copyItemAtPath:fileSrc toPath:fNameDest error:&err]) {
            NSLog(@"File was not copied: %@",[err localizedDescription]);
        }else{
            NSLog(@"File is now copied!");
        }
    }else{
      //  NSLog(@"File does already exist!");
    }
    
    if (sqlite3_open_v2([fNameDest UTF8String], &db, SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK)
    {
        NSLog(@"DB Connection: OK");
        db_query = nil;
    }else{
        NSLog(@"DB Connection: NOT OK!");
        db = nil;
    }
    return (sqlite3 *)db;
}

- (IBAction) getAirfieldsBtnClick:(id)sender {
    // Manual "Get airfields" button is clicked
    [self getAirfieldsInFOV:mapView];
}
- (IBAction)clearMapBtnClick:(id)sender {
    //"Clear map" button is clicked
    [mapView clear];
    [loadedAirfields removeAllObjects];
    [airfieldIndex removeAllObjects];
}




@end
