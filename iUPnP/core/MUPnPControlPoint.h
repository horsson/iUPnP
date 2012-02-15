//
//  UPnPControlPoint.h
//  iUPnPTestPrj
//
//  Created by Hao Hu on 26.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "upnp.h"
#import "NSError+UPnP.h"
#import "MUPnPDevice.h"

/*========================================================================
 Notification const
 =========================================================================*/
extern NSString* const kDeviceDidAddEvent;
extern NSString* const kDeviceDidLeaveEvent;
extern NSString* const kSearchDidTimeout;
extern NSString* const kEventNotifyDidReceiveWithSSID;
extern NSString* const kUPnPDeviceKey;
extern NSString* const kSSID;
extern NSString* const kEventKey;
extern NSString* const kVarName;
extern NSString* const kValue;

@class MSubscription;
@protocol UPnPControlPointDelegate <NSObject>

@optional
-(void) searchDidTimeout;
-(void) errorDidReceive:    (NSError*) error;
-(void) upnpDeviceDidAdd:   (MUPnPDevice*) upnpDevice;
-(void) upnpDeviceDidLeave: (MUPnPDevice*) upnpDevice;
-(void) eventNotifyDidReceiveWithSSID:(NSString*) ssid 
                             eventKey:(NSUInteger) eventKey 
                              varName:(NSString*)varName 
                                value:(NSString*)value; 

@end

//One UPnPControlPoint is a cooresponding UPnP Client in libupnp.
@interface MUPnPControlPoint : NSObject<UPnPDDeviceDelegate> {
    @private
    //It stores the subscriptions and manages automatically(renew).
    //The key is the ssid and the value is the timeout.
    NSMutableDictionary* subscriptions;
    NSNotificationCenter* _nc;
    __weak id<UPnPControlPointDelegate> _delegate;
    
    @public
    dispatch_queue_t eventHandlerQueue;
    dispatch_queue_t discoveryQueue;
    dispatch_queue_t deviceParseQueue;
    dispatch_queue_t actionQueue;
}

@property(nonatomic,weak) id<UPnPControlPointDelegate> delegate;
@property(strong) NSMutableDictionary* devices;
@property(strong,readonly)  NSMutableSet* deviceIDSet;
@property(assign,readonly) UpnpClient_Handle clientHandle;
@property(nonatomic, strong)   NSError* lastError;

-(id) initWithHostAddress:(NSString*) address andPort:(UInt16) port;
-(void) searchTarget:(NSString*) target withMx:(NSUInteger) mx;
-(void) stop;
-(void) refresh:(NSString*) target withMx:(NSUInteger) mx;



-(MUPnPDevice*) getUPnPDeviceById:(NSString*) deviceID;
//Subscribe should be invoked once, otherwise the subscriber will receive more times.
-(MSubscription*) subscribeService:(MUPnPService*) service;
-(MSubscription*) subscribeService:(MUPnPService *)service withTimeout:(NSInteger) timeout;
-(BOOL) unSubscribe:(MSubscription*) subscription;


-(dispatch_queue_t) eventHandlerQueue;
-(dispatch_queue_t) discoveryQueue;
-(dispatch_queue_t) deviceParseQueue;

+(id) sharedUPnPControlPoint;
@end
