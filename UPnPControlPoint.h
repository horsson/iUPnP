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



@protocol UPnPControlPointDelegate <NSObject>

-(void) searchDidTimeout;
-(void) errorDidReceive:    (NSError*) error;
-(void) upnpDeviceDidAdd:   (UPnPDevice*) upnpDevice;
-(void) upnpDeviceDidLeave: (UPnPDevice*) upnpDevice; 

@end

//One UPnPControlPoint is a cooresponding UPnP Client in libupnp.
@interface UPnPControlPoint : NSObject<UPnPDDeviceDelegate> {
    @private
    //UPnP client handle, which is used in the entire Control Point life.
   // UpnpClient_Handle _clientHandle;
   // dispatch_queue_t _controlPointQueue;
    NSLock* _globalLock;  
}

@property(nonatomic,assign) id<UPnPControlPointDelegate> delegate;
@property(retain) NSMutableDictionary* devices;
@property(retain,readonly)  NSMutableSet* deviceIDSet;
@property(assign,readonly) UpnpClient_Handle clientHandle;
@property(nonatomic, retain)   NSError* lastError;

-(id) initWithHostAddress:(NSString*) address andPort:(UInt16) port;
-(void) searchTarget:(NSString*) target withMx:(NSUInteger) mx;
-(void) stop;
-(NSLock*) globalLock;

-(UPnPDevice*) getUPnPDeviceById:(NSString*) deviceID;

-(BOOL) subscribeService:(UPnPService*) service;

-(BOOL) subscribeService:(UPnPService *)service withTimeout:(NSInteger) timeout;

@end
