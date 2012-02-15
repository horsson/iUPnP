//
//  DidlParser.m
//  iUPnP
//
//  Created by Hao Hu on 02.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DidlParser.h"
#import "UPnPArtist.h"


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

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
    _currentString = [[NSMutableString alloc] init];
    
    if ([@"container" isEqualToString:elementName]) {
        _mediaContainer = [[MediaContainer alloc] init];
        _mediaContainer.ID = [attributeDict objectForKey:@"id"];
        _mediaContainer.parentID = [attributeDict objectForKey:@"parentID"];
        #ifdef DIDL_FULL
            _mediaContainer.neverPlayable = [[attributeDict objectForKey:@"neverPlayable"] intValue];
            _mediaContainer.restricted = [[attributeDict objectForKey:@"restricted"] intValue]; 
        #endif
        _mediaContainer.childCount = [[attributeDict objectForKey:@"childCount"] intValue];
        
        _currentTag = _mediaContainer;
    }
    else if ([@"item" isEqualToString:elementName])
    {
        _mediaItem = [[MediaItem alloc] init];
        _mediaItem.ID = [attributeDict objectForKey:@"id"];
        _mediaItem.parentID = [attributeDict objectForKey:@"parentID"];
        _mediaItem.refID = [attributeDict objectForKey:@"refID"];
        #ifdef DIDL_FULL
            _mediaItem.neverPlayable = [[attributeDict objectForKey:@"neverPlayable"] intValue];
            _mediaItem.restricted = [[attributeDict objectForKey:@"restricted"] intValue];
        #endif
        _currentTag = _mediaItem;

    } 
    else if ([@"res" isEqualToString:elementName])
    {
        if (_currentTag.resList == nil) {
            _currentTag.resList = [[NSMutableArray alloc] init];
        }   
        _res = [[MediaRes alloc] init];
        _res.duration = [attributeDict objectForKey:@"duration"];
        // NSLog(@"MediaDuration is %@",_res.duration);
        _res.size = [[attributeDict objectForKey:@"size"] longLongValue];
         //NSLog(@"Size is %llu",_res.size);
        _res.protocolInfo = [attributeDict objectForKey:@"protocolInfo"];
        _res.bitrate = [[attributeDict objectForKey:@"bitrate"] intValue];
        _res.resolution = [attributeDict objectForKey:@"resolution"];
        //NSLog(@"resolution is %@",_res.resolution);
    }
    
    else if ([@"upnp:artist" isEqualToString:elementName])
    {
        if (_currentTag.artistList == nil) {
            _currentTag.artistList = [[NSMutableArray alloc] init];
        }
        _currentUpnpArtist = [[UPnPArtist alloc] init];
        NSString* role = [attributeDict objectForKey:@"role"];

        _currentUpnpArtist.role = role;
    }
    #ifdef DIDL_FULL
        else if ([@"upnp:searchClass" isEqualToString:elementName])
        {
            if (_currentTag.searchClassList == nil)
            {
                _currentTag.searchClassList = [[NSMutableArray alloc] init];
            }
        }
        else if ([@"upnp:createClass" isEqualToString:elementName])
        {
            if (_currentTag.createClassList == nil) {
                _currentTag.createClassList = [[NSMutableArray alloc] init];
            }
        }
        else if ([@"upnp:writeStatus" isEqualToString:elementName])
        {
            if(_currentTag.writeStatusList == nil)
            {
                _currentTag.writeStatusList = [[NSMutableArray alloc] init];
            }
            
        }
        else if ([@"upnp:actor" isEqualToString:elementName])
        {
            if(_currentTag.actorList == nil)
            {
                _currentTag.actorList = [[NSMutableArray alloc] init];

            }
        }
        else if ([@"upnp:author" isEqualToString:elementName])
        {
            if (_currentTag.authorList == nil) 
            {
                _currentTag.authorList = [[NSMutableArray alloc] init];
            }
        }
        else if ([@"upnp:producer" isEqualToString:elementName])
        {

        }
        else if ([@"upnp:director" isEqualToString:elementName])
        {
            if (_currentTag.directorList == nil)
            {
                _currentTag.directorList = [[NSMutableArray alloc] init];
            }
        }
        
        else if ([@"upnp:playlist" isEqualToString:elementName])
        {
            
            if (_currentTag.playlistList == nil)
            {
                _currentTag.playlistList =  [[NSMutableArray alloc] init];
            }
            
        }
    #endif
    
    else if ([@"upnp:genre" isEqualToString:elementName])
    {
        if (_currentTag.genreList == nil)
        {
            _currentTag.genreList = [[NSMutableArray alloc] init];
        }
    }
       else if ([@"upnp:albumArtURI" isEqualToString:elementName])
    {
        if (_currentTag.albumArtURIList == nil) {
            _currentTag.albumArtURIList = [[NSMutableArray alloc] init];
        }

    }
    else if ([@"upnp:album" isEqualToString:elementName])
    {
        if (_currentTag.albumList == nil) {
            _currentTag.albumList = [[NSMutableArray alloc] init];
        }
    }

}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{

    if ([@"container" isEqualToString:elementName])
    {
        [_mediaObjects addObject:_currentTag];
        _mediaContainer = nil;
        _currentTag = nil;
    }
    else if ([@"item" isEqualToString:elementName])
    {

        [_mediaObjects addObject:_currentTag];        
        _mediaItem = nil;
        _currentTag = nil;
    }
       
    else if ([@"upnp:class" isEqualToString:elementName])
    {
        ObjectClass* oc = [[ObjectClass alloc] initWithString:_currentString];
        _currentTag.objectClazz = oc;
    }
    else if ([@"res" isEqualToString:elementName])
    {
        _res.resUrl = _currentString;
        [_currentTag.resList addObject:_res];
    }
        else if ([@"dc:title" isEqualToString:elementName])
    {
        _currentTag.title = _currentString;
    }
    else if ([@"upnp:artist" isEqualToString:elementName])
    {
        _currentUpnpArtist.name = _currentString;
       // NSLog(@"Artist: is %@.", _currentString);
        [_currentTag.artistList addObject:_currentUpnpArtist];
    }
    
    else if ([@"upnp:albumArtURI" isEqualToString:elementName])
    {
        [_currentTag.albumArtURIList addObject:_currentString];
    }
    else if ([@"upnp:album" isEqualToString:elementName])
    {
        [_currentTag.albumList addObject:_currentString];
    }        
    else if ([@"upnp:genre" isEqualToString:elementName])
    {
        [_currentTag.genreList addObject:_currentString];
    }
    else if ([@"dc:date" isEqualToString:elementName])
    {
        _currentTag.date = _currentString;
    }
    #ifdef DIDL_FULL
        else if ([@"upnp:playlist" isEqualToString:elementName])
        {
            [_currentTag.playlistList addObject:_currentString];
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
        else if ([@"upnp:writeStatus" isEqualToString:elementName])
        {
            [_currentTag.writeStatusList addObject:_currentString];
        }
        else if ([@"upnp:originalTrackNumber" isEqualToString:elementName])
        {
            _currentTag.originalTrackNumber = [_currentString intValue];
        }
    #endif    
    _currentString = nil;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    [_currentString appendString:string];
}


@end
