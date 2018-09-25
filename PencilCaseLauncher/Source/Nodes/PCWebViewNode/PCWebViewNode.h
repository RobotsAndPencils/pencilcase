//
//  PCWebViewNode.h
//  PCPlayer
//
//  Created by Cody Rayment on 2014-03-25.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import "PCOverlayNode.h"

@interface PCWebViewNode : SKSpriteNode <PCOverlayNode>

@property (copy, nonatomic) NSString *path;
@property (copy, nonatomic) NSString *currentURL;
@property (copy, nonatomic) NSString *homeURL;

/*
 * Completion handlers are used to resolve promises (this is an async JS API), and are only ever resolved.
 * i.e. There's no concept of success/failure right now, just completion.
 */
- (void)refresh:(JSValue *)completionHandler;
- (void)stop:(JSValue *)completionHandler;
- (void)home:(JSValue *)completionHandler;

/*
 * Back and forward have an async API, but because of a bug in WebKit that is fixed but not merged into iOS yet (https://bugs.webkit.org/show_bug.cgi?id=134482), they get resolved immediately.
 */
- (void)back:(JSValue *)completionHandler;
- (void)forward:(JSValue *)completionHandler;

@end
