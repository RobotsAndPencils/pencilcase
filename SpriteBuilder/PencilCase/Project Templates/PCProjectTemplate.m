//
//  ProjectTemplate.m
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2015-01-14.
//
//

#import "PCProjectTemplate.h"

static NSString *const PCProjectTemplateKeyName = @"name";
static NSString *const PCProjectTemplateKeyiPhone = @"iPhone";
static NSString *const PCProjectTemplateKeyiPad = @"iPad";


@implementation PCProjectTemplate

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if (![PCProjectTemplate dictionaryContainsNecessaryKeys:dictionary]) return nil;
    if (!(self = [super init])) return nil;

    [self loadFromDictionary:dictionary];
    return self;
}

- (instancetype)initWithFile:(NSString *)filePath {
    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:filePath];
    return [self initWithDictionary:dictionary];
}

#pragma mark - Public

- (NSArray *)resourcesForDevice:(PCDeviceTargetType)deviceType {
    switch (deviceType) {
        case PCDeviceTargetTypePhone:
            return self.iPhoneData.resources;
        case PCDeviceTargetTypeTablet:
            return self.iPadData.resources;
    }
    return nil;
}

#pragma mark - Private

+ (BOOL)dictionaryContainsNecessaryKeys:(NSDictionary *)dictionary {
    if (PCIsEmpty(dictionary[PCProjectTemplateKeyName])) return NO;
    if (PCIsEmpty(dictionary[PCProjectTemplateKeyiPad]) && PCIsEmpty(dictionary[PCProjectTemplateKeyiPad])) return NO;
    return YES;
}

- (void)loadFromDictionary:(NSDictionary *)dictionary {
    self.name = dictionary[PCProjectTemplateKeyName];
    self.iPhoneData = [[PCProjectTemplatePlatformData alloc] initWithDictionary:dictionary[PCProjectTemplateKeyiPhone]];
    self.iPadData = [[PCProjectTemplatePlatformData alloc] initWithDictionary:dictionary[PCProjectTemplateKeyiPad]];
}

@end
