//
//  PCCard.m
//  
//
//  Created by Brandon Evans on 2014-09-05.
//
//

#import "PCCard.h"
#import "PCJSContext.h"
#import "PCJSContextCache.h"

@interface PCCard ()

@property (nonatomic, strong, readwrite) NSString *cardFilePath;
@property (nonatomic, strong, readwrite) NSString *jsFilePath;
@property (nonatomic, strong, readwrite) PCJSContext *context;
@property (nonatomic, copy, readwrite) NSUUID *uuid;
@property (nonatomic, assign, readwrite) BOOL canTransition;
@property (nonatomic, strong, readwrite) CCBAnimationManager *animationManager;

@end

@implementation PCCard

+ (instancetype)cardWithPath:(NSString *)path {
    PCCard *card = [[PCCard alloc] init];
    card.uuid = [[NSUUID alloc] initWithUUIDString:[path lastPathComponent]];
    card.cardFilePath = [path stringByAppendingPathExtension:@"ccbi"];
    card.jsFilePath = [path stringByAppendingPathExtension:@"js"];
    card.animationManager = [[CCBAnimationManager alloc] init];
    return card;
}

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }

    _canTransition = NO;

    return self;
}

#pragma mark - Accessors

- (void)setContext:(PCJSContext *)context {
    [_context tearDown];
    _context = context;
}

#pragma mark - Lifecycle

- (void)cardWillAppear {
    self.context = [[PCJSContextCache sharedInstance] take];
}

- (void)cardDidAppear {
    self.canTransition = YES;
}

- (void)cardDidDisappear {
    self.context = nil;
    self.canTransition = NO;

    // Now that a PCCard owns the animation manager this needs to be cleared out when the card goes away.
    // This dictionary maps a node pointer to its sequences. When the node goes away the NSValue (used as the dictionary keys) will throw an exception when you try to get the pointer value from it.
    // Because each time the card is deserialized by CCBReader a new node graph is created, all old keys in the dictionary from previous card loads are invalid but still in the NSValue keys.
    // This next line works around this by blowing away the sequences when the card disappears.
    // In the future if there is an intermediate representation for nodes that persist across actual node displays then this probably wouldn't need to happen.
    self.animationManager.nodeSequences = [NSMutableDictionary dictionary];
}

@end
