//
//  PCBehavioursDataSource.h
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-12-04.
//
//

#import <Foundation/Foundation.h>

@class PCToken;
@class SKNode;
@class CCBDocument;

@interface PCBehavioursDataSource : NSObject

/*
 * @return An array of tokens for objects on the current card that are considered user-facing
 */
+ (NSArray *)objectTokens;

+ (NSArray *)textureTokens;
+ (NSArray *)imageTokens;
+ (NSArray *)beaconTokens;
+ (NSArray *)timelineTokens;
+ (NSArray *)cardTokens;
+ (NSArray *)particleTemplateTokens;

+ (NSArray *)keyValueTokens;
+ (NSString *)nameForObjectWithUUID:(NSUUID *)UUID;
+ (NSString *)nameForCardWithUUID:(NSUUID *)UUID;

+ (NSString *)displayNameForObjectType:(PCNodeType)type;
+ (NSString *)javaScriptNameForObjectType:(PCNodeType)type;

/*
 * @return An array of tokens representing the user-creatable object types
 */
+ (NSArray *)objectTypes;

+ (NSArray *)propertyTokensForNodeToken:(PCToken *)token;
+ (NSArray *)animatablePropertyTokensForNodeToken:(PCToken *)token;
+ (NSArray *)subPropertyTokensForPropertyToken:(PCToken *)token;
+ (NSArray *)subPropertyTokensForPropertyType:(PCPropertyType)type;

+ (NSArray *)viewTokensForMultiViewToken:(PCToken *)multiViewToken indicesOnly:(BOOL)indicesOnly;

+ (NSArray *)cellTokensForTableViewToken:(PCToken *)tableViewToken;
+ (NSString *)displayNameForTableViewToken:(PCToken *)tableViewToken cellUUID:(NSUUID *)cellUUID;

+ (NSArray *)allGlobalTokens;

+ (SKNode *)nodeWithUUID:(NSUUID *)UUID; 

/**
 Allows the user to perform an operation overwriting the current root node to a specified value rather than using `[PCStageScene scene].rootNode`
 @param mockedRootNode The node to use as the root node during the operation
 @param block the block to execute with the mocked root node
 */
+ (void)performWithMockedDocument:(CCBDocument *)newMockedDocument block:(dispatch_block_t)block;

@end
