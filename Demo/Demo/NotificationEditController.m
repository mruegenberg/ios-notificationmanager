//
//  NotificationEditController.m
//  Demo
//
//  Created by Marcel Ruegenberg on 07.09.14.
//
//

#import "NotificationEditController.h"

@interface NotificationEditController ()

@end

@implementation NotificationEditController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

- (IBAction)unwindFreqSelect:(UIStoryboardSegue*)sender
{
    UITableViewController *freqSelector = (UITableViewController *)sender.sourceViewController;
    NSUInteger i = [freqSelector.tableView indexPathForSelectedRow].row;
    
    if(i == 0)
        self.recurrenceFreq = EKRecurrenceFrequencyDaily;
    else if(i == 1)
        self.recurrenceFreq = EKRecurrenceFrequencyWeekly;
    else if(i == 2)
        self.recurrenceFreq = EKRecurrenceFrequencyMonthly;
    else
        self.recurrenceFreq = EKRecurrenceFrequencyYearly;
    
    [self dismissViewControllerAnimated:YES completion:^{
        ;
    }];
}

- (void)setNotification:(DLLocalNotification *)notification {
    if(notification != _notification) {
        _notification = notification;
        
        if(notification == nil) {
            self.fireDateLabel.date = notification.fireDate;
            self.titleLabel.text    = notification.alertAction;
            self.bodyLabel.text     = notification.alertBody;
            self.badgeLabel.text    = [NSString stringWithFormat:@"%d", notification.applicationIconBadgeNumber];
            self.recIntervalLabel.text = [NSString stringWithFormat:@"%d", notification.recurrenceRule.recurrenceInterval];
            self.recurrenceFreq = notification.recurrenceRule.recurrenceFrequency;
        }
        else {
            self.fireDateLabel.date = [NSDate date];
            self.titleLabel.text    = @"";
            self.bodyLabel.text     = @"";
            self.badgeLabel.text    = @"";
            self.recIntervalLabel.text = @"";
            self.recurrenceFreq = EKRecurrenceFrequencyDaily;
        }
    }
}

@end
