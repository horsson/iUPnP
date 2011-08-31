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
    NSMutableArray* _processingService;
    NSArray* _tempServiceList;
    
    NSLock* _upnpServiceLock;
    NSString* _locationURL;
    NSTimeInterval _timeout;
    
}
@property(nonatomic,retain) NSString* deviceType;
@property(nonatomic,retain) NSString* friendlyName;
@property(nonatomic,retain) NSString* manufacturer;
@property(nonatomic,retain) NSString* manufacturerURL;
@property(nonatomic,retain) NSString* modelDescription;
@property(nonatomic,retain) NSString* modelName;
@property(nonatomic,retain) NSString* modelURL;
@property(nonatomic,retain) NSString* modelNumber;
@property(nonatomic,retain) NSString* UDN;
@property(nonatomic,retain) NSString* UPC;
@property(nonatomic,retain) NSString* presentationURL;
@property(nonatomic,retain) NSMutableArray* iconList;
@property(nonatomic,retain) NSMutableDictionary* serviceList;
@property(nonatomic,assign) id<UPnPDDeviceDelegate> delegate;
@property(nonatomic,assign) UpnpClient_Handle controlPointHandle;

-(id) initWithLocationURL:(NSString*) locationURL timeout:(NSTimeInterval) timeout;
-(UPnPService*) getUPnPServiceById:(NSString*) serviceId;
-(UPnPAction*)  getActionByName:(NSString*) actionName;

-(void) startParsing;

@end
