//
//  BasicCrashHandler.m
//  BackgroundLocationExperiment
//
//  Created by Kevin Munc on 12/31/17.
//  Copyright © 2017 Method Up. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BasicCrashHandler.h"
#import <UserNotifications/UserNotifications.h>

@implementation BasicCrashHandler

/** Register the handler. */
+ (void)setUp {
    NSSetUncaughtExceptionHandler(&HandleExceptions);
    struct sigaction newSignalAction;
    memset(&newSignalAction, 0, sizeof(newSignalAction));
    newSignalAction.sa_handler = &SignalHandler;
    sigaction(SIGABRT, &newSignalAction, NULL);
    sigaction(SIGILL, &newSignalAction, NULL);
    sigaction(SIGBUS, &newSignalAction, NULL);
    sigaction(SIGTRAP, &newSignalAction, NULL);
    sigaction(SIGSTOP, &newSignalAction, NULL);
}

/** Signal catcher */
void SignalHandler(int sig) {
    postUserNotification([NSString stringWithFormat:@"%d", sig]);
    NSLog(@"\n#\n# Signal caught! %d\n#\n", sig);
    NSLog(@"%@",[NSThread callStackSymbols]);
    // NOTE: These handlers will never be triggered when running via Xcode.
    // Must run with no debugger attached.
    exit(sig);
}

/** Uncaught exception catcher */
void HandleExceptions(NSException *exception) {
    postUserNotification([NSString stringWithFormat:@"%@", exception]);
    NSLog(@"\n#\n# Uncaught exception! %@\n#\n", exception);
    NSLog(@"%@",[NSThread callStackSymbols]);
    // SUGGEST: see http://chaosinmotion.com/blog/?p=423
    @throw exception;
}

/** Post a notification as a backup way to see the exception information. */
void postUserNotification(NSString *message) {
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.title = @"Unhandled Exception Occurred";
    content.subtitle = @"";
    content.body = message;
    content.sound = [UNNotificationSound defaultSound];
    //UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:1
    //                                                                                                repeats:NO];
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:[NSString stringWithFormat:@"%@", [NSDate date]]
                                                                          content:content
                                                                          trigger:nil];
    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error making user norification request: %@", error);
        }
    }];
}

@end
