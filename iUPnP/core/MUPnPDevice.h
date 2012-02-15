//
//  UPnPDevice.h
//  iUPnPTestPrj
//
//  Created by Hao Hu on 26.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MUPnPIcon.h"
#import "MUPnPService.h"
#import "upnp.h"

@class MUPnPDevice;

@protocol UPnPDDeviceDelegate <NSObject>

-(void) upnpDeviceDidFinishParsing:(MUPnPDevice*) upnpDevice;
-(void) upnpDeviceDidReceiveError:(MUPnPDevice*)  withError:(NSError*) error; 
@end


@interface MUPnPDevice : NSObject<NSXMLParserDelegate,UPnPServiceParserDelegate> {
    @private
    NSData* _xmlData;
    NSXMLParser* _xmlParser;
    NSMutableString* _currentContent;
    MUPnPIcon* _icon;
    MUPnPService* _service;
  
    NSString* _baseURL;

    NSString* _locationURL;
    NSTimeInterval _timeout;
    dispatch_queue_t serviceParseQueue;
    
    NSUInteger serviceCounter;
    NSUInteger numberOfService;
}
@property(nonatomic,copy) NSString* hostIpAddress;
@property(nonatomic,copy) NSString* deviceType;
@property(nonatomic,copy) NSString* friendlyName;
@property(nonatomic,copy) NSString* manufacturer;
@property(nonatomic,copy) NSString* manufacturerURL;
@property(nonatomic,copy) NSString* modelDescription;
@property(nonatomic,copy) NSString* modelName;
@property(nonatomic,copy) NSString* modelURL;
@property(nonatomic,copy) NSString* modelNumber;
@property(nonatomic,copy) NSString* UDN;
@property(nonatomic,copy) NSString* UPC;
@property(nonatomic,copy) NSString* presentationURL;
@property(nonatomic,strong) NSMutableArray* iconList;
@property(nonatomic,strong) NSMutableDictionary* serviceList;
@property(nonatomic,weak) id<UPnPDDeviceDelegate> delegate;
@property(nonatomic,assign) UpnpClient_Handle controlPointHandle;

-(id) initWithLocationURL:(NSString*) locationURL timeout:(NSTimeInterval) timeout;
-(MUPnPService*) getUPnPServiceById:(NSString*) serviceId;
-(MUPnPAction*)  getActionByName:(NSString*) actionName;

-(void) startParsing;

@end
