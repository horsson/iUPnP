//
//  UPnPService.h
//  iUPnPTestPrj
//
//  Created by Hao Hu on 26.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MUPnPAction.h"
#import "MUPnPArgument.h"
#import "MUPnPStack.h"

@class MUPnPService;
@protocol UPnPServiceParserDelegate <NSObject>

-(void) parseDidReceiveError:(MUPnPService*) upnpService withError:(NSError*) error;
-(void) parseDidFinish:(MUPnPService*)  upnpService;

@end

@interface MUPnPService : NSObject<NSXMLParserDelegate> {
    NSData* _xmlData;
    NSXMLParser* _xmlParser;
    MUPnPAction* _action;
    MUPnPArgument* _argument;
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
@property(strong)           NSMutableArray* actionList;
@property(nonatomic,assign) UpnpClient_Handle controlPointHandle;
@property(nonatomic,weak) id<UPnPServiceParserDelegate> delegate;


-(id) initWithURL:(NSString*) url timeout:(NSTimeInterval) timeout;
-(void) startParsing;

-(NSUInteger) actionCount;

@end
