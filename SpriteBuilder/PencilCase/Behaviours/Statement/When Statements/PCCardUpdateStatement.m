//
//  PCCardUpdateStatement.m
//  SpriteBuilder
//
//  Created by Brandon Evans on 15-01-20.
//
//

#import "PCCardUpdateStatement.h"
#import "PCStatementRegistry.h"

@implementation PCCardUpdateStatement

__attribute__((constructor)) static void registerStatement(void) {
    [[PCStatementRegistry sharedInstance] registerWhenStatementClass:[PCCardUpdateStatement class]];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self appendString:@"When the card updates"];
    }
    return self;
}

@end
