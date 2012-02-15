//
//  UPnPMediaServer.m
//  UPnP Player HD
//
//  Created by Hao Hu on 26.10.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MUPnPMediaServer.h"
#import "MUPnPAction.h"
#import "MUPnPControlPoint.h"
#import "DidlParser.h"

NSString* const kBrowserFlagMetaData = @"BrowseMetadata";
NSString* const kBrowserFlagDirectChildren = @"BrowseDirectChildren";

@interface MUPnPMediaServer()
- (MUPnPAction *)getBrowseActionWithObjectId:(NSString *)objectId 
                           flag:(NSString *)flag 
                         filter:(NSString *)filter 
                     startIndex:(NSInteger)startIndex 
                          count:(NSInteger)count 
                           sort:(NSString *)sort;
-(MUPnPAction*) getSearchActionWithContainerId:(NSString*) containerId
                               searchCriteria:(NSString*) searchCriteria 
                                       filter:(NSString*) filter 
                                startingIndex:(NSInteger) startingIndex 
                                 requestCount:(NSInteger) count  
                                 sortCriteria:(NSString*) sort;
@end


@implementation MUPnPMediaServer
@synthesize upnpDevice,delegate;

-(id) initWithUPnPDevice:(MUPnPDevice *)device
{
    self = [super init];
    
    if (self)
    {
        self.upnpDevice = device;
        _ctrlPoint = [MUPnPControlPoint sharedUPnPControlPoint];
        _isTested = NO;
    }
    return self;
}

-(void) setIsAccessible:(BOOL)isAccessible
{
    _isAccessible =isAccessible;
}

-(BOOL) isAccessible
{
    if (_isTested) {
        return _isAccessible;
    }

    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        MUPnPAction* action = [self getBrowseActionWithObjectId:@"0" flag:kBrowserFlagMetaData filter:@"container" startIndex:0 count:1 sort:@""];
        int result = [action sendActionSync];
        if (result == UPNP_E_SUCCESS) {
            _isAccessible = YES;
        }
        else
        {
            _isAccessible = NO;
        }
    });
    _isTested = YES;
    return _isAccessible;
}

#pragma mark - ContentDirectoryService


-(void) browseWithObjectId:(NSString*) objectId 
                browseFlag:(NSString*) flag 
                    filter:(NSString*) filter
                startIndex:(NSInteger) startIndex
              requestCount:(NSInteger) count 
              sortCriteria:(NSString*) sort
                    isSerialQueue:(BOOL) isSync;

{
    
    MUPnPAction *action;
    action = [self getBrowseActionWithObjectId:objectId flag:flag filter:filter startIndex:startIndex count:count sort:sort];

    dispatch_block_t executionBlock = ^(void){
        int result = [action sendActionSync];
        if (result == UPNP_E_SUCCESS) 
        {
            NSString* didlResult = [action getArgumentStringVal:@"Result"];
            NSInteger numberReturned = [action getArgumentIntVal:@"NumberReturned"];
            NSInteger totalMached = [action getArgumentIntVal:@"TotalMatches"];
            DidlParser* parser = [[DidlParser alloc] initWithString:didlResult];
            [parser parse];
            NSArray* mediaObjects = [parser mediaObjects];
            
            
            if ([delegate respondsToSelector:@selector(upnpMediaServer:didReceivedMediaObjects:objectId:numberReturned:totalMaches:)]) 
            {
                [delegate upnpMediaServer:self didReceivedMediaObjects:mediaObjects objectId:objectId numberReturned:numberReturned totalMaches:totalMached];
            }
        }
        else
        {
            NSLog(@"Error: Cannot send Browse action to the Server. the reason is %s", UpnpGetErrorMessage(result));
            if ([delegate respondsToSelector:@selector(upnpMediaServerDidReceiveFail:)])
            {
                [delegate upnpMediaServerDidReceiveFail:self];
            }
        }

    };
    
    if (isSync) {
         dispatch_sync(_ctrlPoint->actionQueue, executionBlock);
    }
    else
    {
        dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
        dispatch_async(queue, executionBlock);
    }
}

