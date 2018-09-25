//
//  InspectorBlendMode.m
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-08-28.
//
//

#import "InspectorSKBlendMode.h"

@interface InspectorSKBlendMode ()

@property (assign, nonatomic) NSInteger blendModeTag;

@end

@implementation InspectorSKBlendMode

- (void)setBlendModeTag:(NSInteger)blendModeTag {
    [self setPropertyForSelection:@(blendModeTag)];
}

- (NSInteger)blendModeTag {
    return [[self propertyForSelection] integerValue];
}

- (void)refresh {
    [self willChangeValueForKey:@"blendModeTag"];
    [self didChangeValueForKey:@"blendModeTag"];
}

@end
