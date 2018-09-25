//
//  SKNode(TouchRecognizers) 
//  PCPlayer
//
//  Created by brandon on 2014-02-25.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import <JavaScriptCore/JSExport.h>
#import <Foundation/Foundation.h>
#import "PCPinchDirectionGestureRecognizer.h"

@protocol SKNodeTouchRecognizersExport <JSExport>

// e.g.:
// `node.addTapRecognizer(1, 1);`
//
// Each handler is passed an object containing the following properties when appropriate:
// {
//     'location': {
//         'x': 0,
//         'y': 0
//     },
//     'direction': 'left',
//     'translation': {
//         'x': 0,
//         'y': 0
//     },
//     'velocity': {
//         'x': 0,
//         'y': 0
//     }
//     'numberOfTouches': 1
// }

JSExportAs(addTapRecognizer,
- (void)pc_addTapRecognizerWithNumberOfTouches:(NSUInteger)numberOfTouches taps:(NSUInteger)numberOfTaps
);

JSExportAs(addLongPressRecognizer,
- (void)pc_addLongPressRecognizerWithNumberOfTouches:(NSUInteger)numberOfTouches taps:(NSUInteger)numberOfTaps
);

JSExportAs(addPinchRecognizer,
- (void)pc_addPinchGestureRecognizerForDirection:(NSString *)pinchDirectionName
);

JSExportAs(addSwipeRecognizer,
- (void)pc_addSwipeRecognizerWithNumberOfTouches:(NSUInteger)numberOfTouches direction:(NSString *)direction
);

- (void)addPanRecognizer;

JSExportAs(addTouchRecognizer,
- (void)pc_addTouchRecognizerWithNumberOfTouches:(NSUInteger)numberOfTouches
);

@end

@interface SKNode (TouchRecognizers) <SKNodeTouchRecognizersExport>

- (void)pc_addTapRecognizerWithNumberOfTouches:(NSUInteger)numberOfTouches taps:(NSUInteger)numberOfTaps;
- (void)pc_addLongPressRecognizerWithNumberOfTouches:(NSUInteger)numberOfTouches taps:(NSUInteger)numberOfTaps;
- (void)pc_addPinchGestureRecognizerForDirection:(NSString *)pinchDirectionName;
- (void)pc_addSwipeRecognizerWithNumberOfTouches:(NSUInteger)numberOfTouches direction:(NSString *)direction;
// We can't JSExportAs a method with 0 arguments, so we're taking the risk of not prefixing this method instead.
- (void)addPanRecognizer;
- (void)pc_addTouchRecognizerWithNumberOfTouches:(NSUInteger)numberOfTouches;

@end
