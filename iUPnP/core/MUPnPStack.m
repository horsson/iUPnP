//
//  UPnPStack.m
//  iUPnPTestPrj
//
//  Created by Hao Hu on 26.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MUPnPStack.h"


@implementation MUPnPStack

+(id) sharedUPnPStack
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
        /*
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        app_doc_path = [documentsDirectory cStringUsingEncoding:NSASCIIStringEncoding];
         */
        
    });

    
    return _sharedObject;
}

-(NSTimeInterval) defaultTimeoutForXmlParsing
{
    return  5.0;
}


-(NSString*) documentPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
}
@end
