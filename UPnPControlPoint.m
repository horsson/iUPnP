//
//  UPnPControlPoint.m
//  iUPnPTestPrj
//
//  Created by Hao Hu on 26.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UPnPControlPoint.h"

@implementation UPnPControlPoint
@synthesize delegate;
@synthesize devices = _devices;


//Callback function for the client.
int upnp_callback_func(Upnp_EventType, void *, void *);
void handle_discovery_message(void*);
id refToSelf = nil;


- (id) init
{
    self = [super init];
    if (self)
    {
        [self initWithHostAddress:nil andPort:0];
    }
    return self;
}

-(dispatch_queue_t) controlPointQueue
{
    return _controlPointQueue;
}

-(NSLock*) devicesLock
{
    return _devicesLock;
}

-(void) fireErrorEvent:(int) upnpError
{
    NSError* error = [[[NSError alloc] initWithUPnPError:upnpError] autorelease];
    if (delegate)
        [delegate errorDidReceive:error];
}




-(id) initWithHostAddress:(NSString *)address andPort:(UInt16)port
{
    self = [super init];
    refToSelf = self;
    if (self)
    {
        int ret = UpnpInit([address cStringUsingEncoding:NSASCIIStringEncoding], port);
        if (ret != UPNP_E_SUCCESS)
        {
            NSLog(@"Cannot init the UPnP Stack");
            [self fireErrorEvent:ret];
        }
        else
        {
            ret = UpnpRegisterClient(upnp_callback_func, nil, &_clientHandle);
            if (ret != UPNP_E_SUCCESS)
            {
                NSLog(@"Cannot Register Client");
                [self fireErrorEvent:ret];
            }
        }
        
        //==========================Init some iVars=====================================
        _devices = [[NSMutableDictionary alloc] init];
        _globalLock =[[NSLock alloc] init];
        _devicesLock = [[NSLock alloc] init];
        _controlPointQueue = dispatch_queue_create("de.haohu.upnp.controlpoint", NULL);
       
    }
    return self;
}



//Callback function for the client.
int upnp_callback_func(Upnp_EventType eventType, void *event, void *cookie)
{
    NSLock* lock = [refToSelf globalLock];
    [lock lock];
    
    switch(eventType)
    {
        case UPNP_DISCOVERY_SEARCH_RESULT:
        case UPNP_DISCOVERY_ADVERTISEMENT_ALIVE:
        {
            if (eventType == UPNP_DISCOVERY_SEARCH_RESULT)
                NSLog(@"Device search result.");
            else
                NSLog(@"Device advertisment.");
            handle_discovery_message(event);
            break;
        }
        case UPNP_DISCOVERY_SEARCH_TIMEOUT:
        {
            NSLog(@"Search Timeout.");
            break;
        }
        case UPNP_DISCOVERY_ADVERTISEMENT_BYEBYE:
        {
            NSLog(@"Device left.");
            break;
        }
            
        default:
        {
            NSLog(@"Unknown eventType");
            break;
        }
    }
    [lock unlock];
    return UPNP_E_SUCCESS;
}


#pragma Callback function different handle
void handle_discovery_message(void* event)
{
    NSAutoreleasePool *pool =[[NSAutoreleasePool alloc] init];

    NSLock* nslock = [refToSelf devicesLock];
    [nslock lock];
    struct Upnp_Discovery *discovery = (struct Upnp_Discovery*) event;
    NSString *deviceID = [NSString stringWithCString:discovery->DeviceId encoding:NSUTF8StringEncoding];
  /*
    if ([[refToSelf devices] objectForKey:deviceID])
    {
        NSLog(@"Device is in, ignore.");
        return;
    }
*/
    NSString* locationURL = [NSString stringWithCString:discovery->Location encoding:NSUTF8StringEncoding];
    
    
    
    UPnPDevice *device = [[UPnPDevice alloc] initWithLocationURL:locationURL timeout:4.0];

   
    device.UDN = deviceID;
    device.delegate = refToSelf;
    [nslock unlock];
    dispatch_async([refToSelf controlPointQueue], ^{
        [device startParsing];
    });
    
    [pool drain];
}




-(void) searchTarget:(NSString*) target withMx:(NSUInteger) mx
{
    UpnpSearchAsync(_clientHandle, mx, [target cStringUsingEncoding:NSUTF8StringEncoding], NULL);
}


-(void) stop
{
    if (_clientHandle != -1)
    {
        UpnpUnRegisterClient(_clientHandle);
        UpnpFinish();
    }
}

-(NSLock*) globalLock
{
    return _globalLock;
}


#pragma UPnPDevice callback
-(void) upnpDeviceDidFinishParsing:(UPnPDevice*) upnpDevice
{
    NSLog(@"Finish parsing.");
    [_devices setObject:upnpDevice forKey:upnpDevice.UDN];
    [delegate upnpDeviceDidAdd:upnpDevice];
    [upnpDevice release];
    
    
}

-(void) upnpDeviceDidReceiveError:(UPnPDevice*)  withError:(NSError*) error;
{
    
}



-(void) dealloc
{
    dispatch_release(_controlPointQueue);
    [_devicesLock release];
    [_globalLock release];
    [_devices release];
    [delegate release];
    [super dealloc];
}
@end
