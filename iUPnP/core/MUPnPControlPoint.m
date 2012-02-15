//
//  UPnPControlPoint.m
//  iUPnPTestPrj
//
//  Created by Hao Hu on 26.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MUPnPControlPoint.h"
#import "NSError+UPnP.h"
#import "EventParser.h"
#import "MSubscription.h"

//#define SHOW_VERBOSE

NSString* const kDeviceDidAddEvent = @"kDeviceDidAddEvent";
NSString* const kDeviceDidLeaveEvent =@"kDeviceDidLeaveEvent";
NSString* const kSearchDidTimeout = @"kSearchDidTimeout";
NSString* const kEventNotifyDidReceiveWithSSID =@"kEventNotifyDidReceiveWithSSID";
NSString* const kUPnPDeviceKey =@"kUPnPDeviceKey";
NSString* const kSSID =@"kSSID";
NSString* const kEventKey =@"kEventKey";
NSString* const kVarName =@"kVarName";
NSString* const kValue =@"kValue";


//==================================ControlPoint private methods=========================================
@interface MUPnPControlPoint() 
- (void)initUPnPStackWithPort:(UInt16)port address:(NSString *)address;
@end
//========================================================================================================

@implementation MUPnPControlPoint

@synthesize devices = _devices,deviceIDSet,clientHandle,lastError;



//Callback function for the client.
//=====================================Functions forward declaration=====================================
int upnp_callback_func(Upnp_EventType, void *, void *);
void handle_discovery_message(struct Upnp_Discovery *);
void handle_byebye_message(void*);
void handle_event_received(void*);
//=======================================================================================================
id refToSelf = nil;


+(id) sharedUPnPControlPoint
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}


-(void) setDelegate:(id<UPnPControlPointDelegate>)delegate
{
    NSLog(@"SetDelegate is %@.", NSStringFromClass([delegate class]));
    _delegate = delegate;
}

-(id<UPnPControlPointDelegate>) delegate
{
    return _delegate;
}

-(dispatch_queue_t) eventHandlerQueue
{
    return eventHandlerQueue;
}

-(dispatch_queue_t) discoveryQueue
{
    return discoveryQueue;
}

-(dispatch_queue_t) deviceParseQueue
{
    return deviceParseQueue;
}

-(void) fireErrorEvent:(int) upnpError
{
    NSError* error = [[NSError alloc] initWithUPnPError:upnpError];
    if ([_delegate respondsToSelector:@selector(errorDidReceive:)])
        [_delegate errorDidReceive:error];
}



-(MUPnPDevice*) getUPnPDeviceById:(NSString*) deviceID
{

    MUPnPDevice* deviceToReturn = [_devices objectForKey:deviceID];
    return deviceToReturn;
}

#pragma mark - Init the methods.
- (void)initUPnPStackWithPort:(UInt16)port address:(NSString *)address
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
}

- (id) init
{
    self = [super init];
    if (self)
    {
        refToSelf = self;
        self = [self initWithHostAddress:nil andPort:0];
        _nc = [NSNotificationCenter defaultCenter];
    }
    return self;
}

-(id) initWithHostAddress:(NSString *)address andPort:(UInt16)port
{
    self = [super init];
    refToSelf = self;
    if (self)
    {
        [self initUPnPStackWithPort:port address:address];
        
        //====================================Init some iVars===============================================
        _devices = [[NSMutableDictionary alloc] init];
        deviceIDSet = [[NSMutableSet alloc] init];
        subscriptions = [[NSMutableDictionary alloc] initWithCapacity:5];
        eventHandlerQueue = dispatch_queue_create("de.haohu.iupnp.eventhandler", NULL);
        discoveryQueue = dispatch_queue_create("de.haohu.iupnp.discovery", NULL);
        deviceParseQueue = dispatch_queue_create("de.haohu.iupnp.deviceparse", NULL);
        actionQueue = dispatch_queue_create("de.haohu.iupnp.action", NULL);
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
            struct Upnp_Discovery *discovery = (struct Upnp_Discovery*) event;
#ifdef SHOW_VERBOSE
            NSLog(@"ID :%s, Type: %s", discovery->DeviceId, discovery->DeviceType);
#endif
            handle_discovery_message(discovery);
            break;
        }
        case UPNP_DISCOVERY_SEARCH_TIMEOUT:
        {
            @autoreleasepool {
                
            
            if ([[refToSelf delegate] respondsToSelector:@selector(searchDidTimeout)])
                [[refToSelf delegate] searchDidTimeout];
            
            NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
            [nc postNotificationName:kSearchDidTimeout object:refToSelf userInfo:nil];
            }
            break;
        }
        case UPNP_DISCOVERY_ADVERTISEMENT_BYEBYE:
        {
            handle_byebye_message(event);           
            break;
        }
            
        case UPNP_EVENT_RECEIVED:
        {
            //NSLog(@"1st event rec!");
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
#pragma mark - Callback function different handle
void handle_discovery_message(struct Upnp_Discovery *discovery)
{
     //NSLog(@"Outside: LocationURL: %s", discovery->Location);
    dispatch_sync([refToSelf discoveryQueue], ^{
        @autoreleasepool 
        {
        NSString *deviceID = [[NSString alloc ] initWithCString:discovery->DeviceId encoding:NSASCIIStringEncoding];
        NSString* locationURL = [[NSString alloc] initWithCString:discovery->Location encoding:NSASCIIStringEncoding];
        //NSLog(@"Inside: LocationURL: %s", discovery->Location);
        //dispatch_queue_t queue =[refToSelf deviceParseQueue];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            @autoreleasepool 
            {
                if ([[refToSelf deviceIDSet] containsObject:deviceID])
                {
                    // NSLog(@"handle_discovery_message end In.Counter = %d",counter);
                    return;
                }
                else
                {
                    [[refToSelf deviceIDSet] addObject:deviceID];
                }
                
                MUPnPDevice *device = [[MUPnPDevice alloc] initWithLocationURL:locationURL timeout:4.0];
                device.controlPointHandle = [refToSelf clientHandle];
                device.UDN = deviceID;
                device.delegate = refToSelf;
                [[refToSelf devices] setObject:device forKey:device.UDN];
                
                [device startParsing];
            }
        });
    }
    });
}

