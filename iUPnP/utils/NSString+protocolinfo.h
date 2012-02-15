//
//  NSString+protocolinfo.h
//  UPnP Player HD
//
//  Created by Hao Hu on 16.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (protocolinfo)

-(NSString*) protocolForProtocolInfo;
-(NSString*) networkForProtocolInfo;
-(NSString*) contentFormatForProtocolInfo;
-(NSString*) additionalInfoForProtocolInfo;
@end
