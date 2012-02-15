//
//  LastChangeParser.h
//  UPnP Player HD
//
//  Created by Hao Hu on 08.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LastChange.h"
@interface LastChangeParser : NSObject<NSXMLParserDelegate>
{
    @private
    LastChange* _lastChange;
    NSXMLParser* _parser;
}
-(id) initWithXml:(NSString*) xmlDoc;
-(LastChange*) lastChange;

@end
