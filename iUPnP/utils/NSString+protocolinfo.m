//
//  NSString+protocolinfo.m
//  UPnP Player HD
//
//  Created by Hao Hu on 16.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSString+protocolinfo.h"

@implementation NSString (protocolinfo)

-(NSString*) componentForPos:(NSUInteger) pos
{
    NSArray* comps = [self componentsSeparatedByString:@":"];
    if (comps.count != 4) {
        return nil;
    }
    else
    {
        return [comps objectAtIndex:pos];
    }
}

-(NSString*) protocolForProtocolInfo
{
    return [self componentForPos:0];
}
-(NSString*) networkForProtocolInfo
{
    return [self componentForPos:1];
}
-(NSString*) contentFormatForProtocolInfo
{
    return [self componentForPos:2];
}
-(NSString*) additionalInfoForProtocolInfo
{
    return [self componentForPos:3];
}
@end
