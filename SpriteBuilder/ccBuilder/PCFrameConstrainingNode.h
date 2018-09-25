//
//  PCFrameConstrainingNode.h
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-07-03.
//
//

#import <Foundation/Foundation.h>

@protocol PCFrameConstrainingNode <NSObject>

- (CGRect)constrainFrameInPoints:(CGRect)frame;

@end
