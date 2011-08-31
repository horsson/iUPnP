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


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

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

-(void) upnpDeviceDidFinishParsing:(UPnPDevice*) upnpDevice
{
    NSLog(@"Device finish.");
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
- (void)dealloc
{
    [super dealloc];
}

@end
