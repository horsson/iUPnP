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
    tableView.dataSource = self;
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
   //UDN: uuid:00113206-57d7-0011-d757-d75706321100
    UPnPDevice* device = [controlPoint getUPnPDeviceById:@"uuid:00113206-57d7-0011-d757-d75706321100"];
    UPnPAction* action = [device getActionByName:@"Browse"];
    
    [action setArgumentStringVal:@"0" forName:@"ObjectID"];
    [action setArgumentStringVal:@"BrowseDirectioinChild" forName:@"BrowseFlag"];
    [action setArgumentStringVal:@"*" forName:@"Filter"];
    [action setArgumentStringVal:@"0" forName:@"StartingIndex"];
    [action setArgumentStringVal:@"100" forName:@"RequestedCount"];
    [action setArgumentStringVal:@"*" forName:@"SortCriteria"];
    if (action)
    {
        int ret =  [action sendActionSync];
        if (ret == UPNP_E_SUCCESS)
        {
            UIAlertView *uiAlert = [[UIAlertView alloc] initWithTitle:@"Info" message:@"Success" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [uiAlert show];
            [uiAlert release];
        }
        else
        {
            NSString* errMsg = [NSString stringWithFormat:@"Error code=%d.",ret];
            UIAlertView *uiAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:errMsg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [uiAlert show];
            [uiAlert release];
        }
    }
    

}

-(IBAction) btnReloadClicked:(id) sender
{
    [tableView reloadData];
    NSLog(@"The number of devices is %d",[_devices count]);
    for (UPnPDevice *aDevice in _devices) {
        NSLog(@"The device name is %@.",aDevice.friendlyName);
    }
}

-(IBAction) btnSearchClicked:(id) sender
{
    [controlPoint searchTarget:@"upnp:rootdevice" withMx:5];
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
    NSLog(@"Device ID is %@", upnpDevice.UDN);
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
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:deviceCellId] autorelease];
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
