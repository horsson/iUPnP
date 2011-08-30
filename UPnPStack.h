//
//  UPnPStack.h
//  iUPnPTestPrj
//
//  Created by Hao Hu on 26.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#define IUPNP_OPTIONAL
#define IUPNP_REQUIRED
@interface UPnPStack : NSObject {
    
}

+(id) sharedUPnPStack;

-(NSTimeInterval) defaultTimeoutForXmlParsing;
@end
