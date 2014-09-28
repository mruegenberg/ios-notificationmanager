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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"SetFreq"]) {
        NSUInteger i = NSNotFound;
        if     (self.recurrenceFreq == DLRecurrenceFrequencyDaily)   i = 0;
        else if(self.recurrenceFreq == DLRecurrenceFrequencyWeekly)  i = 1;
        else if(self.recurrenceFreq == DLRecurrenceFrequencyMonthly) i = 2;
        else if(self.recurrenceFreq == DLRecurrenceFrequencyYearly)  i = 3;
        if(i != NSNotFound) {
            UITableViewController *dest = (UITableViewController *)segue.destinationViewController;
            [dest.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]
                                        animated:NO scrollPosition:UITableViewScrollPositionMiddle];
        }
    }
}

- (IBAction)unwindFreqSelect:(UIStoryboardSegue*)sender
{
    UITableViewController *freqSelector = (UITableViewController *)sender.sourceViewController;
    NSUInteger i = [freqSelector.tableView indexPathForSelectedRow].row;
    
    if(i == 0)
        self.recurrenceFreq = DLRecurrenceFrequencyDaily;
    else if(i == 1)
        self.recurrenceFreq = DLRecurrenceFrequencyWeekly;
    else if(i == 2)
        self.recurrenceFreq = DLRecurrenceFrequencyMonthly;
    else
        self.recurrenceFreq = DLRecurrenceFrequencyYearly;
    
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
            self.badgeLabel.text    = [NSString stringWithFormat:@"%lu", (unsigned long)notification.applicationIconBadgeNumber];
            self.recIntervalLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)notification.recurrenceRule.recurrenceInterval];
            self.recurrenceFreq = notification.recurrenceRule.recurrenceFrequency;
        }
        else {
            self.fireDateLabel.date = [NSDate date];
            self.titleLabel.text    = @"";
            self.bodyLabel.text     = @"";
            self.badgeLabel.text    = @"";
            self.recIntervalLabel.text = @"";
            self.recurrenceFreq = DLRecurrenceFrequencyDaily;
        }
    }
}

@end
