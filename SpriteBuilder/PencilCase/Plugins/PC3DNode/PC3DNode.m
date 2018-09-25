//
//  PC3DNode.m
//  SpriteBuilder
//
//  Created by Cody Rayment on 2/21/2014.
//
//

#import "PC3DNode.h"
#import "PlugInNode.h"
#import <SceneKit/SceneKit.h>
#import "SKNode+LifeCycle.h"
#import "SKNode+CocosCompatibility.h"
#import "SKNode+NodeInfo.h"
#import "PCResourceManager.h"
#import "PCMathUtilities.h"
#import "PCOverlayView.h"
#import "ResourceManagerUtil.h"
#import "PC3DAnimation.h"
#import "AppDelegate.h"

@interface PC3DNode () <PCOverlayNode>

@property (strong, nonatomic) PCView *containerView;
@property (strong, nonatomic) SCNView *sceneKitView;
@property (assign, nonatomic) BOOL enableUserRotation;
@property (assign, nonatomic) BOOL defaultLighting;
@property (strong, nonatomic) PCResource *resource;
@property (strong, nonatomic) SCNSceneSource *resourceSceneSource;
@property (strong, nonatomic) NSMutableSet *children3DNodeIDs;

@end

@implementation PC3DNode

- (PCEditorResizeBehaviour)editorResizeBehaviour {
	return PCEditorResizeBehaviourContentSize;
}

#pragma mark Life Cycle

- (void)pc_didEnterScene {
    [super pc_didEnterScene];
    [self setup];
    [[PCOverlayView overlayView] addTrackingNode:self];
}

- (void)pc_willExitScene {
    [super pc_willExitScene];
    [[PCOverlayView overlayView] removeTrackingNode:self];
}

#pragma mark - PCOverlayView

- (NSView<PCOverlayTrackingView> *)trackingView; {
    return self.containerView;
}

#pragma mark - Node Info

- (NSString *)uniqueDisplayNameFromName:(NSString *)name withinNodes:(NSArray *)nodes {
    if (self.resource && [self.name isEqualToString:name]) {
        // if we have a file path, override the class name so we get names from the file instead
        name = [[self.resource.filePath lastPathComponent] stringByDeletingPathExtension];
    }
    return [super uniqueDisplayNameFromName:name withinNodes:nodes];
}

#pragma mark - Properties

- (void)setFilePath:(NSString *)filePath {
    if ([filePath isEqualToString:_filePath]) return;
    _filePath = filePath;

    [self setExtraProp:filePath forKey:@"filePath"];

    if (self.scene) {
        [self setup];
    }
}

- (void)setDefaultLighting:(BOOL)defaultLighting {
	if (_defaultLighting == defaultLighting) return;
	_defaultLighting = defaultLighting;
	self.sceneKitView.autoenablesDefaultLighting = defaultLighting;
}

- (void)setXRotation3D:(CGFloat)rotationX {
    _xRotation3D = rotationX;
    SCNVector3 angles = self.threeDNode.eulerAngles;
    self.threeDNode.eulerAngles = SCNVector3Make(PC_DEGREES_TO_RADIANS(rotationX), angles.y, angles.z);
}

- (void)setYRotation3D:(CGFloat)rotationY {
    _yRotation3D = rotationY;
    SCNVector3 angles = self.threeDNode.eulerAngles;
    self.threeDNode.eulerAngles = SCNVector3Make(angles.x, PC_DEGREES_TO_RADIANS(rotationY), angles.z);
}

- (void)setZRotation3D:(CGFloat)rotationZ {
    _zRotation3D = rotationZ;
    SCNVector3 angles = self.threeDNode.eulerAngles;
    self.threeDNode.eulerAngles = SCNVector3Make(angles.x, angles.y, PC_DEGREES_TO_RADIANS(rotationZ));
}

