//
//  MediaObject.m
//  iUPnP
//
//  Created by Hao Hu on 02.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MediaObject.h"
#import "MediaContainer.h"

@implementation MediaObject
@synthesize ID,title,parentID,restricted,neverPlayable,clazz,creator,resList,actorList,genreList,artistList,authorList,directorList,playlistList,albumArtURIList,createClassList,searchClassList,writeStatusList,originalTrackNumber,albumList;

-(BOOL) isContainer
{
    if ([self isKindOfClass:[MediaContainer class]])
    {
        return YES;
    }
    else
        return NO;
}

- (void)dealloc {
    [ID release];
    [title release];
    [parentID release];
    [clazz release];
    [createClassList release];
    [creator release];
    [resList release];
    [actorList release];
    [genreList release];
    [artistList release];
    [authorList release];
    [directorList release];
    [playlistList release];
    [albumArtURIList release];
    [searchClassList release];
    [writeStatusList release];
    [super dealloc];
}
@end
