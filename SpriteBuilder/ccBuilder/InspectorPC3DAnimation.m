//
//  InspectorPCShape.m
//  SpriteBuilder
//
//  Created by Orest Nazarewycz on 2014-05-17.
//
//

#import "InspectorPC3DAnimation.h"
#import "CCBWriterInternal.h"
#import "PCNodeManager.h"
#import "PC3DNode.h"
#import "PC3DAnimation.h"
#import "PCTextFieldStepper.h"
#import "AppDelegate.h"

@interface InspectorPC3DAnimation ()

@property (weak, nonatomic) IBOutlet NSPopUpButton *animationPopUpButton;
@property (weak, nonatomic) IBOutlet NSPopUpButton *skeletonPopUpButton;
@property (weak) IBOutlet NSMenu *animationMenu;
@property (weak) IBOutlet NSMenu *skeletonMenu;

@property (weak) IBOutlet PCTextFieldStepper *repeatCountTextField;
@property (weak) IBOutlet PCTextFieldStepper *fadeInTextField;
@property (weak) IBOutlet PCTextFieldStepper *fadeOutTextField;
@property (weak) IBOutlet NSButton *repeatForeverButton;
@property (weak) IBOutlet NSTextField *durationTextField;
@property (weak) IBOutlet NSButton *playButton;

@end

@implementation InspectorPC3DAnimation

- (id)initWithSelection:(PCNodeManager *)s andPropertyName:(NSString *)pn andSetterName:(NSString *)sn andDisplayName:(NSString *)dn andExtra:(NSString *)e placeholderKey:(NSString *)placeholderKey {
    self = [super initWithSelection:s andPropertyName:pn andSetterName:sn andDisplayName:dn andExtra:e placeholderKey:placeholderKey];
    if (self) {
        [self refresh];
    }
    return self;
}

- (void)awakeFromNib {
    self.repeatCountTextField.stepAmount = 1.0;
    self.fadeInTextField.stepAmount = 0.15;
    self.fadeOutTextField.stepAmount = 0.15;
    
    self.repeatCountTextField.formatter = [[NSNumberFormatter alloc] init];
    ((NSNumberFormatter *)self.repeatCountTextField.formatter).minimum = @(0);
    
    self.fadeInTextField.formatter = [[NSNumberFormatter alloc] init];
    ((NSNumberFormatter *)self.fadeInTextField.formatter).generatesDecimalNumbers = YES;
    ((NSNumberFormatter *)self.fadeInTextField.formatter).maximumFractionDigits = 2;
    ((NSNumberFormatter *)self.fadeInTextField.formatter).minimumIntegerDigits = 1;
    ((NSNumberFormatter *)self.fadeInTextField.formatter).minimum = @(0.0);
    
    self.fadeOutTextField.formatter = [[NSNumberFormatter alloc] init];
    ((NSNumberFormatter *)self.fadeOutTextField.formatter).generatesDecimalNumbers = YES;
    ((NSNumberFormatter *)self.fadeOutTextField.formatter).maximumFractionDigits = 2;
    ((NSNumberFormatter *)self.fadeOutTextField.formatter).minimumIntegerDigits = 1;
    ((NSNumberFormatter *)self.fadeOutTextField.formatter).minimum = @(0.0);
    
    self.durationTextField.formatter = [[NSNumberFormatter alloc] init];
    ((NSNumberFormatter *)self.durationTextField.formatter).generatesDecimalNumbers = YES;
    ((NSNumberFormatter *)self.durationTextField.formatter).maximumFractionDigits = 2;
    ((NSNumberFormatter *)self.durationTextField.formatter).minimumIntegerDigits = 1;
    
    [self refresh];    
}

- (void)refresh {
    [self willChangeValueForKey:@"selectedAnimationName"];
    [self didChangeValueForKey:@"selectedAnimationName"];
    
    [self willChangeValueForKey:@"selectedSkeletonName"];
    [self didChangeValueForKey:@"selectedSkeletonName"];

    [self.animationMenu removeAllItems];
    [self.skeletonMenu removeAllItems];
    [[self pc3DNode] refreshAnimations];
    
    [self.animationMenu addItem:[[NSMenuItem alloc] initWithTitle:@"None" action:nil keyEquivalent:@""]];
    for (NSString *animationName in [self pc3DNode].cachedAnimations.allKeys) {
        [self.animationMenu addItem:[[NSMenuItem alloc] initWithTitle:animationName action:nil keyEquivalent:@""]];
    }
    
    for (NSString *skeletonName in [[self pc3DNode] allSkeletonNames]) {
        [self.skeletonMenu addItem:[[NSMenuItem alloc] initWithTitle:skeletonName action:nil keyEquivalent:@""]];
    }
 
    [self refreshAnimationValues];
}

