//
// PCTemplateLibrary.m
// PencilCase
//
// Created by Brandon Evans on 15-02-09.
//

#import "PCTemplateLibrary.h"
#import "PCTemplate.h"
#import "AppDelegate.h"

@interface PCTemplateLibrary ()

@property (nonatomic, strong) NSMutableDictionary *library;

@end

@implementation PCTemplateLibrary

- (instancetype)init {
    self = [super init];
    if (!self) return nil;

    self.library = [[NSMutableDictionary alloc] init];

    return self;
}

- (void)loadLibrary {
    [self.library removeAllObjects];

    NSDictionary *serialization = [NSDictionary dictionaryWithContentsOfFile:[[PCTemplateLibrary templateDirectory] stringByAppendingPathComponent:@"templates.plist"]];
    if (!serialization) {
        return;
    }

    for (NSString *nodeType in serialization) {
        NSArray *serializationTemplates = serialization[nodeType];
        NSMutableArray *templates = [NSMutableArray array];

        for (NSDictionary *serializationTemplate in serializationTemplates) {
            PCTemplate *templ = [[PCTemplate alloc] initWithSerialization:serializationTemplate];
            [templates addObject:templ];
        }

        self.library[nodeType] = templates;
    }
}

- (BOOL)hasTemplateForNodeType:(NSString *)type andName:(NSString *)name {
    NSArray *templates = [self templatesForNodeType:type];
    for (PCTemplate *templ in templates) {
        if ([[templ.name lowercaseString] isEqualToString:[name lowercaseString]]) return YES;
    }
    return NO;
}

- (void)addTemplate:(PCTemplate *)templateToAdd {
    NSMutableArray *templates = self.library[templateToAdd.nodeType];
    if (!templates) {
        templates = [NSMutableArray array];
        self.library[templateToAdd.nodeType] = templates;
    }

    [templates addObject:templateToAdd];

    [self store];
}

- (void)removeTemplate:(PCTemplate *)templateToRemove {
    NSMutableArray *templates = self.library[templateToRemove.nodeType];
    if (templates) {
        for (PCTemplate *eachTemplate in templates) {
            if (eachTemplate == templateToRemove) {
                // Remove preview image
                NSFileManager *fileManager = [NSFileManager defaultManager];
                [fileManager removeItemAtPath:[templateToRemove imageFilePath] error:nil];
                break;
            }
        }

        [templates removeObject:templateToRemove];
    }

    [self store];
}

- (NSArray *)templatesForNodeType:(NSString *)nodeType {
    NSArray *templates = self.library[nodeType];
    if (templates) return templates;
    return [NSArray array];
}

- (NSArray *)nodeTypes {
    return self.library.allKeys ?: @[];
}

+ (NSString *)templateDirectory {
    NSString *path = [[[AppDelegate appDelegate].currentProjectSettings rootProjectResourcesPath] stringByAppendingPathComponent:@"templates"];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    return path;
}

+ (NSString *)templateConfigFilePath {
    return [[self templateDirectory] stringByAppendingPathComponent:@"templates.plist"];
}

- (void)store {
    NSMutableDictionary *serialization = [NSMutableDictionary dictionary];

    for (NSString *nodeType in self.library) {
        NSMutableArray *serializationTemplates = [NSMutableArray array];

        NSArray *templates = [self templatesForNodeType:nodeType];

        for (PCTemplate *templ in templates) {
            [serializationTemplates addObject:[templ serialization]];
        }

        serialization[nodeType] = serializationTemplates;
    }

    [serialization writeToFile:[PCTemplateLibrary templateConfigFilePath] atomically:YES];
}

@end
