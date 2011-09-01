//
//  UPnPAction.h
//  iUPnPTestPrj
//
//  Created by Hao Hu on 29.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "upnp.h"
#import "UPnPArgument.h"
#import "ixml.h"
#include "upnptools.h"


@interface UPnPAction : NSObject {

    @private
    NSString* serviceType;
    NSString* controlURL;
    NSString* deviceUDN;
}

@property(nonatomic,copy) NSString* name;
@property(nonatomic,retain) NSMutableArray* argumentList;
@property(nonatomic,assign) UpnpClient_Handle controlPointHandle;


-(UPnPArgument*) getArgumentByName:(NSString*) argumentName;

-(void) setArgumentStringVal:(NSString*) val forName:(NSString*) argumentName;
//-(void) setArgumentIntVal:(NSInteger) val forName:(NSString*) argumentName;
//-(void) setArgumentUIntVal:(NSUInteger) val forName:(NSString*) argumentName;
-(void) getArgumentStringVal:(NSString*) argumentName;

-(void) setServiceType:(NSString*) newServiceType;
-(void) setControlURL:(NSString*) newControlURL;
-(void) setDeviceUDN:(NSString*) newDeviceUDN;

-(int) sendActionSync;



@end

