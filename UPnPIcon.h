//
//  UPnPIcon.h
//  iUPnPTestPrj
//
//  Created by Hao Hu on 30.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UPnPIcon : NSObject {
    
}
@property (nonatomic,retain)   NSString* mimetype;
@property (nonatomic,retain)   NSString* url;
@property (nonatomic)           UInt16 width;
@property (nonatomic)           UInt16 height;
@property (nonatomic)           UInt8 depth;

@end
