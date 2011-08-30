//
//  UPnPArgument.m
//  iUPnPTestPrj
//
//  Created by Hao Hu on 29.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UPnPArgument.h"


@implementation UPnPArgument
@synthesize name,direction,relatedStateVariable;

- (void)dealloc {
    [name release];
    [relatedStateVariable release];
    [super dealloc];
}
@end
