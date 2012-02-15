//
//  MediaObject.m
//  iUPnP
//
//  Created by Hao Hu on 02.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MediaObject.h"
#import "MediaContainer.h"
#import "UPnPArtist.h"
#import "MediaRes.h"
#import "ObjectClass.h"
#import "NSString+Utils.h"
#import "NSString+protocolinfo.h"

 NSString* const kArtistRoleAlbumArtist = @"AlbumArtist";
 NSString* const kArtistRolePerformer = @"Performer";
 NSString* const kArtistRoleComposer = @"Composer";

@implementation MediaObject
@synthesize ID,title,parentID,objectClazz,resList,albumList,genreList,artistList,albumArtURIList,date

#ifdef DIDL_FULL
,restricted,neverPlayable,creator,actorList,
authorList,directorList,playlistList,createClassList,
searchClassList,writeStatusList,originalTrackNumber
#endif

;

-(BOOL) isContainer
{
    if ([self isKindOfClass:[MediaContainer class]])
    {
        return YES;
    }
    else
        return NO;
}

-(NSString*) artistNameForRole:(NSString*) role
{
    if (artistList.count == 1) {
        UPnPArtist* anArtist = [artistList lastObject];
        return anArtist.name;
    }
    
    
    for (UPnPArtist* anArtist in artistList) {
        if ([anArtist.role isEqualToString:role]) {
            return anArtist.name;
        }
    }
    
    return nil;
}

-(MediaRes*) bestMediaRes
{
    MediaRes* res = nil;
    if (objectClazz.isImageItem) 
    {
        NSInteger maxSize = -1;
        for (MediaRes* aMediaRes in resList) 
        {
            if (aMediaRes.resolution.resolutionSize > maxSize) 
            {
                maxSize = aMediaRes.resolution.resolutionSize;
                res = aMediaRes;
            }
        }
    }
    else if (objectClazz.isAudioItem) 
    {
        //Find out the mpeg and http as the resource.
        for (MediaRes* aMediaRes in resList) 
        {
            if ([aMediaRes.protocolInfo.protocolForProtocolInfo isEqualToString:@"http-get"] && [aMediaRes.protocolInfo.contentFormatForProtocolInfo isEqualToString:@"audio/mpeg"]) {
                res  = aMediaRes;
            }
        }
        if (res == nil)
            res = [resList lastObject];
    }
    else if (objectClazz.isVideoItem) 
    {
        NSInteger maxSize = -1;
        for (MediaRes* aMediaRes in resList) 
        {
            if([aMediaRes.protocolInfo isContainsSubString:@"video"])
            {
                if (aMediaRes.resolution.resolutionSize > maxSize) 
                {
                    res = aMediaRes;
                    maxSize = aMediaRes.resolution.resolutionSize;
                }
            }
        }
    }
    return res;
}

-(MediaRes*) minMediaRes
{
    MediaRes* minMediaRes = nil;
    NSUInteger minSize = NSUIntegerMax;
    for (MediaRes* aMediaRes in resList) 
    {
        if (aMediaRes.resolution.resolutionSize < minSize) {
            minSize = aMediaRes.resolution.resolutionSize;
            minMediaRes = aMediaRes;
        }
    }
    
    return minMediaRes;
}

@end


@implementation NSDate (UPnP)
-(id) initWithUPnPDateString:(NSString*) dateString
{
    NSRange range = [dateString rangeOfString:@"T"];
    if (range.location != NSNotFound) 
    {
        dateString = [dateString substringToIndex:range.location];
    }
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    self = [dateFormatter dateFromString:dateString];
    return self;
}
@end