-(void) browseWithObjectId:(NSString*) objectId 
                browseFlag:(NSString*) flag 
                    filter:(NSString*) filter
                startIndex:(NSInteger) startIndex
              requestCount:(NSInteger) count 
              sortCriteria:(NSString*) sort
                     block:(MediaServer_browse_blk) cb_block
                    isSerialQueue:(BOOL) isSync;
{
    MUPnPAction *action;
    action = [self getBrowseActionWithObjectId:objectId flag:flag filter:filter startIndex:startIndex count:count sort:sort];
    
     dispatch_block_t executionBlock = ^(void){
         int result = [action sendActionSync];
         if (result == UPNP_E_SUCCESS) 
         {
             NSString* didlResult = [action getArgumentStringVal:@"Result"];
             NSInteger numberReturned = [action getArgumentIntVal:@"NumberReturned"];
             NSInteger totalMached = [action getArgumentIntVal:@"TotalMatches"];
             DidlParser* parser = [[DidlParser alloc] initWithString:didlResult];
             [parser parse];
             NSArray* mediaObjects = [parser mediaObjects];
             cb_block(YES,mediaObjects,numberReturned,totalMached,nil);
         }
         else
         {
             NSLog(@"Error: Cannot send Browse action to the Server. the reason is %s", UpnpGetErrorMessage(result));
             NSError* err = [[NSError alloc] initWithUPnPError:result];
             cb_block(NO,nil,0,-1,&err);
         }         
     };
    if (isSync)
    {
        dispatch_sync(_ctrlPoint->actionQueue, executionBlock);
    }
    else
    {
        dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
        dispatch_async(queue, executionBlock);
    }
}

-(DidlResult*) syncBrowseWithObjectId:(NSString*) objectId 
                           browseFlag:(NSString*) flag 
                               filter:(NSString*) filter
                           startIndex:(NSInteger) startIndex
                         requestCount:(NSInteger) count 
                         sortCriteria:(NSString*) sort 
                                error:(NSError**) error
{
    MUPnPAction* action = [self getBrowseActionWithObjectId:objectId flag:flag filter:filter startIndex:startIndex count:count sort:sort];

    if (action == nil) {
        *error = [[NSError alloc] initWithUPnPError:UPNP_E_NOT_FOUND];
        return nil;
    }
    
    int result = [action sendActionSync];
    if (result == UPNP_E_SUCCESS) 
    {
        NSString* didlResult = [action getArgumentStringVal:@"Result"];
        NSInteger numberReturned = [action getArgumentIntVal:@"NumberReturned"];
        NSInteger totalMaches = [action getArgumentIntVal:@"TotalMatches"];
        DidlParser* parser = [[DidlParser alloc] initWithString:didlResult];
        [parser parse];
        NSArray* mediaObjects = [parser mediaObjects];
        DidlResult* resToReturn = [[DidlResult alloc] init];
        resToReturn.mediaObjects = mediaObjects;
        resToReturn.numberReturned = numberReturned;
        resToReturn.totalMaches = totalMaches;
        return resToReturn;
    }
    else
    {
        *error = [[NSError alloc] initWithUPnPError:result];
        return nil;
    }
}


-(void) searchContainerId:(NSString*) containerId 
           searchCriteria:(SearchCriteria*) searchCriteria 
                   filter:(NSString*) filter 
            startingIndex:(NSInteger) startingIndex 
             requestCount:(NSInteger) count  
             sortCriteria:(NSString*) sort
{
    
}

-(DidlResult*) syncSearchContainerId:(NSString*) containerId 
                   searchCriteria:(SearchCriteria*) searchCriteria 
                           filter:(NSString*) filter 
                    startingIndex:(NSInteger) startingIndex 
                     requestCount:(NSInteger) count  
                     sortCriteria:(NSString*) sort
                            error:(NSError**) error
{
        
    MUPnPAction* action = [self getSearchActionWithContainerId:containerId searchCriteria:[searchCriteria stringFormat] filter:filter startingIndex:startingIndex requestCount:count sortCriteria:sort];
    if (action == nil) 
    {
        //Hao: Debug
        //*error = [[NSError alloc] initWithUPnPError:UPNP_E_NOT_FOUND];
        return nil;
    }
    
    int result = [action sendActionSync];
    if (result == UPNP_E_SUCCESS) 
    {
        NSString* didlResult = [action getArgumentStringVal:@"Result"];
        NSInteger numberReturned = [action getArgumentIntVal:@"NumberReturned"];
        NSInteger totalMaches = [action getArgumentIntVal:@"TotalMatches"];
        DidlParser* parser = [[DidlParser alloc] initWithString:didlResult];
        [parser parse];
        NSArray* mediaObjects = [parser mediaObjects];
        DidlResult* resToReturn = [[DidlResult alloc] init];
        resToReturn.mediaObjects = mediaObjects;
        resToReturn.numberReturned = numberReturned;
        resToReturn.totalMaches = totalMaches;
        return resToReturn;
    }
    else
    {
        //FIXME:
        NSLog(@"Cannot send Search action. The reason is %s. The code is %d", UpnpGetErrorMessage(result), result);
        //*error = [[NSError alloc] initWithUPnPError:result];
        return nil;
    }
}

