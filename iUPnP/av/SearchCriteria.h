//
//  SearchCriteria.h
//  UPnP Player HD
//
//  Created by Hao Hu on 07.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RelExp.h"


typedef enum
{
	LogicOperationAnd,
	LogicOperationOr
} LogicOperationType;






#pragma mark - SearchCriteria class
@interface SearchCriteria : NSObject
{
    @private
    NSMutableString* _stringFormat;
}

-(id) initWithRelExp:(RelExp*) relExp;

-(void) addSingleRelExp:(RelExp*) relExp;
-(void) addRelExp:(RelExp*) relExp logOp:(LogicOperationType) logOp theOtherRelExp:(RelExp*) theOtherRelExp;
-(NSString*) stringFormat;

@end