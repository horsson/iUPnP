//
//  UPnPAction.m
//  iUPnPTestPrj
//
//  Created by Hao Hu on 29.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UPnPAction.h"


@implementation UPnPAction
@synthesize argumentList,name,controlPointHandle,parentService;



-(UPnPArgument*) getArgumentByName:(NSString*) argumentName
{
    for (UPnPArgument* anArg in argumentList) {
        if ([argumentName isEqualToString:anArg.name])
            return anArg;
    }
    return nil;
}

-(void) setArgumentStringVal:(NSString*) val forName:(NSString*) argumentName
{
    for (UPnPArgument* anArg in argumentList) {
        if ([argumentName isEqualToString:anArg.name] && (anArg.direction == UPnPArgumentDirectionIn))
        {
            anArg.strValue = val;
            anArg.valueType = UPnPArgumentValueString;
        }
    }
}

-(void) setArgumentIntVal:(NSInteger) val forName:(NSString*) argumentName
{
    for (UPnPArgument* anArg in argumentList) {
        if ([argumentName isEqualToString:anArg.name] && (anArg.direction == UPnPArgumentDirectionIn))
        {
            anArg.intValue = val;
            anArg.valueType = UPnPArgumentValueInt;
        }
    }
}

-(void) setArgumentUIntVal:(NSUInteger) val forName:(NSString*) argumentName
{
    for (UPnPArgument* anArg in argumentList) {
        if ([argumentName isEqualToString:anArg.name] && (anArg.direction == UPnPArgumentDirectionIn))
        {
            anArg.uintValue = val;
            anArg.valueType = UPnPArgumentValueUInt;
        }
    }
}

-(void) getArgumentStringVal:(NSString*) argumentName
{

}

-(int) sendActionSync
{
    return 0;
}



- (void)dealloc {
    [parentService release];
    [argumentList release];
    [name release];
    [super dealloc];
}
@end
