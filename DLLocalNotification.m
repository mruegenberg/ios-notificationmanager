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

@implementation DLLocalNotificationRecurrence

- (NSDate *)nextInstanceAfter:(NSDate *)date {
    // recurrence ends before the date
    NSDate *next = ({
        NSDateComponents *dC = [[NSDateComponents alloc] init];
        switch (self.recurrenceFrequency ) {
            case EKRecurrenceFrequencyDaily:  dC.day = self.recurrenceInterval; break;
            case EKRecurrenceFrequencyWeekly: dC.week = self.recurrenceInterval; break;
            case EKRecurrenceFrequencyMonthly: dC.month = self.recurrenceInterval; break;
            case EKRecurrenceFrequencyYearly: dC.year = self.recurrenceInterval; break;
            default: break;
        }
        NSCalendar *cal = [NSCalendar autoupdatingCurrentCalendar];
        NSDate *next = [cal dateByAddingComponents:dC toDate:date options:0];
        // FIXME: inefficient. can be done much faster by directly computing the right number of days to add
        //        at least for daily and weekly recurrence
        while ([next earlierDate:date] == next) {
            next = [cal dateByAddingComponents:dC toDate:date options:0];
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
        else if([self.fireDate laterDate:dateOrNil] == self.fireDate) result = nil; // next instance start would be in future
        else if(self.recurrenceRule == nil) {
            if([self.fireDate earlierDate:dateOrNil] != self.fireDate)
                result = nil;
            else
                result = self.fireDate;
        }
        else
            result = [self.recurrenceRule nextInstanceAfter:dateOrNil];
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

@end
