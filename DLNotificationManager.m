//
//  DLNotificationManager.m
//  Classes
//
//  Created by Marcel Ruegenberg on 23.08.14.
//  Copyright (c) 2014 Dustlab. All rights reserved.
//

#import "DLNotificationManager.h"
#import "DLLocalNotification_Internal.h"

// maximum number `UILocalNotification`s to use. Needs to be <= 64.
#define MAX_USED_NOTIFICATIONS 50

NSURL *notificationsURL() {
    NSURL *appDocDir = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    return [appDocDir URLByAppendingPathComponent:@".dlnotifications.plist"];
}

NSArray *scheduledNotifications() {
    return [[UIApplication sharedApplication] scheduledLocalNotifications];
}

/*
@interface DLNotificationBreakInterval ()
@property (readwrite) NSDate *start;
@property (readwrite) NSDate *end;
@end

@implementation DLNotificationBreakInterval
+ (DLNotificationBreakInterval *)breakFrom:(NSDate *)s to:(NSDate *)e {
    DLNotificationBreakInterval *breakI = [DLNotificationBreakInterval new];
    breakI.start = s; breakI.end = e;
    return breakI;
}
@end
 */

@interface DLNotificationManager ()

@property NSMutableDictionary *notifications; // TODO: check whether using a dictionary here actually helps much. otherwise use an array
- (void)persist; // persist settings

- (void)setNeedsPersistence;
- (void)beginUpdates;
- (void)endUpdates;
@property BOOL updating;
@property BOOL shouldPersist;

- (NSArray *)scheduledNotificationsForId:(NSUUID *)notifId;

// TODO: use this when scheduling local notifications
@property (strong) NSMutableSet *breakIntervals;

@end

/** Implementation notes:
We have to work around two problems:
- apps are limited to 64 local notifications
- we use more complex recurrence rules than UILocalNotification

For simplicity, we just schedule every single occurence of all notifications directly, i.e we don't even try to use `UILocalNotification` sorry support for recurrence.
    
*/
@implementation DLNotificationManager

+ (DLNotificationManager *)sharedNotificationManager {
    static DLNotificationManager *sharedInstance;
    if(sharedInstance == nil) sharedInstance = [DLNotificationManager new];
    return sharedInstance;
}

- (id)init {
    if((self = [super init])) {
        // TODO: decode to DLLocalNotification objects.
        //       the dictionary written may only contain NSString, NSData, and the other usual property list suspects
        self.notifications = [NSMutableDictionary dictionaryWithContentsOfURL:notificationsURL()];
        if(self.notifications == nil) {
            self.notifications = [NSMutableDictionary dictionary];
		}
    }
    return self;
}

// TODO: replace some persist calls by a persistIfNeeded combined with a beginUpdates and endUpdates method,
//       in order to prevent unnecessary writes
- (void)persist {
    // TODO: transcode the notifications to property list format
    BOOL success = [self.notifications writeToURL:notificationsURL() atomically:YES];
    if(! success) {
        NSLog(@"Saving purchases to %@ failed!", notificationsURL());
    }
}

- (void)beginUpdates {
    self.updating = YES;
    self.shouldPersist = NO;
}

- (void)endUpdates {
    if(self.shouldPersist)
        [self persist];
    self.updating = NO;
}

- (void)setNeedsPersistence {
    if(self.updating) // currently in a block
        self.shouldPersist = YES;
    else // currently not in a block, so persist immediately
        [self persist];
}

- (NSArray *)scheduledNotificationsForId:(NSUUID *)notifId {
    NSArray *notifications = scheduledNotifications();
    NSPredicate *pred = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        UILocalNotification *notif = evaluatedObject;
        return [[notif.userInfo objectForKey:LocalNotificationIdKey] isEqual:notifId];
    }];
    return [notifications filteredArrayUsingPredicate:pred];
}

