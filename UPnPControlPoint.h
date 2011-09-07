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
#import "UPnPDevice.h"



@protocol UPnPControlPointDelegate

@optional
-(void) searchDidTimeout;
-(void) errorDidReceive:    (NSError*) error;
-(void) upnpDeviceDidAdd:   (UPnPDevice*) upnpDevice;
-(void) upnpDeviceDidLeave: (UPnPDevice*) upnpDevice;
-(void) eventNotifyDidReceiveWithSSID:(NSString*) ssid 
                             eventKey:(NSUInteger) eventKey 
                              varName:(NSString*)varName 
                                value:(NSString*)value; 

@end

//One UPnPControlPoint is a cooresponding UPnP Client in libupnp.
@interface UPnPControlPoint : NSObject<UPnPDDeviceDelegate> {
    @private
    //It stores the subscriptions and manages automatically(renew).
    //The key is the ssid and the value is the timeout.
    NSMutableDictionary* subscriptions;
    
    dispatch_queue_t eventHandlerQueue;
}

@property(nonatomic,assign) id<UPnPControlPointDelegate> delegate;
@property(retain) NSMutableDictionary* devices;
@property(retain,readonly)  NSMutableSet* deviceIDSet;
@property(assign,readonly) UpnpClient_Handle clientHandle;
@property(nonatomic, retain)   NSError* lastError;

-(id) initWithHostAddress:(NSString*) address andPort:(UInt16) port;
-(void) searchTarget:(NSString*) target withMx:(NSUInteger) mx;
-(void) stop;

-(UPnPDevice*) getUPnPDeviceById:(NSString*) deviceID;

-(BOOL) subscribeService:(UPnPService*) service;

-(BOOL) subscribeService:(UPnPService *)service withTimeout:(NSInteger) timeout;

-(dispatch_queue_t) eventHandlerQueue;

@end