void handle_byebye_message(void* event)
{

    dispatch_sync([refToSelf discoveryQueue], ^(void) {
        struct Upnp_Discovery* discovery = (struct Upnp_Discovery*) event;
        NSString* deviceId = [NSString stringWithCString:discovery->DeviceId encoding:NSASCIIStringEncoding];
        MUPnPDevice* upnpDevice = [[refToSelf devices] objectForKey:deviceId];
        [[refToSelf devices] removeObjectForKey:deviceId];
        [[refToSelf deviceIDSet] removeObject:deviceId];
        if ([[refToSelf delegate] respondsToSelector:@selector(upnpDeviceDidLeave:)])
            [[refToSelf delegate] upnpDeviceDidLeave:upnpDevice];
        NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
        [nc postNotificationName:kDeviceDidAddEvent object:refToSelf userInfo:[NSDictionary dictionaryWithObjectsAndKeys:upnpDevice,kUPnPDeviceKey,nil]];
    });
}

void handle_event_received(void* event)
{

    dispatch_sync([refToSelf eventHandlerQueue], ^(void) {
           @autoreleasepool {
               //NSLog(@"handle_event_received");
            struct Upnp_Event* upnpEvent = (struct Upnp_Event*) event;
            char* ssid = upnpEvent->Sid;
               //NSLog(@"SSID: %s", ssid);
            int eventKey = upnpEvent->EventKey;
            IXML_Document* doc = upnpEvent->ChangedVariables;
            NSString* strSSID = [NSString stringWithCString:ssid encoding:NSASCIIStringEncoding];
            NSString* xmlDocString = [[NSString alloc] initWithCString:ixmlDocumenttoString(doc) encoding:NSASCIIStringEncoding];
            EventParser* eventParser = [[EventParser alloc] initWithXMLString:xmlDocString];
            [eventParser parse];
            NSDictionary* varValueDict =eventParser.varValueDict;
            [varValueDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                if ([[refToSelf delegate] respondsToSelector:@selector(eventNotifyDidReceiveWithSSID:eventKey:varName:value:)])    
                {
                    [[refToSelf delegate] eventNotifyDidReceiveWithSSID:strSSID eventKey:eventKey varName:key value:obj];
                }

                NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
                [nc postNotificationName:kEventNotifyDidReceiveWithSSID object:refToSelf userInfo:[NSDictionary dictionaryWithObjectsAndKeys:strSSID,kSSID,[NSNumber numberWithInt:eventKey], kEventKey, key,kVarName, obj,kValue, nil]];
            }];
           }
    });
       
}
//================================================================================================================================

#pragma mark - Public methods
-(void) searchTarget:(NSString*) target withMx:(NSUInteger) mx
{
    [deviceIDSet removeAllObjects];
    [_devices removeAllObjects];
    UpnpSearchAsync(clientHandle, mx, [target cStringUsingEncoding:NSASCIIStringEncoding], NULL);
}

-(void) refresh:(NSString*) target withMx:(NSUInteger) mx
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


-(MSubscription*) subscribeService:(MUPnPService*) service
{
    return [self subscribeService:service withTimeout:UPNP_INFINITE];;
}

-(MSubscription*) subscribeService:(MUPnPService *)service withTimeout:(NSInteger) timeout
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
        MSubscription* subscription = [[MSubscription alloc] init];
        NSString* ssidAsKey = [[NSString alloc] initWithCString:ssid encoding:NSASCIIStringEncoding];

        subscription.ssid =ssidAsKey;
        subscription.timeout = timeout;
        subscription.timeStamp = [[NSDate date] timeIntervalSince1970];
        [subscriptions setObject:subscription forKey:ssidAsKey];
        return subscription;
    }
    else
    {
        NSError* temp = [[NSError alloc] initWithUPnPError:ret];
        self.lastError = temp;
        return nil;
    }
}

-(BOOL) unSubscribe:(MSubscription*) subscription
{
    const char* ssid = [subscription.ssid cStringUsingEncoding:NSASCIIStringEncoding];
    int ret = UpnpUnSubscribe(self.clientHandle, ssid);
    if (ret == UPNP_E_SUCCESS)
    {
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
-(void) upnpDeviceDidFinishParsing:(MUPnPDevice*) upnpDevice
{
   // NSLog(@"%@ Finish parsing.", upnpDevice.UDN);
    if ([_delegate respondsToSelector:@selector(upnpDeviceDidAdd:)])
        [_delegate upnpDeviceDidAdd:upnpDevice];
    [_nc postNotificationName:kDeviceDidAddEvent object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:upnpDevice,kUPnPDeviceKey, nil]];
}

-(void) upnpDeviceDidReceiveError:(MUPnPDevice*)  withError:(NSError*) error;
{
    
}

/*
-(void) eventParser:(EventParser*) parser didFinishWithResult:(NSDictionary*) varValues
{
    
}
 */

-(void) dealloc
{
    NSLog(@"UPnPControlPoint dealloc.");
    dispatch_release(eventHandlerQueue);
    dispatch_release(discoveryQueue);
    dispatch_release(deviceParseQueue);
    [self stop];
}
@end
