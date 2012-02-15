//
//  UPnPArgument.m
//  iUPnPTestPrj
//
//  Created by Hao Hu on 29.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MUPnPArgument.h"


@implementation MUPnPArgument
@synthesize name,direction,relatedStateVariable,valueType,strValue,intValue,uintValue;

-(BOOL) isInArgument
{
    return (direction == UPnPArgumentDirectionIn);
}


@end
