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



-(id) initWithLocationURL:(NSString*) locationURL timeout:(NSTimeInterval) timeout
{
    self = [super init];
    if (self)
    {
        if (_locationURL)
        {
            _locationURL = nil;
        }
        
        _locationURL = [locationURL copy];
        
        NSURL* tempUrl = [[NSURL alloc] initWithString:_locationURL];
        
        _baseURL = [[NSString alloc] initWithFormat:@"%@://%@:%@",[tempUrl scheme],[tempUrl host],[[tempUrl port] stringValue]];
        
        _timeout = timeout;
        serviceParseQueue = dispatch_queue_create("de.haohu.iupnp.service", NULL);
    }
    
    return self;
}

-(void) startParsing
{
    NSURL* nsurl = [[NSURL alloc] initWithString:_locationURL];
    NSURLRequest* urlRequest = [[NSURLRequest alloc] initWithURL:nsurl cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:_timeout];
    NSURLResponse* resp = NULL;
    _xmlData = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&resp error:NULL];
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
- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    _currentContent = [[NSMutableString alloc] initWithCapacity:255];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
  
    _currentContent = nil;
}

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
    
    [_currentContent setString:@""];

}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    static  NSString* kDeviceType=@"deviceType";
    static  NSString* kUDN = @"UDN";

    
    if ([elementName isEqualToString:kDeviceType])
    {
        self.deviceType = _currentContent;
        //[_currentContent release];
        //_currentContent = nil;
    }
    if ([elementName isEqualToString:kUDN])
    {
        self.UDN = _currentContent;
    }
    if ([elementName isEqualToString:@"friendlyName"])
    {
        self.friendlyName = _currentContent;

    }
    if ([elementName isEqualToString:@"manufacturer"])
    {
        self.manufacturer = _currentContent;

    }
    if ([elementName isEqualToString:@"manufacturerURL"])
    {
        self.manufacturerURL = _currentContent;
    }
    if ([elementName isEqualToString:@"modelName"])
    {
        self.modelName = _currentContent;

    }
    if ([elementName isEqualToString:@"modelURL"])
    {
       self.modelURL = _currentContent;
    }
    if ([elementName isEqualToString:@"modelDescription"])
    {
        self.modelDescription = _currentContent;

    }
    if ([elementName isEqualToString:@"presentationURL"])
    {
        self.presentationURL = _currentContent;
    }
    if ([elementName isEqualToString:@"mimetype"])
    {
        _icon.mimetype = _currentContent;
    }

    if ([elementName isEqualToString:@"height"])
    {
        _icon.height = [_currentContent intValue];
    }
    
    if ([elementName isEqualToString:@"width"])
    {
       _icon.width = [_currentContent intValue];

    }
    
    if ([elementName isEqualToString:@"depth"])
    {
        _icon.depth = [_currentContent intValue];

    }
    if ([elementName isEqualToString:@"url"])
    {   
       NSString* fullUrl = [[NSString alloc] initWithFormat:@"%@%@",_baseURL ,_currentContent];
        _icon.url = fullUrl;
    }
    
    if ([elementName isEqualToString:@"icon"])
    {
       [iconList addObject:_icon];
        _icon = nil;
    }
    
    if ([elementName isEqualToString:@"serviceType"])
    {
        _service.serviceType = _currentContent;

    }
    
    if ([elementName isEqualToString:@"serviceId"])
    {
        _service.serviceId = _currentContent;

    }
    if ([elementName isEqualToString:@"SCPDURL"])
    {
         NSString* fullUrl = [[NSString alloc] initWithFormat:@"%@%@",_baseURL ,_currentContent];
        _service.SCPDURL = fullUrl;

    }
    if ([elementName isEqualToString:@"eventSubURL"])
    {
         NSString* fullUrl = [[NSString alloc] initWithFormat:@"%@%@",_baseURL ,_currentContent];
        _service.eventSubURL = fullUrl;

    }
    if ([elementName isEqualToString:@"controlURL"])
    {
         NSString* fullUrl = [[NSString alloc] initWithFormat:@"%@%@",_baseURL ,_currentContent];
        _service.controlURL = fullUrl;

    }
    
    if ([elementName isEqualToString:@"service"])
    {
        [serviceList setObject:_service forKey:_service.serviceId];
       // NSLog(@"Before service retain count is %d.", [_service retainCount]);
        __weak UPnPService* tempService = _service;
        dispatch_async(serviceParseQueue, ^(void) {
            [tempService startParsing];
        });
        
       // NSLog(@"After release service retain count is %d.", [_service retainCount]);
        _service = nil;
    }
    
    if ([elementName isEqualToString:@"serviceList"])
    {

        numberOfService = [serviceList count];

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
    serviceCounter++;
    
    if (serviceCounter == numberOfService)
    {
        [delegate upnpDeviceDidFinishParsing:self];
    }
}

-(void) parseDidFinish:(UPnPService*)  upnpService
{
    serviceCounter++;
    if (serviceCounter == numberOfService)

    {

        [delegate upnpDeviceDidFinishParsing:self];
    }
}


#pragma dealloc and clean code.
- (void)dealloc {

    NSLog(@"UPnPDevice %@ dealloc", self.friendlyName);
    dispatch_release(serviceParseQueue);
}


@end
