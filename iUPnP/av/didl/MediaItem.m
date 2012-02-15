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
    
    metadata = nil;
}



@end
