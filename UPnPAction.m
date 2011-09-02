//
//  UPnPAction.m
//  iUPnPTestPrj
//
//  Created by Hao Hu on 29.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UPnPAction.h"
@interface UPnPAction() 
-(int) getXmlDocForAction:(IXML_Document**) xmlDoc;

@end

@implementation UPnPAction
@synthesize argumentList,name,controlPointHandle;


-(void) setServiceType:(NSString*) newServiceType
{
    [serviceType release];
    serviceType = [newServiceType copy];
}

-(void) setControlURL:(NSString*) newControlURL
{
    [controlURL release];
    controlURL = [newControlURL copy];
}
-(void) setDeviceUDN:(NSString*) newDeviceUDN
{
    [deviceUDN release];
    deviceUDN = [newDeviceUDN copy];
}

-(UPnPArgument*) getArgumentByName:(NSString*) argumentName
{
    for (UPnPArgument* anArg in argumentList) {
        if ([argumentName isEqualToString:anArg.name])
            return anArg;
    }
    return nil;
}

-(void) setArgumentStringVal:(NSString*) val forName:(NSString*) argumentName
{
    for (UPnPArgument* anArg in argumentList) {
        if ([argumentName isEqualToString:anArg.name] && (anArg.direction == UPnPArgumentDirectionIn))
        {
            anArg.strValue = val;
            anArg.valueType = UPnPArgumentValueString;
        }
    }
}



-(NSString*) getArgumentStringVal:(NSString*) argumentName
{
   UPnPArgument* arg =  [self getArgumentByName:argumentName];
   if (arg)
   {
       return  arg.strValue;
   }
    else
    {
        return  nil;
    }
}

-(int) sendActionSync
{
    IXML_Document* actionNode = NULL;
    
    IXML_Document* actionResp = NULL;//=ixmlDocument_createDocument();
    
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
    [respData release];
    [respParser setDelegate:self];
    [respParser parse];
    [respParser release];
    return result;
}


-(int) getXmlDocForAction:(IXML_Document**) xmlDoc
{
    const char* pcharActionName = [name cStringUsingEncoding:NSUTF8StringEncoding];
    const char* pcharServiceType = [serviceType cStringUsingEncoding:NSUTF8StringEncoding];
    const char* pcharArgName = NULL;
    const char* pcharArgValue = NULL;
    for (UPnPArgument* anArg in argumentList) {
        if ([anArg isInArgument])
        {
            pcharArgName = [anArg.name cStringUsingEncoding:NSUTF8StringEncoding];
            pcharArgValue = [anArg.strValue cStringUsingEncoding:NSUTF8StringEncoding];
            if (pcharArgValue) {
                UpnpAddToAction(xmlDoc, pcharActionName, pcharServiceType, pcharArgName, pcharArgValue);
            }
            else
                return UPNP_E_INVALID_ARGUMENT;
        }
    }
    return UPNP_E_SUCCESS;
}


- (void)dealloc {
    [controlURL release];
    [deviceUDN release];
    [serviceType release];
    [argumentList release];
    [name release];
    [super dealloc];
}


#pragma NSXMLParser delegate method.
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
    //DEBUG
    if (_contentStr)
    {
        [_contentStr release];
        _contentStr = nil;
    }
    _contentStr = [[NSMutableString alloc] init];
  
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    UPnPArgument* arg = [self getArgumentByName:elementName];
    if (arg)
    {
        arg.strValue = _contentStr;
        [_contentStr release];
        _contentStr = nil;
    }
    
    if (_contentStr) {
        [_contentStr release];
        _contentStr = nil;
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    [_contentStr appendString:string];
}

@end
