//
//  PCContextSound.h
//  PencilCaseLauncherDemo
//
//  Created by Brandon Evans on 15-01-19.
//
//

#import "RPJSCoreModule.h"

@interface PCContextSound : NSObject <RPJSCoreModule>

// The completion block is currently called immediately
// There will probably come a time in the future where we want the option of it completing after the sound finishes
// This way the API won't have to change
+ (void)playSoundAtPath:(NSString *)soundPath completion:(JSValue *)completionHandler;

@end
