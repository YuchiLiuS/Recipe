//
//  AlarmViewController.m
//  Recipe
//
//  Created by yuchiliu on 12/3/13.
//  Copyright (c) 2013 CS193P. All rights reserved.
//

#import "AlarmViewController.h"

@interface AlarmViewController ()

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

@property (nonatomic) NSTimeInterval countdownDuration;

@property (strong, nonatomic) UILocalNotification* cookLocalNotification;
@end

@implementation AlarmViewController

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
    self.title = @"CookAlarm";
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)startAlarm:(id)sender {
    self.countdownDuration = [self.datePicker countDownDuration];
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:self.countdownDuration];
    localNotification.alertBody = @"Your food is burning!";
    localNotification.applicationIconBadgeNumber = 1;
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    self.cookLocalNotification = localNotification;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

- (IBAction)cancelAlarm:(id)sender {
    [[UIApplication sharedApplication] cancelLocalNotification:self.cookLocalNotification];
    self.cookLocalNotification = nil;
}

@end