- (void)setSelectedAnimationName:(NSString *)selectedAnimationName {
    [self setExtraProp:selectedAnimationName forKey:@"selectedAnimationName"];
    [self runAnimation:selectedAnimationName];
}

- (NSString *)selectedAnimationName {
    return [self extraPropForKey:@"selectedAnimationName"];
}

- (PC3DAnimation *)selectedAnimation {
    return self.cachedAnimations[self.selectedAnimationName];
}

- (BOOL)selectable {
    if ([self isPC3DAnimationNode]) return NO;
    return [super selectable];
}

- (BOOL)visible {
    if ([self isPC3DAnimationNode]) return NO;
    return [super visible];
}

- (BOOL)locked {
    if ([self isPC3DAnimationNode]) return YES;
    return [super locked];
}

- (BOOL)seqExpanded {
    if ([self isPC3DAnimationNode]) return NO;
    return [super seqExpanded];
}

- (CGSize)contentSize {
    if ([self isPC3DAnimationNode]) return CGSizeZero; 
    return [super contentSize];
}

- (CGPoint)position {
    if ([self isPC3DAnimationNode]) return CGPointZero;
    return [super position];
}

#pragma mark - Materials

- (void)setMaterialColor:(NSColor *)color materialType:(PC3DMaterialType)materialType materialName:(NSString *)materialName intensity:(CGFloat)intensity {
    NSArray *materials = [self nodeMaterialFromName:materialName inNode:[self threeDNode]];
    if (![materials count]) return;
    
    for (SCNMaterial *material in materials) {
        if (materialType == PC3DMaterialTypeTransparent) {
            // when setting the transparency as a single color, it's not using the transparent but the transparency property
            material.transparency = CGColorGetAlpha(color.CGColor);
            material.transparencyMode = SCNTransparencyModeAOne;
        }
        else {
            [self materialPropertyForType:materialType material:material].contents = color;
            [self materialPropertyForType:materialType material:material].intensity = intensity;
        }
    }
}

- (void)setMaterialTexture:(NSImage *)image materialType:(PC3DMaterialType)materialType materialName:(NSString *)materialName intensity:(CGFloat)intensity {
    NSArray *materials = [self nodeMaterialFromName:materialName inNode:[self threeDNode]];
    if (![materials count]) return;
    
    for (SCNMaterial *material in materials) {
        if (materialType == PC3DMaterialTypeTransparent) {
            material.transparencyMode = SCNTransparencyModeRGBZero;
        }
        [self materialPropertyForType:materialType material:material].contents = image;
        [self materialPropertyForType:materialType material:material].intensity = intensity;
    }
}

- (void)setMaterialLocksAmbientWithDiffuse:(BOOL)value materialName:(NSString *)materialName {
    NSArray *materials = [self nodeMaterialFromName:materialName inNode:[self threeDNode]];
    if (![materials count]) return;
    
    for (SCNMaterial *material in materials) {
        material.locksAmbientWithDiffuse = value;
    }
}

- (void)setMaterialFresnelExponent:(CGFloat)value materialName:(NSString *)materialName {
    NSArray *materials = [self nodeMaterialFromName:materialName inNode:[self threeDNode]];
    if (![materials count]) return;
    
    for (SCNMaterial *material in materials) {
        material.fresnelExponent = value;
    }
}

- (void)setMaterialShininess:(CGFloat)value materialName:(NSString *)materialName {
    NSArray *materials = [self nodeMaterialFromName:materialName inNode:[self threeDNode]];
    if (![materials count]) return;
    
    for (SCNMaterial *material in materials) {
        material.shininess = value;
    }
}

- (NSArray *)nodeMaterialFromName:(NSString *)materialName inNode:(SCNNode *)node {
    NSArray *materials = [self materialsForNode:node];
    return [materials filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        SCNMaterial *material = evaluatedObject;
        return [material.name isEqualToString:materialName];
    }]];
}

#pragma mark - Material Type

