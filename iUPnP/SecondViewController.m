//
//  SecondViewController.m
//  iUPnP
//
//  Created by Hao Hu on 30.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SecondViewController.h"


@implementation SecondViewController
NSString* const kDeviceURL = @"http://192.168.200.150:9000/TMSDeviceDescription.xml";

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


-(IBAction) btnParserDeviceClicked:(id)sender
{
    if (_upnpDevice)
    {
        [_upnpDevice release];
        _upnpDevice = nil;
    }
    _upnpDevice = [[UPnPDevice alloc] initWithLocationURL:kDeviceURL timeout:4.0];
    _upnpDevice.delegate = self;
    [_upnpDevice startParsing];
}

-(IBAction) btnParserServiceClicked:(id)sender
{

    
}


- (void)dealloc
{
    [super dealloc];
}

#pragma  DEBUG helper
-(void) assertEqual:(BOOL) expression withDescription:(NSString*) description
{
    if (expression)
    {
        UIAlertView * uiView = [[UIAlertView alloc] initWithTitle:description message:@"Test Passed" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [uiView show];
        [uiView release];
    }
    else
    {
        UIAlertView * uiView = [[UIAlertView alloc] initWithTitle:description message:@"Test Fail" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [uiView show];
        [uiView release];
    }
}


#pragma UPnPDeviceDelegate
-(void) upnpDeviceDidFinishParsing:(UPnPDevice*) upnpDevice
{
  
    /*
        UIAlertView * uiView = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Done" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [uiView show];
        [uiView release];
        NSUInteger countOfService = [upnpDevice.serviceList count];
        [self assertEqual:(countOfService == 3) withDescription:@"Service count"];
        NSLog(@"The count of services is %d", countOfService);
        
        UPnPService * upnpService = [upnpDevice getUPnPServiceById:@"urn:upnp-org:serviceId:ContentDirectory"];
        [self assertEqual:(upnpDevice != nil) withDescription:@"Service Null"];
        NSUInteger countOfAction = [upnpService.actionList count];
        [self assertEqual:(countOfAction == 12) withDescription:@"Action count"];
        NSLog(@"The count of actions is %d", countOfAction);
        
        UPnPAction* upnpAction = [upnpService getActionByName:@"Search"];
        [self assertEqual:(upnpAction != nil) withDescription:@"Action Null"];
    
        NSUInteger countOfArg =  [upnpAction.argumentList count];
    
        [self assertEqual:(countOfArg == 10) withDescription:@"Args count"];
     */
    
    UPnPAction* anAction = [upnpDevice getActionByName:@"Search"];
    [self assertEqual:(anAction!=nil) withDescription:@"Action from Device"];
    
}
-(void) upnpDeviceDidReceiveError:(UPnPDevice*)  withError:(NSError*) error
{
    UIAlertView * uiView = [[UIAlertView alloc] initWithTitle:@"Fail" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [uiView show];
    [uiView release];
}

@end
