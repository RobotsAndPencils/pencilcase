//
//  CCNode(JavaScript)
//  PROJECTNAME
//
//  Created by brandon on 2/3/2014.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import <JavaScriptCore/JavaScriptCore.h>
#import <SpriteKit/SpriteKit.h>


@interface SKNode (JavaScript)

@property (strong, nonatomic) NSString *generatedName;
@property (strong, nonatomic) NSDictionary *buildIn;
@property (strong, nonatomic) NSDictionary *buildOut;
@property (strong, nonatomic) NSMutableArray *eventScripts;
@property (assign, nonatomic) CGFloat originalOpacity;
@property (assign, nonatomic) BOOL hasBuildIn;
@property (assign, nonatomic) BOOL hasBuildOut;

/**
 *  @return An array containing this node and all of its children, recursively
 */
- (NSArray *)allNodes;

/**
 *  Intended to be used in the case that a node doesn't have a name
 *
 *  @return A unique string that can be used as a valid JS instance name
 */
+ (NSString *)uniqueInstanceName;

@end
