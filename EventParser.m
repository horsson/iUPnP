//
//  EventParser.m
//  iUPnP
//
//  Created by Hao Hu on 07.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EventParser.h"


@implementation EventParser
@synthesize XMLString,varValueDict;
static  NSString* kEPPropertyset = @"e:propertyset";
static  NSString* kEPProperty = @"e:property";

-(id) initWithXMLString:(NSString*) xmlString
{
    self = [super init];
    if (self)
    {
        self.XMLString = xmlString;
        _xmlParser = [[NSXMLParser alloc] initWithData:[self.XMLString dataUsingEncoding:NSUTF8StringEncoding]];
        [_xmlParser setDelegate:self];
        varValueDict = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(BOOL) parse
{
    return [_xmlParser parse];
}




#pragma NSXMLParserDelegate

-(void) parserDidStartDocument:(NSXMLParser *)parser
{
    _currentString = [[NSMutableString alloc] init];
 
}

-(void) parserDidEndDocument:(NSXMLParser *)parser
{
    [_currentString release];
    _currentString = nil;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
    [_currentString setString:@""];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:kEPProperty] || [elementName isEqualToString:kEPPropertyset])
    {
        return;
    }
    NSString* varName = [elementName copy];
    NSString* value = [_currentString copy];
    [varValueDict setObject:value forKey:varName];
    [varName release];
    [value release];
}

-(void) parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    [_currentString appendString:string];
}

- (void)dealloc {
    [varValueDict release];
    [self.XMLString release];
    [_xmlParser release];
    [super dealloc];
}
@end
