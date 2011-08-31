//
//  FirstViewController.h
//  iUPnP
//
//  Created by Hao Hu on 30.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UPnPDevice.h"
#import "UPnPAction.h"

@interface FirstViewController : UIViewController<UPnPDDeviceDelegate> {

    UPnPDevice* _upnpDevice;
}

-(IBAction) btnSendAction:(id) sender;

@end
