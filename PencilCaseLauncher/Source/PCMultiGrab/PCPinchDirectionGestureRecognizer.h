//
//  PCPinchDirectionGesutureRecognizer.h
//  
//
//  Created by Orest Nazarewycz on 2014-11-03.
//
//

#import <UIKit/UIKit.h>
#import <UIKit/UIGestureRecognizerSubclass.h>

typedef NS_ENUM(NSInteger, PCPinchDirection) {
    PCPinchDirectionClosed = 0,
    PCPinchDirectionOpen
};

@interface PCPinchDirectionGestureRecognizer : UIPinchGestureRecognizer

@property (assign, nonatomic) PCPinchDirection pinchDirection;

+ (NSString *)pc_jsRecognizerName;

@end
