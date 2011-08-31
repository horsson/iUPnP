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
#import "UPnPControlPoint.h"

@interface FirstViewController : UIViewController<UPnPDDeviceDelegate,UPnPControlPointDelegate> {

    UPnPDevice* _upnpDevice;
    UPnPControlPoint* controlPoint;
}

@property(nonatomic,retain)IBOutlet UITableView* tableView;
-(IBAction) btnSendAction:(id) sender;
-(IBAction) btnSearchClicked:(id) sender;

@end
