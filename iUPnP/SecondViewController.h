//
//  SecondViewController.h
//  iUPnP
//
//  Created by Hao Hu on 30.08.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UPnPDevice.h"

@interface SecondViewController : UIViewController<UPnPDDeviceDelegate> {
    
    @private
    UPnPDevice* _upnpDevice;
}

-(IBAction) btnParserDeviceClicked:(id)sender;
-(IBAction) btnParserServiceClicked:(id)sender;

@end
