//
//  UPnPDevice.h
//  iUPnPTestPrj
//
//  Created by Hao Hu on 26.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UPnPIcon.h"
#import "UPnPService.h"
#import "upnp.h"

@class UPnPDevice;

@protocol UPnPDDeviceDelegate <NSObject>

-(void) upnpDeviceDidFinishParsing:(UPnPDevice*) upnpDevice;
-(void) upnpDeviceDidReceiveError:(UPnPDevice*)  withError:(NSError*) error; 
@end


@interface UPnPDevice : NSObject<NSXMLParserDelegate,UPnPServiceParserDelegate> {
    @private
    NSData* _xmlData;
    NSXMLParser* _xmlParser;
    NSMutableString* _currentContent;
    UPnPIcon* _icon;
    UPnPService* _service;
  
    NSString* _baseURL;
   // NSArray* _tempServiceList;
    
    NSString* _locationURL;
    NSTimeInterval _timeout;
    dispatch_queue_t serviceParseQueue;
    
    NSUInteger serviceCounter;
    NSUInteger numberOfService;
}

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
@property(nonatomic,retain) NSMutableArray* iconList;
@property(nonatomic,retain) NSMutableDictionary* serviceList;
@property(nonatomic,assign) id<UPnPDDeviceDelegate> delegate;
@property(nonatomic,assign) UpnpClient_Handle controlPointHandle;

-(id) initWithLocationURL:(NSString*) locationURL timeout:(NSTimeInterval) timeout;
-(UPnPService*) getUPnPServiceById:(NSString*) serviceId;
-(UPnPAction*)  getActionByName:(NSString*) actionName;

-(void) startParsing;

@end
