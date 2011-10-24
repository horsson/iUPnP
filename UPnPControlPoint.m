//
//  UPnPControlPoint.m
//  iUPnPTestPrj
//
//  Created by Hao Hu on 26.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UPnPControlPoint.h"
#import "NSError+UPnP.h"
#import "EventParser.h"

//#define DEBUG_THREAD

//==================================ControlPoint private methods=========================================
@interface UPnPControlPoint() 


@end
//========================================================================================================

@implementation UPnPControlPoint

@synthesize devices = _devices,deviceIDSet,clientHandle,lastError,delegate;


//Callback function for the client.
//=====================================Functions forward declaration=====================================
int upnp_callback_func(Upnp_EventType, void *, void *);
void handle_discovery_message(void*);
void handle_byebye_message(void*);
void handle_event_received(void*);
//=======================================================================================================
id refToSelf = nil;


- (id) init
{
    self = [super init];
    if (self)
    {
        refToSelf = self;
        self = [self initWithHostAddress:nil andPort:0];
    }
    return self;
}


-(dispatch_queue_t) eventHandlerQueue
{
    return eventHandlerQueue;
}

-(dispatch_queue_t) discoveryQueue
{
    return discoveryQueue;
}

-(void) fireErrorEvent:(int) upnpError
{
    NSError* error = [[NSError alloc] initWithUPnPError:upnpError];
    if (delegate)
        [delegate errorDidReceive:error];
}

-(UPnPDevice*) getUPnPDeviceById:(NSString*) deviceID
{

    UPnPDevice* deviceToReturn = [_devices objectForKey:deviceID];
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
        
        //====================================Init some iVars===============================================
        _devices = [[NSMutableDictionary alloc] init];
        deviceIDSet = [[NSMutableSet alloc] init];
        subscriptions = [[NSMutableDictionary alloc] initWithCapacity:5];
        eventHandlerQueue = dispatch_queue_create("de.haohu.iupnp.eventhandler", NULL);
        discoveryQueue = dispatch_queue_create("de.haohu.iupnp.discovery", NULL);
        deviceLock = [[NSLock alloc] init];
        //==================================================================================================
    }
    return self;
}



//Callback function for the client.
int upnp_callback_func(Upnp_EventType eventType, void *event, void *cookie)
{
    //NSLog(@"upnp_callback_func begin");
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
            
        case UPNP_EVENT_RECEIVED:
        {
            handle_event_received(event);
            break;
        }
        default:
        {
            NSLog(@"Unknown eventType");
            break;
        }
    }
    // NSLog(@"upnp_callback_func end");
    return UPNP_E_SUCCESS;
}

//=================================Handle different callback functions==========================================
#pragma Callback function different handle
void handle_discovery_message(void* event)
{
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);

    //@synchronized(event)
  //  {
    
    //dispatch_queue_t queue = [refToSelf discoveryQueue];
    dispatch_async(queue, ^{
        NSLog(@"handle_discovery_message begin");
      
        struct Upnp_Discovery *discovery = (struct Upnp_Discovery*) event;
        
        NSString *deviceID = [NSString stringWithCString:discovery->DeviceId encoding:NSASCIIStringEncoding];
       /*
        if (deviceID == nil)
        {
            NSLog(@"%s", discovery->DeviceId);
            NSLog(@"Found a deviceID is null.");
            return;
        }
        */
        
        if ([[refToSelf deviceIDSet] containsObject:deviceID])
        {
            NSLog(@"Device is already found, ignore.");
            return;
        }
        else
        {
           // NSLog(@"DeviceID = %@",deviceID);
            [[refToSelf deviceIDSet] addObject:deviceID];
        }
        
        NSString* locationURL = [[NSString alloc] initWithCString:discovery->Location encoding:NSASCIIStringEncoding];
        
        /*
        if (locationURL == nil)
        {
            NSLog(@"The location url is nil, the deviceId is %s.", discovery->DeviceId);
        }
         */
        
        UPnPDevice *device = [[UPnPDevice alloc] initWithLocationURL:locationURL timeout:4.0];
        device.controlPointHandle = [refToSelf clientHandle];
        device.UDN = deviceID;
        device.delegate = refToSelf;
        [[refToSelf devices] setObject:device forKey:device.UDN];
        [device startParsing];
         NSLog(@"handle_discovery_message end");
    });
  //  }

}

