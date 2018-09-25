//
//  SKNode(JavaScript)
//  PCPlayer
//
//  Created by brandon on 2/3/2014.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

@import JavaScriptCore;


@protocol SKNodeJavaScriptExport <JSExport>

@property (strong, nonatomic) NSString *uuid;

@end


@interface SKNode (JavaScript) <SKNodeJavaScriptExport>

@property (strong, nonatomic) NSString *generatedName;
@property (strong, nonatomic) NSMutableDictionary *eventScripts;
@property (strong, nonatomic) NSString *uuid;

@property (assign, nonatomic) CGFloat originalOpacity;

// Returns an array of all recursive children and the parentNode itself
- (NSArray *)allNodes;

@end
