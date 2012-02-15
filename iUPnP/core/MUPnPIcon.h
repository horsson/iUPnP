//
//  UPnPIcon.h
//  iUPnPTestPrj
//
//  Created by Hao Hu on 30.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MUPnPIcon : NSObject {
    
}
@property (nonatomic,copy)   NSString* mimetype;
@property (nonatomic,copy)   NSString* url;
@property (nonatomic)           UInt16 width;
@property (nonatomic)           UInt16 height;
@property (nonatomic)           UInt8 depth;

@end
