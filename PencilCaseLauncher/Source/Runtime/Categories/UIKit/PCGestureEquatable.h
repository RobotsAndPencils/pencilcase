//
//  PCGestureEquatable.h
//  
//
//  Created by Brandon Evans on 2014-12-29.
//
//

#import <UIKit/UIKit.h>

@protocol PCGestureEquatable <NSObject>

@required
- (BOOL)pc_isEqualConfiguration:(id)recognizer;

@end
