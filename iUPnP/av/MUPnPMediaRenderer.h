//
//  UPnPMediaRenderer.h
//  UPnP Player HD
//
//  Created by Hao Hu on 04.11.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MUPnPDevice.h"
#import "MMediaTime.h"
#import "PositionInfo.h"
#import "TransportInfo.h"
#import "MSubscription.h"
#import "MUPnPControlPoint.h"
#import "MMediaTime.h"

#define DEFAULT_INSTANCE_ID @"0"

typedef enum 
{
    TRANSITIONING,
    PLAYING,
    STOPPED,
    PAUSED_PLAYBACK
}UPnPMediaRendererState;

typedef struct _MLastState
{
    NSTimeInterval timeStamp;
    UPnPMediaRendererState state;
    
} MLastState;


@class MUPnPMediaRenderer;

@protocol UPNPMediaRendererDelegate <NSObject>
-(void) upnpMediaRenderer:(MUPnPMediaRenderer*) aMediaRenderer didChangeState:(UPnPMediaRendererState) aState;
@end

@interface MUPnPMediaRenderer : NSObject<UPnPControlPointDelegate>
{
    @private
    MUPnPDevice* _upnpDevice;
    UPnPMediaRendererState _state;
    MSubscription* _subscription;
    NSString* _currentObjectClass;
    MLastState _lastState;
}

@property(nonatomic,strong) MUPnPDevice* upnpDevice;
@property(nonatomic,weak) id<UPNPMediaRendererDelegate> delegate;
@property(nonatomic,strong) MSubscription* subscription;

-(id) initWithUPnPDevice:(MUPnPDevice*) upnpDevice;

#pragma mark - UPnP MediaRenderer standard actions
//----------------------------UPnP MediaRenderer standard actions----------------------------------------
-(BOOL) nextForInstanceId:(NSString*) instanceId;
-(BOOL) pauseForInstanceId:(NSString*) instanceId;
-(BOOL) playForInstanceId:(NSString*) instanceId speed:(NSString*) speed;
-(BOOL) stopForInstanceId:(NSString*) instanceId;
-(BOOL) previousForInstanceId:(NSString*) instanceId;
-(BOOL) seekForInstanceId:(NSString*) instanceId unit:(NSString*) unit target:(NSString*) target;
-(BOOL) setAVTransportURIForInstanceId:(NSString*) instanceId objectClass:(NSString*) objectClass currentURI:(NSString*) uri metaData:(NSString*) metaData;
-(BOOL) setMuteForInstanceId:(NSString*) instanceId channel:(NSString*) channel desireMute:(BOOL) desiredMute;
-(BOOL) setVolumeForInstanceId:(NSString*) instanceId channel:(NSString*) channel desiredVolume:(NSInteger) desiredVolume;

-(PositionInfo*) positionInfoForInstanceId:(NSString*) instanceId;
-(TransportInfo*) transportInfoForInstanceId:(NSString*) instanceId;
-(NSInteger) volumeForInstanceId:(NSString*) instanceId channel:(NSString*) channel;
-(NSInteger) muteForInstanceId:(NSString*) instanceId channel:(NSString*) channel;

#pragma mark - convenient methods
//--------------------------------convenient methods------------------------------------------------------

-(BOOL) play;
-(BOOL) stop;
-(BOOL) pause;
-(BOOL) seekToMedaiTime:(MMediaTime*) mediaTime;
-(NSInteger) getVolume;
-(BOOL) setVolumeOffSet:(NSInteger) volOffset;
-(BOOL) setVolume:(NSInteger) vol;
-(BOOL) toggleMute;
@end
