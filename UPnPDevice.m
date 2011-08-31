//
//  UPnPDevice.m
//  iUPnPTestPrj
//
//  Created by Hao Hu on 26.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UPnPDevice.h"


@implementation UPnPDevice
@synthesize friendlyName,UDN, UPC,iconList,modelURL,serviceList,modelName,deviceType,modelNumber,manufacturer,manufacturerURL,presentationURL,modelDescription,delegate,controlPointHandle;

-(NSString*) getBaseUrlFrom:(NSString*) url
{
    NSURL *tempUrl = [[NSURL alloc] initWithString:url];
    NSString* baseUrl = [NSString stringWithFormat:@"%@://%@:%@",[tempUrl scheme],[tempUrl host],[[tempUrl port] stringValue]];
    [tempUrl release];
    return baseUrl;
}

-(id) initWithLocationURL:(NSString*) locationURL timeout:(NSTimeInterval) timeout
{
    self = [super init];
    if (self)
    {
        if (_locationURL)
        {
            [_locationURL release];
        }
        _locationURL = locationURL;
        [_locationURL copy];
        _baseURL = [[self getBaseUrlFrom:locationURL] retain];
        _upnpServiceLock = [[NSLock alloc] init];
        _timeout = timeout;
    }
    
    return self;
}

-(void) startParsing
{
    NSURL* nsurl = [[NSURL alloc] initWithString:_locationURL];
    NSURLRequest* urlRequest = [[NSURLRequest alloc] initWithURL:nsurl cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:_timeout];
    [nsurl release];
    NSURLResponse* resp = NULL;
    _xmlData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&resp error:NULL];
    [urlRequest release];
    NSHTTPURLResponse* httpResp = (NSHTTPURLResponse*) resp;
    
    if (_xmlData == nil)
    {
        [delegate upnpDeviceDidReceiveError:self : NULL];
    }
    
    if ([httpResp statusCode] == 200)
    {
        _xmlParser = [[NSXMLParser alloc] initWithData:_xmlData];
        [_xmlParser setDelegate:self];
        [_xmlParser parse];
        [_xmlParser release];
        _xmlParser = nil;

    }
}

-(UPnPService*) getUPnPServiceById:(NSString*) serviceId
{
   return [serviceList objectForKey:serviceId];
}

-(UPnPAction*)  getActionByName:(NSString*) actionName
{
    NSArray* services = [serviceList allValues];
    for (UPnPService* aService in services) {
        for (UPnPAction* anAction in aService.actionList) {
            if ([actionName isEqualToString:anAction.name])
            {
                [anAction setControlURL:aService.controlURL];
                [anAction setServiceType:aService.serviceType];
                [anAction setDeviceUDN:UDN];
                return anAction;
            }
        }
    }
    return nil;
}

