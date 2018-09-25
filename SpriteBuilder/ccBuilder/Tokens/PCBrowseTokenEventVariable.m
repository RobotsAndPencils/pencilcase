//
//  PCBrowseTokenEventVariable.m
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-09-19.
//
//

#import "PCBrowseTokenEventVariable.h"

@interface PCBrowseTokenEventVariable ()

@property (copy, nonatomic) NSString *name;

@end

@implementation PCBrowseTokenEventVariable

- (instancetype)initWithName:(NSString *)name {
    self = [super init];
    if (self) {
        _name = name;
    }
    return self;
}

#pragma mark - PCTokenBrowsable

- (NSString *)browseDisplayName {
    return self.name;
}

- (NSArray *)browseChildren {
    return @[];
}

- (BOOL)isSelectable {
    return YES;
}

@end
