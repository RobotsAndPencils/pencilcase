//
//  PCContextSound.m
//  PencilCaseLauncherDemo
//
//  Created by Brandon Evans on 15-01-19.
//
//

#import "PCContextSound.h"
#import "PCAppViewController.h"
#import "OALSimpleAudio.h"
#import "PCSKView.h"
#import "PCScene.h"
#import "PCApp.h"
#import "PCConstants.h"

@implementation PCContextSound

+ (void)playSoundAtPath:(NSString *)soundPath completion:(JSValue *)completionHandler {
    ALBuffer *buffer = [[OALSimpleAudio sharedInstance] preloadEffect:soundPath];
    SKAction *waitAction = [SKAction waitForDuration:buffer.duration];

    SKAction *soundAction = [SKAction runBlock:^{
        id<ALSoundSource> source = [[OALSimpleAudio sharedInstance] playEffect:soundPath];
    }];
    SKAction *completionAction = [SKAction runBlock:^{
        if (completionHandler) [completionHandler callWithArguments:@[]];
    }];

    SKAction *chain;
    if ([PCAppViewController lastCreatedInstance].runningApp.fileFormatVersion.integerValue >= PCFirstFileVersionExpectingCorrectSequentialSoundBehaviour) {
        chain = [SKAction sequence:@[ soundAction, waitAction, completionAction ]];
    }
    else {
        chain = [SKAction sequence:@[ soundAction, completionAction ]];
    }

    PCSKView *view = [PCAppViewController lastCreatedInstance].spriteKitView;
    [view.pc_scene runAction:chain];
}

+ (void)setupInContext:(JSContext *)context {
    context[@"__sound_playSoundAtPath"] = ^(NSString *soundName, JSValue *completionHandler) {
        [self playSoundAtPath:soundName completion:completionHandler];
    };
}

@end
