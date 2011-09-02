//
//  MediaRes.h
//  iUPnP
//
//  Created by Hao Hu on 02.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MediaRes : NSObject {
    
}

@property(nonatomic,copy)   NSString* protocolInfo;
@property(nonatomic,copy)   NSString* duration;
@property(nonatomic,copy)   NSString* resUrl;
@property(nonatomic,copy)   NSString* resolution;
@property(nonatomic,assign) UInt64 size;
@property (nonatomic,assign) NSUInteger bitrate;

@end
