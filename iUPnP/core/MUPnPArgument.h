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

@interface MUPnPArgument : NSObject {
}

@property(nonatomic,strong)       NSString* name;
@property(nonatomic,assign)     ArgumentValueType valueType;
@property(nonatomic,assign)     ArgumentDirection direction;
@property(nonatomic,assign)     NSInteger  intValue;
@property(nonatomic,assign)     NSUInteger uintValue;
@property(nonatomic,strong)       NSString*   strValue;
@property(nonatomic,strong)       NSString* relatedStateVariable;

-(BOOL) isInArgument;

@end
