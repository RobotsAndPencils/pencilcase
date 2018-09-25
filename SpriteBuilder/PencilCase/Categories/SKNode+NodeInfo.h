//
//  SKNode(NodeInfo) 
//  SpriteBuilder
//
//  Created by Brandon Evans on 14-07-11.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "SKNode+CocosCompatibility.h"
#import "Constants.h"

@class PlugInNode;
@class SequencerNodeProperty;
@class SequencerKeyframe;
@class NodePhysicsBody;

@interface SKNode (NodeInfo)

@property (nonatomic, assign) BOOL seqExpanded;
@property (nonatomic, assign) BOOL locked;
@property (nonatomic, assign, readonly) BOOL parentHidden;
@property (nonatomic, readonly) PlugInNode *plugIn;
@property (nonatomic, copy) NSString *displayName;
@property (nonatomic, retain) NSMutableArray *customProperties;
@property (nonatomic, assign) CGPoint transformStartPosition;
@property (nonatomic, assign) float transformStartRotation;
@property (nonatomic, assign) float transformStartScaleX;
@property (nonatomic, assign) float transformStartScaleY;
@property (nonatomic, assign) float transformStartSkewX;
@property (nonatomic, assign) float transformStartSkewY;
@property (nonatomic, assign) CGPoint transformStartAnchorPoint;
@property (nonatomic, retain) NodePhysicsBody *nodePhysicsBody;
@property (nonatomic, weak) NSString *generatedName;
@property (nonatomic, assign) BOOL hideFromUI;
@property (assign, nonatomic) BOOL selectable;
@property (nonatomic, assign, readonly) BOOL canParticipateInPhysics;

/**
 * @discussion `uuid` is legacy. Transitioning away from it but it remains to avoid migration complications. Please use `UUID` instead.
 */
@property (nonatomic, copy) NSString *uuid;

/**
 * @discussion Replacing the `uuid` property. Please use this one going forward.
 */
@property (nonatomic, copy) NSUUID *UUID;

@property (nonatomic, strong) NSDictionary *buildIn;
@property (nonatomic, strong) NSDictionary *buildOut;
@property (nonatomic, assign) BOOL usesFlashSkew;
@property (assign, nonatomic, readonly) PCNodeType nodeType;

- (id)extraPropForKey:(NSString *)key;
- (void)setExtraProp:(id)prop forKey:(NSString *)key;
- (void)removeExtraPropForKey:(NSString *)key;

- (id)baseValueForProperty:(NSString *)name;
- (void)setBaseValue:(id)value forProperty:(NSString *)name;

- (NSString *)customPropertyNamed:(NSString *)name;
- (void)setCustomPropertyNamed:(NSString *)name value:(NSString *)value;

- (id)serializeCustomProperties;
- (void)loadCustomPropertiesFromSerialization:(id)ser;
- (void)loadCustomPropertyValuesFromSerialization:(id)ser;

- (PCEditorResizeBehaviour)editorResizeBehaviour;
- (NSString *)propertyNameForResizeBehaviour;

- (void)deselect;
- (void)doubleClick:(NSEvent *)theEvent;

- (BOOL)propertyIsReadOnly:(NSString *)propertyName;
- (BOOL)allowsUserPositioning;
- (BOOL)allowsUserSizing;
- (BOOL)allowsUserRotation;
- (BOOL)allowsUserAnchorPointChange;
- (BOOL)allowsUserSkewChange;

- (BOOL)applyForceCompatible;

- (BOOL)hasParent:(SKNode *)parent;
- (NSArray *)recursiveChildrenOfClass:(Class)klass;
- (NSArray *)childrenOfClass:(Class)klass;

- (SKNode *)childInsertionNode;
- (BOOL)hasNodeChangeProperties;
- (void)ensureDisplayNameIsUnique;
- (NSString *)uniqueDisplayNameFromName:(NSString *)name withinNodes:(NSArray *)nodes;

/**
 *  Recursively search the children nodes for node with uuid
 *
 *  @param uuid UUID to search for
 *
 *  @return nil if we don't find anything
 */
- (SKNode *)recursiveChildNodeWithUUID:(NSString *)uuid;

/**
 @returns TRUE if this node has any properties with inspectors on the physics tab
 */
- (BOOL)hasPhysicsProperties;

/**
 *  If the name is empty, assigns the generated name if it exists or a new unique name
 */
- (void)generateNameIfMissing;

#pragma mark - Resources

/**
 * Given the provided key, will display a missing image resource
 * 
 * @param key The key matching the property the image should be set to.
 */
- (void)showMissingResourceImageWithKey:(NSString *)key;

/**
 Does nothing by default. Nodes that should update when their backing resource is deleted should override this method to check if their backing resource is still valid, and if so, show the missing resource image.
 */
- (void)showMissingResourceImageIfResourceMissing;

@end
