//
//  MediaItem.m
//  iUPnP
//
//  Created by Hao Hu on 02.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MediaItem.h"


@implementation MediaItem
@synthesize metadata,refID;


-(void) releaseMetadata
{
    
    [metadata release];
    metadata = nil;
}

- (void)dealloc {
    
    [refID release];
    if (metadata)
    {
        [metadata release];
        metadata = nil;
    }
    [super dealloc];
}

@end
