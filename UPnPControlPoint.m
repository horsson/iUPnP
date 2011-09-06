//
//  UPnPControlPoint.m
//  iUPnPTestPrj
//
//  Created by Hao Hu on 26.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UPnPControlPoint.h"
//#define DEBUG_THREAD

@implementation UPnPControlPoint
@synthesize delegate;
@synthesize devices = _devices,deviceIDSet,clientHandle;


//Callback function for the client.
int upnp_callback_func(Upnp_EventType, void *, void *);
void handle_discovery_message(void*);
void handle_byebye_message(void*);

id refToSelf = nil;


- (id) init
{
    self = [super init];
    if (self)
    {
        refToSelf = self;
        [self initWithHostAddress:nil andPort:0];
    }
    return self;
}

-(dispatch_queue_t) controlPointQueue
{
    return _controlPointQueue;
}


-(void) fireErrorEvent:(int) upnpError
{
    NSError* error = [[[NSError alloc] initWithUPnPError:upnpError] autorelease];
    if (delegate)
        [delegate errorDidReceive:error];
}

-(UPnPDevice*) getUPnPDeviceById:(NSString*) deviceID
{
    [_deviceListLock lock];
    UPnPDevice* deviceToReturn = [[[_devices objectForKey:deviceID] retain]autorelease];
    [_deviceListLock unlock];
    return deviceToReturn;
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
            ret = UpnpRegisterClient(upnp_callback_func, nil, &clientHandle);
            if (ret != UPNP_E_SUCCESS)
            {
                NSLog(@"Cannot Register Client");
                [self fireErrorEvent:ret];
            }
        }
        
        //==========================Init some iVars=====================================
        _devices = [[NSMutableDictionary alloc] init];
        _globalLock =[[NSLock alloc] init];
        _controlPointQueue = dispatch_queue_create("de.haohu.upnp.controlpoint", NULL);
        deviceIDSet = [[NSMutableSet alloc] init];
        _deviceListLock = [[NSLock alloc] init];
    }
    return self;
}



//Callback function for the client.
int upnp_callback_func(Upnp_EventType eventType, void *event, void *cookie)
{
    NSLock* lock = [refToSelf globalLock];
    [lock lock];
    NSAutoreleasePool *pool =[[NSAutoreleasePool alloc] init];
#ifdef DEBUG_THREAD
    static int idForThread = 0;
    NSThread* thread = [NSThread currentThread];
    NSString* threadName = [thread name];
    if (threadName == nil)
    {
        idForThread++;
        [thread setName:[NSString stringWithFormat:@"ID:%d",idForThread]];
    }
    NSLog(@"Thread name is %@",[thread name]);
#endif
    
    
    switch(eventType)
    {
        case UPNP_DISCOVERY_SEARCH_RESULT:
        case UPNP_DISCOVERY_ADVERTISEMENT_ALIVE:
        {
            handle_discovery_message(event);
            break;
        }
        case UPNP_DISCOVERY_SEARCH_TIMEOUT:
        {
            NSLog(@"Timeout.");
            [[refToSelf delegate] searchDidTimeout];
            break;
        }
        case UPNP_DISCOVERY_ADVERTISEMENT_BYEBYE:
        {
            handle_byebye_message(event);           
            break;
        }
            
        default:
        {
            NSLog(@"Unknown eventType");
            break;
        }
    }
    [pool drain];
    [lock unlock];
    return UPNP_E_SUCCESS;
}


#pragma Callback function different handle
void handle_discovery_message(void* event)
{

    struct Upnp_Discovery *discovery = (struct Upnp_Discovery*) event;

    NSString *deviceID = [NSString stringWithCString:discovery->DeviceId encoding:NSUTF8StringEncoding];
  
    if ([[refToSelf deviceIDSet] containsObject:deviceID])
    {
       // NSLog(@"Device is in, ignore.");
        return;
    }
    else
    {
        [[refToSelf deviceIDSet] addObject:deviceID];
    }
    NSString* locationURL = [[NSString alloc] initWithCString:discovery->Location encoding:NSUTF8StringEncoding];
    __block UPnPDevice *device = [[UPnPDevice alloc] initWithLocationURL:locationURL timeout:4.0];
    [locationURL release];
    device.controlPointHandle = [refToSelf clientHandle];
    device.UDN = deviceID;
    device.delegate = refToSelf;
  //  NSLog(@"UPnPDevice before the queue retain count is %d",[device retainCount]);
    dispatch_async([refToSelf controlPointQueue], ^{
        [device startParsing];
    });
    
    // NSLog(@"UPnPDevice after the queue retain count is %d",[device retainCount]);
}

void handle_byebye_message(void* event)
{
    struct Upnp_Discovery* discovery = (struct Upnp_Discovery*) event;
    NSString* deviceId = [NSString stringWithCString:discovery->DeviceId encoding:NSUTF8StringEncoding];
    [[refToSelf devices] removeObjectForKey:deviceId];
    [[refToSelf deviceIDSet] removeObject:deviceId];
    if ([refToSelf delegate])
    {
        NSString* udn = [[deviceId copy] autorelease];
        [[refToSelf delegate] upnpDeviceDidLeave:udn];
    }
}


-(void) searchTarget:(NSString*) target withMx:(NSUInteger) mx
{
    UpnpSearchAsync(clientHandle, mx, [target cStringUsingEncoding:NSUTF8StringEncoding], NULL);
}


-(void) stop
{
    if (clientHandle != -1)
    {
        UpnpUnRegisterClient(clientHandle);
        UpnpFinish();
        clientHandle = -1;
    }
}

-(NSLock*) globalLock
{
    return _globalLock;
}


#pragma UPnPDevice callback
-(void) upnpDeviceDidFinishParsing:(UPnPDevice*) upnpDevice
{
    //NSLog(@"Finish parsing.");
    [_deviceListLock lock];
    [_devices setObject:upnpDevice forKey:upnpDevice.UDN];
    NSString* udn = [[upnpDevice.UDN copy] autorelease];
    [delegate upnpDeviceDidAdd:udn];
    [upnpDevice release];
    NSLog(@"UPNPDevice retain count is %d", [upnpDevice retainCount]);
    [_deviceListLock unlock];
}

-(void) upnpDeviceDidReceiveError:(UPnPDevice*)  withError:(NSError*) error;
{
    
}

-(void) dealloc
{
    NSLog(@"UPnPControlPoint dealloc.");
    [deviceIDSet release];
    dispatch_release(_controlPointQueue);
    [_globalLock release];
    [_deviceListLock release];
    [_devices release];
    [delegate release];
    [super dealloc];
}
@end
