//
//  PCGuidesNode.m
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2014-08-07.
//
//

#import "PCGuidesNode.h"
#import "PCStageScene.h"
#import "AppDelegate.h"

static const CGFloat PCGuideGrabAreaWidth = 15.0;
static const CGFloat PCGuideMoveAreaRadius = 4.0;
static const NSUInteger PCGuideNone = NSUIntegerMax;

@interface PCGuidesNode ()

@property (assign, nonatomic) CGSize winSize;
@property (assign, nonatomic) CGPoint stageOrigin;
@property (assign, nonatomic) CGFloat zoom;

@property (assign, nonatomic) BOOL showingMoveCursor;
@property (assign, nonatomic) CGPoint mousePosition;
@property (assign, nonatomic) NSUInteger indexOfCurrentlyDraggingGuide;

@property (assign, nonatomic) BOOL showingPoofCursor;

@end

@implementation PCGuidesNode

- (id)init {
    self = [super init];
    if (!self) return nil;

    self.indexOfCurrentlyDraggingGuide = PCGuideNone;
    self.guides = [[NSMutableArray alloc] init];

    return self;
}

- (void)updateGuides {
    PCStageScene *stageScene = [PCStageScene scene];

    [self removeAllChildren];

    CGRect viewRect = CGRectZero;
    viewRect.size = self.winSize;

    NSColor *guideColor = [NSColor colorWithRed:33 / 255.0f green:124 / 255.0f blue:255 / 255.0f alpha:255 / 255.0f];

    for (PCGuide *guide in self.guides) {
        if (guide.orientation == PCGuideOrientationHorizontal) {
            CGPoint viewPosition = [stageScene convertToViewSpace:CGPointMake(0, guide.position * [PCStageScene scene].stageZoom)];
            viewPosition.x = 0;
            viewPosition.y += self.stageOrigin.y;

            if (!CGRectContainsPoint(viewRect, viewPosition)) {
                continue;
            }
            SKSpriteNode *guideNode = [SKSpriteNode spriteNodeWithColor:guideColor size:CGSizeMake(self.winSize.width, 2)];
            guideNode.anchorPoint = CGPointMake(0, 0.5f);
            guideNode.position = viewPosition;
            [self addChild:guideNode];
        } else {
            CGPoint viewPosition = [stageScene convertToViewSpace:CGPointMake(guide.position * [PCStageScene scene].stageZoom, 0)];
            viewPosition.x += self.stageOrigin.x;
            viewPosition.y = 0;

            if (!CGRectContainsPoint(viewRect, viewPosition)) {
                continue;
            }
            SKSpriteNode *guideNode = [SKSpriteNode spriteNodeWithColor:guideColor size:CGSizeMake(self.winSize.width, 2)];
            guideNode.anchorPoint = CGPointMake(0, 0.5f);
            guideNode.position = viewPosition;
            guideNode.zRotation = M_PI_2;
            [self addChild:guideNode];
        }
    }
}

- (void)updateWithSize:(CGSize)winSize stageOrigin:(CGPoint)stageOrigin zoom:(CGFloat)zoom {
    if (self.hidden) return;

    if (CGSizeEqualToSize(winSize, self.winSize) && CGPointEqualToPoint(stageOrigin, self.stageOrigin) && zoom == self.zoom) {
        return;
    }

    // Store values
    self.winSize = winSize;
    self.stageOrigin = stageOrigin;
    self.zoom = zoom;

    [self updateGuides];
}

- (NSUInteger)addGuideWithOrientation:(PCGuideOrientation)orientation {
    PCGuide *guide = [[PCGuide alloc] init];
    guide.orientation = orientation;

    [self.guides addObject:guide];
    return [self.guides count] - 1;
}

- (void)removeGuideAtIndex:(NSUInteger)guideIndex {
    [self.guides removeObjectAtIndex:guideIndex];
    [self updateGuides];
}

- (NSUInteger)indexOfGuideUnderPoint:(CGPoint)point {
    PCStageScene *stageScene = [PCStageScene scene];
    AppDelegate *appDelegate = [AppDelegate appDelegate];
    NSUInteger guideIndex = PCGuideNone;
    for (NSUInteger i = 0; i < [self.guides count]; i++) {
        PCGuide *guide = self.guides[i];

        if (guide.orientation == PCGuideOrientationHorizontal) {
            CGPoint viewPosition = [stageScene convertToViewSpace:CGPointMake(0, guide.position)];
            viewPosition.x = 0;

            if (point.y > viewPosition.y - PCGuideMoveAreaRadius && point.y < viewPosition.y + PCGuideMoveAreaRadius) {
                guideIndex = i;
                [appDelegate saveUndoStateDidChangeProperty:@"*guide"];
                break;
            }
        } else {
            CGPoint viewPosition = [stageScene convertToViewSpace:CGPointMake(guide.position, 0)];
            viewPosition.y = 0;

            if (point.x > viewPosition.x - PCGuideMoveAreaRadius && point.x < viewPosition.x + PCGuideMoveAreaRadius) {
                guideIndex = i;
                [appDelegate saveUndoStateDidChangeProperty:@"*guide"];
                break;
            }
        }
    }
    return guideIndex;
}

