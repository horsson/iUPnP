//
//  FirstViewController.m
//  iUPnP
//
//  Created by Hao Hu on 30.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FirstViewController.h"
#import "ixml.h"

@implementation FirstViewController
@synthesize tableView;


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    controlPoint = [[UPnPControlPoint alloc] init];
    _devices = [[NSMutableArray alloc] init];
    controlPoint.delegate = self;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}


- (void)viewDidUnload
{
    [super viewDidUnload];

    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(IBAction) btnSendAction:(id) sender
{
    if (_upnpDevice)
    {
        [_upnpDevice release];
        _upnpDevice = nil;
    }
    _upnpDevice = [[UPnPDevice alloc] initWithLocationURL:@"http://192.168.200.150:9000/TMSDeviceDescription.xml" timeout:3.0];
    _upnpDevice.delegate = self;
    [_upnpDevice startParsing];
    
}

-(IBAction) btnReloadClicked:(id) sender
{
    [tableView reloadData];
    NSLog(@"The number of devices is %d",[_devices count]);
}

-(IBAction) btnSearchClicked:(id) sender
{
    [controlPoint searchTarget:@"ssdp:all" withMx:5];
}

#pragma UPnPDevice delegate method.
-(void) upnpDeviceDidFinishParsing:(UPnPDevice*) upnpDevice
{
       
    IXML_Document* resDoc= NULL;
    UPnPAction* action = [upnpDevice getActionByName:@"Browse"];
    
    [action setArgumentStringVal:@"0" forName:@"ObjectID"];
    [action setArgumentStringVal:@"BrowseDirectioinChild" forName:@"BrowseFlag"];
    [action setArgumentStringVal:@"*" forName:@"Filter"];
    [action setArgumentStringVal:@"0" forName:@"StartingIndex"];
    [action setArgumentStringVal:@"100" forName:@"RequestedCount"];
    [action setArgumentStringVal:@"*" forName:@"SortCriteria"];

    
    if(action)
    {
        int rc = [action getXmlDocForAction:&resDoc];
        if (rc == UPNP_E_SUCCESS)
        {
            NSLog(@"Success!!!");
            DOMString str =  ixmlDocumenttoString(resDoc);
            NSLog(@"%s",str);
            ixmlDocument_free(resDoc);
            ixmlFreeDOMString(str);
        }
    }
}

-(void) upnpDeviceDidReceiveError:(UPnPDevice*)  withError:(NSError*) error
{
    
}

#pragma UPnPControlPoint callback

-(void) errorDidReceive:    (NSError*) error
{
    
}

-(void) upnpDeviceDidAdd:   (UPnPDevice*) upnpDevice
{
    NSLog(@"Device finish. The name is %@",upnpDevice.friendlyName);
    [_devices addObject:upnpDevice];

}

-(void) upnpDeviceDidLeave: (UPnPDevice*) upnpDevice
{
    [tableView reloadData];
}

#pragma UITableViewDatasource delegate
- (UITableViewCell *)tableView:(UITableView *)tableVieww cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* deviceCellId = @"DeviceListCellId";
    UITableViewCell* cell = [tableVieww dequeueReusableCellWithIdentifier:deviceCellId];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:deviceCellId];
        NSUInteger row = [indexPath row];
        UPnPDevice* upnpDevice = [_devices objectAtIndex:row];
        cell.textLabel.text = upnpDevice.friendlyName;
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableVieww numberOfRowsInSection:(NSInteger)section
{
    return [_devices count];
}

- (void)dealloc
{
    [_devices release];
    [controlPoint release];
    [super dealloc];
}

@end
