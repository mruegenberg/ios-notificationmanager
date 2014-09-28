//
//  MasterViewController.m
//  Demo
//
//  Created by Marcel Ruegenberg on 07.09.14.
//
//

#import "NotificationListController.h"
#import "DLNotificationManager.h"
#import "DLLocalNotification.h"
#import "DateField.h"
#import "NotificationEditController.h"

@implementation NotificationListController

- (void)awakeFromNib
{
    self.clearsSelectionOnViewWillAppear = NO;
    self.preferredContentSize = CGSizeMake(320.0, 600.0);
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[DLNotificationManager sharedNotificationManager] scheduledNotifications] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NotificationCell" forIndexPath:indexPath];
    
    UILabel *actionLabel     = (UILabel *)[cell viewWithTag:1];
    UILabel *dateLabel       = (UILabel *)[cell viewWithTag:2];
    UILabel *recurrenceLabel = (UILabel *)[cell viewWithTag:3];
    UILabel *badgeLabel      = (UILabel *)[cell viewWithTag:4];
    
    NSArray *notifications = [[DLNotificationManager sharedNotificationManager] scheduledNotifications];
    DLLocalNotification *notif = [notifications objectAtIndex:indexPath.row];
    
    actionLabel.text = notif.alertBody;
    
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.timeStyle = NSDateFormatterMediumStyle;
    formatter.dateStyle = NSDateFormatterMediumStyle;
    dateLabel.text = [formatter stringFromDate:notif.fireDate];
    
    recurrenceLabel.text = [NSString stringWithFormat:@"%@", notif.recurrenceRule];
    
    badgeLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)notif.applicationIconBadgeNumber];
    
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[DLNotificationManager sharedNotificationManager] cancelLocalNotification:[[[DLNotificationManager sharedNotificationManager] scheduledNotifications] objectAtIndex:indexPath.row]];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    CGRect displayFrom = [tableView convertRect:cell.frame fromView:cell];
    
    self.popoverAnchorButton.frame = displayFrom;
    [self performSegueWithIdentifier:@"Edit" sender:cell];
}

#pragma mark -

- (IBAction)unwindPopover:(UIStoryboardSegue*)sender
{
    NotificationEditController *editC = (NotificationEditController *)sender.sourceViewController;
    
    DLLocalNotification *notif = editC.notification;
    if(notif == nil) notif = [[DLLocalNotification alloc] init];
    notif.alertBody = editC.bodyLabel.text;
    notif.fireDate = editC.fireDateLabel.date;
    notif.alertAction = editC.titleLabel.text;
    notif.applicationIconBadgeNumber = [editC.badgeLabel.text integerValue];
    notif.recurrenceRule = [DLLocalNotificationRecurrence recurrenceRuleWithFrequency:editC.recurrenceFreq interval:[editC.recIntervalLabel.text integerValue] endDate:nil];
    
    [self dismissViewControllerAnimated:YES completion:^{ ; }];
    
    [[DLNotificationManager sharedNotificationManager] scheduleLocalNotification:notif];
    [self.tableView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"Add"]) {
        ; // add button pressed.
    }
    else if([segue.identifier isEqualToString:@"Edit"]) {
        NSLog(@"sender = %@", sender);
    }
}

@end