- (void)schedulePendingNotifications {
    // for simplicity, we first remove all scheduled notifications.
    // this isn't the most efficient way, but there's no point in making things unnecessarily complex
    // for uncertain performance gains.
    // afterwards, we schedule the next set of notifications from scratch.
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    // We need to schedule more notifications as long as we have less than MAX_USED_NOTIFICATIONS
    // and we want to schedule those notifications first that will actually fire first.
    // simply adding the next instance for all notifications is wrong: if we have one notification that fires daily and
    // another one that just fired and should fire again in a year, we need to schedule the daily instances first
    //
    // To achieve this, we get the next instance for all notifications (nextNotifications)
    // and the instance after the next one (afterNextNotifications)
    // then we schedule all notifications in `nextNotifications` that are before the
    // notification in `afterNextNotifications` that fires first.
    // for those scheduled notifications, we add their corresponding element in `afterNextNotifications` to
    // `nextNotifications` and compute the new corresponding elements in `afterNextNotifications`.
    // we keep going like this until all notifications are done.
    //
    // possible optimization: use a priority queue for `afterNextNotifications`
    
    NSArray *notifications = [self.notifications allValues]; // need to save this since order of `allValues` between calls is not defined (at least theoretically)
    NSUInteger c = [notifications count];
    NSMutableArray *nextNotifications      = [NSMutableArray arrayWithCapacity:c];
    NSMutableArray *afterNextNotifications = [NSMutableArray arrayWithCapacity:c];
    NSDate *now = [NSDate date];
   
    for(DLLocalNotification *notif in notifications)
        [nextNotifications addObject:[notif nextInstanceAfter:now]];
    __block NSDate *smallestAfterNext = nil;
    NSMutableArray *indices = [NSMutableArray arrayWithCapacity:c];
    for (NSUInteger i = 0; i<c; ++i) {
        DLLocalNotification *notif        = [notifications objectAtIndex:i];
        UILocalNotification *nextInstance = [nextNotifications objectAtIndex:i];
        UILocalNotification *afterNextInstance = [notif nextInstanceAfter:nextInstance.fireDate];
        [afterNextNotifications addObject:afterNextInstance];
        if(smallestAfterNext == nil ||
           [afterNextInstance.fireDate earlierDate:smallestAfterNext] == afterNextInstance.fireDate)
            smallestAfterNext = afterNextInstance.fireDate;
        [indices addObject:@(i)];
    }
    
    
    __block NSUInteger scheduledCount = 0;
    while(scheduledCount < MAX_USED_NOTIFICATIONS && [nextNotifications count] > 0) {
        NSMutableIndexSet *notifsToScheduleIdx = [NSMutableIndexSet indexSet];
        for(NSUInteger i = 0; i<c; ++i) {
            UILocalNotification *nextInstance = [nextNotifications objectAtIndex:i];
            if([nextInstance.fireDate earlierDate:smallestAfterNext] == nextInstance.fireDate) {
                [notifsToScheduleIdx addIndex:i];
            }
        }
        
        // remove unneeded indices if necessary
        if(scheduledCount + [notifsToScheduleIdx count] >= MAX_USED_NOTIFICATIONS){
            NSMutableArray *notifsToSchedule = [NSMutableArray arrayWithCapacity:[notifsToScheduleIdx count]];
            [notifsToScheduleIdx enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                [notifsToSchedule addObject:@[@(idx),[nextNotifications objectAtIndex:idx]]];
            }];
            [notifsToSchedule sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                NSDate *d1 = ((UILocalNotification *)[obj1 objectAtIndex:1]).fireDate;
                NSDate *d2 = ((UILocalNotification *)[obj2 objectAtIndex:1]).fireDate;
                return [d1 compare:d2];
            }];
            NSAssert([notifsToSchedule count] == [notifsToScheduleIdx count], @"Something went wrong.");
            for(NSUInteger i = MAX_USED_NOTIFICATIONS - scheduledCount; i < [notifsToScheduleIdx count]; ++i) {
                NSUInteger idx = [[[notifsToSchedule objectAtIndex:i] objectAtIndex:0] unsignedIntegerValue];
                [notifsToScheduleIdx removeIndex:idx];
            }
        }
                 
        
        [notifsToScheduleIdx enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
            // schedule the notification
            UILocalNotification *nextInstance = [nextNotifications objectAtIndex:idx];
            [[UIApplication sharedApplication] scheduleLocalNotification:nextInstance];
            scheduledCount++; // TODO: need to sort the nextNotifs
            
            // update the corresponding position in nextNotifications and afterNextNotifications
            UILocalNotification *afterNextInstance = [afterNextNotifications objectAtIndex:idx];
            if(smallestAfterNext == afterNextInstance.fireDate)
                smallestAfterNext = nil;
            [nextNotifications replaceObjectAtIndex:idx withObject:afterNextInstance];
            
            DLLocalNotification *notif = [notifications objectAtIndex:idx];
            UILocalNotification *newAfterNextInstance = [notif nextInstanceAfter:afterNextInstance.fireDate];
            [afterNextNotifications replaceObjectAtIndex:idx withObject:newAfterNextInstance];
        }];
        
        // compute new smallestAfterNext:
        if(smallestAfterNext == nil) {
            for(UILocalNotification *afterNextInstance in afterNextNotifications) {
                if(smallestAfterNext == nil ||
                   [afterNextInstance.fireDate earlierDate:smallestAfterNext] == afterNextInstance.fireDate)
                    smallestAfterNext = afterNextInstance.fireDate;
            }
        }
        else {
            [notifsToScheduleIdx enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                UILocalNotification *afterNextInstance = [afterNextNotifications objectAtIndex:idx];
                if(smallestAfterNext == nil ||
                   [afterNextInstance.fireDate earlierDate:smallestAfterNext] == afterNextInstance.fireDate)
                    smallestAfterNext = afterNextInstance.fireDate;
            }];
        }
    }
}

