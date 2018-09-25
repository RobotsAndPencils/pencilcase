//
//  PCDeploymentMenuItemView.m
//  SpriteBuilder
//
//  Created by Brandon on 2014-03-24.
//
//

#import "PCDeploymentMenuItemView.h"

@interface PCDeploymentMenuItemView ()

@property (assign, nonatomic, getter = isHighlighted) BOOL highlighted;
@property (strong, nonatomic) NSTrackingArea *trackingArea;
@property (strong, nonatomic) CALayer *cellBackgroundLayer;

@end

@implementation PCDeploymentMenuItemView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];

    if (self) {
        if ([[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self topLevelObjects:nil]) {
            self.enabled = YES;
            [self.view setFrame:[self bounds]];
            self.cellBackgroundLayer = [CALayer layer];
            [self setWantsLayer:YES];
            [self setLayer:self.cellBackgroundLayer];
            [self addSubview:self.view];
        }
    }
    
    return self;
}

- (void)mouseUp:(NSEvent*)event {
    if (!self.enabled) return;
    NSMenuItem *item = [self enclosingMenuItem];
    NSMenu *menu = [item menu];
    [menu cancelTracking];
    [menu performActionForItemAtIndex:[menu indexOfItem:item]];
}

- (void)mouseEntered:(NSEvent *)event {
    if (!self.enabled) return;
    self.highlighted = YES;
    self.titleLabel.textColor = [NSColor whiteColor];
    self.subtitleLabel.textColor = [NSColor whiteColor];
    [self.cellBackgroundLayer setBackgroundColor:[NSColor selectedMenuItemColor].CGColor];
    [self setNeedsDisplay:YES];
}

- (void)mouseExited:(NSEvent *)event {
    if (!self.enabled) return;
    self.highlighted = NO;
    self.titleLabel.textColor = [NSColor blackColor];
    self.subtitleLabel.textColor = [NSColor disabledControlTextColor];
    [self.cellBackgroundLayer setBackgroundColor:[NSColor clearColor].CGColor];
    [self setNeedsDisplay:YES];
}

-(void)updateTrackingAreas {
    [super updateTrackingAreas];
    if (self.trackingArea) {
        [self removeTrackingArea:self.trackingArea];
    }

    NSInteger opts = (NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways);
    self.trackingArea = [[NSTrackingArea alloc] initWithRect:[self bounds] options:opts owner:self userInfo:nil];
    [self addTrackingArea:self.trackingArea];
}

@end
