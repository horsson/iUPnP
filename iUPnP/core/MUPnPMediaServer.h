//
//  UPnPMediaServer.h
//  UPnP Player HD/Users/hh/Library/Application Support/iPhone Simulator
//
//  Created by Hao Hu on 26.10.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//


#import "MUPnPDevice.h"
#import "DidlResult.h"
#import "SearchCriteria.h"

/**************************************************
 Music
 *************************************************/
#define DEFAULT_MEDIA_SERVER_FILTER_FOR_MUSIC @"dc:title,upnp:genre,upnp:album,upnp:albumArtURI,upnp:class,upnp:artist@role,upnp:artist,res@duration"

/**************************************************
 Picture  does NOT need genre, artist, duration.
 *************************************************/
#define DEFAULT_MEDIA_SERVER_FILTER_FOR_PICTURE @"dc:title,dc:date,upnp:album,upnp:albumArtURI,upnp:class,res@resolution"

/**************************************************
 Video 
 *************************************************/
#define DEFAULT_MEDIA_SERVER_FILTER_FOR_VIDEO @"dc:title,dc:date,upnp:album,upnp:albumArtURI,upnp:class,res@duration,res@protocolInfo,res@resolution"


//Callback block for the Browse
/*************************
 Parameters:
 1. If success.
 2. MediaObjects
 3. numberReturned
 4. totalMaches
 5. Error
 ************************/
typedef void (^MediaServer_browse_blk)(BOOL, NSArray*, NSInteger, NSInteger, NSError**);


extern NSString* const kBrowserFlagMetaData;
extern NSString* const kBrowserFlagDirectChildren;

@class MUPnPControlPoint;
@class MUPnPMediaServer;

@protocol UPnPMediaServerDelegate <NSObject>

-(void) upnpMediaServer:(MUPnPMediaServer*) mediaServer
 didReceivedMediaObjects:(NSArray*) mediaObjects
               objectId:(NSString*) objectId
         numberReturned:(NSInteger) numberReturned 
            totalMaches:(NSInteger) totalMaches;

-(void) upnpMediaServerDidReceiveFail:(MUPnPMediaServer*) mediaServer;

@end

@interface MUPnPMediaServer : NSObject
{
    MUPnPControlPoint* _ctrlPoint;
    BOOL _isTested;
    BOOL _isAccessible;
}

/*
 It indicates if the media server is accessible by control point.
 */
@property(nonatomic) BOOL isAccessible;
@property(nonatomic,strong) MUPnPDevice* upnpDevice;
@property(nonatomic,weak) id<UPnPMediaServerDelegate> delegate;

-(BOOL) isSupportSearchWithKeyword:(NSString*) keyword;

-(id) initWithUPnPDevice:(MUPnPDevice*) device;

-(void) browseWithObjectId:(NSString*) objectId 
                browseFlag:(NSString*) flag 
                    filter:(NSString*) filter
                startIndex:(NSInteger) startIndex
              requestCount:(NSInteger) count 
              sortCriteria:(NSString*) sort
                    isSerialQueue:(BOOL) isSerialQueue;

-(DidlResult*) syncBrowseWithObjectId:(NSString*) objectId 
                           browseFlag:(NSString*) flag 
                               filter:(NSString*) filter
                           startIndex:(NSInteger) startIndex
                         requestCount:(NSInteger) count 
                         sortCriteria:(NSString*) sort
                                error:(NSError**) error;

-(void) browseWithObjectId:(NSString*) objectId 
                browseFlag:(NSString*) flag 
                    filter:(NSString*) filter
                startIndex:(NSInteger) startIndex
              requestCount:(NSInteger) count 
              sortCriteria:(NSString*) sort
                     block:(MediaServer_browse_blk) cb_block
                    isSerialQueue:(BOOL) isSerialQueue;

-(void) searchContainerId:(NSString*) containerId 
           searchCriteria:(SearchCriteria*) searchCriteria 
                   filter:(NSString*) filter 
            startingIndex:(NSInteger) startingIndex 
             requestCount:(NSInteger) count  
             sortCriteria:(NSString*) sort;

-(DidlResult*) syncSearchContainerId:(NSString*) containerId 
               searchCriteria:(SearchCriteria*) searchCriteria 
                       filter:(NSString*) filter 
                startingIndex:(NSInteger) startingIndex 
                 requestCount:(NSInteger) count  
                 sortCriteria:(NSString*) sort
                error:(NSError**) error;

-(NSString*) syncBrowseMetadataWithObjectId:(NSString*) objectId;
-(NSArray*) getSearchCapabilities:(NSError**) err;

@end