- (SCNMaterialProperty *)materialPropertyForType:(PC3DMaterialType)materialType material:(SCNMaterial *)material {
    switch (materialType){
        case PC3DMaterialTypeDiffuse: return material.diffuse;
        case PC3DMaterialTypeAmbient: return material.ambient;
        case PC3DMaterialTypeSpecular: return material.specular;
        case PC3DMaterialTypeNormal: return material.normal;
        case PC3DMaterialTypeReflective: return material.reflective;
        case PC3DMaterialTypeEmission: return material.emission;
        case PC3DMaterialTypeTransparent: return material.transparent;
        case PC3DMaterialTypeMultiply: return material.multiply;
    }
    return nil;
}

#pragma mark - Animations Loading

- (BOOL)has3DChildNodesBeenUpdated {
    NSMutableSet *childrenUUIDs = [[NSMutableSet alloc] init];
    NSMutableArray *nodes = [[self recursiveChildrenOfClass:[PC3DNode class]] mutableCopy];
    [nodes insertObject:self atIndex:0];
    
    for (PC3DNode *node in nodes){
        [childrenUUIDs addObject:node.UUID];
    }
    
    // return yes if we haven't loaded any IDs or the current set of IDs doesn't match existing one
    BOOL result = !self.children3DNodeIDs || ![self.children3DNodeIDs isEqualToSet:childrenUUIDs];
    self.children3DNodeIDs = childrenUUIDs;
    
    return result;
}

- (void)refreshAnimations {
    if (!self.filePath) return; 
    if (![self has3DChildNodesBeenUpdated]) return; //skip if the child PC3DNodes hasn't been update
    
    if (!self.cachedAnimations) self.cachedAnimations = [@{} mutableCopy];
    self.cachedAnimations = [self.cachedAnimations mutableCopy]; // seems to comes back as a NSDictionary from archive
    
    // get all the animations inside this node and its children
    NSArray *animations = [PC3DNode animationsForNode:self];
    NSMutableArray *animationNames = [@[] mutableCopy];
    
    // add or update any animations not in the dictionary
    for (PC3DAnimation *animation in animations) {
        if (![self.cachedAnimations.allKeys containsObject:animation.name]) {
            animation.skeletonName = [self allSkeletonNames].firstObject;
            self.cachedAnimations[animation.name] = animation;
        }
        else {
            // update animation to the latest one in case it has changed
            PC3DAnimation *cachedAnimation = self.cachedAnimations[animation.name];
            cachedAnimation.animation = animation.animation;
        }
        [animationNames addObject:animation.name];
    }
    
    // remove any animations in dictionary but not in the list
    NSArray *removeAnimations = [self.cachedAnimations.allKeys filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        NSString *animationName = evaluatedObject;
        return ![animationNames containsObject:animationName];
    }]];
    
    [self.cachedAnimations removeObjectsForKeys:removeAnimations];
    
    // when creating a new PC3DNode, make sure to set it to default animation
    if (!self.selectedAnimationName) {
        self.selectedAnimationName = [self defaultSelectedAnimationName];
    }
    
    if (self.selectedAnimationName && self.cachedAnimations[self.selectedAnimationName]){
        [self runAnimation:self.selectedAnimationName];
    }
}

- (NSString *)defaultSelectedAnimationName {
    NSString *result = @"None";
    
    // Search through all the animations and find the longest one
    NSUInteger longestDuration = 0;
    for (NSString *animationKey in self.cachedAnimations) {
        PC3DAnimation *pcAnimation = self.cachedAnimations[animationKey];
        if (pcAnimation.animation.duration > longestDuration) {
            longestDuration = pcAnimation.animation.duration;
            result = animationKey;
        }
    }
    
    // In cases where it is using animation groups, find the one with most keyframes
    // This take precedence over the longest duration animation
    NSUInteger highAnimationsCount = 0;
    for (NSString *animationKey in self.cachedAnimations) {
        PC3DAnimation *pcAnimation = self.cachedAnimations[animationKey];
        if ([pcAnimation.animation isKindOfClass:[CAAnimationGroup class]]) {
            CAAnimationGroup *animationGroup = (CAAnimationGroup *)pcAnimation.animation;
            if (animationGroup.animations.count > highAnimationsCount) {
                result = animationKey;
                highAnimationsCount = animationGroup.animations.count;
            }
        }
    }
    
    return result;
}

