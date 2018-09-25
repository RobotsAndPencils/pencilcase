//
//  SKNode+SizeChangeBlock.m
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-10-23.
//
//

#import "SKNode+SizeChangeBlock.h"
#import <objc/runtime.h>
#import <JRSwizzle/JRSwizzle.h>

@implementation SKNode (SizeChangeBlock)

#pragma mark - Setup

__attribute__((constructor)) static void pc_SetupSizeSetup(void) {
    @autoreleasepool {
        [SKNode jr_swizzleMethod:@selector(observeValueForKeyPath:ofObject:change:context:) withMethod:@selector(pc_sizeBlockObserveValueForKeyPath:ofObject:change:context:) error:nil];
        SEL deallocSelector = sel_registerName("dealloc");
        [SKNode jr_swizzleMethod:deallocSelector withMethod:@selector(pc_sizeBlockDealloc) error:nil];
    }
}

#pragma mark - KVO

- (void)pc_sizeBlockObserveValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
/**
 We would call this if the original class implemented the method.
 There is something special about this method so we can't just blindly call it or will crash.
 */
//    [self pc_sizeBlockObserveValueForKeyPath:keyPath ofObject:object change:change context:context];
    [[self pc_SizeChangeBlocks] compact]; // Remove nil blocks
    if (![keyPath isEqualToString:@"size"] && object == self) return;

    CGSize oldSize = [change[NSKeyValueChangeOldKey] sizeValue];
    CGSize newSize = [change[NSKeyValueChangeNewKey] sizeValue];

    NSPointerArray *pointerArray = [self pc_SizeChangeBlocks];
    NSInteger count = [pointerArray count];
    for (NSInteger i = 0; i < count; i++) {
        void *pointer = [pointerArray pointerAtIndex:i];
        if (pointer) {
            ((__bridge PCNodeSizeChangeBlock)pointer)(oldSize, newSize);
        }
    }
}

- (void)pc_sizeBlockDealloc {
    [self pc_unregisterForKVO];
    [self pc_sizeBlockDealloc];
}

#pragma mark - Public

- (void)pc_registerSizeChangeBlock:(PCNodeSizeChangeBlock)block {
    [self pc_regsiterForKVO];
    [[self pc_SizeChangeBlocks] insertPointer:(void *)[block copy] atIndex:[[self pc_SizeChangeBlocks] count]];
}

#pragma mark - Private

- (NSPointerArray *)pc_SizeChangeBlocks {
    NSPointerArray *blocks = objc_getAssociatedObject(self, @selector(pc_SizeChangeBlocks));
    if (!blocks) {
        blocks = [NSPointerArray weakObjectsPointerArray];
        [self pc_setSizeChangeBlocks:blocks];
    }
    return blocks;
}

- (void)pc_setSizeChangeBlocks:(NSPointerArray *)blocks {
    objc_setAssociatedObject(self, @selector(pc_SizeChangeBlocks), blocks, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)pc_didRegisterForKVO {
    return [objc_getAssociatedObject(self, @selector(pc_didRegisterForKVO)) boolValue];
}

- (void)pc_setRegisteredForKVO:(BOOL)regsitered {
    objc_setAssociatedObject(self, @selector(pc_didRegisterForKVO), @(regsitered), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)pc_regsiterForKVO {
    if ([self pc_didRegisterForKVO]) return;
    [self addObserver:self forKeyPath:@"size" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    [self pc_setRegisteredForKVO:YES];
}

- (void)pc_unregisterForKVO {
    if (![self pc_didRegisterForKVO]) return;
    [self removeObserver:self forKeyPath:@"size"];
}

@end
