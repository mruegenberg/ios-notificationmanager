#import "DLLocalNotification.h"

extern NSString *LocalNotificationIdKey;

@interface DLLocalNotificationRecurrence ()

- (NSDate *)nextInstanceAfter:(NSDate *)date withStart:(NSDate *)start;

@end

@interface DLLocalNotification ()

@property (strong) NSUUID *notificationId;

// generate a local notification corresponding to this notification with a fireDate after `dateOrNil`.
// If `dateOrNil == nil`, the internal fireDate is assumed.
// If the recurrence ends before `dateOrNil` or the internal fireDate is `nil`, `nil` is returned.
// If the recurrence is `nil`, there is only one instance, namely the one with the internal fireDate (as long as it is not `nil)
//
// if the notification fires exactly at `dateOrNil`, the instance *after* `dateOrNil is returned.
- (UILocalNotification *)nextInstanceAfter:(NSDate *)dateOrNil;

+ (DLLocalNotification *)fromPlistRepresentation:(NSDictionary *)plist;
- (NSDictionary *)plistRepresentation;

@end