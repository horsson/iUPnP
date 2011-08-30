//
//  UPnPAction.m
//  iUPnPTestPrj
//
//  Created by Hao Hu on 29.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UPnPAction.h"


@implementation UPnPAction
@synthesize argumentList,name;

- (void)dealloc {
    [argumentList release];
    [name release];
    [super dealloc];
}
@end