#pragma mark - Actions

- (IBAction)selectAnimationPopUpButton:(id)sender {
    BOOL saveUndoState = [self pc3DNode].selectedAnimationName != [sender selectedItem].title;
    [self pc3DNode].selectedAnimationName = [sender selectedItem].title;
    [self refreshAnimationValues];
    [[self pc3DNode] runAnimation:[self pc3DNode].selectedAnimationName]; 
    if (saveUndoState) [[AppDelegate appDelegate] saveUndoStateDidChangePropertySkipSameCheck:@"PC3DAnimationChanged"];
}

- (IBAction)selectSkeletonPopUpButton:(id)sender {
    [self pc3DAnimation].skeletonName = [sender selectedItem].title;
    [self refreshAnimationValues];
}

- (IBAction)repeatAnimationForever:(id)sender {
    if ([self isRepeatForever]) {
        [self pc3DAnimation].repeatCount = 0;
    }
    else {
        [self pc3DAnimation].repeatCount = NSIntegerMax;
    }
    [self refreshAnimationValues];
}

- (IBAction)playAnimation:(id)sender {
    [[self pc3DNode] runAnimation:[self pc3DNode].selectedAnimationName];
}

#pragma mark - Properties

- (void)setRepeatCount:(NSInteger)repeatCount {
    if (![self pc3DAnimation]) return;
    [self pc3DAnimation].repeatCount = repeatCount;
    [self refreshAnimationValues];
}

- (NSInteger)repeatCount {
    if (![self pc3DAnimation]) return 0;
    return [self pc3DAnimation].repeatCount;
}

- (void)setFadeIn:(CGFloat)fadeIn {
    if (![self pc3DAnimation]) return;
    [self pc3DAnimation].fadeInDuration = fadeIn;
    [self refreshAnimationValues];
}

- (CGFloat)fadeIn {
    if (![self pc3DAnimation]) return 0.0;
    return [self pc3DAnimation].fadeInDuration;
}

- (void)setFadeOut:(CGFloat)fadeOut {
    if (![self pc3DAnimation]) return;    
    [self pc3DAnimation].fadeOutDuration = fadeOut;
    [self refreshAnimationValues];
}

- (CGFloat)fadeOut {
    if (![self pc3DAnimation]) return 0.0;
    return [self pc3DAnimation].fadeOutDuration;
}

#pragma mark - Private

- (void)refreshAnimationValues {
    [self.animationPopUpButton selectItemWithTitle:[self pc3DNode].selectedAnimationName];
    
    BOOL disableAnimation = ![self pc3DAnimation];
    
    self.animationPopUpButton.enabled = ![[self pc3DNode] isPC3DAnimationNode];
    self.skeletonPopUpButton.enabled = !disableAnimation;
    self.repeatForeverButton.enabled = !disableAnimation;
    self.repeatCountTextField.enabled = !disableAnimation;
    self.fadeInTextField.enabled = !disableAnimation;
    self.fadeOutTextField.enabled = !disableAnimation;
    self.playButton.enabled = !disableAnimation;
    
    if ([self pc3DAnimation]) {
        [self.skeletonPopUpButton selectItemWithTitle:[self pc3DAnimation].skeletonName];
        self.repeatForeverButton.state = [self isRepeatForever] ? NSOnState : NSOffState;
        self.durationTextField.floatValue = [self pc3DAnimation].duration;
        [[self pc3DNode] saveCachedAnimations];
    }
    else {
        self.skeletonPopUpButton.title = @"";
        self.repeatForeverButton.state = NSOffState;        
        self.repeatCount = 0;
        self.fadeIn = 0.0;
        self.fadeOut = 0.0;
        self.durationTextField.stringValue = @"";
    }
    
    [self willChangeValueForKey:@"repeatCount"];
    [self didChangeValueForKey:@"repeatCount"];
    
    [self willChangeValueForKey:@"fadeIn"];
    [self didChangeValueForKey:@"fadeIn"];
    
    [self willChangeValueForKey:@"fadeOut"];
    [self didChangeValueForKey:@"fadeOut"];
    
    if ([self isRepeatForever]) self.repeatCountTextField.floatValue = INFINITY;
    self.repeatCountTextField.enabled = !disableAnimation && ![self isRepeatForever];
}

- (PC3DNode *)pc3DNode {
    return self.selection.managedNodes.firstObject;
}

- (PC3DAnimation *)pc3DAnimation {
    return [[self pc3DNode] selectedAnimation];
}

- (BOOL)isRepeatForever {
    return [self pc3DAnimation].repeatCount == NSIntegerMax;
}

@end
