//
//  PCInspector.h
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-05-16.
//
//

#import <Foundation/Foundation.h>

@class PCInspector;

@protocol PCInspectorDelegate <NSObject>

- (void)inspector:(PCInspector *)inspector valueChanged:(id)newValue forValueInfoAtIndex:(NSInteger)index;

@end


@interface PCInspector : NSObject

@property (strong, nonatomic) IBOutlet NSView *view;
@property (assign, nonatomic) id<PCInspectorDelegate> delegate;
@property (strong, nonatomic) NSArray *valueInfos;
@property (weak, nonatomic) IBOutlet NSTextField *titleTextField;

- (void)setValue:(id)value forValueInfoIndex:(NSInteger)index;
- (void)setTitle:(NSString *)title;

@end
