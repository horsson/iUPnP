//
//  NSError+UPnP.m
//  iUPnPTestPrj
//
//  Created by Hao Hu on 26.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSError+UPnP.h"


@implementation NSError (NSError_UPnP)

-(id) initWithUPnPError:(int) errorCode
{
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] initWithCapacity:2];
    
    const char* errMsg =UpnpGetErrorMessage(errorCode); 
    
    NSString * errDesc = [[NSString alloc] initWithBytes:errMsg length:strlen(errMsg) encoding:NSUTF8StringEncoding];
    [userInfo setObject:errDesc forKey:NSLocalizedDescriptionKey];
    self = [self initWithDomain:@"UPnP_Domain" code:errorCode userInfo:userInfo];
    return self;
}
@end