/*
 * Recursively search through all the nodes and return all the animations
 */
+ (NSArray *)animationsForNode:(SKNode *)node {
    if (![node isKindOfClass:[PC3DNode class]]) return nil;
    NSMutableArray *results = [@[] mutableCopy];
    
    NSMutableArray *nodes = [[node recursiveChildrenOfClass:[PC3DNode class]] mutableCopy];
    [nodes insertObject:node atIndex:0];
    
    for (PC3DNode *threeDNode in nodes) {
        for (NSString *entryIdentifier in [threeDNode animationEntries]) {
            PC3DAnimation *animationEntry = [[PC3DAnimation alloc] init];
            animationEntry.name = entryIdentifier;
            animationEntry.animation = [threeDNode animationEntry:entryIdentifier];
            [results addObject:animationEntry]; 
        }
    }
    
    return results;
}

- (CAAnimation *)animationEntry:(NSString *)animationName {
    return [[self sceneSource] entryWithIdentifier:animationName withClass:[CAAnimation class]];
}

- (NSArray *)animationEntries {
    return [[self sceneSource] identifiersOfEntriesWithClass:[CAAnimation class]];
}

- (SCNSceneSource *)sceneSource {
    if (!self.resource) return nil;    
    if (!self.resource.filePath) return nil;
    if (self.resourceSceneSource) return self.resourceSceneSource;
    
    NSURL *daeURL = [NSURL fileURLWithPath:self.resource.filePath];
    self.resourceSceneSource = [SCNSceneSource sceneSourceWithURL:daeURL options:@{SCNSceneSourceConvertToYUpKey:@YES}];
    return self.resourceSceneSource;
}

#pragma mark - Animations Actions

- (void)runAnimation:(NSString *)key {
    [self stopAllAnimation:[self threeDNode]];
    
    PC3DAnimation *animation = self.cachedAnimations[key];
    if (!animation) {
        // reset the whole thing, need do this if we are setting it to "None"
        // need to make sure animation and scene has been loaded first though
        if ([self.cachedAnimations count] > 0 && self.sceneKitView) [self setup];
        return;
    }
    
    [animation refresh];
    SCNNode *animationNode = [[self threeDNode] childNodeWithName:animation.skeletonName recursively:YES];
    if (!animationNode) {
        animationNode = [self threeDNode]; 
    }
    
    [animationNode addAnimation:animation.animation forKey:animation.name];
}

- (void)stopAllAnimation:(SCNNode *)node {
    [node removeAllAnimations];
    for (SCNNode *child in node.childNodes){
        [self stopAllAnimation:child];
    }
}

#pragma mark - Private

- (void)setup {
    if (!self.containerView) {
        self.containerView = [[PCView alloc] initWithFrame:self.frame];
    }
    [self.sceneKitView removeFromSuperview];

    self.resource = [[PCResourceManager sharedManager] resourceWithUUID:self.filePath];
    if (!self.resource) {
        return;
    }
    
    self.sceneKitView = [[SCNView alloc] initWithFrame:CGRectMake(0, 0, self.size.width, self.size.height)];
    self.sceneKitView.autoenablesDefaultLighting = self.defaultLighting;
    self.sceneKitView.backgroundColor = [NSColor clearColor];
    self.sceneKitView.scene = [self loadSCNScene];
    self.sceneKitView.autoresizingMask = NSViewWidthSizable|NSViewHeightSizable;

    // apply the rotations that may have already been set (prior to loading the 3D model)
    self.xRotation3D = _xRotation3D;
    self.yRotation3D = _yRotation3D;
    self.zRotation3D = _zRotation3D;
    self.defaultLighting = _defaultLighting;

    [self.containerView addSubview:self.sceneKitView];
    
    // check if we are just an animation node, if so refresh the parent's list of animations
    if (![self isPC3DAnimationNode]) {
        [self stopAllAnimation:[self threeDNode]];
        // On 10.11 the animation wont start unless we delay a runloop
        dispatch_async(dispatch_get_main_queue(), ^{
            [self refreshAnimations];
        });
    }
}

