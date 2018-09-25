//
//  PCScrollView.m
//  PCPlayer
//
//  Created by Cody Rayment on 2014-06-27.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import "PCScrollView.h"
#import "SKNode+SFGestureRecognizers.h"
#import "PCAppViewController.h"

@interface UIScrollView (Expose) <UIGestureRecognizerDelegate>
@end


@implementation PCScrollView

// This comes directly from CCNode+SFGestureRecognizers
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (!self.userInteractionEnabled) return NO;
    
    BOOL result = NO;
    
    SEL selector = @selector(gestureRecognizer:shouldReceiveTouch:);
    if ([super respondsToSelector:selector]) {
        result = [super gestureRecognizer:gestureRecognizer shouldReceiveTouch:touch];
    }
    
    
    if (gestureRecognizer == self.panGestureRecognizer) {
        SKView *view = [PCAppViewController lastCreatedInstance].spriteKitView;
        CGPoint pt = [view convertPoint:[touch locationInView:view] toScene:view.scene];
        result = [self.node sf_isPointTouchableInArea:pt];
        
        //! we need to make sure that no other node ABOVE this one was touched, we want ONLY the top node with gesture recognizer to get callback
        if (result) {
            SKNode *curNode = self.node;
            SKNode *parent = self.node.parent;
            while (curNode != nil && result) {
                BOOL nodeFound = NO;
                for (SKNode *child in parent.children){
                    if (!nodeFound) {
                        if (!nodeFound && curNode == child) {
                            nodeFound = YES;
                        }
                        continue;
                    }
                    if( [child sf_isNodeInTreeTouched:pt])
                    {
                        result = NO;
                        break;
                    }
                }
                
                curNode = parent;
                parent = curNode.parent;
            }
        }
    }
    
    return result;
}

@end
