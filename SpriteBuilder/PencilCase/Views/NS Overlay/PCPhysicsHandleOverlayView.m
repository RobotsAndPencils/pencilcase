//
//  PCPhysicsHandleOverlayView.m
//  SpriteBuilder
//
//  Created by Orest Nazarewycz on 2014-12-18.
//
//

#import "PCPhysicsHandleOverlayView.h"
#import "PCOverlayView.h"
#import "PCPhysicsHandleInfo.h"

@interface PCPhysicsHandleOverlayView()

@property (strong, nonatomic) NSMutableArray *handleList;
@property (strong, nonatomic) NSMutableArray *handleInfoList;
@property (strong, nonatomic) NSMutableArray *paths;

@end


@implementation PCPhysicsHandleOverlayView

- (id)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if (self) {
        self.handleInfoList = [[NSMutableArray alloc] init];
        self.handleList = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)removeAllPhysicsHandles {
    for (NSImageView *image in self.handleList) {
        [image removeFromSuperview];
    }
    [self.handleList removeAllObjects];
    [self.handleInfoList removeAllObjects];
    [self setNeedsDisplay:YES];
}

- (void)drawPhysicsHandleForNode:(SKNode *)node withPoints:(NSMutableArray *)points physicsShape:(PCPhysicsBodyShape)physicsShape {
    NSMutableArray *convertedPoints = [[NSMutableArray alloc] init];
    for (NSInteger pointIndex = 0; pointIndex < points.count; pointIndex++) {
        CGPoint point = [points[pointIndex] pointValue];
        NSImageView *handleImageView = [[NSImageView alloc] init];
        handleImageView.image = [NSImage imageNamed:@"select-physics-corner"];
        [self addSubview:handleImageView];
        [self.handleList addObject:handleImageView];
        CGRect frame = [[PCOverlayView overlayView] convertRect:CGRectMake(point.x, point.y, 0, 0) toOverlayContentViewFromNode:node withNesting:NO];
        [convertedPoints addObject:[NSValue valueWithPoint:CGPointMake(frame.origin.x, frame.origin.y)]];
        handleImageView.frame = CGRectMake(frame.origin.x - (handleImageView.image.size.width/2), frame.origin.y - (handleImageView.image.size.height/2), handleImageView.image.size.width, handleImageView.image.size.height);
    }
    [self.handleInfoList addObject:[[PCPhysicsHandleInfo alloc] initWithPoints:convertedPoints andShapeType:physicsShape]];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    for (PCPhysicsHandleInfo *physicsHandle in self.handleInfoList) {
        [[physicsHandle bezierPathForHandleInfo] stroke];
    }
}

@end

