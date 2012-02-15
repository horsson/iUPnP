//
//  DidlParser.h
//  iUPnP
//
//  Created by Hao Hu on 02.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MediaContainer.h"
#import "MediaObject.h"
#import "MediaItem.h"
#import "MediaRes.h"
@class UPnPArtist;
@interface DidlParser : NSObject<NSXMLParserDelegate> {
    @private
    NSXMLParser* _parser;
    MediaItem* _mediaItem;
    MediaContainer* _mediaContainer;
    MediaObject* _currentTag;
    NSMutableString *_currentString;
    NSMutableArray* _mediaObjects;
    MediaRes*       _res;
    UPnPArtist* _currentUpnpArtist;
}
-(id) initWithData:(NSData *)data;
-(id) initWithString:(NSString*) xmlString;

-(BOOL) parse;

-(NSArray*) mediaObjects;
@end