- (void)removeAllGuides {
    [self.guides removeAllObjects];
    [self updateGuides];
}

#pragma mark - Serialization

- (id)serializeGuides {
    NSMutableArray *serialization = [NSMutableArray array];

    for (PCGuide *guide in self.guides) {
        NSMutableDictionary *guideDictionary = [NSMutableDictionary dictionary];
        guideDictionary[@"orientation"] = @(guide.orientation);
        guideDictionary[@"position"] = @(guide.position);
        [serialization addObject:guideDictionary];
    }

    return serialization;
}

- (void)loadSerializedGuides:(id)serializedData {
    [self.guides removeAllObjects];

    if (![serializedData isKindOfClass:[NSArray class]]) return;

    for (NSDictionary *guideDict in serializedData) {
        PCGuideOrientation orientation = (enum PCGuideOrientation)[guideDict[@"orientation"] intValue];
        CGFloat pos = [guideDict[@"position"] floatValue];

        PCGuide *guide = [[PCGuide alloc] init];
        guide.position = pos;
        guide.orientation = orientation;
        [self.guides addObject:guide];
    }

    [self updateGuides];
}

#pragma mark - Key Events

- (void)flagsChanged:(NSEvent *)event {
    NSUInteger indexOfGuideUnderPoint = [self indexOfGuideUnderPoint:self.mousePosition];
    BOOL commandKeyPressed = ((event.modifierFlags & NSCommandKeyMask) == NSCommandKeyMask);
    BOOL mouseIsOverGuide = indexOfGuideUnderPoint != PCGuideNone;
    if (commandKeyPressed && indexOfGuideUnderPoint != PCGuideNone && !self.showingMoveCursor) {
        enum PCGuideOrientation orientation = ((PCGuide *)self.guides[indexOfGuideUnderPoint]).orientation;
        self.showingMoveCursor = YES;
        if (orientation == PCGuideOrientationVertical) {
            [[NSCursor resizeLeftRightCursor] push];
        }
        else {
            [[NSCursor resizeUpDownCursor] push];
        }
    }
    else if (((!commandKeyPressed && mouseIsOverGuide) || (commandKeyPressed && !mouseIsOverGuide)) && self.showingMoveCursor) {
        self.showingMoveCursor = NO;
        [NSCursor pop];
    }
}

#pragma mark - Mouse Events

- (void)mouseMoved:(NSEvent *)event {
    PCStageScene *stageScene = [PCStageScene scene];
    self.mousePosition = [event locationInNode:stageScene.contentLayer];
    NSUInteger indexOfGuideUnderPoint = [self indexOfGuideUnderPoint:self.mousePosition];
    BOOL commandKeyPressed = ((event.modifierFlags & NSCommandKeyMask) == NSCommandKeyMask);
    BOOL mouseIsOverGuide = indexOfGuideUnderPoint != PCGuideNone;
    if (commandKeyPressed && mouseIsOverGuide && !self.showingMoveCursor) {
        enum PCGuideOrientation orientation = ((PCGuide *)self.guides[indexOfGuideUnderPoint]).orientation;
        self.showingMoveCursor = YES;
        if (orientation == PCGuideOrientationVertical) {
            [[NSCursor resizeLeftRightCursor] push];
        } else {
            [[NSCursor resizeUpDownCursor] push];
        }
    } else if (((!commandKeyPressed && mouseIsOverGuide) || (commandKeyPressed && !mouseIsOverGuide)) && self.showingMoveCursor) {
        self.showingMoveCursor = NO;
        [NSCursor pop];
    }
}

- (BOOL)mouseDown:(CGPoint)point event:(NSEvent *)event {
    if (self.hidden) return NO;
    AppDelegate *appDelegate = [AppDelegate appDelegate];

    NSUInteger indexOfGuideUnderPoint = PCGuideNone;
    CGPoint worldPoint = [[PCStageScene scene].contentLayer convertPoint:point toNode:[PCStageScene scene]];

    if (worldPoint.x < PCGuideGrabAreaWidth) {
        indexOfGuideUnderPoint = [self addGuideWithOrientation:PCGuideOrientationVertical];
        [appDelegate saveUndoStateDidChangeProperty:@"*guide"];
    } else if (worldPoint.y < PCGuideGrabAreaWidth) {
        indexOfGuideUnderPoint = [self addGuideWithOrientation:PCGuideOrientationHorizontal];
        [appDelegate saveUndoStateDidChangeProperty:@"*guide"];
    } else if (event.modifierFlags & NSCommandKeyMask) {
        indexOfGuideUnderPoint = [self indexOfGuideUnderPoint:point];
    }

    if (indexOfGuideUnderPoint != PCGuideNone) {
        self.indexOfCurrentlyDraggingGuide = indexOfGuideUnderPoint;
        return YES;
    }
    return NO;
}

