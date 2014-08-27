//
//  DLNotificationManager.h
//  Classes
//
//  Created by Marcel Ruegenberg on 23.08.14.
//  Copyright (c) 2014 Dustlab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DLLocalNotification.h"

@interface DLNotificationManager : NSObject

+ (DLNotificationManager *)sharedNotificationManager;

- (void)scheduleLocalNotification:(DLLocalNotification *)notification;
- (void)presentLocalNotificationNow:(DLLocalNotification *)notification;
- (void)cancelLocalNotification:(DLLocalNotification *)notification;
- (void)cancelAllLocalNotifications;

- (void)schedulePendingNotifications; // updates the local notifications actually scheduled

// TODO: support for periods without notifications (aka holidays)

@end
