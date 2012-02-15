//
//  RelExp.m
//  UPnP Player HD
//
//  Created by Hao Hu on 07.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "RelExp.h"

@implementation RelExp
-(id) initWithValue:(NSString*) value operation:(ConditionOperationType) op forName:(NSString*) name
{
    self = [super init];
	if (self)
    {
        _name = name;
        _value = value;
        _op = op;
    }
    return self;
}

-(NSString*) stringFormat
{
	static NSString* opPattern = @"%@ %@ \"%@\"";
	NSString* result;
	switch(_op)
	{
		case ConditionOperationTypeEqual:
            result = [NSString stringWithFormat:opPattern, _name, @"=", _value];
            break;
		case ConditionOperationTypeNotEqual:
            result = [NSString stringWithFormat:opPattern, _name, @"!=", _value];
            break;
		case ConditionOperationTypeLess:
            result = [NSString stringWithFormat:opPattern, _name, @"<", _value];
            break;
		case ConditionOperationTypeLessEqual:
            result = [NSString stringWithFormat:opPattern, _name, @"<=", _value];
            break;
		case ConditionOperationTypeGreater:
            result = [NSString stringWithFormat:opPattern, _name, @">", _value];
            break;
		case ConditionOperationTypeGreaterEqual:
            result = [NSString stringWithFormat:opPattern, _name, @">=", _value];
            break;
		case ConditionOperationTypeContains:
            result = [NSString stringWithFormat:opPattern, _name, @"contains", _value];
            break;
		case ConditionOperationTypeDoseNotContain:
            result = [NSString stringWithFormat:opPattern, _name, @"doesNotContain", _value];
            break;
		case ConditionOperationTypeDerivedFrom:
            result = [NSString stringWithFormat:opPattern, _name, @"derivedfrom", _value];
            break;
		case ConditionOperationTypeExists:
            result = [NSString stringWithFormat:opPattern, _name, @"exists", _value];
            break;
	}
	return result;
}

@end