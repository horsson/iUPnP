//
//  ObjectClass.h
//  iUPnP
//
//  Created by Hao Hu on 02.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ObjectClass : NSObject {
    @private
    NSString* _className;
    NSArray* _parts;
}

-(id) initWithString:(NSString*) className;

-(BOOL) isVideoItem;
-(BOOL) isAudioItem;
-(BOOL) isImageItem;
-(BOOL) isContainer;
-(BOOL) isItem:(NSString*) itemName;

-(NSString*) stringFormat;
@end