void handle_byebye_message(void* event)
{

    dispatch_async([refToSelf discoveryQueue], ^(void) {
        struct Upnp_Discovery* discovery = (struct Upnp_Discovery*) event;
        NSString* deviceId = [NSString stringWithCString:discovery->DeviceId encoding:NSASCIIStringEncoding];
        UPnPDevice* upnpDevice = [[refToSelf devices] objectForKey:deviceId];
        [[refToSelf devices] removeObjectForKey:deviceId];
        [[refToSelf deviceIDSet] removeObject:deviceId];
        [[refToSelf delegate] upnpDeviceDidLeave:upnpDevice];
    });
    
       
}

void handle_event_received(void* event)
{

    dispatch_async([refToSelf eventHandlerQueue], ^(void) {

            struct Upnp_Event* upnpEvent = (struct Upnp_Event*) event;
            char* ssid = upnpEvent->Sid;
            int eventKey = upnpEvent->EventKey;
            IXML_Document* doc = upnpEvent->ChangedVariables;
            NSString* strSSID = [NSString stringWithCString:ssid encoding:NSASCIIStringEncoding];
            NSString* xmlDocString = [[NSString alloc] initWithCString:ixmlDocumenttoString(doc) encoding:NSASCIIStringEncoding];
            EventParser* eventParser = [[EventParser alloc] initWithXMLString:xmlDocString];
            [eventParser parse];
            NSDictionary* varValueDict =eventParser.varValueDict;
            [varValueDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                [[refToSelf delegate] eventNotifyDidReceiveWithSSID:strSSID eventKey:eventKey varName:key value:obj];
            }];
    });
       
    
}
//================================================================================================================================

-(void) searchTarget:(NSString*) target withMx:(NSUInteger) mx
{
    UpnpSearchAsync(clientHandle, mx, [target cStringUsingEncoding:NSASCIIStringEncoding], NULL);
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


-(BOOL) subscribeService:(UPnPService*) service
{
    return [self subscribeService:service withTimeout:UPNP_INFINITE];;
}

-(BOOL) subscribeService:(UPnPService *)service withTimeout:(NSInteger) timeout
{
    const char* subsURL = [service.eventSubURL UTF8String];
    Upnp_SID ssid;
    if (timeout == UPNP_INFINITE)
    {
        timeout = -1;
    }
    int ret = UpnpSubscribe(self.clientHandle, subsURL, &timeout, ssid);
    
    if (ret == UPNP_E_SUCCESS)
    {
        NSString* ssidAsKey = [[NSString alloc] initWithCString:ssid encoding:NSASCIIStringEncoding];
        NSNumber* timeoutAsVal = [[NSNumber alloc] initWithInt:timeout];
        [subscriptions setObject:timeoutAsVal forKey:ssidAsKey];
        return YES;
    }
    else
    {
        NSError* temp = [[NSError alloc] initWithUPnPError:ret];
        self.lastError = temp;
        return NO;
    }
}



#pragma UPnPDevice callback
-(void) upnpDeviceDidFinishParsing:(UPnPDevice*) upnpDevice
{
   // NSLog(@"%@ Finish parsing.", upnpDevice.UDN);
    UPnPDevice* upnpDeviceRet = upnpDevice;
    [delegate upnpDeviceDidAdd:upnpDeviceRet];
}

-(void) upnpDeviceDidReceiveError:(UPnPDevice*)  withError:(NSError*) error;
{
    
}

-(void) eventParser:(EventParser*) parser didFinishWithResult:(NSDictionary*) varValues
{
    
}

-(void) dealloc
{
    NSLog(@"UPnPControlPoint dealloc.");
    dispatch_release(eventHandlerQueue);
}
@end
