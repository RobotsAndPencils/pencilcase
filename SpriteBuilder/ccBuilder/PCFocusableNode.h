//
//  PCFocusableNode.h
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-06-16.
//
//

#import <Foundation/Foundation.h>

@protocol PCFocusableNode <NSObject>

- (void)focus;
- (void)endFocus;
- (BOOL)selectionOfNodesShouldEndFocus:(NSArray *)nodes;

@optional

@property (copy, nonatomic) dispatch_block_t endFocusHandler;

- (void)setMainFocus:(BOOL)mainFocus; /* Is the leaf of focus tree or a child has focus */

@end