- (void)scheduleLocalNotification:(DLLocalNotification *)notification {
    [self.notifications setObject:notification forKey:notification.notificationId];
    [self schedulePendingNotifications];
}

- (void)presentLocalNotificationNow:(DLLocalNotification *)notification {
    UILocalNotification *localNotif = ({
        UILocalNotification *result = nil;
        NSArray *scheduledNotifs = [self scheduledNotificationsForId:notification.notificationId];
        if([scheduledNotifs count] != 0)
            result = [scheduledNotifs firstObject];
        else
            result = [notification nextInstanceAfter:nil];
        result;
    });

    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotif];
}

- (void)cancelLocalNotification:(DLLocalNotification *)notification {
    NSUUID *notifId = notification.notificationId;
    NSArray *scheduledNotifs = [self scheduledNotificationsForId:notifId];
    for(UILocalNotification *notif in scheduledNotifs) {
        [[UIApplication sharedApplication] cancelLocalNotification:notif];
    }
    [self.notifications removeObjectForKey:notifId];
    [self setNeedsPersistence];
    
}

- (void)cancelAllLocalNotifications {
    [self beginUpdates];
    NSArray *notifications = [self.notifications allValues];
    for(DLLocalNotification *notif in notifications) {
        [self cancelLocalNotification:notif];
    }
    [self endUpdates];
}


/*
#pragma mark - Breaks

- (NSSet *)breaks {
    if(self.breakIntervals == nil) self.breakIntervals = [NSMutableSet set];
    return self.breakIntervals;
}

- (void)addBreak:(DLNotificationBreakInterval *)breakI {
    if(self.breakIntervals == nil) self.breakIntervals = [NSMutableSet set];
    [self.breakIntervals addObject:breakI];
}

- (void)removeBreak:(DLNotificationBreakInterval *)breakI {
    if(self.breakIntervals == nil) self.breakIntervals = [NSMutableSet set];
    [self.breakIntervals removeObject:breakI];
}
 */


@end
