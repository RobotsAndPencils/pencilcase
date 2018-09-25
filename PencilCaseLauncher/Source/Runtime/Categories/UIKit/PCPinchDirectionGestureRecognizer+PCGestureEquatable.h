//
//  UIPinchGestureRecognizer+PCGestureEquatable.h
//  
//
//  Created by Brandon Evans on 2014-12-29.
//
//

#import <UIKit/UIKit.h>
#import "PCGestureEquatable.h"
#import "PCPinchDirectionGestureRecognizer.h"

@interface PCPinchDirectionGestureRecognizer (PCGestureEquatable) <PCGestureEquatable>

- (BOOL)pc_isEqualConfiguration:(id)recognizer;

@end