- (BOOL)rightMouseDown:(CGPoint)point event:(NSEvent *)event {
    if (self.hidden) return NO;
    NSUInteger indexOfGuideUnderPoint = [self indexOfGuideUnderPoint:point];
    if (indexOfGuideUnderPoint != PCGuideNone) {
        [self.guides removeObjectAtIndex:indexOfGuideUnderPoint];
        [self updateGuides];
        return YES;
    }
    return NO;
}

- (BOOL)mouseDragged:(CGPoint)point event:(NSEvent *)event {
    if (self.hidden) return NO;
    if (self.indexOfCurrentlyDraggingGuide == PCGuideNone) return NO;

    PCStageScene *stageScene = [PCStageScene scene];
    CGPoint guidePos = [stageScene convertToDocSpace:point];

    PCGuide *guide = self.guides[self.indexOfCurrentlyDraggingGuide];

    if (guide.orientation == PCGuideOrientationHorizontal) {
        guide.position = (NSInteger)guidePos.y;
        if (point.y > PCGuideGrabAreaWidth) guide.hasBeenDraggedOutsideGrabArea = YES;
    } else {
        guide.position = (NSInteger)guidePos.x;
        if (point.x > PCGuideGrabAreaWidth) guide.hasBeenDraggedOutsideGrabArea = YES;
    }

    // Show/hide the pending disappearing item cursor
    CGPoint worldPoint = [event locationInNode:self.scene];
    BOOL mouseIsOutsideBoundsForHorizontalGuide = worldPoint.y < PCGuideGrabAreaWidth || worldPoint.y >= self.winSize.height;
    BOOL mouseIsOutsideBoundsForVerticalGuide = worldPoint.x < PCGuideGrabAreaWidth || worldPoint.x >= self.winSize.width;

    BOOL shouldShowPoofForHorizontalGuide = guide.orientation == PCGuideOrientationHorizontal && mouseIsOutsideBoundsForHorizontalGuide && guide.hasBeenDraggedOutsideGrabArea;
    BOOL shouldShowPoofForVerticalGuide = guide.orientation == PCGuideOrientationVertical && mouseIsOutsideBoundsForVerticalGuide && guide.hasBeenDraggedOutsideGrabArea;

    if (shouldShowPoofForHorizontalGuide && !self.showingPoofCursor) {
        self.showingPoofCursor = YES;
        [[NSCursor disappearingItemCursor] push];
    } else if (shouldShowPoofForVerticalGuide && !self.showingPoofCursor) {
        self.showingPoofCursor = YES;
        [[NSCursor disappearingItemCursor] push];
    } else if (!shouldShowPoofForHorizontalGuide && !shouldShowPoofForVerticalGuide && self.showingPoofCursor) {
        self.showingPoofCursor = NO;
        [NSCursor pop];
    }

    [self updateGuides];
    return YES;
}

- (BOOL)mouseUp:(CGPoint)point event:(NSEvent *)event {
    if (self.hidden) return NO;

    if (self.indexOfCurrentlyDraggingGuide == PCGuideNone) return NO;

    PCGuide *guide = self.guides[self.indexOfCurrentlyDraggingGuide];

    BOOL mouseIsOutsideBoundsForHorizontalGuide = point.y < PCGuideGrabAreaWidth || point.y >= self.winSize.height;
    BOOL mouseIsOutsideBoundsForVerticalGuide = point.x < PCGuideGrabAreaWidth || point.x >= self.winSize.width;

    if (guide.orientation == PCGuideOrientationHorizontal && mouseIsOutsideBoundsForHorizontalGuide) {
        [self removeGuideAtIndex:self.indexOfCurrentlyDraggingGuide];
    } else if (guide.orientation == PCGuideOrientationVertical && mouseIsOutsideBoundsForVerticalGuide) {
        [self removeGuideAtIndex:self.indexOfCurrentlyDraggingGuide];
    }

    if (self.showingPoofCursor) {
        self.showingPoofCursor = NO;
        [NSCursor pop];
        NSShowAnimationEffect(NSAnimationEffectPoof, [NSEvent mouseLocation], NSZeroSize, NULL, NULL, NULL);

        if (self.showingMoveCursor) {
            self.showingMoveCursor = NO;
            [NSCursor pop];
        }
    }

    self.indexOfCurrentlyDraggingGuide = PCGuideNone;

    return YES;
}

@end
