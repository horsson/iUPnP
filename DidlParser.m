//
//  DidlParser.m
//  iUPnP
//
//  Created by Hao Hu on 02.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DidlParser.h"

@interface DidlParser()
-(void) freeString:(NSString*) string;

@end;

@implementation DidlParser


-(id) initWithData:(NSData *)data
{
    self = [super init];
    if (self)
    {
        _parser = [[NSXMLParser alloc] initWithData:data];
        [_parser setDelegate:self];
        _mediaObjects = [[NSMutableArray alloc] init];
        
    }
    return self;
}

-(BOOL) parse
{
    return [_parser parse];
}

-(void) freeString:(NSString*) string
{
    [string release];
    string = nil;
}

-(NSArray*) mediaObjects
{
    return [_mediaObjects autorelease];
}

- (void)dealloc {
    [_mediaObjects release];
    [_parser release];
    [super dealloc];
}



#pragma NSXMLParserDelegate
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
    if ([@"container" isEqualToString:elementName]) {
        _mediaContainer = [[MediaContainer alloc] init];
        _mediaContainer.ID = [attributeDict objectForKey:@"id"];
        _mediaContainer.parentID = [attributeDict objectForKey:@"parentID"];
        _mediaContainer.neverPlayable = [[attributeDict objectForKey:@"neverPlayable"] unsignedIntValue];
        _mediaContainer.restricted = [[attributeDict objectForKey:@"restricted"] unsignedIntValue];
        _mediaContainer.childCount = [[attributeDict objectForKey:@"childCount"] unsignedIntValue];
        _currentTag = _mediaContainer;
    }
    else if ([@"item" isEqualToString:elementName])
    {
        _mediaItem = [[MediaItem alloc] init];
        _mediaItem.ID = [attributeDict objectForKey:@"id"];
        _mediaItem.parentID = [attributeDict objectForKey:@"parentID"];
        _mediaItem.refID = [attributeDict objectForKey:@"refID"];
        _mediaItem.neverPlayable = [[attributeDict objectForKey:@"neverPlayable"] unsignedIntValue];
        _mediaItem.restricted = [[attributeDict objectForKey:@"restricted"] unsignedIntValue];
        _currentTag = _mediaItem;

    } else if ([@"res" isEqualToString:elementName])
    
    {
        _res = [[MediaRes alloc] init];
        _res.duration = [attributeDict objectForKey:@"duration"];
        _res.size = [[attributeDict objectForKey:@"size"] unsignedLongLongValue];
        _res.protocolInfo = [attributeDict objectForKey:@"protocolInfo"];
        _res.bitrate = [[attributeDict objectForKey:@"bitrate"] unsignedIntValue];
        _res.resolution = [attributeDict objectForKey:@"resolution"];
    }
    
    else if ([@"upnp:searchClass" isEqualToString:elementName])
    {
        if (_currentTag.searchClassList == nil)
        {
            NSMutableArray* array = [[NSMutableArray alloc] init];
            _currentTag.searchClassList = array;
            [array release];
        }
    }
    else if ([@"upnp:createClass" isEqualToString:elementName])
    {
        if (_currentTag.createClassList == nil) {
            NSMutableArray* array = [[NSMutableArray alloc] init];
            _currentTag.createClassList = array;
            [array release];
        }
    }
    else if ([@"upnp:writeStatus" isEqualToString:elementName])
    {
        if(_currentTag.writeStatusList == nil)
        {
            NSMutableArray* array = [[NSMutableArray alloc] init];
            _currentTag.writeStatusList = array;
            [array release];
        }
        
    }
    else if ([@"upnp:artist" isEqualToString:elementName])
    {
        if (_currentTag.artistList == nil) {
            NSMutableArray* array = [[NSMutableArray alloc] init];
            _currentTag.artistList = array;
            [array release];
        }
    }
    else if ([@"upnp:actor" isEqualToString:elementName])
    {
        if(_currentTag.actorList == nil)
        {
            NSMutableArray* array = [[NSMutableArray alloc] init];
            _currentTag.actorList = array;
            [array release];

        }
    }
    else if ([@"upnp:author" isEqualToString:elementName])
    {
        if (_currentTag.authorList == nil) 
        {
            NSMutableArray* array = [[NSMutableArray alloc] init];
            _currentTag.authorList = array;
            [array release];
        }
    }
    else if ([@"upnp:producer" isEqualToString:elementName])
    {

    }
    else if ([@"upnp:director" isEqualToString:elementName])
    {
        if (_currentTag.directorList == nil)
        {
            NSMutableArray* array = [[NSMutableArray alloc] init];
            _currentTag.directorList = array;
            [array release];
        }
    }
    else if ([@"upnp:genre" isEqualToString:elementName])
    {
        if (_currentTag.genreList == nil)
        {
            NSMutableArray* array = [[NSMutableArray alloc] init];
            _currentTag.genreList = array;
            [array release];
        }
    }
    else if ([@"upnp:playlist" isEqualToString:elementName])
    {
        
        if (_currentTag.playlistList == nil)
        {
            NSMutableArray* array = [[NSMutableArray alloc] init];
            _currentTag.playlistList = array;
            [array release];
        }

    }
    else if ([@"upnp:albumArtURI" isEqualToString:elementName])
    {
        if (_currentTag.albumArtURIList) {
            NSMutableArray* array = [[NSMutableArray alloc] init];
            _currentTag.albumArtURIList = array;
            [array release];
        }

    }
    else if ([@"upnp:album" isEqualToString:elementName])
    {
        if (_currentTag.albumList) {
            NSMutableArray* array = [[NSMutableArray alloc] init];
            _currentTag.albumList = array;
            [array release];
        }
    }

    _currentString = [[NSMutableString alloc] init];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([@"container" isEqualToString:elementName])
    {
        [_mediaObjects addObject:_mediaContainer];
        [_mediaContainer release];
        _mediaContainer = nil;
        _currentTag = nil;
    }
    else if ([@"item" isEqualToString:elementName])
    {
        [_mediaObjects addObject:_mediaItem];
        [_mediaItem release];
        _mediaItem = nil;
        _currentTag = nil;
    }
    else if ([@"upnp:searchClass" isEqualToString:elementName])
    {
        ObjectClass* oc = [[ObjectClass alloc] initWithString:_currentString];
        [self freeString:_currentString];
        [_currentTag.searchClassList addObject:oc];
        [oc release];
    }
    else if ([@"upnp:createClass" isEqualToString:elementName])
    {
        ObjectClass* oc = [[ObjectClass alloc] initWithString:_currentString];
        [self freeString:_currentString];
        [_currentTag.createClassList addObject:oc];
        [oc release];
    }
    
    else if ([@"upnp:class" isEqualToString:elementName])
    {
        ObjectClass* oc = [[ObjectClass alloc] initWithString:_currentString];
       [self freeString:_currentString];
        _currentTag.clazz = oc;
        [oc release];
    }
    else if ([@"res" isEqualToString:elementName])
    {
        _res.resUrl = _currentString;
        [self freeString:_currentString];    
    }
    else if ([@"upnp:writeStatus" isEqualToString:elementName])
    {
        [_currentTag.writeStatusList addObject:_currentString];
        [self freeString:_currentString];
    }
    else if ([@"upnp:originalTrackNumber" isEqualToString:elementName])
    {
        _currentTag.originalTrackNumber = [_currentString intValue];
        [self freeString:_currentString];
    }
    else if ([@"upnp:artist" isEqualToString:elementName])
    {
        [_currentTag.artistList addObject:_currentString];
        [self freeString:_currentString];
    }
    else if ([@"upnp:actor" isEqualToString:elementName])
    {
        [_currentTag.actorList addObject:_currentString];
        [self freeString:_currentString];
    }
    else if ([@"upnp:author" isEqualToString:elementName])
    {
        [_currentTag.authorList addObject:_currentString];
        [self freeString:_currentString];
    }
    else if ([@"upnp:director" isEqualToString:elementName])
    {
        [_currentTag.directorList addObject:_currentString];
        [self freeString:_currentString];
    }
    else if ([@"upnp:genre" isEqualToString:elementName])
    {
        [_currentTag.genreList addObject:_currentString];
        [self freeString:_currentString];
    }
    else if ([@"upnp:playlist" isEqualToString:elementName])
    {
        [_currentTag.playlistList addObject:_currentString];
        [self freeString:_currentString];
    }
    else if ([@"upnp:albumArtURI" isEqualToString:elementName])
    {
        [_currentTag.albumArtURIList addObject:_currentString];
        [self freeString:_currentString];
    }
    else if ([@"upnp:album" isEqualToString:elementName])
    {
        [_currentTag.albumList addObject:_currentString];
        [self freeString:_currentString];
    }

    
    // double check _contentString
    if (_currentString)
    {
        [_currentString release];
        _currentString = nil;
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    [_currentString appendString:string];
}

@end
