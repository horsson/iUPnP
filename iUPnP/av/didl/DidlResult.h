//
//  DidlResult.h
//  UPnP Player HD
//
//  Created by Hao Hu on 04.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DidlResult : NSObject

@property(nonatomic,strong) NSArray* mediaObjects;
@property(nonatomic) NSInteger numberReturned;
@property(nonatomic) NSInteger totalMaches;
@property(nonatomic) NSInteger updateId;

@end
