//
//  UPnPMediaRenderer.m
//  UPnP Player HD
//
//  Created by Hao Hu on 04.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MUPnPMediaRenderer.h"
#import "MUPnPAction.h"
#import "LastChange.h"
#import "LastChangeParser.h"
#import "NSString+Utils.h"

#define SUBSCRIPTION_TIME_INTERVAL 1.0f
#define SUBSCRIPTION_KEY   @"subscription_key"



@interface MUPnPMediaRenderer()
-(MUPnPAction*) upnpActionForName:(NSString*) name;
-(BOOL) executeAction:(MUPnPAction*) action;
@end;

@implementation MUPnPMediaRenderer
@synthesize upnpDevice = _upnpDevice, delegate, subscription = _subscription;





-(id) initWithUPnPDevice:(MUPnPDevice*) upnpDevice
{
    self = [super init];
    if (self)
    {
        _upnpDevice = upnpDevice;
        _state = STOPPED;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(eventNotifyDidReceive:) name:kEventNotifyDidReceiveWithSSID object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground:) name:@"UIApplicationDidEnterBackgroundNotification" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground:) name:@"UIApplicationWillEnterForegroundNotification" object:nil];
        
    }
    return self;
}


#pragma mark - UPnP MediaRenderer standard actions
-(BOOL) nextForInstanceId:(NSString*) instanceId
{
    MUPnPAction* action = [self upnpActionForName:@"Next"];
    if (action) {
        [action setArgumentStringVal:instanceId forName:@"InstanceID"];
         return [self executeAction:action];     
    }
    else
    {
        return NO;
    }
    
}
-(BOOL) pauseForInstanceId:(NSString*) instanceId
{
    MUPnPAction* action = [self upnpActionForName:@"Pause"];
    if (action) {
        [action setArgumentStringVal:instanceId forName:@"InstanceID"];
        BOOL isSuccess = [self executeAction:action];
        return isSuccess;     
    }
    else
    {
        return NO;
    }

}
- (void)subscribeTransportService
{
    //Subscribe to the media renderer.
    if (_subscription == nil)
    {
        MUPnPService* service = [_upnpDevice getUPnPServiceById:@"urn:upnp-org:serviceId:AVTransport"];
        if (service == nil)
        {
            service = [_upnpDevice getUPnPServiceById:@"urn:upnp-org:serviceId:AVTransportServiceID"];
        }
        _subscription = [[MUPnPControlPoint sharedUPnPControlPoint] subscribeService:service];
        if (_subscription == nil)
        {
            NSLog(@"Cannot create the subscription.");
        }
        else
        {
            NSLog(@"SSID:%@ is created.", _subscription.ssid);
        }
    }
}

-(BOOL) playForInstanceId:(NSString*) instanceId speed:(NSString*) speed;
{
    [self subscribeTransportService];
    
    MUPnPAction* action = [self upnpActionForName:@"Play"];
    if (action) {
        [action setArgumentStringVal:instanceId forName:@"InstanceID"];
        [action setArgumentStringVal:speed forName:@"Speed"];
        BOOL isSuccess = [self executeAction:action];
        return isSuccess;
    }
    else
    {
        return NO;
    }
}

-(BOOL) stopForInstanceId:(NSString*) instanceId
{
    if (_subscription)
    {
        [[MUPnPControlPoint sharedUPnPControlPoint] unSubscribe:_subscription];
        _subscription = nil;
    }
    
    MUPnPAction* action = [self upnpActionForName:@"Stop"];
    if (action) {
        [action setArgumentStringVal:instanceId forName:@"InstanceID"];
        BOOL isSuccess = [self executeAction:action];
        return isSuccess;    
    }
    else
    {
        return NO;
    }

}
-(BOOL) previousForInstanceId:(NSString*) instanceId
{
    MUPnPAction* action = [self upnpActionForName:@"Previous"];
    if (action) 
    {
        [action setArgumentStringVal:instanceId forName:@"InstanceID"];
         return [self executeAction:action];    
    }
    else
    {
        return NO;
    }

}

-(BOOL) seekForInstanceId:(NSString*) instanceId unit:(NSString*) unit target:(NSString*) target
{
    MUPnPAction* action = [self upnpActionForName:@"Seek"];
    if (action) 
    {
        [action setArgumentStringVal:instanceId forName:@"InstanceID"];
        [action setArgumentStringVal:unit forName:@"Unit"];
        [action setArgumentStringVal:target forName:@"Target"];
        return [self executeAction:action];
    }
    else
    {
        return NO;
    }
}

-(BOOL) setAVTransportURIForInstanceId:(NSString*) instanceId objectClass:(NSString*) objectClass currentURI:(NSString*) uri metaData:(NSString*) metaData
{
    _currentObjectClass = objectClass;
    MUPnPAction* action = [self upnpActionForName:@"SetAVTransportURI"];
    if (action) {
        [action setArgumentStringVal:instanceId forName:@"InstanceID"];
        [action setArgumentStringVal:uri forName:@"CurrentURI"];
        [action setArgumentStringVal:metaData forName:@"CurrentURIMetaData"];
        return [self executeAction:action];    
    }
    else
    {
        return NO;
    }
}

