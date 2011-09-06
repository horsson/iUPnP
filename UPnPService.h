//
//  UPnPService.h
//  iUPnPTestPrj
//
//  Created by Hao Hu on 26.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UPnPAction.h"
#import "UPnPArgument.h"
#import "UPnPStack.h"

@class UPnPService;
@protocol UPnPServiceParserDelegate <NSObject>

-(void) parseDidReceiveError:(UPnPService*) upnpService withError:(NSError*) error;
-(void) parseDidFinish:(UPnPService*)  upnpService;

@end

@interface UPnPService : NSObject<NSXMLParserDelegate> {
    NSData* _xmlData;
    NSXMLParser* _xmlParser;
    UPnPAction* _action;
    UPnPArgument* _argument;
    NSMutableString *_currentContent;
    NSString* _lastElement;
    NSString* _currentElement;
    NSTimeInterval _timeout;
}
@property(nonatomic,copy) NSString* serviceType;
@property(nonatomic,copy) NSString* serviceId;
@property(nonatomic,copy) NSString* SCPDURL;
@property(nonatomic,copy) NSString* eventSubURL;
@property(nonatomic,copy) NSString* controlURL;
@property(retain)           NSMutableArray* actionList;
@property(nonatomic,assign) UpnpClient_Handle controlPointHandle;
@property(nonatomic,assign) id<UPnPServiceParserDelegate> delegate;


-(id) initWithURL:(NSString*) url timeout:(NSTimeInterval) timeout;
-(void) startParsing;

-(NSUInteger) actionCount;

@end
