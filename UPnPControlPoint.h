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

-(void) errorDidReceived:(NSError*) error;


@end

//One UPnPControlPoint is a cooresponding UPnP Client in libupnp.
@interface UPnPControlPoint : NSObject {
    @private
    //UPnP client handle, which is used in the entire Control Point life.
    UpnpClient_Handle _clientHandle;

    NSLock* _globalLock;

}

@property(nonatomic,retain) id<UPnPControlPointDelegate> delegate;

//All the devices found in the LAN, key is the Device_id.
@property(retain) NSMutableDictionary* devices;


-(id) initWithHostAddress:(NSString*) address andPort:(UInt16) port;

-(void) searchTarget:(NSString*) target withMx:(NSUInteger) mx;

-(void) stop;


-(NSMutableDictionary*) getDevices;
-(NSLock*) getGlobalLock;

@end
