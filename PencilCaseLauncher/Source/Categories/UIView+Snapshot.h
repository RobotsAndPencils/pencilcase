//
//  UIView+Snapshot.h
//  SpriteBuilder
//
//  Created by Cody Rayment on 2015-02-23.
//
//

#import <UIKit/UIKit.h>

@interface UIView (Snapshot)

- (UIImage *)pc_snapshotAfterScreenUpdates:(BOOL)afterScreenUpdates;

@end
