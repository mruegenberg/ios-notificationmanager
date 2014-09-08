//
//  DLNotificationManager.h
//  Classes
//
//  Created by Marcel Ruegenberg on 23.08.14.
//  Copyright (c) 2014 Dustlab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DLLocalNotification.h"

// an interval where no notifications should fire
@interface DLNotificationBreakInterval : NSObject
@property (readonly) NSDate *start;
@property (readonly) NSDate *end;
+ (DLNotificationBreakInterval *)breakFrom:(NSDate *)s to:(NSDate *)e;
@end

@interface DLNotificationManager : NSObject

+ (DLNotificationManager *)sharedNotificationManager;

- (void)scheduleLocalNotification:(DLLocalNotification *)notification;
- (void)presentLocalNotificationNow:(DLLocalNotification *)notification;
- (void)cancelLocalNotification:(DLLocalNotification *)notification;
- (void)cancelAllLocalNotifications;

- (void)schedulePendingNotifications; // updates the local notifications actually scheduled
- (NSArray *)scheduledNotifications;

// handle a local notification. returns `NO`, if the notification was not scheduled using a manager
- (BOOL)receivedLocalNotification:(UILocalNotification *)notification;

// TODO: support for periods without notifications (aka holidays):
/*
@property (nonatomic,readonly) NSSet *breaks; // contains `DLNotificationBreakInterval` objects
- (void)addBreak:(DLNotificationBreakInterval *)breakI;
- (void)removeBreak:(DLNotificationBreakInterval *)breakI; // removes the exact object.
 */

@end
