//
//  PCSlidesViewController.h
//  SpriteBuilder
//
//  Created by Orest Nazarewycz on 1/23/2014.
//
//

#import <Cocoa/Cocoa.h>
#import "PCSlide.h"

@interface PCSlidesViewController : NSViewController <NSTableViewDelegate, NSTableViewDataSource>

- (void)addSlide:(PCSlide *)slide;
- (void)selectSlideAtIndex:(NSInteger)index;
- (void)selectSlideAtIndexNumber:(NSNumber *)index;
- (NSInteger)selectedSlideIndex;
- (void)deselectAll;
- (BOOL)isFirstResponder;
- (NSString *)uuidForSlideAtIndex:(NSInteger)index;
- (void)removeSlideAtIndex:(NSInteger)index;

@end
