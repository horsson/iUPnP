//
//  MediaObject.h
//  iUPnP
//
//  Created by Hao Hu on 02.09.11.
//  strongright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ObjectClass.h"

//#define DIDL_LITE
//#define DIDL_FULL

extern  NSString* const kArtistRoleAlbumArtist;
extern  NSString* const kArtistRolePerformer;
extern  NSString* const kArtistRoleComposer;
@class MediaRes;
@interface MediaObject : NSObject {
    
}
//id
@property(nonatomic,copy)       NSString* ID;
//parentID
@property(nonatomic,copy)       NSString* parentID;
//dc:title
@property(nonatomic,copy)       NSString* title;
//dc:date
@property(nonatomic,copy)       NSString* date;
//didl-lite:res
@property(nonatomic,strong)     NSMutableArray* resList;
//upnp:class
@property(nonatomic,strong)     ObjectClass* objectClazz;
//genre
@property(nonatomic,strong)     NSMutableArray* genreList;
//artist(It should be personWithRole type)
@property(nonatomic,strong)     NSMutableArray* artistList;
//upnp:album
@property(nonatomic,strong)     NSMutableArray* albumList;
//albumArtURI
@property(nonatomic,strong)     NSMutableArray* albumArtURIList;

#ifdef DIDL_FULL
//createClass, a list of ObjectClass
@property(nonatomic,strong) NSMutableArray* createClassList;
//searchClass, a list of ObjectClass
@property(nonatomic,strong) NSMutableArray* searchClassList;
//writeStatus
//writeStatus is an enum, it can be WRITABLE,PROTECTED,NOT_WRITABLE,UNKNOWN,MIXED
@property(nonatomic,strong) NSMutableArray* writeStatusList;
//restricted
@property(nonatomic,assign) NSUInteger restricted;
//neverPlayable
@property(nonatomic,assign) NSUInteger neverPlayable;
//actor(It should be personWithRole type)
@property(nonatomic,strong) NSMutableArray* actorList;
//author(It should be personWithRole type)
@property(nonatomic,strong) NSMutableArray* authorList;
//director
@property(nonatomic,strong) NSMutableArray* directorList;
//playList
@property(nonatomic,strong) NSMutableArray* playlistList;

//originalTrackNumber
@property(nonatomic,assign)   NSUInteger originalTrackNumber;
//creator
@property(nonatomic,copy)   NSString* creator;
#endif


-(BOOL) isContainer;

-(NSString*) artistNameForRole:(NSString*) role;

-(MediaRes*) bestMediaRes;
-(MediaRes*) minMediaRes;

@end

@interface NSDate (UPnP)
-(id) initWithUPnPDateString:(NSString*) dateString;
@end
