//
//  AppDelegate.m
//  EmbeddedPlayer
//
//  Created by Michael Beauregard on 2014-12-18.
//
//

#import "AppDelegate.h"
#import <PencilCaseLauncher/PencilCaseLauncher.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    PCApp *pencilCaseApp = [PCApp createWithURL:[self pencilCaseAppURL]];
    PCAppViewController *appViewController = [[PCAppViewController alloc] initWithApp:pencilCaseApp startSlideIndex:[self startSlideIndex] options:@{}];

    self.window.rootViewController = appViewController;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Private

/**
 By default will use EmbeddedApp.app within the bundle but you can specify another path using launch arguments.
 */
- (NSURL *)pencilCaseAppURL {
    NSString *launchArgumentAppPath = [[NSUserDefaults standardUserDefaults] stringForKey:@"AppPath"];
    if ([launchArgumentAppPath length] > 0) {
        return [NSURL fileURLWithPath:launchArgumentAppPath];
    }
    else {
        return [[NSBundle mainBundle] URLForResource:@"MyProject" withExtension:@"creation"];
    }
}

/**
 By default will use launch to slide 0 but you can specify another using launch arguments.
 */
- (NSInteger)startSlideIndex {
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"StartSlideIndex"];
}

@end
