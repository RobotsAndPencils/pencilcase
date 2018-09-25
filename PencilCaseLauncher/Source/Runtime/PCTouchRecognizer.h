//
//  PCTouchRecognizer.h
//  PencilCaseLauncherDemo
//
//  Created by Brandon Evans on 15-02-03.
//
//

@import UIKit;
#import "PCGestureEquatable.h"

@interface PCTouchRecognizer : UIGestureRecognizer <PCGestureEquatable>

@property (nonatomic, assign) NSUInteger numberOfTouchesRequired;

@end
