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

#include "upnptools.h"
@class UPnPService;

@interface UPnPAction : NSObject {

}

@property(nonatomic,retain) NSString* name;
@property(nonatomic,retain) NSMutableArray* argumentList;
@property(nonatomic,assign) UpnpClient_Handle controlPointHandle;
@property(nonatomic,retain) UPnPService* parentService;

-(UPnPArgument*) getArgumentByName:(NSString*) argumentName;

-(void) setArgumentStringVal:(NSString*) val forName:(NSString*) argumentName;
-(void) setArgumentIntVal:(NSInteger) val forName:(NSString*) argumentName;
-(void) setArgumentUIntVal:(NSUInteger) val forName:(NSString*) argumentName;
-(void) getArgumentStringVal:(NSString*) argumentName;

-(int) sendActionSync;



@end
