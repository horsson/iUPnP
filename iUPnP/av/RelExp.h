//
//  RelExp.h
//  UPnP Player HD
//
//  Created by Hao Hu on 07.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
	ConditionOperationTypeEqual,
	ConditionOperationTypeNotEqual,
	ConditionOperationTypeLess,
	ConditionOperationTypeLessEqual,
	ConditionOperationTypeGreater,
	ConditionOperationTypeGreaterEqual,
	ConditionOperationTypeContains,
	ConditionOperationTypeDoseNotContain,
	ConditionOperationTypeDerivedFrom,
	ConditionOperationTypeExists
} ConditionOperationType;

@interface RelExp:NSObject
{
	NSString* _name;
	NSString* _value;
	ConditionOperationType _op;
	
}

-(id) initWithValue:(NSString*) value operation:(ConditionOperationType) op forName:(NSString*) name;
-(NSString*) stringFormat;
@end
