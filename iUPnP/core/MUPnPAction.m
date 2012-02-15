//
//  UPnPAction.m
//  iUPnPTestPrj
//
//  Created by Hao Hu on 29.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MUPnPAction.h"

@interface MUPnPAction() 
-(int) getXmlDocForAction:(IXML_Document**) xmlDoc;

@end

@implementation MUPnPAction
@synthesize argumentList,name,controlPointHandle;

-(id) init
{
    self = [super init];
    if (self)
    {
        [self setMaxContentLength:UPNP_ACTION_MAX_CONTENT_LENGTH];
    }
    return self;
}

-(void) setServiceType:(NSString*) newServiceType
{
    serviceType = [newServiceType copy];
}

-(void) setControlURL:(NSString*) newControlURL
{
    controlURL = [newControlURL copy];
}
-(void) setDeviceUDN:(NSString*) newDeviceUDN
{
    deviceUDN = [newDeviceUDN copy];
}

-(MUPnPArgument*) getArgumentByName:(NSString*) argumentName
{
    for (MUPnPArgument* anArg in argumentList) {
        if ([argumentName isEqualToString:anArg.name])
            return anArg;
    }
    return nil;
}

-(void) setArgumentStringVal:(NSString*) val forName:(NSString*) argumentName
{
    for (MUPnPArgument* anArg in argumentList) {
        if ([argumentName isEqualToString:anArg.name] && (anArg.direction == UPnPArgumentDirectionIn))
        {
            anArg.strValue = val;
            anArg.valueType = UPnPArgumentValueString;
        }
    }
}

-(void) setArgumentIntVal:(NSInteger) val forName:(NSString*) argumentName
{
    NSString* strVal = [[NSString alloc] initWithFormat:@"%d", val];
    [self setArgumentStringVal:strVal forName:argumentName];
}



-(NSString*) getArgumentStringVal:(NSString*) argumentName
{
   MUPnPArgument* arg =  [self getArgumentByName:argumentName];
   if (arg)
   {
       return  arg.strValue;
   }
    else
    {
        return  nil;
    }
}

-(NSInteger) getArgumentIntVal:(NSString*) argumentName
{
    NSString* tempVal = [self getArgumentStringVal:argumentName];
    return [tempVal intValue];
}

-(int) sendActionSync
{
    IXML_Document* actionNode = NULL;
    
    IXML_Document* actionResp = NULL;

    int ret =  [self getXmlDocForAction:&actionNode] ;
    if (ret != UPNP_E_SUCCESS)
    {
        return ret;
    }
    
    const char* pcharActonurl = [controlURL cStringUsingEncoding:NSUTF8StringEncoding];
    const char* pcharServiceType = [serviceType cStringUsingEncoding:NSUTF8StringEncoding];
    const char* pcharUDN = [deviceUDN cStringUsingEncoding:NSUTF8StringEncoding];
    int result = UpnpSendAction(controlPointHandle, pcharActonurl, pcharServiceType, pcharUDN, actionNode, &actionResp);
    
    if (result != UPNP_E_SUCCESS)
    {
        if (actionResp != NULL)
            ixmlDocument_free(actionResp);
        ixmlDocument_free(actionNode);
        return result;
    }
    ixmlDocument_free(actionNode);
    
    //Parser the result.
    char* pcharResult = ixmlDocumenttoString(actionResp);
    
    ixmlDocument_free(actionResp);
    
    if (pcharResult == NULL)
    {
        
      return UPNP_E_INTERNAL_ERROR;      
    }
    
    NSData* respData = [[NSData alloc] initWithBytes:pcharResult length:strlen(pcharResult)];
    free(pcharResult);
    
    NSXMLParser* respParser = [[NSXMLParser alloc] initWithData:respData];
    [respParser setDelegate:self];
    [respParser parse];
    return result;
}


-(void) setMaxContentLength:(size_t)contentLength
{
    UpnpSetMaxContentLength(contentLength);
}

-(int) getXmlDocForAction:(IXML_Document**) xmlDoc
{
    const char* pcharActionName = [name cStringUsingEncoding:NSUTF8StringEncoding];
    const char* pcharServiceType = [serviceType cStringUsingEncoding:NSUTF8StringEncoding];
    
    const char* pcharArgName = NULL;
    const char* pcharArgValue = NULL;
    
    BOOL hasInArgument = NO;
    
    for (MUPnPArgument* anArg in argumentList) {
        if ([anArg isInArgument])
        {
            hasInArgument = YES;
            pcharArgName = [anArg.name cStringUsingEncoding:NSUTF8StringEncoding];
            pcharArgValue = [anArg.strValue cStringUsingEncoding:NSUTF8StringEncoding];
            if (pcharArgValue) {
                UpnpAddToAction(xmlDoc, pcharActionName, pcharServiceType, pcharArgName, pcharArgValue);
            }
            else
                return UPNP_E_INVALID_ARGUMENT;
        }
    }
    if (hasInArgument) {
        return UPNP_E_SUCCESS;
    }
    else
    {
        *xmlDoc =  UpnpMakeAction(pcharActionName, pcharServiceType, 0, NULL);
        return UPNP_E_SUCCESS;
    }
}




#pragma NSXMLParser delegate method.
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
    _contentStr = [[NSMutableString alloc] init];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    MUPnPArgument* arg = [self getArgumentByName:elementName];
    if (arg)
    {
        arg.strValue = _contentStr;
        _contentStr = nil;
    }
}


- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    [_contentStr appendString:string];
}

@end
