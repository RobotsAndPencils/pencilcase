//
//  SKLabelNode+ContentSize.m
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2015-06-16.
//
//

#import "SKLabelNode+ContentSize.h"

@implementation SKLabelNode (ContentSize)

- (CGSize)contentSize {
    return [self.text sizeWithAttributes:@{ NSFontAttributeName : [NSFont fontWithName:self.fontName size:self.fontSize] }];
}

@end
