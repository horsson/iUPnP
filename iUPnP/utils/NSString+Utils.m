//
//  NSString+Contains.m
//  UPnP Player HD
//
//  Created by Hao Hu on 31.10.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "NSString+Utils.h"

@implementation NSString (Utils)
-(BOOL) isContainsSubString:(NSString*) subString
{
    NSRange subRange = [self rangeOfString:subString options:NSCaseInsensitiveSearch];
    if (subRange.location == NSNotFound)
    {
        return NO;
    }
    else
        return YES;
}

-(NSString*) trim
{
     return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

+ (NSString*) stringWithUUID {
    CFUUIDRef	uuidObj = CFUUIDCreate(nil);//create a new UUID
    //get the string representation of the UUID
    NSString	*uuidString = (__bridge_transfer NSString*)CFUUIDCreateString(nil, uuidObj);
    CFRelease(uuidObj);
    return uuidString;
}

+ (NSString*) stringWithNow
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"HH:mm:ss yyyy-MM-dd"];
	NSDate* now = [NSDate date];
	return [dateFormat stringFromDate:now];
}

-(BOOL) isNumber
{
    for (int i = 0; i < self.length; i++) 
    {
        unichar ch = [self characterAtIndex:i];
        if (ch >= 48 && ch <= 57) {
            continue;
        }
        else
        {
            return NO;
        }
    }
    return YES;
}

- (NSString *)encodeString:(NSStringEncoding)encoding
{
    return (__bridge NSString *) CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef)self,
                                                                NULL, (CFStringRef)@";/?:@&=$+{}<>,",
                                                                CFStringConvertNSStringEncodingToEncoding(encoding));
} 

-(NSString*) relativeUrl
{
    NSURL* url = [[NSURL alloc] initWithString:self];
    NSInteger port = [url.port intValue];
    if (port == 0) 
    {
        port = 80;
    }
    NSString* query = url.query;
    NSString* relativePath = url.relativePath;
    if (query) 
    {
        return [NSString stringWithFormat:@"%d%@?%@",port,relativePath,query];
    }
    else
    {
        return [NSString stringWithFormat:@"%d%@", port,relativePath];
    }

}

@end
