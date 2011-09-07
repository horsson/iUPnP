//
//  EventParser.h
//  iUPnP
//
//  Created by Hao Hu on 07.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface EventParser : NSObject<NSXMLParserDelegate> {
    @private
    NSXMLParser* _xmlParser;
   
    NSMutableString* _currentString;
}
@property(nonatomic,copy) NSString* XMLString;
@property(nonatomic,retain)  NSMutableDictionary* varValueDict;

-(id) initWithXMLString:(NSString*) xmlString;
-(BOOL) parse;

@end
