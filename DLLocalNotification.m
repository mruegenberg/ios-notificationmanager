//
//  DLLocalNotification.m
//  Classes
//
//  Created by Marcel Ruegenberg on 23.08.14.
//  Copyright (c) 2014 Dustlab. All rights reserved.
//

#import "DLLocalNotification.h"
#import "DLLocalNotification_Internal.h"

NSString *LocalNotificationIdKey = @"LNIdentifier";
#define SECONDS_PER_DAY (60 * 60 * 24)

@implementation DLLocalNotificationRecurrence

- (NSDate *)nextInstanceAfter:(NSDate *)date withStart:(NSDate *)start {
    NSDate *next = ({
        // add some time to the start date, then (if necessary) iterate until
        // we are after `date`
        
        NSDateComponents *dC = [[NSDateComponents alloc] init];
        BOOL needsIter = NO; // do we need to iterate, or can we directly go to the
                             // right date?
        if(self.recurrenceFrequency == EKRecurrenceFrequencyMonthly) {
            dC.month = self.recurrenceInterval;
            needsIter = YES;
        }
        else if(self.recurrenceFrequency == EKRecurrenceFrequencyYearly) {
            dC.month = self.recurrenceInterval;
            needsIter = YES;
        }
        else { // weekly or daily
            needsIter = NO;
            NSTimeInterval dt = [date timeIntervalSinceDate:start];
            NSInteger days = self.recurrenceFrequency == EKRecurrenceFrequencyWeekly ? 7 : 1;
            NSTimeInterval recurrenceInterval = days * SECONDS_PER_DAY;
            dC.day = ceil(dt / recurrenceInterval);
        }
        NSCalendar *cal = [NSCalendar autoupdatingCurrentCalendar];
        NSDate *next = [cal dateByAddingComponents:dC toDate:start options:0];
        if(needsIter) {
            // keep going until `next` is (strictly) in the future wrt `date`
            while([date laterDate:next] != next) {
                next = [cal dateByAddingComponents:dC toDate:date options:0];
            }
        }
        next;
    });
    if(self.recurrenceEnd != nil && [next earlierDate:self.recurrenceEnd] == self.recurrenceEnd)
        return nil;
    return next;
}

@end



@implementation DLLocalNotification

+ (DLLocalNotification *)notificationWithLocal:(UILocalNotification *)notification {
    return [[DLLocalNotification alloc] initWithNotification:notification];
}

- (id)initWithNotification:(UILocalNotification *)notification_ {
    if((self = [super init])) {
        self.fireDate    = notification_.fireDate;
        self.timeZone    = notification_.timeZone;
        self.alertBody   = notification_.alertBody;
        self.hasAction   = notification_.hasAction;
        self.alertAction = notification_.alertAction;
        self.alertLaunchImage = notification_.alertLaunchImage;
        self.soundName        = notification_.soundName;
        self.applicationIconBadgeNumber = notification_.applicationIconBadgeNumber;
        self.userInfo = ({
            NSMutableArray *keys = [NSMutableArray arrayWithArray:[notification_.userInfo allKeys]];
            [keys removeObjectsInArray:@[LocalNotificationIdKey]];
            [notification_.userInfo dictionaryWithValuesForKeys:keys];
        });
    }
    return self;
}

- (UILocalNotification *)nextInstanceAfter:(NSDate *)dateOrNil {
    NSDate *fireDate = ({
        NSDate *result = nil;
        if(self.fireDate == nil) result = nil;
        else if(dateOrNil == nil) result = self.fireDate;
        else if(self.recurrenceRule == nil) {
            // if there is no recurrence, we can only return fireDate.
            // we only return that if it is (strictly) in the future wrt dateOrNil
            if([dateOrNil laterDate:self.fireDate] == self.fireDate)
                result = self.fireDate;
            else
                result = nil;
        }
        else // self.recurrenceRule != nil, self.fireDate != nil, dateOrNil != nil
            result = [self.recurrenceRule nextInstanceAfter:dateOrNil withStart:self.fireDate];
        result;
    });
    if(fireDate == nil) return nil;
    UILocalNotification *localNotif = [UILocalNotification new];
    localNotif.fireDate = fireDate;
    localNotif.timeZone = self.timeZone;
    localNotif.alertBody = self.alertBody;
    localNotif.hasAction = self.hasAction;
    localNotif.alertAction = self.alertAction;
    localNotif.alertLaunchImage = self.alertLaunchImage;
    localNotif.soundName = self.soundName;
    localNotif.applicationIconBadgeNumber = self.applicationIconBadgeNumber;
    localNotif.userInfo = ({
        NSMutableDictionary *uI = [NSMutableDictionary dictionaryWithDictionary:self.userInfo];
        [uI setObject:[self.notificationId UUIDString] forKey:LocalNotificationIdKey];
        uI;
    });
    
    return localNotif;
}

