//
//  ObjectClass.m
//  iUPnP
//
//  Created by Hao Hu on 02.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ObjectClass.h"




@implementation ObjectClass

-(id) initWithString:(NSString *)className
{
    self = [super init];
    if (self)
    {
        _className =className;
        _parts = [_className componentsSeparatedByString:@"."];
        
    }
    return  self;
}

-(BOOL) isItem:(NSString *)itemName
{
    if ([self isContainer])
        return NO;
    else if ([itemName isEqualToString:[_parts objectAtIndex:2]])
        return YES;
    else
        return NO;

}

-(BOOL) isVideoItem
{
    return [self isItem:@"videoItem"]; 
}

-(BOOL) isAudioItem
{
    return [self isItem:@"audioItem"]; 
}

-(BOOL) isImageItem
{
    return [self isItem:@"imageItem"]; 
}


-(BOOL) isContainer
{
    if ([_parts count] < 2)
        return NO;
    if ([@"container" isEqualToString:[_parts objectAtIndex:1]])
    {
        return YES;
    }
    else
        return NO;
}

-(NSString*) stringFormat
{
    return _className;
}

@end
