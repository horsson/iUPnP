//
//  NSString+Contains.h
//  UPnP Player HD
//
//  Created by Hao Hu on 31.10.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Utils)
-(BOOL) isContainsSubString:(NSString*) subString;
-(NSString*) trim;
+ (NSString*) stringWithUUID;
+ (NSString*) stringWithNow;
-(BOOL) isNumber;
-(NSString *)encodeString:(NSStringEncoding)encoding;
-(NSString*) relativeUrl;
@end