#pragma XML-SAX callback.
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
    if ([elementName isEqualToString:@"iconList"])
    {
        iconList = [[NSMutableArray alloc] init];
    }
    if ([elementName isEqualToString:@"serviceList"])
    {
        serviceList = [[NSMutableDictionary alloc] init];
     
    }
    if ([elementName isEqualToString:@"icon"])
    {
       _icon = [[UPnPIcon alloc] init];
    }
    if ([elementName isEqualToString:@"service"])
    {
        _service = [[UPnPService alloc] init];
        _service.controlPointHandle = self.controlPointHandle;
        _service.delegate = self;
    }
    else if ([elementName isEqualToString:@"deviceType"]        ||  [elementName isEqualToString:@"UDN"]            || 
             [elementName isEqualToString:@"friendlyName"]      ||  [elementName isEqualToString:@"manufacturer"]   || 
             [elementName isEqualToString:@"manufacturerURL"]   ||  [elementName isEqualToString:@"modelName"]      || 
             [elementName isEqualToString:@"modelURL"]          ||  [elementName isEqualToString:@"modelDescription"] || 
             [elementName isEqualToString:@"presentationURL"]   ||  [elementName isEqualToString:@"mimetype"]       ||
             [elementName isEqualToString:@"height"]            ||  [elementName isEqualToString:@"width"]          ||
             [elementName isEqualToString:@"depth"]             ||  [elementName isEqualToString:@"url"]            ||
             [elementName isEqualToString:@"serviceType"]       ||  [elementName isEqualToString:@"serviceId"]      ||
             [elementName isEqualToString:@"SCPDURL"]           ||  [elementName isEqualToString:@"eventSubURL"]    ||
             [elementName isEqualToString:@"controlURL"]
             )
    {
        _currentContent = [[NSMutableString alloc] init];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:@"deviceType"])
    {
        self.deviceType = _currentContent;
        [_currentContent release];
        _currentContent = nil;
    }
    if ([elementName isEqualToString:@"UDN"])
    {
        self.UDN = _currentContent;
        [_currentContent release];
          _currentContent = nil;
    }
    if ([elementName isEqualToString:@"friendlyName"])
    {
        self.friendlyName = _currentContent;
        [_currentContent release];
          _currentContent = nil;
    }
    if ([elementName isEqualToString:@"manufacturer"])
    {
        self.manufacturer = _currentContent;
        [_currentContent release];
          _currentContent = nil;
    }
    if ([elementName isEqualToString:@"manufacturerURL"])
    {
        self.manufacturerURL = _currentContent;
        [_currentContent release];
          _currentContent = nil;
    }
    if ([elementName isEqualToString:@"modelName"])
    {
        self.modelName = _currentContent;
        [_currentContent release];
          _currentContent = nil;
    }
    if ([elementName isEqualToString:@"modelURL"])
    {
       self.modelURL = _currentContent;
        [_currentContent release];
          _currentContent = nil;
    }
    if ([elementName isEqualToString:@"modelDescription"])
    {
        self.modelDescription = _currentContent;
        [_currentContent release];
          _currentContent = nil;
    }
    if ([elementName isEqualToString:@"presentationURL"])
    {
        self.presentationURL = _currentContent;
        [_currentContent release];
          _currentContent = nil;
    }
    if ([elementName isEqualToString:@"mimetype"])
    {
        _icon.mimetype = _currentContent;
        [_currentContent release];
          _currentContent = nil;
    }

    if ([elementName isEqualToString:@"height"])
    {
        _icon.height = [_currentContent intValue];
        [_currentContent release];
          _currentContent = nil;
    }
    
    if ([elementName isEqualToString:@"width"])
    {
       _icon.width = [_currentContent intValue];
        [_currentContent release];
          _currentContent = nil;
    }
    
    if ([elementName isEqualToString:@"depth"])
    {
        _icon.depth = [_currentContent intValue];
        [_currentContent release];
          _currentContent = nil;
    }
    if ([elementName isEqualToString:@"url"])
    {   
       NSString* fullUrl = [[NSString alloc] initWithFormat:@"%@%@",_baseURL ,_currentContent];
        _icon.url = fullUrl;
        [fullUrl release];
        [_currentContent release];
          _currentContent = nil;
    }
    
    if ([elementName isEqualToString:@"icon"])
    {
       [iconList addObject:_icon];
        [_icon release];
        _icon = nil;
    }
    
    if ([elementName isEqualToString:@"serviceType"])
    {
        _service.serviceType = _currentContent;
        [_currentContent release];
          _currentContent = nil;
    }
    
    if ([elementName isEqualToString:@"serviceId"])
    {
        _service.serviceId = _currentContent;
        [_currentContent release];
        _currentContent = nil;
    }
    if ([elementName isEqualToString:@"SCPDURL"])
    {
         NSString* fullUrl = [[NSString alloc] initWithFormat:@"%@%@",_baseURL ,_currentContent];
        _service.SCPDURL = fullUrl;
        [fullUrl release];
        [_currentContent release];
        _currentContent = nil;
    }
    if ([elementName isEqualToString:@"eventSubURL"])
    {
         NSString* fullUrl = [[NSString alloc] initWithFormat:@"%@%@",_baseURL ,_currentContent];
        _service.eventSubURL = fullUrl;
        [fullUrl release];
        [_currentContent release];
        _currentContent = nil;
    }
    if ([elementName isEqualToString:@"controlURL"])
    {
         NSString* fullUrl = [[NSString alloc] initWithFormat:@"%@%@",_baseURL ,_currentContent];
        _service.controlURL = fullUrl;
        [fullUrl release];
        [_currentContent release];
        _currentContent = nil;
    }
    
    if ([elementName isEqualToString:@"service"])
    {
        [serviceList setObject:_service forKey:_service.serviceId];
        
        /*
        dispatch_async(upnpServiceQueue, ^(void) {
            //TODO maybe bug here:
            //FIXME!!
            UPnPService* tempService = [[serviceList objectForKey:_service.serviceId] retain];
            [tempService beginParser];
            [tempService release];
        });
         
         */
        [_service release];
        _service = nil;
    }
    
    if ([elementName isEqualToString:@"serviceList"])
    {
        dispatch_queue_t upnpServiceQueue = dispatch_queue_create("de.haohu.upnp.service", NULL);
        _tempServiceList =[serviceList allValues];
        _processingService =[[NSMutableArray alloc] initWithArray:[serviceList allKeys] copyItems:YES];
        size_t count = [_tempServiceList count];
        dispatch_apply(count, upnpServiceQueue, ^(size_t i) {
            UPnPService * tempService = [_tempServiceList objectAtIndex:i];
            [tempService startParsing];
        });
        dispatch_release(upnpServiceQueue);
        
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    [_currentContent appendString:string];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    [delegate upnpDeviceDidReceiveError:self :parseError];
}

-(BOOL) isFinishParsing:(UPnPService*) upnpService
{
    NSString* serviceId = upnpService.serviceId;
    [_upnpServiceLock lock];
    [_processingService removeObject:serviceId];
    if ([_processingService count] == 0)
    {
        [_upnpServiceLock unlock];
        return YES;
    }
    else
    {
        [_upnpServiceLock unlock];
        return NO;
    }
    
}

#pragma UPnPService callback delegate
-(void) parseDidReceiveError:(UPnPService*) upnpService withError:(NSError*) error
{
    if (error == NULL)
    {
        NSLog(@"Timeout. When parsing %@",upnpService.serviceId);
    }
    else
    {
        NSLog(@"%@",[error localizedDescription]);
    }
    if ([self isFinishParsing:upnpService])
    {
        [delegate upnpDeviceDidFinishParsing:self];
    }
}

-(void) parseDidFinish:(UPnPService*)  upnpService
{
    NSLog(@"Parser done at %@",upnpService.serviceId);
    if ([self isFinishParsing:upnpService])
    {
        [_processingService release];
        _processingService = nil;
        [delegate upnpDeviceDidFinishParsing:self];
    }
}


#pragma dealloc and clean code.
- (void)dealloc {

    [_baseURL release];
    [_locationURL release];
    [_upnpServiceLock release];
    [deviceType release];
    [friendlyName release];
    [manufacturer release];
    [manufacturerURL release];
    [modelDescription release];
    [modelName release];
    [modelNumber release];
    [modelURL release];
    [UDN release];
    [UPC release];
    [presentationURL release];
    [iconList release];
    [serviceList release];

    [super dealloc];
}


@end