-(NSString*) syncBrowseMetadataWithObjectId:(NSString*) objectId
{

    MUPnPAction* action = [self getBrowseActionWithObjectId:objectId flag:kBrowserFlagMetaData filter:@"*" startIndex:0 count:0 sort:@""];
    if (action)
    {
        int result = [action sendActionSync];
        if (result == UPNP_E_SUCCESS)
        {
            return [action getArgumentStringVal:@"Result"];
        }
        else
        {
            NSLog( @"Cannot get the metadata, the reason is %s, the code is %d", UpnpGetErrorMessage(result), result);
            return nil;
        }
    }
    else
    {
        return nil;
    }
}

-(NSArray*) getSearchCapabilities:(NSError**) err
{
    MUPnPAction* action = [upnpDevice getActionByName:@"GetSearchCapabilities"];
    if (action == nil) {
        NSLog( @"%@ does not support Search action.", upnpDevice.friendlyName);
        return nil;
    }
    
    int result = [action sendActionSync];
    if (result == UPNP_E_SUCCESS) {
        NSString* strResult = [action getArgumentStringVal:@"SearchCaps"];
        return [strResult componentsSeparatedByString:@","];
    }
    else
    {
        //*err = [[NSError alloc] initWithUPnPError:result];
        NSLog( @"Cannot send GetSearchCapabilities, the reason is %s", UpnpGetErrorMessage(result));
        return nil;
    }
}




#pragma mark - private methods
- (MUPnPAction *)getBrowseActionWithObjectId:(NSString *)objectId 
                           flag:(NSString *)flag 
                         filter:(NSString *)filter 
                     startIndex:(NSInteger)startIndex 
                          count:(NSInteger)count 
                           sort:(NSString *)sort
                          
{
    MUPnPAction* action = [upnpDevice getActionByName:@"Browse"];
    [action setArgumentStringVal:objectId forName:@"ObjectID"];
    [action setArgumentStringVal:flag forName:@"BrowseFlag"];
    [action setArgumentStringVal:filter forName:@"Filter"];
    [action setArgumentIntVal:startIndex forName:@"StartingIndex"];
    [action setArgumentIntVal:count forName:@"RequestedCount"];
    [action setArgumentStringVal:sort forName:@"SortCriteria"];
    return action;
}


-(MUPnPAction*) getSearchActionWithContainerId:(NSString*) containerId
                               searchCriteria:(NSString*) searchCriteria 
                                       filter:(NSString*) filter 
                                startingIndex:(NSInteger) startingIndex 
                                 requestCount:(NSInteger) count  
                                 sortCriteria:(NSString*) sort
{
    MUPnPAction* action = [upnpDevice getActionByName:@"Search"];
    if (action)
    {
        [action setArgumentStringVal:containerId forName:@"ContainerID"];
        [action setArgumentStringVal:searchCriteria forName:@"SearchCriteria"];
        [action setArgumentStringVal:filter forName:@"Filter"];
        [action setArgumentIntVal:startingIndex forName:@"StartingIndex"];
        [action setArgumentIntVal:count forName:@"RequestedCount"];
        [action setArgumentStringVal:sort forName:@"SortCriteria"];
        return action;
    }
    else
    {
        return nil;
    }
}

-(BOOL) isSupportSearchWithKeyword:(NSString*) keyword
{
    NSArray* searchCaps = [self getSearchCapabilities:nil];
    if (searchCaps && [searchCaps containsObject:keyword])
    {
        return YES;
    }
    else
        return NO;
}

@end
