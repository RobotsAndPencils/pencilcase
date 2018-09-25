//
//  PCNodeManager.h
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-07-23.
//
//

#import <SpriteKit/SpriteKit.h>

@class PlugInNode;

@interface PCNodeManager : SKSpriteNode

@property (strong, nonatomic) PlugInNode *emptyPlugIn;
@property (strong, nonatomic) NSMutableDictionary *mixedProperties;
@property (strong, nonatomic) NSMutableDictionary *isMixedStateDict;
@property (strong, nonatomic) NSArray *managedNodes;
@property (strong, nonatomic) NSString *parameterKey;
@property (assign, nonatomic) BOOL canParticipateInPhysics;
@property (assign, nonatomic) CGFloat storedTimelinePosition;

- (instancetype)initWithNodes:(NSArray *)nodes uuid:(NSString *)uuid;
- (BOOL)isManagingNodes:(NSArray *)selectedNodes;
- (void)updateNodeManagerInspectorForProperty:(NSString *)prop;
- (BOOL)determineMixedStateForProperty:(NSString *)prop;

@end