-(BOOL) setMuteForInstanceId:(NSString*) instanceId channel:(NSString*) channel desireMute:(BOOL) desiredMute
{
    MUPnPAction* action = [self upnpActionForName:@"SetMute"];
    if (action) 
    {
        [action setArgumentStringVal:instanceId forName:@"InstanceID"];
        [action setArgumentStringVal:channel forName:@"Channel"];
        [action setArgumentIntVal:(desiredMute ? 1 : 0) forName:@"DesiredMute"];
        return [self executeAction:action];
    }
    else
    {
        return NO;
    }
}

-(BOOL) setVolumeForInstanceId:(NSString*) instanceId channel:(NSString*) channel desiredVolume:(NSInteger) desiredVolume
{
    MUPnPAction* action = [self upnpActionForName:@"SetVolume"];
    if (action)
    {
        [action setArgumentStringVal:instanceId forName:@"InstanceID"];
        [action setArgumentStringVal:channel forName:@"Channel"];
        [action setArgumentIntVal:desiredVolume forName:@"DesiredVolume"];
        return [self executeAction:action];
    }
    else
    {
        return NO;
    }
}

-(PositionInfo*) positionInfoForInstanceId:(NSString*) instanceId
{
    MUPnPAction* action = [self upnpActionForName:@"GetPositionInfo"];
    
    if (action) 
    {
        [action setArgumentStringVal:instanceId forName:@"InstanceID"];
        if ([self executeAction:action]) {
            PositionInfo *posInfo = [[PositionInfo alloc] init];
            posInfo.trackDuration =[[MMediaTime alloc] initWithStringFormat:[action getArgumentStringVal:@"TrackDuration"]];
            posInfo.relTime = [[MMediaTime alloc] initWithStringFormat:[action getArgumentStringVal:@"RelTime"]];
            posInfo.absTime = [[MMediaTime alloc] initWithStringFormat:[action getArgumentStringVal:@"AbsTime"]];
            posInfo.track = [action getArgumentIntVal:@"Track"];
            posInfo.trackURI = [action getArgumentStringVal:@"TrackURI"];
            posInfo.trackMetadata = [action getArgumentStringVal:@"TrackMetaData"];
            posInfo.relCount = [action getArgumentIntVal:@"RelCount"];
            posInfo.absCount = [action getArgumentIntVal:@"AbsCount"];
            return posInfo;
        }
        else
        {
            return nil;
        }
    }
    else
    {
        return nil;
    }
}

-(TransportInfo*) transportInfoForInstanceId:(NSString*) instanceId
{
    MUPnPAction* action = [self upnpActionForName:@"GetTransportInfo"];
    if (action)
    {
        [action setArgumentStringVal:instanceId forName:@"InstanceID"];
        if ([self executeAction:action])
        {
            TransportInfo *transInfo = [TransportInfo new];
            transInfo.currentTransportState = [action getArgumentStringVal:@"CurrentTransportState"];
            transInfo.currentTransportStatus = [action getArgumentStringVal:@"CurrentTransportStatus"];
            transInfo.currentSpeed = [action getArgumentStringVal:@"CurrentSpeed"];
            return transInfo;
        }
        else
        {
            return nil;
        }
    }
    else
    {
        return nil;
    }
}

-(NSInteger) volumeForInstanceId:(NSString*) instanceId channel:(NSString*) channel
{
    MUPnPAction* action = [self upnpActionForName:@"GetVolume"];
    if (action) {
        [action setArgumentStringVal:instanceId forName:@"InstanceID"];
        [action setArgumentStringVal:channel forName:@"Channel"];
        if ([self executeAction:action]) {
           return [action getArgumentIntVal:@"CurrentVolume"];
        }
        else
        {
            return -1;
        }
    }
    else
    {
        return -1;
    }
}

-(NSInteger) muteForInstanceId:(NSString*) instanceId channel:(NSString*) channel
{
    MUPnPAction* action = [self upnpActionForName:@"GetMute"];
    if (action) 
    {
        [action setArgumentStringVal:instanceId forName:@"InstanceID"];
        [action setArgumentStringVal:channel forName:@"Channel"];
        if ([self executeAction:action])
        {
            return [action getArgumentIntVal:@"CurrentMute"];
        }
        else
        {
            return -1;
        }
    }
    else
    {
        return -1;
    }
}


#pragma mark - convenient methods
-(BOOL) play
{
   return [self playForInstanceId:DEFAULT_INSTANCE_ID speed:@"1"];
}

-(BOOL) stop
{
    return [self stopForInstanceId:DEFAULT_INSTANCE_ID];
}
-(BOOL) pause
{
    return [self pauseForInstanceId:DEFAULT_INSTANCE_ID];
}

-(BOOL) seekToMedaiTime:(MMediaTime*) mediaTime
{
    return [self seekForInstanceId:DEFAULT_INSTANCE_ID unit:@"REL_TIME" target:[mediaTime stringForSeek]];
}

