//
//  NotificationEditController.h
//  Demo
//
//  Created by Marcel Ruegenberg on 07.09.14.
//
//

#import <UIKit/UIKit.h>
#import "DateField.h"
#import <EventKit/EKRecurrenceRule.h>
#import "DLLocalNotification.h"

@interface NotificationEditController : UIViewController

@property (nonatomic, strong) IBOutlet DateField *fireDateLabel;
@property (nonatomic, strong) IBOutlet UITextField *titleLabel;
@property (nonatomic, strong) IBOutlet UITextField *bodyLabel;
@property (nonatomic, strong) IBOutlet UITextField *recIntervalLabel;
@property (nonatomic, strong) IBOutlet UITextField *badgeLabel;

@property (nonatomic) EKRecurrenceFrequency recurrenceFreq;

@property (nonatomic, strong) DLLocalNotification *notification;

@end
