//
//  InspectorPCShape.h
//  SpriteBuilder
//
//  Created by Orest Nazarewycz on 2014-05-17.
//
//

#import <Foundation/Foundation.h>
#import "InspectorValue.h"

@interface InspectorPC3DAnimation : InspectorValue

@property (strong, nonatomic) NSString *selectedAnimationName;
@property (strong, nonatomic) NSString *selectedSkeletonName;

@property (assign, nonatomic) NSInteger repeatCount;
@property (assign, nonatomic) CGFloat fadeIn;
@property (assign, nonatomic) CGFloat fadeOut;

- (IBAction)selectAnimationPopUpButton:(id)sender;
- (IBAction)selectSkeletonPopUpButton:(id)sender;

@end