+ (DLLocalNotification *)fromPlistRepresentation:(NSDictionary *)plist {
    DLLocalNotification *notif = [DLLocalNotification new];
    notif.fireDate = [plist objectForKey:@"fireDate"];
    notif.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:[(NSNumber *)[plist objectForKey:@"timeZone"] integerValue]];
    notif.alertBody = [plist objectForKey:@"alertBody"];
    notif.hasAction = [(NSNumber *)[plist objectForKey:@"hasAction"] boolValue];
    notif.alertAction = [plist objectForKey:@"alertAction"];
    notif.alertLaunchImage = [plist objectForKey:@"alertLaunchImage"];
    notif.soundName = [plist objectForKey:@"soundName"];
    notif.applicationIconBadgeNumber = [(NSNumber *)[plist objectForKey:@"applicationIconBadgeNumber"] unsignedIntegerValue];
    notif.userInfo = [plist objectForKey:@"userInfo"];
    notif.notificationId = [[NSUUID alloc] initWithUUIDString:[plist objectForKey:@"uuid"]];
    DLLocalNotificationRecurrence *recurrence = [DLLocalNotificationRecurrence new];
    recurrence.recurrenceFrequency = ({
        EKRecurrenceFrequency result;
        switch ([[plist objectForKey:@"recurrenceFrequency"] unsignedIntegerValue]) {
            case 0:  result = EKRecurrenceFrequencyDaily; break;
            case 1:  result = EKRecurrenceFrequencyWeekly; break;
            case 2:  result = EKRecurrenceFrequencyMonthly; break;
            default: result = EKRecurrenceFrequencyYearly; break; // 3
        }
        result;
    });
    recurrence.recurrenceInterval = [[plist objectForKey:@"recurrenceInterval"] unsignedIntegerValue];
    recurrence.recurrenceEnd      = [plist objectForKey:@"recurrenceEnd"];
    notif.recurrenceRule = recurrence;
    return notif;
}

- (NSDictionary *)plistRepresentation {
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:10];
    [result setValue:self.fireDate forKey:@"fireDate"];
    [result setValue:@([self.timeZone secondsFromGMT]) forKey:@"timeZone"];
    [result setValue:self.alertBody    forKey:@"alertBody"];
    [result setValue:@(self.hasAction) forKey:@"hasAction"];
    [result setValue:self.alertAction  forKey:@"alertAction"];
    [result setValue:self.alertLaunchImage forKey:@"alertLaunchImage"];
    [result setValue:self.soundName forKey:@"soundName"];
    [result setValue:@(self.applicationIconBadgeNumber) forKey:@"applicationIconBadgeNumber"];
    [result setValue:self.userInfo forKey:@"userInfo"];
    [result setValue:[self.notificationId UUIDString] forKey:@"uuid"];
    if(self.recurrenceRule) {
        NSUInteger freq = ({
            NSUInteger result;
            switch (self.recurrenceRule.recurrenceFrequency) {
                case EKRecurrenceFrequencyDaily:         result = 0; break;
                case EKRecurrenceFrequencyWeekly:        result = 1; break;
                case EKRecurrenceFrequencyMonthly:       result = 2; break;
                default: /*EKRecurrenceFrequencyYearly*/ result = 3; break;
            }
            result;
        });
        [result setValue:@(freq) forKeyPath:@"recurrenceFrequency"];
        [result setValue:@(self.recurrenceRule.recurrenceInterval) forKeyPath:@"recurrenceInterval"];
        [result setValue:self.recurrenceRule.recurrenceEnd forKeyPath:@"recurrenceEnd"];
    }
    return result;
}

@end
