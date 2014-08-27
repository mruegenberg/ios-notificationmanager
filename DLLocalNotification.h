//
//  DLLocalNotification.h
//  Classes
//
//  Created by Marcel Ruegenberg on 23.08.14.
//  Copyright (c) 2014 Dustlab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EKRecurrenceRule.h>
#import <UIKit/UIKit.h>

@interface DLLocalNotificationRecurrence : NSObject

@property EKRecurrenceFrequency recurrenceFrequency;
@property NSUInteger recurrenceInterval;
@property NSDate *recurrenceEnd;

@end



// a notification. the interface is identical to UILocalNotification except for recurrence
@interface DLLocalNotification : NSObject

+ (DLLocalNotification *)notificationWithLocal:(UILocalNotification *)notification;
- (id)initWithNotification:(UILocalNotification *)notification;

@property(nonatomic,copy) NSDate *fireDate;
@property(nonatomic,copy) NSTimeZone *timeZone;

@property(strong) DLLocalNotificationRecurrence *recurrenceRule;

@property(nonatomic,copy) NSString *alertBody;
@property(nonatomic) BOOL hasAction;
@property(nonatomic,copy) NSString *alertAction;
@property(nonatomic,copy) NSString *alertLaunchImage;

@property(nonatomic,copy) NSString *soundName;

@property(nonatomic) NSUInteger applicationIconBadgeNumber;

@property(nonatomic,copy) NSDictionary *userInfo;

@end
