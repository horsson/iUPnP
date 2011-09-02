//
//  NSError+UPnP.h
//  iUPnPTestPrj
//
//  Created by Hao Hu on 26.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "upnp.h"
#import "upnptools.h"

@interface NSError (NSError_UPnP)

-(id) initWithUPnPError:(int) errorCode;
@end
