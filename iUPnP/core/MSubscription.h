//
//  Subscription.h
//  UPnP Player HD
//
//  Created by Hao Hu on 08.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MSubscription : NSObject

@property(nonatomic,copy) NSString* ssid;
@property(nonatomic) NSInteger timeout;
@property(nonatomic) NSTimeInterval timeStamp;

@end
