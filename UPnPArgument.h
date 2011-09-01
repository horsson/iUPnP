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

typedef enum _ArgumentValueType {
    UPnPArgumentValueString,
    UPnPArgumentValueInt,
    UPnPArgumentValueUInt
} ArgumentValueType;

@interface UPnPArgument : NSObject {
}

@property(nonatomic,copy)       NSString* name;
@property(nonatomic,assign)     ArgumentValueType valueType;
@property(nonatomic,assign)     ArgumentDirection direction;
@property(nonatomic,assign)     NSInteger  intValue;
@property(nonatomic,assign)     NSUInteger uintValue;
@property(nonatomic,copy)       NSString*   strValue;
@property(nonatomic,copy)       NSString* relatedStateVariable;

-(BOOL) isInArgument;

@end
