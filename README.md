ios-notificationmanager
=======================

The `UILocalNotification` class in iOS is severely limited:

- each app is limited to only 64 active notifications
- only very basic repeat patterns are supported (something as simple as "repeat every 2 weeks" is not possible)

The alternative, push notifications, is often too much trouble and unnecessarily complicated.

**ios-notificationmanager** manages notifications for you and provides an `EventKit`-like API.
The only known caveat is that your users needs to start the app from time to time (i.e about every 50 notifications) in order for new ones to be scheduled.

How to use
----------

```objective-c
#include <DLNotificationManager.h>
    
// ...

DLLocalNotification *notification = [DLLocalNotification new];
notification.alertBody = "Hello, World! In two hours...";
notification.fireDate = [[NSDate date] dateByAddingTimeInterval:(60*60*2)];

DLLocalNotificationRecurrence *every2Weeks = [DLLocalNotificationRecurrence new];
every2Weeks.recurrenceFrequency = EKRecurrenceFrequencyWeekly;
every2Weeks.recurrenceInterval  = 2;
notification.recurrenceRule = every2Weeks;

DLNotificationManager *notificationManager = [DLNotificationManager sharedNotificationManager];
[notificationManager scheduleLocalNotification];
```

On app launch, the managed notifications have to be translated to `UILocalNotification` objects for the system:
```objective-c
// AppDelegate.m

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // ...
    [[DLNotificationManager sharedNotificationManager] schedulePendingNotifications];
}
```

------------

![Travis CI build status](https://api.travis-ci.org/mruegenberg/IAPManager.png)