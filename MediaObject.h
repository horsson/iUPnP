//
//  MediaObject.h
//  iUPnP
//
//  Created by Hao Hu on 02.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ObjectClass.h"

@interface MediaObject : NSObject {
    
}
//id
@property(nonatomic,copy)   NSString* ID;
//parentID
@property(nonatomic,copy)   NSString* parentID;
//restricted
@property(nonatomic,assign) NSUInteger restricted;
//neverPlayable
@property(nonatomic,assign) NSUInteger neverPlayable;
//dc:title
@property(nonatomic,copy)   NSString* title;
//didl-lite:res
@property(nonatomic,retain) NSMutableArray* resList;
//upnp:class
@property(nonatomic,retain) ObjectClass* clazz;
//createClass, a list of ObjectClass
@property(nonatomic,retain) NSMutableArray* createClassList;
//searchClass, a list of ObjectClass
@property(nonatomic,retain) NSMutableArray* searchClassList;
//writeStatus
//writeStatus is an enum, it can be WRITABLE,PROTECTED,NOT_WRITABLE,UNKNOWN,MIXED
@property(nonatomic,retain) NSMutableArray* writeStatusList;
//artist(It should be personWithRole type)
@property(nonatomic,retain) NSMutableArray* artistList;
//actor(It should be personWithRole type)
@property(nonatomic,retain) NSMutableArray* actorList;
//author(It should be personWithRole type)
@property(nonatomic,retain) NSMutableArray* authorList;
//director
@property(nonatomic,retain) NSMutableArray* directorList;
//genre
@property(nonatomic,retain) NSMutableArray* genreList;
//playList
@property(nonatomic,retain) NSMutableArray* playlistList;
//albumArtURI
@property(nonatomic,retain) NSMutableArray* albumArtURIList;
//originalTrackNumber
@property(nonatomic,assign)   NSUInteger originalTrackNumber;
//creator
@property(nonatomic,copy)   NSString* creator;
//upnp:albuma
@property(nonatomic,copy)   NSMutableArray* albumList;
-(BOOL) isContainer;
@end
