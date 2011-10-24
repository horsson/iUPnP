//
//  DidlParser.m
//  iUPnP
//
//  Created by Hao Hu on 02.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DidlParser.h"



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

-(id) initWithString:(NSString*) xmlString
{
    self = [self initWithData:[xmlString dataUsingEncoding:NSUTF8StringEncoding]];
    return self;
}

-(BOOL) parse
{
    return [_parser parse];
}


-(NSArray*) mediaObjects
{
    return [_mediaObjects copy];
}




#pragma NSXMLParserDelegate

-(void) parserDidStartDocument:(NSXMLParser *)parser
{
    _currentString = [[NSMutableString alloc] init];
}

-(void) parserDidEndDocument:(NSXMLParser *)parser
{
    _currentString = nil;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
    if ([@"container" isEqualToString:elementName]) {
        _mediaContainer = [[MediaContainer alloc] init];
        _mediaContainer.ID = [attributeDict objectForKey:@"id"];
        _mediaContainer.parentID = [attributeDict objectForKey:@"parentID"];
        _mediaContainer.neverPlayable = [[attributeDict objectForKey:@"neverPlayable"] intValue];
        _mediaContainer.restricted = [[attributeDict objectForKey:@"restricted"] intValue];
        _mediaContainer.childCount = [[attributeDict objectForKey:@"childCount"] intValue];
        _currentTag = _mediaContainer;
    }
    else if ([@"item" isEqualToString:elementName])
    {
        _mediaItem = [[MediaItem alloc] init];
        _mediaItem.ID = [attributeDict objectForKey:@"id"];
        _mediaItem.parentID = [attributeDict objectForKey:@"parentID"];
        _mediaItem.refID = [attributeDict objectForKey:@"refID"];
        _mediaItem.neverPlayable = [[attributeDict objectForKey:@"neverPlayable"] intValue];
        
        _mediaItem.restricted = [[attributeDict objectForKey:@"restricted"] intValue];
        _currentTag = _mediaItem;

    } else if ([@"res" isEqualToString:elementName])
    
    {
        if (_currentTag.resList == nil) {
            NSMutableArray* array = [[NSMutableArray alloc] init];
            _currentTag.resList = array;
        }   
        _res = [[MediaRes alloc] init];
        _res.duration = [attributeDict objectForKey:@"duration"];
        _res.size = [[attributeDict objectForKey:@"size"] longLongValue];
        _res.protocolInfo = [attributeDict objectForKey:@"protocolInfo"];
        _res.bitrate = [[attributeDict objectForKey:@"bitrate"] intValue];
        _res.resolution = [attributeDict objectForKey:@"resolution"];
    }
    
    else if ([@"upnp:searchClass" isEqualToString:elementName])
    {
        if (_currentTag.searchClassList == nil)
        {
            NSMutableArray* array = [[NSMutableArray alloc] init];
            _currentTag.searchClassList = array;
        }
    }
    else if ([@"upnp:createClass" isEqualToString:elementName])
    {
        if (_currentTag.createClassList == nil) {
            NSMutableArray* array = [[NSMutableArray alloc] init];
            _currentTag.createClassList = array;
        }
    }
    else if ([@"upnp:writeStatus" isEqualToString:elementName])
    {
        if(_currentTag.writeStatusList == nil)
        {
            NSMutableArray* array = [[NSMutableArray alloc] init];
            _currentTag.writeStatusList = array;
        }
        
    }
    else if ([@"upnp:artist" isEqualToString:elementName])
    {
        if (_currentTag.artistList == nil) {
            NSMutableArray* array = [[NSMutableArray alloc] init];
            _currentTag.artistList = array;
        }
    }
    else if ([@"upnp:actor" isEqualToString:elementName])
    {
        if(_currentTag.actorList == nil)
        {
            NSMutableArray* array = [[NSMutableArray alloc] init];
            _currentTag.actorList = array;

        }
    }
    else if ([@"upnp:author" isEqualToString:elementName])
    {
        if (_currentTag.authorList == nil) 
        {
            NSMutableArray* array = [[NSMutableArray alloc] init];
            _currentTag.authorList = array;
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
        }
    }
    else if ([@"upnp:genre" isEqualToString:elementName])
    {
        if (_currentTag.genreList == nil)
        {
            NSMutableArray* array = [[NSMutableArray alloc] init];
            _currentTag.genreList = array;
        }
    }
    else if ([@"upnp:playlist" isEqualToString:elementName])
    {
        
        if (_currentTag.playlistList == nil)
        {
            NSMutableArray* array = [[NSMutableArray alloc] init];
            _currentTag.playlistList = array;
        }

    }
    else if ([@"upnp:albumArtURI" isEqualToString:elementName])
    {
        if (_currentTag.albumArtURIList) {
            NSMutableArray* array = [[NSMutableArray alloc] init];
            _currentTag.albumArtURIList = array;
        }

    }
    else if ([@"upnp:album" isEqualToString:elementName])
    {
        if (_currentTag.albumList) {
            NSMutableArray* array = [[NSMutableArray alloc] init];
            _currentTag.albumList = array;
        }
    }

    [_currentString setString:@""];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([@"container" isEqualToString:elementName])
    {
        [_mediaObjects addObject:_mediaContainer];
        _mediaContainer = nil;
        _currentTag = nil;
    }
    else if ([@"item" isEqualToString:elementName])
    {
        [_mediaObjects addObject:_mediaItem];
        _mediaItem = nil;
        _currentTag = nil;
    }
    else if ([@"upnp:searchClass" isEqualToString:elementName])
    {
        ObjectClass* oc = [[ObjectClass alloc] initWithString:_currentString];
        [_currentTag.searchClassList addObject:oc];
    }
    else if ([@"upnp:createClass" isEqualToString:elementName])
    {
        ObjectClass* oc = [[ObjectClass alloc] initWithString:_currentString];
        [_currentTag.createClassList addObject:oc];
    }
    
    else if ([@"upnp:class" isEqualToString:elementName])
    {
        ObjectClass* oc = [[ObjectClass alloc] initWithString:_currentString];
        _currentTag.clazz = oc;
    }
    else if ([@"res" isEqualToString:elementName])
    {
        _res.resUrl = _currentString;
        [_currentTag.resList addObject:_res];
    }
    else if ([@"upnp:writeStatus" isEqualToString:elementName])
    {
        [_currentTag.writeStatusList addObject:_currentString];
    }
    else if ([@"upnp:originalTrackNumber" isEqualToString:elementName])
    {
        _currentTag.originalTrackNumber = [_currentString intValue];
    }
    else if ([@"upnp:artist" isEqualToString:elementName])
    {
        [_currentTag.artistList addObject:_currentString];
    }
    else if ([@"upnp:actor" isEqualToString:elementName])
    {
        [_currentTag.actorList addObject:_currentString];
    }
    else if ([@"upnp:author" isEqualToString:elementName])
    {
        [_currentTag.authorList addObject:_currentString];
    }
    else if ([@"upnp:director" isEqualToString:elementName])
    {
        [_currentTag.directorList addObject:_currentString];
    }
    else if ([@"upnp:genre" isEqualToString:elementName])
    {
        [_currentTag.genreList addObject:_currentString];
    }
    else if ([@"upnp:playlist" isEqualToString:elementName])
    {
        [_currentTag.playlistList addObject:_currentString];
    }
    else if ([@"upnp:albumArtURI" isEqualToString:elementName])
    {
        [_currentTag.albumArtURIList addObject:_currentString];
    }
    else if ([@"upnp:album" isEqualToString:elementName])
    {
        [_currentTag.albumList addObject:_currentString];
    }

     
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    [_currentString appendString:string];
}

@end
