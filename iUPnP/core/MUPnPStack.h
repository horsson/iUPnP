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
extern const char* app_doc_path;
@interface MUPnPStack : NSObject {
    
}

+(id) sharedUPnPStack;

-(NSTimeInterval) defaultTimeoutForXmlParsing;

-(NSString*) documentPath;
@end
