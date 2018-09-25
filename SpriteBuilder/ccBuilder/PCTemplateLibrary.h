//
// PCTemplateLibrary.h
// PencilCase
//
// Created by Brandon Evans on 15-02-09.
//

@class PCTemplate;

@interface PCTemplateLibrary : NSObject

@property (nonatomic, strong, readonly) NSArray *nodeTypes;

- (void)loadLibrary;
- (void)store;

- (void)addTemplate:(PCTemplate *)templateToAdd;
- (void)removeTemplate:(PCTemplate *)templateToRemove;
- (NSArray *)templatesForNodeType:(NSString *)nodeType;
- (BOOL)hasTemplateForNodeType:(NSString *)type andName:(NSString *)name;

+ (NSString *)templateDirectory;
+ (NSString *)templateConfigFilePath;

@end
