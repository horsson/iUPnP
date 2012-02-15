//
//  MediaItem.h
//  iUPnP
//
//  Created by Hao Hu on 02.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MediaObject.h"

@interface MediaItem : MediaObject {
    
}
@property(nonatomic,strong) NSString* metadata;
@property(nonatomic,strong) NSString* refID;

//Release all the metadata.
-(void) releaseMetadata;

@end
