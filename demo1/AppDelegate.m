//
//  AppDelegate.m
//  demo1
//
//  Created by mac on 2017/8/22.
//  Copyright © 2017年 maceastwin. All rights reserved.
//

#import "AppDelegate.h"
#import "StationControlWindow.h"
#import "LoginWindow.h"
@interface AppDelegate ()
{
//    PACSocketDebugWinDelegate *pacSocketDelegate;
//    SerialPortDelegate *serialPortDelegate;
    StationControlWindow *selectStation;
    LoginWindow *loginWindow;
}
@end

@implementation AppDelegate
- (IBAction)StationControl_Tool:(id)sender
{
    
    
    if (!loginWindow)
    {
        loginWindow = [[LoginWindow alloc] init];
    }
    
    [loginWindow showWindow:self];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"disableToSelectStationNoti" object:nil];
    
    //    if (!selectStation)
    //    {
    //        selectStation = [[StationControlWindow alloc] init];
    //    }
    //
    //    [selectStation showWindow:self];
    //
    //    [[NSNotificationCenter defaultCenter] postNotificationName:@"disableToSelectStationNoti" object:nil];

}
- (IBAction)NULLTEST:(id)sender
{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NULLTEST" object:nil];
}
- (IBAction)DOE:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TestDOE" object:nil];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
