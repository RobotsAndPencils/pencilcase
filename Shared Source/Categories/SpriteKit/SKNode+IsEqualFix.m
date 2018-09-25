//
//  SKNode+SKNode_IsEqualFix.m
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2014-09-29.
//
//

#import "SKNode+IsEqualFix.h"
#import <JRSwizzle/JRSwizzle.h>

@implementation SKNode (IsEqualFix)

__attribute__((constructor)) static void pc_fixIsEqual(void) {
    @autoreleasepool {
        NSError *error;
        [SKNode jr_swizzleMethod:@selector(isEqual:) withMethod:@selector(pc_isEqualFixed:) error:&error];
        if (error) {
            NSLog(@"Failed to fix isEqual. %@", error);
        }
    }
}

- (BOOL)pc_isEqualFixed:(id)other {
    if (![other isKindOfClass:[SKNode class]]) {
        return NO;
    }
    return [self pc_isEqualFixed:other];
}

@end
