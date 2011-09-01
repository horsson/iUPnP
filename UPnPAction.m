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

//TODO Maybe support in next version.
/*
-(void) setArgumentIntVal:(NSInteger) val forName:(NSString*) argumentName
{
    for (UPnPArgument* anArg in argumentList) {
        if ([argumentName isEqualToString:anArg.name] && (anArg.direction == UPnPArgumentDirectionIn))
        {
            anArg.intValue = val;
            anArg.valueType = UPnPArgumentValueInt;
        }
    }
}

-(void) setArgumentUIntVal:(NSUInteger) val forName:(NSString*) argumentName
{
    for (UPnPArgument* anArg in argumentList) {
        if ([argumentName isEqualToString:anArg.name] && (anArg.direction == UPnPArgumentDirectionIn))
        {
            anArg.uintValue = val;
            anArg.valueType = UPnPArgumentValueUInt;
        }
    }
}
*/

-(void) getArgumentStringVal:(NSString*) argumentName
{
    
}

-(int) sendActionSync
{
    IXML_Document* actionNode = NULL;
    IXML_Document* actionResp =ixmlDocument_createDocument();
    [self getXmlDocForAction:&actionNode];
    const char* pcharActonurl = [controlURL cStringUsingEncoding:NSUTF8StringEncoding];
    const char* pcharServiceType = [serviceType cStringUsingEncoding:NSUTF8StringEncoding];
    const char* pcharUDN = [deviceUDN cStringUsingEncoding:NSUTF8StringEncoding];
    int result = UpnpSendAction(controlPointHandle, pcharActonurl, pcharServiceType, pcharUDN, actionNode, &actionResp);
    
    
    
    ixmlDocument_free(actionResp);
    ixmlDocument_free(actionNode);
    
    
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
@end
