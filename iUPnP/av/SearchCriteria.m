//
//  SearchCriteria.m
//  UPnP Player HD
//
//  Created by Hao Hu on 07.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SearchCriteria.h"

@implementation SearchCriteria

-(id) init
{
    self = [super init];
    if (self)
    {
        _stringFormat  = [[NSMutableString alloc] init];
    }
    return self;
}

-(id) initWithRelExp:(RelExp*) relExp
{
    self = [self init];
    if (self)
    {
        [_stringFormat appendFormat:@"%@ ", [relExp stringFormat]];
    }
    return self;
}

-(void) addSingleRelExp:(RelExp*) relExp
{
    [_stringFormat appendFormat:@"%@ ", [relExp stringFormat]];
}

-(void) addRelExp:(RelExp*) relExp logOp:(LogicOperationType) logOp theOtherRelExp:(RelExp*) theOtherRelExp
{
    static NSString* andPattern = @"%@ and %@ ";
    static NSString* orPattern = @"%@ or %@ ";
    switch (logOp) {
        case LogicOperationOr:
            [_stringFormat appendFormat:orPattern, [relExp stringFormat], [theOtherRelExp stringFormat]];
            break;
        case LogicOperationAnd:
            [_stringFormat appendFormat:andPattern, [relExp stringFormat], [theOtherRelExp stringFormat]];
            break;
    }
}

-(NSString*) stringFormat
{
    return [_stringFormat stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}
@end
