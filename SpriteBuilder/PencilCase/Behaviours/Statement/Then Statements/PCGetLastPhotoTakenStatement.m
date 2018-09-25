//
//  PCGetLastPhotoTakenStatement.m
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2015-02-24.
//
//

#import "PCGetLastPhotoTakenStatement.h"
#import "PCStatementRegistry.h"
#import "PCStatement+Subclass.h"
#import "PCTokenVariableDescriptor.h"
#import "PCToken.h"

@implementation PCGetLastPhotoTakenStatement

__attribute__((constructor)) static void registerStatement(void) {
    [[PCStatementRegistry sharedInstance] registerThenStatementClass:[PCGetLastPhotoTakenStatement class]];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self appendString:@"Then get the latest image from photo library"];

        [self exposeToken:[PCToken tokenWithDescriptor:[PCTokenVariableDescriptor descriptorWithVariableName:@"Fetched Photo" evaluationType:PCTokenEvaluationTypeTexture sourceUUID:self.UUID]]];
    }
    return self;
}

- (BOOL)evaluatesAsync {
    return YES;
}

@end
