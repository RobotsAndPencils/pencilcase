//
//  PCFrameSnapping.h
//  SpriteBuilder
//
//  Created by Orest Nazarewycz on 2014-11-21.
//
//
#import "PCGuide.h"
#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>
#import "PCStageScene.h"
#import "SKNode+Selection.h"

typedef NS_OPTIONS(NSUInteger, PCSnapPoints) {
    PCSnapPointNone = 0,
    PCSnapPointLeftToLeft = 1 << 0,
    PCSnapPointLeftToMiddleX = 1 << 1,
    PCSnapPointLeftToRight = 1 << 2,
    PCSnapPointRightToLeft = 1 << 3,
    PCSnapPointRightToMiddleX = 1 << 4,
    PCSnapPointRightToRight = 1 << 5,
    PCSnapPointMiddleXToLeft = 1 << 6,
    PCSnapPointMiddleXToMiddleX = 1 << 7,
    PCSnapPointMiddleXToRight = 1 << 8,

    PCSnapPointBottomToBottom = 1 << 9,
    PCSnapPointBottomToMiddleY = 1 << 10,
    PCSnapPointBottomToTop = 1 << 11,
    PCSnapPointTopToBottom = 1 << 12,
    PCSnapPointTopToMiddleY = 1 << 13,
    PCSnapPointTopToTop = 1 << 14,
    PCSnapPointMiddleYToBottom = 1 << 15,
    PCSnapPointMiddleYToMiddleY = 1 << 16,
    PCSnapPointMiddleYToTop = 1 << 17,

    PCSnapPointToLeftEdgeMask = PCSnapPointLeftToLeft | PCSnapPointMiddleXToLeft | PCSnapPointRightToLeft,
    PCSnapPointToMiddleXMask = PCSnapPointLeftToMiddleX | PCSnapPointMiddleXToMiddleX | PCSnapPointRightToMiddleX,
    PCSnapPointToRightEdgeMask = PCSnapPointLeftToRight | PCSnapPointMiddleXToRight | PCSnapPointRightToRight,

    PCSnapPointToBottomEdgeMask = PCSnapPointBottomToBottom | PCSnapPointMiddleYToBottom | PCSnapPointTopToBottom,
    PCSnapPointToMiddleYMask = PCSnapPointBottomToMiddleY | PCSnapPointMiddleYToMiddleY | PCSnapPointTopToMiddleY,
    PCSnapPointToTopEdgeMask = PCSnapPointBottomToTop | PCSnapPointMiddleYToTop | PCSnapPointTopToTop,

    PCSnapPointToVerticalEdgeMask = PCSnapPointToLeftEdgeMask | PCSnapPointToMiddleXMask | PCSnapPointToRightEdgeMask,
    PCSnapPointToHorizontalEdgeMask = PCSnapPointToBottomEdgeMask | PCSnapPointToMiddleYMask | PCSnapPointToTopEdgeMask,
};

static const CGFloat PCDefaultDragSnapSensitivity = 5;
static const CGFloat PCDefaultDragLineSensitivity = 2;

@interface PCSnapFrame : NSObject

@property (strong, nonatomic) SKNode *node;
@property (assign, nonatomic) CGRect frame;
@property (assign, nonatomic) CGPoint anchorInFrame;
@property (assign, nonatomic) CGFloat left, bottom, right, top, centerX, centerY;

- (id)initWithNode:(SKNode *)node;
- (id)initWithGuide:(PCGuide *)guide;
- (id)initWithFrame:(CGRect)frame;

/**
Determines where (if at all) a node snaps against another node.
@param node the node to check for snapping against.
@param sensitivity how close an edge has to be be considered snappable
@returns an NSUInteger mask of PCSnapPoints representing all points that snap within the sensitivity.
@returns PCSnapPointNone if the node does not snap with the other node.
*/
- (PCSnapPoints)snapPointsWithNode:(PCSnapFrame *)node snapHandle:(PCTransformEdgeHandle)snapHandle snapSensitivity:(CGFloat)sensitivity;
- (BOOL)snapEdgesToFrame:(PCSnapFrame *)frame withHandle:(PCTransformEdgeHandle)handle lockAspectRatio:(BOOL)lockAspectRatio;
- (BOOL)snapNodeToFrame:(PCSnapFrame *)frame withHandle:(PCTransformEdgeHandle)handle;
- (PCTransformEdgeHandle)transformEdgeHandleFromCornerId:(CCBCornerId)cornerId;

@end


