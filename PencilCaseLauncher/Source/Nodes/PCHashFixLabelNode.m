//
//  PCHashFixLabelNode.m
//  
//
//  Created by Cody Rayment on 2014-12-09.
//
//

#import "PCHashFixLabelNode.h"
#import "SKNode+JavaScript.h"

@implementation PCHashFixLabelNode

- (NSUInteger)hash {
    return [self.uuid hash];
}

@end
