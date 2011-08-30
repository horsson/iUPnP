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
    
    NSString * errDesc = nil;
    switch (errorCode) {
        case UPNP_E_INIT_FAILED:
            errDesc =@"";
            break;
        case UPNP_E_INIT:
            errDesc =@"";
            break;
        case UPNP_E_NETWORK_ERROR:
            errDesc =@"";
            break;
        case UPNP_E_SOCKET_WRITE:
            errDesc =@"";
            break;
        case UPNP_E_SOCKET_BIND:
            errDesc =@"";
            break;
            
        case UPNP_E_SOCKET_CONNECT:
            errDesc =@"";
            break;
        default:
            break;
    }
    
    [userInfo setObject:errDesc forKey:NSLocalizedDescriptionKey];
    
    self = [self initWithDomain:@"UPnP_Domain" code:errorCode userInfo:userInfo];
    return self;
}
@end
