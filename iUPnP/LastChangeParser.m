//
//  LastChangeParser.m
//  UPnP Player HD
//
//  Created by Hao Hu on 08.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "LastChangeParser.h"

@implementation LastChangeParser

-(id) initWithXml:(NSString*) xmlDoc
{
    self = [super init];
    if (self)
    {
        _parser = [[NSXMLParser alloc] initWithData:[xmlDoc dataUsingEncoding:NSUTF8StringEncoding]];
        _parser.delegate = self;
    }
    
    return self;
}
-(LastChange*) lastChange
{
    _lastChange = [[LastChange alloc] init];
    if ([_parser parse])
    {
        return _lastChange;
    }
    else
    {
        return nil;
    }
    
}

#pragma mark - XML Parser delegate
-(void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if ([elementName isEqualToString:@"TransportStatus"]) 
    {
        _lastChange.transportStatus = [attributeDict objectForKey:@"val"];
    }
    else if ([elementName isEqualToString:@"TransportState"]) 
    {
        _lastChange.transportState = [attributeDict objectForKey:@"val"];
    }
}


@end
