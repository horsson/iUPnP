//
//  UPnPAction.h
//  iUPnPTestPrj
//
//  Created by Hao Hu on 29.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "upnp.h"
#import "MUPnPArgument.h"
#import "ixml.h"
#include "upnptools.h"

#define UPNP_ACTION_MAX_CONTENT_LENGTH 1024*1024*1024
@interface MUPnPAction : NSObject<NSXMLParserDelegate> {

    @private
    NSString* serviceType;
    NSString* controlURL;
    NSString* deviceUDN;
    NSMutableString* _contentStr;
}

@property(nonatomic,strong) NSString* name;
@property(nonatomic,strong) NSMutableArray* argumentList;
@property(nonatomic,assign) UpnpClient_Handle controlPointHandle;


-(MUPnPArgument*) getArgumentByName:(NSString*) argumentName;


-(void) setArgumentStringVal:(NSString*) val forName:(NSString*) argumentName;
-(void) setArgumentIntVal:(NSInteger) val forName:(NSString*) argumentName;
-(NSString*) getArgumentStringVal:(NSString*) argumentName;
-(NSInteger) getArgumentIntVal:(NSString*) argumentName;

-(void) setServiceType:(NSString*) newServiceType;
-(void) setControlURL:(NSString*) newControlURL;
-(void) setDeviceUDN:(NSString*) newDeviceUDN;

-(int) sendActionSync;

/*
 
 */
-(void) setMaxContentLength:(size_t) contentLength;

@end

