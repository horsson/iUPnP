//
//  TransportInfo.h
//  UPnP Player HD
//
//  Created by Hao Hu on 04.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TransportInfo : NSObject

@property(nonatomic,strong) NSString* currentTransportState;
@property(nonatomic,strong) NSString* currentTransportStatus;
@property(nonatomic,strong) NSString* currentSpeed;

@end
