//
//  UPnPArgument.m
//  iUPnPTestPrj
//
//  Created by Hao Hu on 29.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UPnPArgument.h"


@implementation UPnPArgument
@synthesize name,direction,relatedStateVariable,valueType,strValue,intValue,uintValue;

-(BOOL) isInArgument
{
    return (direction == UPnPArgumentDirectionIn);
}


@end