- (SCNNode *)threeDNode {
    return self.sceneKitView.scene.rootNode;
}

- (SCNScene *)loadSCNScene {
	NSURL *daeURL   = [NSURL fileURLWithPath:self.resource.filePath];
    SCNScene *scene = [SCNScene sceneWithURL:daeURL options:@{SCNSceneSourceConvertToYUpKey:@YES} error:nil];
	return scene;
}

+ (BOOL)hasPC3DNodeAsParent:(SKNode *)node {
    if ([node.parent isKindOfClass:[PC3DNode class]]) return YES;
    if (!node.parent) return NO;
    return [PC3DNode hasPC3DNodeAsParent:node.parent];
}

+ (PC3DNode *)pc3DNodeParentOf:(SKNode *)node {
    if ([node.parent isKindOfClass:[PC3DNode class]]) return (PC3DNode *)node.parent;
    if (!node.parent) return nil;
    return [PC3DNode pc3DNodeParentOf:node.parent];
}

#pragma mark - Public

/*
 * Recursively search through all the nodes and return all the materials
 */
- (NSArray *)materialsForNode:(SCNNode *)node {
    NSMutableArray *results = [@[] mutableCopy];
    if ([node.childNodes count]) {
        for (SCNNode *childNode in node.childNodes) {
            [results addObjectsFromArray:[self materialsForNode:childNode]];
        }
    }
    if (node.geometry && [node.geometry.materials count]) {
        [results addObjectsFromArray:node.geometry.materials];
    }
    return results;
}

- (NSArray *)materialNames {
    NSMutableSet *results = [[NSMutableSet alloc] init];
    NSArray *materials = [self materialsForNode:[self threeDNode]];
    for (SCNMaterial *material in materials) {
        [results addObject:material.name];
    }
    return [[results allObjects] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}

- (NSArray *)allSkeletonNames {
    NSArray *skinners = [[self threeDNode] childNodesPassingTest:^BOOL(SCNNode *child, BOOL *stop) {
        return child.skinner != nil;
    }];
    
    // return only the name of the actual skeleton node
    NSMutableArray *results = [@[] mutableCopy];
    for (SCNNode *node in skinners) {
        NSString *nodeName = node.skinner.skeleton.name;
        if (nodeName) [results addObject:nodeName];
    }
    
    return results;
}

- (BOOL)isPC3DAnimationNode {
    return [PC3DNode hasPC3DNodeAsParent:self];
}

- (void)saveCachedAnimations {    
    // generate a deep copy of the animations so we can compare for changes
    NSDictionary *cachedAnimations = [[NSDictionary alloc] initWithDictionary:self.cachedAnimations copyItems:YES];
    NSDictionary *savedAnimations = [self extraPropForKey:@"cachedAnimations"];
    
    if (!savedAnimations || ![cachedAnimations isEqualToDictionary:savedAnimations]) {
        [self setExtraProp:cachedAnimations forKey:@"cachedAnimations"];
        if (savedAnimations) [[AppDelegate appDelegate] saveUndoStateDidChangePropertySkipSameCheck:@"PC3DCachedAnimations"];
        
        [self stopAllAnimation:[self threeDNode]];
        [self runAnimation:self.selectedAnimationName];
    }    
}


@end
