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
@property(nonatomic,strong) NSMutableArray* resList;
//upnp:class
@property(nonatomic,strong) ObjectClass* clazz;
//createClass, a list of ObjectClass
@property(nonatomic,strong) NSMutableArray* createClassList;
//searchClass, a list of ObjectClass
@property(nonatomic,strong) NSMutableArray* searchClassList;
//writeStatus
//writeStatus is an enum, it can be WRITABLE,PROTECTED,NOT_WRITABLE,UNKNOWN,MIXED
@property(nonatomic,strong) NSMutableArray* writeStatusList;
//artist(It should be personWithRole type)
@property(nonatomic,strong) NSMutableArray* artistList;
//actor(It should be personWithRole type)
@property(nonatomic,strong) NSMutableArray* actorList;
//author(It should be personWithRole type)
@property(nonatomic,strong) NSMutableArray* authorList;
//director
@property(nonatomic,strong) NSMutableArray* directorList;
//genre
@property(nonatomic,strong) NSMutableArray* genreList;
//playList
@property(nonatomic,strong) NSMutableArray* playlistList;
//albumArtURI
@property(nonatomic,strong) NSMutableArray* albumArtURIList;
//originalTrackNumber
@property(nonatomic,assign)   NSUInteger originalTrackNumber;
//creator
@property(nonatomic,copy)   NSString* creator;
//upnp:albuma
@property(nonatomic,copy)   NSMutableArray* albumList;
-(BOOL) isContainer;
@end
