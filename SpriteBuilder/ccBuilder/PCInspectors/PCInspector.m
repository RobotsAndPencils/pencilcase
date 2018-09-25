//
//  PCInspector.m
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-05-16.
//
//

#import "PCInspector.h"

@interface PCInspector ()

@end

@implementation PCInspector

- (void)setValue:(id)value forValueInfoIndex:(NSInteger)index {}

- (void)setTitle:(NSString *)title {
    if (!title) return;
    self.titleTextField.stringValue = title;
}

@end
