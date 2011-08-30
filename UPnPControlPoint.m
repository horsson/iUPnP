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
@synthesize devices = _device;

typedef void (^upnpXmlParserBlock)(void);

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



-(void) fireErrorEvent:(int) upnpError
{
    NSError* error = [[[NSError alloc] initWithUPnPError:upnpError] autorelease];
    if (delegate)
        [delegate errorDidReceived:error];
}

-(NSMutableDictionary*) getDevices
{
    @synchronized(self)
    {
        [[_device retain] autorelease];
    }
    return _device;
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
        
        _device = [[NSMutableDictionary alloc] init];
        _globalLock =[[NSLock alloc] init];
    }
    return self;
}



//Callback function for the client.
int upnp_callback_func(Upnp_EventType eventType, void *event, void *cookie)
{
    NSLock* lock = [[refToSelf getGlobalLock] retain];
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
    [lock release];
    return UPNP_E_SUCCESS;
}


#pragma Callback function different handle
void handle_discovery_message(void* event)
{
    /*
  
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    struct Upnp_Discovery *discovery = (struct Upnp_Discovery*) event;
    UPnPDevice *device = [[UPnPDevice alloc] init];
    NSString* locationURL = [[NSString stringWithCString:discovery->Location encoding:NSUTF8StringEncoding] autorelease];
    NSString *deviceID = [[NSString stringWithCString:discovery->DeviceId encoding:NSUTF8StringEncoding] autorelease];
    device.UDN = deviceID;
    //dispatch_queue_t  upnpXmlParserQueue;
    
    //upnpXmlParserQueue = dispatch_queue_create("de.haohu.upnp.xml.queue", NULL);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        NSMutableDictionary* devicesDict = [refToSelf getDevices];
        [devicesDict retain];
        [devicesDict setObject:device forKey:deviceID];
        [devicesDict release];

        
    });
    //dispatch_release(upnpXmlParserQueue);
    
    [device release];
    [pool drain];
     */

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

-(NSLock*) getGlobalLock
{
    return _globalLock;
}
-(void) dealloc
{
    [_globalLock release];
    [_device release];
    [delegate release];
    [super dealloc];
}
@end
