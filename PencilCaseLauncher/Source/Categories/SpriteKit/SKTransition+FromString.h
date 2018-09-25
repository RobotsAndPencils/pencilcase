//
//  SKTransition+FromString.h
//  
//
//  Created by Brandon Evans on 2014-10-06.
//
//

#import <SpriteKit/SpriteKit.h>

@interface SKTransition (FromString)

+ (SKTransition *)transitionFromString:(NSString *)transitionName withDuration:(CGFloat)duration;

@end
