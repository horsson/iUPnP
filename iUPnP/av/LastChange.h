//
//  LastChange.h
//  UPnP Player HD
//
//  Created by Hao Hu on 08.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LastChange : NSObject
{
    NSString* _xmlString;
}

@property(nonatomic,copy) NSString* instanceId;
@property(nonatomic,copy) NSString* currentTrackURI;
@property(nonatomic,copy) NSString* avtransportURI;
@property(nonatomic,copy) NSString* transportState;
@property(nonatomic,copy) NSString* transportStatus;

@end
