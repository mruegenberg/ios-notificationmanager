//
//  LocalNotificationList.m
//  Demo
//
//  Created by Marcel Ruegenberg on 28.09.14.
//
//

#import "LocalNotificationListController.h"

NSArray *localNotifications() {
    return [[UIApplication sharedApplication] scheduledLocalNotifications];
}

@implementation LocalNotificationListController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [localNotifications() count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NotificationCell" forIndexPath:indexPath];
    
    UILabel *actionLabel     = (UILabel *)[cell viewWithTag:1];
    UILabel *dateLabel       = (UILabel *)[cell viewWithTag:2];
    UILabel *recurrenceLabel = (UILabel *)[cell viewWithTag:3];
    UILabel *badgeLabel      = (UILabel *)[cell viewWithTag:4];
    
    NSArray *notifications = localNotifications();
    UILocalNotification *notif = [notifications objectAtIndex:indexPath.row];
    
    actionLabel.text = notif.alertBody;
    
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.timeStyle = NSDateFormatterMediumStyle;
    formatter.dateStyle = NSDateFormatterMediumStyle;
    dateLabel.text = [formatter stringFromDate:notif.fireDate];
    
    recurrenceLabel.text = [NSString stringWithFormat:@"Repeat every %lu", (unsigned long)notif.repeatInterval];
    
    badgeLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)notif.applicationIconBadgeNumber];
    
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
