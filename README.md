ios-notificationmanager
=======================

The `UILocalNotification` class in iOS is severely limited:

- each app is limited to 64 active notifications
- only very simple repeat patterns are supported (something as simple as "repeat every 2 weeks" is not possible)

The alternative, push notifications, is often too much trouble.
*ios-notificationmanager* manages notifications for you and provides an `EventKit`-like API.
The main drawback of this solution is that your users needs to start the app from time to time (i.e about every 50 notifications) in order for new ones to be scheduled.
