//
//  PCNodeHandlesOverlayView.m
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2015-03-10.
//
//

@import SpriteKit;

#import "PCNodeHandlesOverlayView.h"

@interface PCNodeHandlesOverlayView()

@property (strong, nonatomic) NSMutableArray *anchorPoints;

@end

@implementation PCNodeHandlesOverlayView

- (instancetype)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.anchorPoints = [NSMutableArray array];
}

- (void)removeAnchorPoints {
    [self.anchorPoints makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.anchorPoints removeAllObjects];
}

- (void)showAnchorPointAtPosition:(CGPoint)position {
    NSImage *anchorPointImage = [NSImage imageNamed:@"select-pt"];
    CGRect frame = NSMakeRect(position.x - anchorPointImage.size.width / 2,
                              position.y - anchorPointImage.size.height / 2,
                              anchorPointImage.size.width,
                              anchorPointImage.size.height);
    NSImageView *anchorPointImageView = [[NSImageView alloc] initWithFrame:frame];
    anchorPointImageView.image = anchorPointImage;
    [self addSubview:anchorPointImageView];
    [self.anchorPoints addObject:anchorPointImageView];
}

@end
