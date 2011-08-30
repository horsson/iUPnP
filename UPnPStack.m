//
//  UPnPStack.m
//  iUPnPTestPrj
//
//  Created by Hao Hu on 26.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UPnPStack.h"


@implementation UPnPStack

+(id) sharedUPnPStack
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

-(NSTimeInterval) defaultTimeoutForXmlParsing
{
    return  3.0;
}
@end
