//
//  UIView+FirstResponder.h
//  PencilCaseLauncher
//
//  Created by Stephen Gazzard on 2015-04-24.
//
//

#import <UIKit/UIKit.h>

@interface UIView (Snapshot)

/**
 Finds the first responder, if it is this view or one of its child views
 @returns The UIView that is first responder if it is in this node tree, or nil if it is not
 */
- (id)findFirstResponderInViewTree;

@end
