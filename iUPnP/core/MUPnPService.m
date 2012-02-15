//
//  UPnPService.m
//  iUPnPTestPrj
//
//  Created by Hao Hu on 26.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MUPnPService.h"


@implementation MUPnPService
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
        
    if (SCPDURL == nil)
    {
        NSLog(@"Warning! SCPDUR is null");
        return;
    }
    
    NSURL* nsurl = [[NSURL alloc] initWithString:SCPDURL];
    if (_timeout == 0) {
        _timeout = [[MUPnPStack sharedUPnPStack] defaultTimeoutForXmlParsing];
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
    else
    {
        //FixME:Should do some to handle the non-200 response.
    }
}



-(NSUInteger) actionCount
{
    return [actionList count];
}


#pragma XML SAX callback handler



- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
    _lastElement = _currentElement;
    _currentElement = elementName;
    if ([elementName isEqualToString:@"actionList"])
    {
        self.actionList = [[NSMutableArray alloc] init];;
    }
    
    if ([elementName isEqualToString:@"action"])
    {
        _action = [[MUPnPAction alloc] init];
        _action.controlPointHandle = self.controlPointHandle;
    }
    
    if ([elementName isEqualToString:@"argumentList"])
    {
        _action.argumentList = [[NSMutableArray alloc] init];;
    }
    
    if ([elementName isEqualToString:@"argument"])
    {
        _argument = [[MUPnPArgument alloc] init];
    }
    _currentContent = [[NSMutableString alloc] initWithCapacity:20];
}



- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    
   if ([elementName isEqualToString:@"action"])
    {
        [actionList addObject:_action];
    }
    
    if ([elementName isEqualToString:@"name"])
    {
        if ([_lastElement isEqualToString:@"argument"])
        {
            _argument.name = _currentContent;
        }
        //Hao: The "Optional" element is for the FrizBox.
        else  if ([_lastElement isEqualToString:@"action"] || [_lastElement isEqualToString:@"Optional"])
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
    
    _currentContent = nil;
}


- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (_currentContent)
        [_currentContent appendString:string];
}


- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    NSLog(@"Error occurs, when parsing UPnPService. The reason is %@. The URL is %@", [parseError localizedDescription], self.SCPDURL);
}


@end
