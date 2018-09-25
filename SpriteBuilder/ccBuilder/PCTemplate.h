//
//  PCTemplate.h
//  CocosBuilder
//
//  Created by Viktor on 7/30/13.
//
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>

@interface PCTemplate : NSObject <NSCoding>

@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSImage *image;
@property (nonatomic, copy) NSString *nodeType;
@property (nonatomic, strong) NSColor *color;
@property (nonatomic, strong) NSArray *properties;

// This is a kludge to workaround the fact that templates are included with the project template that gets unpacked when
// a new one is created. The reason it's a kludge is that this conflates template objects that get applied to objects and
// the "unpacking" or setup of templates during project unpacking. In our future utopia, when all templates, in
// anticipation of downloadable template packs, are stored in Application Support, this setup bit can be better
// separated from the template objects themselves that are stored and used within a project. At that time we can just
// ignore any serialized versions of this property and remove it from the implementation.
//
// The current intended usage of this property is similar to `properties`: an array of dictionaries with the following
// layout:
// {
//   name: the key name in `properties` for the value to be optionally changed after setup
//   type: our case is for particle sprite images, which uses 'SpriteFrame' for this value
//   value: the value used during setup, such as a file name that will be added to the resource manager
// }
//
// From the above, you can see that the other downside of having this setup leak into this class is that it's now in two
// places (templates, resource manager) instead of one (resource manager).
//
// - Brandon
@property (nonatomic, strong) NSArray *projectSetupProperties;

- (instancetype)initWithNode:(SKNode *)node name:(NSString *)name bgColor:(NSColor *)color;
- (instancetype)initWithSerialization:(NSDictionary *)dictionary;

- (NSDictionary *)serialization;
- (NSString *)imageFilePath;
- (void)applyToNode:(SKNode *)node;
- (void)updatePropertyName:(NSString *)propertyName value:(NSString *)newValue;

@end
