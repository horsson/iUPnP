//
//  MediaRes.m
//  iUPnP
//
//  Created by Hao Hu on 02.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MediaRes.h"
#import "NSString+Utils.h"

@implementation MediaRes
@synthesize size,resUrl,bitrate,duration,resolution,protocolInfo;

-(NSString*) relativeUrl
{
    
    return resUrl.relativeUrl;
    /*
    NSURL* url = [[NSURL alloc] initWithString:self.resUrl];
    NSInteger port = [url.port intValue];
    if (port == 0) {
        port = 80;
    }
    NSString* query = url.query;
    NSString* relativePath = url.relativePath;
    if (query) 
    {
        return [NSString stringWithFormat:@"%d%@?%@",port,relativePath,query];
    }
    else
    {
        return [NSString stringWithFormat:@"%d%@", port,relativePath];
    }
     */
}

 -(NSString*) description
 {
     NSString* desc = [NSString stringWithFormat:@"Width:%d, Height:%d, Size:%d", self.resolution.resolutionWidth, self.resolution.resolutionHeight, self.resolution.resolutionSize];
     return desc;
 }

@end

@implementation NSString(MediaRes)

-(NSInteger) resolutionWidth
{
    
    NSArray* comps = [self componentsSeparatedByString:@"x"];
    if ([comps count] != 2) {
        return 0;
    }
    else
    {
        return [[comps objectAtIndex:0] intValue];
    }
}

-(NSInteger) resolutionHeight
{
    NSArray* comps = [self componentsSeparatedByString:@"x"];
    if ([comps count] != 2) {
        return 0;
    }
    else
    {
        return [[comps objectAtIndex:1] intValue];
    }
}

-(NSInteger) resolutionSize
{
    return (self.resolutionHeight * self.resolutionWidth);
}



@end