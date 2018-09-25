//
//  PCProjectTemplatePlatformData.m
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2015-01-14.
//
//

#import "PCProjectTemplatePlatformData.h"

static NSString *const PCProjectTemplateKeyResources = @"resources";

@implementation PCProjectTemplatePlatformData

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if (![PCProjectTemplatePlatformData dictionaryContainsNecessaryKeys:dictionary]) return nil;
    if (!(self = [super init])) return nil;

    [self loadFromDictionary:dictionary];
    return self;
}

#pragma mark - private

+ (BOOL)dictionaryContainsNecessaryKeys:(NSDictionary *)dictionary {
    if (PCIsEmpty(dictionary[PCProjectTemplateKeyResources])) return NO;
    return YES;
}

- (void)loadFromDictionary:(NSDictionary *)dictionary {
    self.resources = dictionary[PCProjectTemplateKeyResources];
}

@end
