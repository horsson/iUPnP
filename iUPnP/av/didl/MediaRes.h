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

@property(nonatomic,strong)   NSString* protocolInfo;
@property(nonatomic,strong)   NSString* duration;
@property(nonatomic,strong)   NSString* resUrl;
@property(nonatomic,strong)   NSString* resolution;
@property(nonatomic,assign) UInt64 size;
@property (nonatomic,assign) NSUInteger bitrate;

-(NSString*) relativeUrl;
@end

@interface NSString(MediaRes)
-(NSInteger) resolutionWidth;
-(NSInteger) resolutionHeight;
-(NSInteger) resolutionSize;
@end
