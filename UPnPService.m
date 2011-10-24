//
//  UPnPService.m
//  iUPnPTestPrj
//
//  Created by Hao Hu on 26.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UPnPService.h"


@implementation UPnPService
@synthesize serviceId,serviceType,SCPDURL,controlURL,eventSubURL,actionList,delegate,controlPointHandle;


-(id) initWithURL:(NSString*) url timeout:(NSTimeInterval) timeout
{
    self = [super init];
    if (self)
    {
        SCPDURL = url;
        _timeout = timeout;
    }
    return self;
}

-(void) startParsing
{
   // NSLog(@"The url is %@",SCPDURL);
    NSURL* nsurl = [[NSURL alloc] initWithString:SCPDURL];
    if (_timeout == 0) {
        _timeout = [[UPnPStack sharedUPnPStack] defaultTimeoutForXmlParsing];
    }
    NSURLRequest* urlRequest = [[NSURLRequest alloc] initWithURL:nsurl cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:_timeout];
    NSURLResponse* resp = nil;
    _xmlData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&resp error:NULL];
    NSHTTPURLResponse* httpResp = (NSHTTPURLResponse*) resp;
    if (_xmlData == nil)
    {
        [delegate parseDidReceiveError:self withError:NULL];
        return;
    }
    if ([httpResp statusCode] == 200)
    {
        _xmlParser = [[NSXMLParser alloc] initWithData:_xmlData];
        [_xmlParser setDelegate:self];
        if ([_xmlParser parse])
        {
            [delegate parseDidFinish:self];
        }
        else
        {
            [delegate parseDidReceiveError:self withError:[_xmlParser parserError]];  
        }
        _xmlParser = nil;
    }
}



-(NSUInteger) actionCount
{
    return [actionList count];
}

-(void) dealloc
{
    NSLog(@"UPnPService %@ dealloc.", self.serviceId);
}


#pragma XML SAX callback handler

-(void) parserDidStartDocument:(NSXMLParser *)parser
{
    _currentContent = [[NSMutableString alloc] initWithCapacity:255];
}

-(void) parserDidEndDocument:(NSXMLParser *)parser
{
    _currentContent = nil;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
    _lastElement = _currentElement;
    _currentElement = elementName;
    if ([elementName isEqualToString:@"actionList"])
    {
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        self.actionList = tempArray;
    }
    
    if ([elementName isEqualToString:@"action"])
    {
        _action = [[UPnPAction alloc] init];
        _action.controlPointHandle = self.controlPointHandle;
    }
    
    if ([elementName isEqualToString:@"argumentList"])
    {
        NSMutableArray *argumentList = [[NSMutableArray alloc] init];
        _action.argumentList = argumentList;
    }
    
    if ([elementName isEqualToString:@"argument"])
    {
        _argument = [[UPnPArgument alloc] init];
    }
    
    
    [_currentContent setString:@""];
}



- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
   if ([elementName isEqualToString:@"action"])
    {
        [actionList addObject:_action];
        _action = nil;
    }
    
    if ([elementName isEqualToString:@"name"])
    {
        if ([_lastElement isEqualToString:@"argument"])
        {
            _argument.name = _currentContent;
        }
        else  if ([_lastElement isEqualToString:@"action"])
        {
            _action.name = _currentContent;

        }
        
    }
    
    if ([elementName isEqualToString:@"direction"])
    {
        if ([_currentContent isEqualToString:@"out"])
        {
            _argument.direction = UPnPArgumentDirectionOut;
        }
        else
        {
            _argument.direction = UPnPArgumentDirectionIn;
        }

    }
    
    if ([elementName isEqualToString:@"relatedStateVariable"])
    {
        _argument.relatedStateVariable = _currentContent;

    }
    
    if ([elementName isEqualToString:@"argument"])
    {
        [_action.argumentList addObject:_argument];
        _argument = nil;
    }
}


- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (_currentContent)
        [_currentContent appendString:string];
}


- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    
}

@end
