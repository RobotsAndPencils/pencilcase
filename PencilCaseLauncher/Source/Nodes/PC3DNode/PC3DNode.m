//
//  PC3DNode.m
//  PCPlayer
//
//  Created by Cody Rayment on 2014-03-25.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import "PC3DNode.h"
#import <SceneKit/SceneKit.h>
#import "SKNode+LifeCycle.h"
#import "SKNode+CocosCompatibility.h"
#import "PCOverlayNode.h"
#import "PCOverlayView.h"
#import "CCFileUtils.h"
#import "PCResourceManager.h"
#import <RXCollections/RXCollection.h>
#import "PC3DAnimation.h"

@interface PC3DNode () <PCOverlayNode>

@property (strong, nonatomic) SCNView *sceneKitView;
@property (copy, nonatomic) NSString *filePath;
@property (assign, nonatomic) BOOL enableUserRotation;
@property (assign, nonatomic) BOOL defaultLighting;

@property (weak, nonatomic) UIPanGestureRecognizer *panGestureRecognizer;
@property (assign, nonatomic) SCNMatrix4 startMatrix;
@property (strong, nonatomic) SCNSceneSource *resourceSceneSource;

@end

@implementation PC3DNode

- (void)pc_presentationDidStart {
    [super pc_presentationDidStart];
    [[PCOverlayView overlayView] addTrackingNode:self];
}

- (void)pc_dismissTransitionWillStart {
    [super pc_dismissTransitionWillStart];
    [[PCOverlayView overlayView] removeTrackingNode:self];
}

- (void)pc_presentationCompleted {
    [super pc_presentationCompleted];
    [self stopAllAnimation:[self threeDNode]]; // turn off all animations by default, so we only handle animations ourselves
    [self refreshAnimations];
}

#pragma mark - Properties

- (void)setSize:(CGSize)size {
    [super setSize:size];
    [self.sceneKitView setFrame:CGRectMake(0, 0, size.width, size.height)];
}

- (void)setXRotation3D:(CGFloat)rotationX {
    _xRotation3D = rotationX;
    SCNVector3 angles = self.threeDNode.eulerAngles;
    self.threeDNode.eulerAngles = SCNVector3Make(DEGREES_TO_RADIANS(rotationX), angles.y, angles.z);
}

- (void)setYRotation3D:(CGFloat)rotationY {
    _yRotation3D = rotationY;
    SCNVector3 angles = self.threeDNode.eulerAngles;
    self.sceneKitView.scene.rootNode.eulerAngles = SCNVector3Make(angles.x, DEGREES_TO_RADIANS(rotationY), angles.z);
}

- (void)setZRotation3D:(CGFloat)rotationZ {
    _zRotation3D = rotationZ;
    SCNVector3 angles = self.threeDNode.eulerAngles;
    self.sceneKitView.scene.rootNode.eulerAngles = SCNVector3Make(angles.x, angles.y, DEGREES_TO_RADIANS(rotationZ));
}

- (PC3DAnimation *)selectedAnimation {
    return self.cachedAnimations[self.selectedAnimationName];
}

- (void)setUserInteractionEnabled:(BOOL)userInteractionEnabled {
    [super setUserInteractionEnabled:userInteractionEnabled];
    [self updateUIUserInteractionEnabled:userInteractionEnabled];
}

- (void)updateUIUserInteractionEnabled:(BOOL)userInteractionEnabled {
    self.sceneKitView.userInteractionEnabled = userInteractionEnabled;
}

#pragma mark - PCOverlayNode

- (UIView *)trackingView {
    return self.sceneKitView;
}

- (SCNNode *)threeDNode {
    return self.sceneKitView.scene.rootNode;
}

#pragma mark - Private

- (void)setFilePath:(NSString *)filePath {
    if (![filePath isEqualToString:_filePath]) {
        _filePath = filePath;

        self.sceneKitView = [[SCNView alloc] init];
        self.sceneKitView.autoenablesDefaultLighting = self.defaultLighting;
        self.sceneKitView.backgroundColor = [UIColor clearColor];
        self.sceneKitView.scene = [self loadSCNScene];

        if (self.enableUserRotation) {
            [self addPanGestureRecognizer];
        }

        // apply the rotations that may have already been set (prior to loading the 3D model)
        self.xRotation3D = _xRotation3D;
        self.yRotation3D = _yRotation3D;
        self.zRotation3D = _zRotation3D;

        self.defaultLighting = _defaultLighting;
        [self updateUIUserInteractionEnabled:self.userInteractionEnabled];
    }
}

