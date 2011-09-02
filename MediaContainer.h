//
//  MediaContainer.h
//  iUPnP
//
//  Created by Hao Hu on 02.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MediaObject.h"

@interface MediaContainer : MediaObject {
    
}

@property(nonatomic,assign) NSUInteger childCount;
@property(nonatomic,assign) NSUInteger searchable;

@end
