//
//  MMediaTime.m
//  Temp
//
//  Created by Hao Hu on 09.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MMediaTime.h"
#import "NSString+Utils.h"

@interface MMediaTime()
-(void) processString;
+(NSString*) formatStringWithHour:(NSUInteger) hour 
                           minute:(NSUInteger) minute 
                           second:(NSUInteger) second
                          isMinus:(BOOL) isMinus;
@end

@implementation MMediaTime
@synthesize stringFormat,hours,minutes,seconds,totalSecond;

-(id) initWithStringFormat:(NSString *)time
{
    self = [super init];
    if (self)
    {
        self.stringFormat = [MMediaTime formatTime:time];
        [self processString];
    }
    return self;
}

-(id) initWithSeconds:(NSInteger) sseconds
{
    self = [super init];
    if (self)
    {
        BOOL isMinus = (sseconds < 0) ? YES : NO;
        NSUInteger tempSecond = abs(sseconds);
        totalSecond = sseconds;
        hours = tempSecond / 3600;
        tempSecond -= hours*3600;
        minutes = tempSecond / 60;
        tempSecond -= minutes*60;
        seconds = tempSecond;
        self.stringFormat = [MMediaTime formatStringWithHour:hours minute:minutes second:seconds isMinus:isMinus];
    }
    return self;
}


+(NSString*) formatTime:(NSString*) time
{
    if (![time isContainsSubString:@"."])
    {
        return time;
    }
    else
    {
        NSArray* parts = [time componentsSeparatedByString:@"."];

        return [parts objectAtIndex:0];
    }
}



-(NSUInteger) totalMins
{
    return totalSecond / 60;
}

-(void) processString
{
    NSArray* parts = [stringFormat componentsSeparatedByString:@":"];
    if ([parts count] == 3)
    {
        hours = [[parts objectAtIndex:0] intValue];
        minutes = [[parts objectAtIndex:1] intValue];
        seconds = [[parts objectAtIndex:2] intValue];
    }
    else if ([parts count] == 2)
    {
        hours = 0;
        minutes = [[parts objectAtIndex:0] intValue];
        seconds = [[parts objectAtIndex:1] intValue];
    }
    else
    {
        hours = 0;
        minutes = 0;
        seconds = 0;
    }
    totalSecond = hours * 3600 + minutes * 60 + seconds; 

}

+(void) processString:(NSString*) time 
                hours:(NSUInteger*) hours 
              minutes:(NSUInteger*) minutes 
              seconds:(NSUInteger*) seconds
          totalSecond:(NSUInteger*) totalSecond
{
    NSArray* parts = [time componentsSeparatedByString:@":"];
    if ([parts count] == 3)
    {
        *hours = [[parts objectAtIndex:0] intValue];
        *minutes = [[parts objectAtIndex:1] intValue];
        *seconds = [[parts objectAtIndex:2] intValue];
    }
    else if ([parts count] == 2)
    {
        *hours = 0;
        *minutes = [[parts objectAtIndex:0] intValue];
        *seconds = [[parts objectAtIndex:1] intValue];
    }
    else
    {
        *hours = 0;
        *minutes = 0;
        *seconds = 0;
    }
    *totalSecond = *hours * 3600 + *minutes * 60 + *seconds; 
}

+(NSString*) formattedStringWitchSecond:(NSInteger) second
{
    BOOL isMinus = (second < 0) ? YES : NO;
    NSUInteger tempSecond = abs(second);
    NSUInteger hours = tempSecond / 3600;
    tempSecond -= hours*3600;
    NSUInteger minutes = tempSecond / 60;
    tempSecond -= minutes*60;
    NSUInteger seconds = tempSecond;
    return [MMediaTime formatStringWithHour:hours minute:minutes second:seconds isMinus:isMinus];
}


+(MMediaTime*) seekMediaTime:(MMediaTime*) mediaTime toPercentage:(NSUInteger) percentage
{
    NSUInteger newTime =  mediaTime.totalSecond * percentage / 100;
    MMediaTime *newMediaTime = [[MMediaTime alloc] initWithSeconds:newTime];
    return newMediaTime;
}

+(MMediaTime*) subtractMediaTime:(MMediaTime*) mediaTimeA withOther:(MMediaTime*) mediaTimeB
{
    NSInteger sec = mediaTimeA.totalSecond - mediaTimeB.totalSecond;
    return [[MMediaTime alloc] initWithSeconds:sec];
}

-(NSString*) formattedStringWithPercentage:(NSUInteger) percentage
{
    NSInteger sec =  self.totalSecond * percentage / 100;
    return [MMediaTime formattedStringWitchSecond:sec];
}

-(NSString*) description
{
    return self.stringFormat;
}


+(NSString*) formatStringWithHour:(NSUInteger) hour 
                           minute:(NSUInteger) minute 
                           second:(NSUInteger) second
                          isMinus:(BOOL)isMinus
{
    if (hour == 0)
    {
        return isMinus ? [NSString stringWithFormat:@"-%02u:%02u",minute,second] :[NSString stringWithFormat:@"%02u:%02u",minute,second];
    }
    else
    {
        return isMinus ? [NSString stringWithFormat:@"-%02u:%02u:%02u",hour,minute,second] :[NSString stringWithFormat:@"%02u:%02u:%02u",hour,minute,second];
    }
    
}

-(NSString*) stringForSeek
{
    return [NSString stringWithFormat:@"%02u:%02u:%02u",hours,minutes,seconds];
}


@end
