//
//  MediaRes.m
//  iUPnP
//
//  Created by Hao Hu on 02.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MediaRes.h"


@implementation MediaRes
@synthesize size,resUrl,bitrate,duration,resolution,protocolInfo;

- (void)dealloc {
    [resUrl release];
    [duration release];
    [resolution release];
    [protocolInfo release];
    [super dealloc];
}
@end
