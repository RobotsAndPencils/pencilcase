//
//  PCNodeCollisionHandler.m
//  
//
//  Created by Brandon Evans on 2014-09-17.
//
//

#import "PCNodeCollisionHandler.h"
#import "SKNode+JavaScript.h"

@interface PCNodeCollisionHandler ()

@property (nonatomic, strong, readwrite) SKNode *node;
@property (nonatomic, strong, readwrite) SKNode *otherNode;
@property (nonatomic, strong, readwrite) JSManagedValue *managedHandler;

@end

@implementation PCNodeCollisionHandler

- (instancetype)initWithNode:(SKNode *)node otherNode:(SKNode *)otherNode handler:(JSValue *)handler {
    self = [super init];
    if (!self) {
        return nil;
    }

    _node = node;
    _otherNode = otherNode;
    _managedHandler = [JSManagedValue managedValueWithValue:handler andOwner:self];

    return self;
}

- (JSValue *)handler {
    return self.managedHandler.value;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"node: %@, otherNode: %@, handler: %@", self.node.uuid, self.otherNode.uuid, self.handler];
}

@end
