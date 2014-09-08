//
//  DateField.m
//  Demo
//
//  Created by Marcel Ruegenberg on 07.09.14.
//
//

#import "DateField.h"

@interface DateField ()

@property (strong) UIDatePicker *picker;
@property (strong) NSDateFormatter *formatter;

@end

@implementation DateField

- (void)doInit {
    self.picker = [[UIDatePicker alloc] init];
    [self.picker sizeToFit];
    self.picker.datePickerMode = UIDatePickerModeDateAndTime;
    [self.picker addTarget:self action:@selector(pickerDidChange:) forControlEvents:UIControlEventValueChanged];
    self.inputView = self.picker;
    
    self.formatter = [NSDateFormatter new];
    self.formatter.timeStyle = NSDateFormatterMediumStyle;
    self.formatter.dateStyle = NSDateFormatterMediumStyle;
    
    self.text = [self.formatter stringFromDate:self.picker.date];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self doInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if((self = [super initWithCoder:aDecoder])) {
        [self doInit];
    }
    return self;
}

- (void)pickerDidChange:(UIDatePicker *)picker {
    self.text = [self.formatter stringFromDate:picker.date];
}

- (NSDate *)date {
    return self.picker.date;
}

- (void)setDate:(NSDate *)date {
    self.picker.date = date;
    self.text = [self.formatter stringFromDate:self.picker.date];
}

@end