- (void)setDefaultLighting:(BOOL)defaultLighting {
    _defaultLighting = defaultLighting;
    self.sceneKitView.autoenablesDefaultLighting = self.defaultLighting;
}

- (void)setEnableUserRotation:(BOOL)enableUserRotation {
    _enableUserRotation = enableUserRotation;
    if (!enableUserRotation) {
        [self.sceneKitView removeGestureRecognizer:self.panGestureRecognizer];
    } else {
        [self addPanGestureRecognizer];
    }
}

- (void)addPanGestureRecognizer {
    if (!self.sceneKitView) return;
    if (self.panGestureRecognizer) return;

    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizerUpdated:)];
    panGestureRecognizer.minimumNumberOfTouches = 1;
    panGestureRecognizer.maximumNumberOfTouches = 1;
    [self.sceneKitView addGestureRecognizer:panGestureRecognizer];
    self.panGestureRecognizer = panGestureRecognizer;
}

- (NSString *)absoluteFilePath {
    return [[CCFileUtils sharedFileUtils] fullPathForFilename:[PCResourceManager sharedInstance].resources[self.filePath]];
}

/**
 *  Returns an array of paths that should be searched for images used by the dae file.
 *  This uses the current search logic in CCFileUtils.
 */
- (NSArray *)imageSearchPaths {
    CCFileUtils *fileUtils = [CCFileUtils sharedFileUtils];
    NSString *parentPath = [[self absoluteFilePath] stringByDeletingLastPathComponent];
    return [fileUtils.searchResolutionsOrder rx_mapWithBlock:^id(NSString *deviceType) {
        NSString *searchDirectory = fileUtils.directoriesDict[deviceType];
        searchDirectory = [parentPath stringByAppendingPathComponent:searchDirectory];
        return [NSURL fileURLWithPath:searchDirectory isDirectory:YES];
    }];
}

- (SCNScene *)loadSCNScene {
    NSError *error;

    NSString *filePath = [self absoluteFilePath];
    if (PCIsEmpty(filePath) || ![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return nil;
    }

    NSURL *fileURL = [NSURL fileURLWithPath:filePath isDirectory:NO];

    NSDictionary *options = @{
                              SCNSceneSourceCreateNormalsIfAbsentKey:@YES,
                              SCNSceneSourceFlattenSceneKey:@YES,
                              SCNSceneSourceAssetDirectoryURLsKey: [self imageSearchPaths],
                              };
    SCNScene *scene = [SCNScene sceneWithURL:fileURL options:options error:&error];
    if (error) {
        PCLog(@"%@", error);
    }
    return scene;
}

- (void)reloadRotationValues {
    _xRotation3D = RADIANS_TO_DEGREES(self.sceneKitView.scene.rootNode.eulerAngles.x);
    _yRotation3D = RADIANS_TO_DEGREES(self.sceneKitView.scene.rootNode.eulerAngles.y);
    _zRotation3D = RADIANS_TO_DEGREES(self.sceneKitView.scene.rootNode.eulerAngles.z);
}

#pragma mark - Input

- (void)panGestureRecognizerUpdated:(UIPanGestureRecognizer *)panGestureRecognizer {
    if (panGestureRecognizer != self.panGestureRecognizer) return;

    switch (panGestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
            self.startMatrix = self.sceneKitView.scene.rootNode.transform;
            break;
        case UIGestureRecognizerStateChanged: {
            CGPoint translation = [panGestureRecognizer translationInView:self.sceneKitView];
            SCNMatrix4 transformedMatrix = SCNMatrix4Rotate(self.startMatrix, translation.x / CGRectGetWidth(self.sceneKitView.frame) * M_PI * 2, 0, 1, 0);
            transformedMatrix = SCNMatrix4Rotate(transformedMatrix, translation.y / CGRectGetHeight(self.sceneKitView.frame) * M_PI * 2, 1, 0, 0);
            self.sceneKitView.scene.rootNode.transform = transformedMatrix;
            [self reloadRotationValues];
            break;
        }
        case UIGestureRecognizerStateEnded:
            self.startMatrix = SCNMatrix4Identity;
            break;
        default:
            break;
    }
}

#pragma mark - Materials

- (void)setMaterialColor:(UIColor *)color materialType:(PC3DMaterialType)materialType materialName:(NSString *)materialName intensity:(CGFloat)intensity {
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

- (void)setMaterialTexture:(UIImage *)image materialType:(PC3DMaterialType)materialType materialName:(NSString *)materialName intensity:(CGFloat)intensity {
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

- (NSArray *)nodeMaterialFromName:(NSString *)materialName inNode:(SCNNode *)node {
    NSArray *materials = [self materialsForNode:node];

    return [materials filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        SCNMaterial *material = evaluatedObject;
        return [material.name isEqualToString:materialName];
    }]];
}

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

#pragma mark - Animations Loading

- (void)refreshAnimations {
    if (!self.filePath) return;     
    if (!self.cachedAnimations) self.cachedAnimations = [@{} mutableCopy];
    self.cachedAnimations = [self.cachedAnimations mutableCopy];
    
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
    
    if (self.selectedAnimationName) [self runAnimation:self.selectedAnimationName];
}

+ (NSArray *)recursivePC3DNodeChildrenOf:(SKNode *)skNode {
    NSMutableArray *nodes = [[skNode.children filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return [evaluatedObject isKindOfClass:[PC3DNode class]];
    }]] mutableCopy];
    
    for (SKNode *child in skNode.children) {
        [nodes addObjectsFromArray:[PC3DNode recursivePC3DNodeChildrenOf:child]];
    }
    return [nodes copy];
}

