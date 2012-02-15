//
//  MMediaTime.h

//
//  Created by Hao Hu on 09.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
//MMediaTime stands for a time object, the representation is like:
// HH:MM:SS

@interface MMediaTime : NSObject {

}

@property(nonatomic,copy) NSString* stringFormat;
@property(nonatomic,readonly) NSUInteger hours;
@property(nonatomic,readonly) NSUInteger minutes;
@property(nonatomic,readonly) NSUInteger seconds;
@property(nonatomic,readonly) NSInteger totalSecond;

-(id) initWithStringFormat:(NSString*) time;
-(id) initWithSeconds:(NSInteger) seconds;
-(NSString*) formattedStringWithPercentage:(NSUInteger) percentage;
-(NSUInteger) totalMins;
-(NSString*) stringForSeek;

+(MMediaTime*) subtractMediaTime:(MMediaTime*) mediaTimeA withOther:(MMediaTime*) mediaTimeB;
+(MMediaTime*) seekMediaTime:(MMediaTime*) mediaTime toPercentage:(NSUInteger) percentage;
+(NSString*) formattedStringWitchSecond:(NSInteger) second;
+(NSString*) formatTime:(NSString*) time;



+(void) processString:(NSString*) time 
                hours:(NSUInteger*) hours 
              minutes:(NSUInteger*) minutes 
              seconds:(NSUInteger*) seconds
          totalSecond:(NSUInteger*) totalSecond;


@end
