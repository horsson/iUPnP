//
//  UPnPArgument.h
//  iUPnPTestPrj
//
//  Created by Hao Hu on 29.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum _ArgumentDirection{
    UPnPArgumentDirectionOut,
    UPnPArgumentDirectionIn
} ArgumentDirection;


@interface UPnPArgument : NSObject {
    
}
@property(nonatomic,retain) NSString* name;
@property(nonatomic) ArgumentDirection direction;
@property(nonatomic,retain) NSString* relatedStateVariable;

@end
