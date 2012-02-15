//
//  UPnPDevice.m
//  iUPnPTestPrj
//
//  Created by Hao Hu on 26.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MUPnPDevice.h"
@interface MUPnPDevice()
-(NSString*) fullUrlFromPath:(NSString*) urlPath;
@end


@implementation MUPnPDevice
@synthesize hostIpAddress,friendlyName,UDN, UPC,iconList,modelURL,serviceList,modelName,deviceType,modelNumber,manufacturer,manufacturerURL,presentationURL,modelDescription,delegate,controlPointHandle;


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
        self.hostIpAddress = [tempUrl host];
        int port = 80;
        if ([[tempUrl port] intValue] != 0) 
        {
            port = [[tempUrl port] intValue];
        }
        _baseURL = [[NSString alloc] initWithFormat:@"%@://%@:%d",[tempUrl scheme],[tempUrl host],port];
        //NSLog(@"Base url is %@", _baseURL);
        //NSLog(@"The location url is %@", locationURL);
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

-(MUPnPService*) getUPnPServiceById:(NSString*) serviceId
{
   return [serviceList objectForKey:serviceId];
}

-(MUPnPAction*)  getActionByName:(NSString*) actionName
{
    //NSLog(@"Action name to be got is %@.", actionName);
    NSArray* services = [serviceList allValues];
    //NSLog(@"There are %d services.", services.count);
    for (MUPnPService* aService in services) 
    {
       // NSLog(@"Service name is %@. It has %d actions.", aService.serviceType, aService.actionList.count);
        for (MUPnPAction* anAction in aService.actionList) 
        {
            //NSLog(@"Action name: %@", anAction.name);
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

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
   
    //NSLog(@"%@. There are %d services to be got!",self.friendlyName, [serviceList count]);
   [serviceList enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
       dispatch_async(serviceParseQueue, ^{
           MUPnPService* service = (MUPnPService*) obj;
           [service startParsing];
       });
          
   } ];
    
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
       _icon = [[MUPnPIcon alloc] init];
    }
    if ([elementName isEqualToString:@"service"])
    {
        _service = [[MUPnPService alloc] init];
        _service.controlPointHandle = self.controlPointHandle;
        _service.delegate = self;
    }
    _currentContent = [[NSMutableString alloc] initWithCapacity:255];

}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    static  NSString* kDeviceType=@"deviceType";
    static  NSString* kUDN = @"UDN";

    
    if ([elementName isEqualToString:kDeviceType])
    {
        self.deviceType = _currentContent;
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
       //NSString* fullUrl = [[NSString alloc] initWithFormat:@"%@%@",_baseURL ,_currentContent];
        _icon.url = [self fullUrlFromPath:_currentContent];
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
        /*
        //SCPDURL can be the absolute or relative url.
        NSRange range = [_currentContent rangeOfString:@"/"];
        NSString* fullUrl = nil;
        if (range.location == 0) 
        {
            //Absolute url.
            fullUrl = [[NSString alloc] initWithFormat:@"%@%@",_baseURL ,_currentContent];
            if (fullUrl == nil) 
            {
                NSLog(@"SCPDURL is null, the name is %@", self.friendlyName);
            }
        }
        else    //Relative URL
        {
            NSURL* tempUrl = [NSURL URLWithString:_locationURL];
            NSString* lastPathComp = [tempUrl lastPathComponent];
            NSRange range = [_locationURL rangeOfString:lastPathComp];
            NSString* tempBaseUrl = [_locationURL substringToIndex:range.location];
            fullUrl = [[NSString alloc] initWithFormat:@"%@%@", tempBaseUrl,_currentContent];
        }
         */
        _service.SCPDURL = [self fullUrlFromPath:_currentContent];

    }
    if ([elementName isEqualToString:@"eventSubURL"])
    {
         //NSString* fullUrl = [[NSString alloc] initWithFormat:@"%@%@",_baseURL ,_currentContent];
        _service.eventSubURL = [self fullUrlFromPath:_currentContent];

    }
    if ([elementName isEqualToString:@"controlURL"])
    {
         //NSString* fullUrl = [[NSString alloc] initWithFormat:@"%@%@",_baseURL ,_currentContent];
        _service.controlURL = [self fullUrlFromPath:_currentContent];

    }
    
    if ([elementName isEqualToString:@"service"])
    {
        [serviceList setObject:_service forKey:_service.serviceId];
       // NSLog(@"Before service retain count is %d.", [_service retainCount]);
        //__weak UPnPService* tempService = _service;
        
        
       // NSLog(@"After release service retain count is %d.", [_service retainCount]);
        //_service = nil;
    }
    
    if ([elementName isEqualToString:@"serviceList"])
    {
        numberOfService = [serviceList count];
    }
     _currentContent = nil;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    [_currentContent appendString:string];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    NSLog(@"Error occurs, when parsing the device description. The reason is %@", [parseError localizedDescription]);
    [delegate upnpDeviceDidReceiveError:self :parseError];
}




#pragma UPnPService callback delegate
-(void) parseDidReceiveError:(MUPnPService*) upnpService withError:(NSError*) error
{
    if (error == NULL)
    {
        NSLog(@"Timeout. When parsing ServiceId:%@. FriendlyName:%@",upnpService.serviceId, self.friendlyName);
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

-(void) parseDidFinish:(MUPnPService*)  upnpService
{
    serviceCounter++;
    if (serviceCounter == numberOfService)
    {
        [delegate upnpDeviceDidFinishParsing:self];
    }
}




-(NSString*) fullUrlFromPath:(NSString*) urlPath
{
    NSRange range = [urlPath rangeOfString:@"/"];
    NSString* fullUrl = nil;
    if (range.location == 0) 
    {
        //Absolute url.
        fullUrl = [[NSString alloc] initWithFormat:@"%@%@",_baseURL ,urlPath];
        if (fullUrl == nil) 
        {
            NSLog(@"Path is null, the name is %@", self.friendlyName);
        }
    }
    else    //Relative URL
    {
        //http:MediaRenderer_AVTransport/scpd.xml
        //http://192.168.55.140:10184/MediaRenderer_AVTransport/scpd.xml
        NSURL* tempUrl = [NSURL URLWithString:_locationURL];
        NSString* lastPathComp = [tempUrl lastPathComponent];
        if ([lastPathComp isEqualToString:@"/"]) 
        {
            fullUrl = [[NSString alloc] initWithFormat:@"%@%@", _locationURL,urlPath];
        }
        else
        {
            NSRange range = [_locationURL rangeOfString:lastPathComp];
            NSString* tempBaseUrl = [_locationURL substringToIndex:range.location];
            fullUrl = [[NSString alloc] initWithFormat:@"%@%@", tempBaseUrl,urlPath];
        }
    }
    return fullUrl;
}

#pragma dealloc and clean code.
- (void)dealloc {
    dispatch_release(serviceParseQueue);
}



@end