-(NSInteger) getVolume
{
    return [self volumeForInstanceId:DEFAULT_INSTANCE_ID channel:@"Master"];
}


-(BOOL) setVolumeOffSet:(NSInteger) volOffset
{
    NSInteger currentVol = [self getVolume];
    currentVol += volOffset;
    currentVol = (currentVol < 0) ?   0 : currentVol;
    currentVol = (currentVol > 100) ? 100 : currentVol;
    return [self setVolumeForInstanceId:DEFAULT_INSTANCE_ID channel:@"Master" desiredVolume:currentVol];
}

-(BOOL) setVolume:(NSInteger) vol
{
    return [self setVolumeForInstanceId:DEFAULT_INSTANCE_ID channel:@"Master" desiredVolume:vol];
}

-(BOOL) toggleMute
{
    NSInteger res = [self muteForInstanceId:DEFAULT_INSTANCE_ID channel:@"Master"];
    BOOL desiredMute = NO;
    if (res != -1) {
        //Success!
        desiredMute = (res == 1) ? YES : NO;
       return [self setMuteForInstanceId:DEFAULT_INSTANCE_ID channel:@"Master" desireMute:desiredMute];
    }
    else
    {
        return NO;
    }   
}

#pragma mark - private api
-(MUPnPAction*) upnpActionForName:(NSString*) name
{
    MUPnPAction* action = [_upnpDevice getActionByName:name];
    if (action == nil) {
         NSLog(@"Action %@ does not support by %@", name, _upnpDevice.friendlyName);
    }
    return action;
}

-(BOOL) executeAction:(MUPnPAction*) action
{
    int result = [action sendActionSync];
    if (result == UPNP_E_SUCCESS) {
        return YES;
    }
    else
    {
        NSLog(@"Cannot execute action, The reason is %s",UpnpGetErrorMessage(result));
        return NO;
    }
}



#pragma mark Notification callback

-(void) appDidEnterBackground:(NSNotification*) notification
{
    NSLog(@"App enter background.");
      NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (_subscription)
    {
        BOOL isSuccess = [[MUPnPControlPoint sharedUPnPControlPoint] unSubscribe:_subscription];
        if (isSuccess) 
        {
            NSLog(@"Unsubscribe service.");
            [defaults setBool:YES forKey:SUBSCRIPTION_KEY];
            _subscription = nil;
            return;
        }
    }
     [defaults setObject:[NSNumber numberWithBool:NO] forKey:SUBSCRIPTION_KEY];
}

-(void) appWillEnterForeground:(NSNotification*) notification
{
    NSLog(@"App will enter foreground.");
    //Restore the subscirption.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL isSubscribed = [defaults boolForKey:SUBSCRIPTION_KEY];
    if (isSubscribed) {
        [self subscribeTransportService];
    }
}


-(void) eventNotifyDidReceive:(NSNotification*) notification
{
    // [nc postNotificationName:kEventNotifyDidReceiveWithSSID object:refToSelf userInfo:[NSDictionary dictionaryWithObjectsAndKeys:strSSID,kSSID,[NSNumber numberWithInt:eventKey], kEventKey, key,kVarName, obj,kValue, nil]];
    
    NSDictionary* userInfo = notification.userInfo;
    NSString* ssid = [userInfo objectForKey:kSSID];
    NSString* varName = [userInfo objectForKey:kVarName];
    NSString* value = [userInfo objectForKey:kValue];
    
    
    if ([ssid isEqualToString:_subscription.ssid])
    {
        if ([varName isEqualToString:@"LastChange"])
        {
            //UPnPMediaRendererState mediaRenderState;
            LastChangeParser* parser = [[LastChangeParser alloc] initWithXml:value];
            LastChange* lastChange = [parser lastChange];
            // NSLog(@"LastChange is %@", lastChange.transportState);
            if ([lastChange.transportState isEqualToString:@"PLAYING"])
            {
                _state = PLAYING;
            }
            else if ([lastChange.transportState isEqualToString:@"STOPPED"])
            {
                _state = STOPPED;
            }
            else if ([lastChange.transportState isEqualToString:@"PAUSED_PLAYBACK"])
            {
                _state = PAUSED_PLAYBACK;
            }
            else if ([lastChange.transportState isEqualToString:@"TRANSITIONING"])
            {
                _state = TRANSITIONING;
            }
            
            
            NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
            //NSLog(@"The duration is %f.", (_lastState.timeStamp - now));
            if ((_lastState.state == _state) && ( now - _lastState.timeStamp < SUBSCRIPTION_TIME_INTERVAL)) 
            {
                // NSLog(@"State not Changed., duplicate");
            }
            else
            {
                if ([delegate respondsToSelector:@selector(upnpMediaRenderer:didChangeState:)])
                {
                    [delegate upnpMediaRenderer:self didChangeState:_state];
                }
            }
            
            _lastState.state = _state;
            _lastState.timeStamp = [[NSDate date] timeIntervalSince1970];
        }
    }

    
    
}

-(void) dealloc
{
    NSLog(@"MediaRenderer dealloc.");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
