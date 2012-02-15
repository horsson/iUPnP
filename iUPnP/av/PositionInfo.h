//
//  PositionInfo.h
//  UPnP Player HD
//
//  Created by Hao Hu on 04.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMediaTime.h"

@interface PositionInfo : NSObject

@property(nonatomic)        NSInteger track;
@property(nonatomic,strong) MMediaTime* trackDuration;
@property(nonatomic,strong) MMediaTime* relTime;
@property(nonatomic,strong) MMediaTime* absTime;
@property(nonatomic,strong) NSString* trackURI;
@property(nonatomic,strong) NSString* trackMetadata;
@property(nonatomic)        NSInteger relCount;
@property(nonatomic)        NSInteger absCount;

@end