/*
 * Recursively search through all the nodes and return all the animations
 */
+ (NSArray *)animationsForNode:(PC3DNode *)node {
    if (![node isKindOfClass:[PC3DNode class]]) return nil;
    NSMutableArray *results = [@[] mutableCopy];
    
    NSMutableArray *nodes = [[PC3DNode recursivePC3DNodeChildrenOf:node] mutableCopy];
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
    if (![self absoluteFilePath]) return nil;
    if (self.resourceSceneSource) return self.resourceSceneSource;
    
    NSURL *daeURL = [NSURL fileURLWithPath:[self absoluteFilePath]];
    self.resourceSceneSource = [SCNSceneSource sceneSourceWithURL:daeURL options:@{}];
    return self.resourceSceneSource;
}

- (NSArray *)allSkeletonNames {
    NSArray *skinners = [[self threeDNode] childNodesPassingTest:^BOOL(SCNNode *child, BOOL *stop) {
        return child.skinner != nil;
    }];
    
    // return only the name of the actual skeleton node
    NSMutableArray *results = [@[] mutableCopy];
    for (SCNNode *node in skinners) {
        [results addObject:node.skinner.skeleton.name];
    }
    
    return results;
}

- (PC3DAnimation *)animationWithName:(NSString *)animationName {
    return self.cachedAnimations[animationName];
}

#pragma mark - Animations Actions

- (void)runAnimation:(NSString *)key {
    [self stopAllAnimation:[self threeDNode]];
    
    PC3DAnimation *animation = self.cachedAnimations[key];
    if (!animation) return;
    
    [animation refresh];
    SCNNode *animationNode = [[self threeDNode] childNodeWithName:animation.skeletonName recursively:YES];
    if (!animationNode) {
        animationNode = [self threeDNode];
    };
    
    [animationNode addAnimation:animation.animation forKey:animation.name];
}

- (void)stopAllAnimation:(SCNNode *)node {
    [node removeAllAnimations];
    for (SCNNode *child in node.childNodes){
        [self stopAllAnimation:child];
    }
}

- (void)stopAnimation:(NSString *)key {
    PC3DAnimation *animation = self.cachedAnimations[key];
    if (!animation) return;
    
    SCNNode *animationNode = [[self threeDNode] childNodeWithName:animation.skeletonName recursively:YES];
    if (!animationNode) {
        animationNode = [self threeDNode];
    };
    
    [animationNode removeAnimationForKey:animation.skeletonName];
}


@end
