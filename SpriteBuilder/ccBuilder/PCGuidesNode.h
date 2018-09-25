//
//  PCGuidesNode.h
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2014-08-07.
//
//

#import <SpriteKit/SpriteKit.h>
#import "PCGuide.h"

@interface PCGuidesNode : SKNode

@property (strong, nonatomic) NSMutableArray *guides;

- (BOOL)mouseDown:(CGPoint)point event:(NSEvent *)event;
- (BOOL)mouseDragged:(CGPoint)point event:(NSEvent *)event;
- (BOOL)mouseUp:(CGPoint)point event:(NSEvent *)event;
- (BOOL)rightMouseDown:(CGPoint)point event:(NSEvent *)event;
- (void)flagsChanged:(NSEvent *)event;
- (void)updateWithSize:(CGSize)size stageOrigin:(CGPoint)stageOrigin zoom:(CGFloat)zoom;

- (id)serializeGuides;
- (void)loadSerializedGuides:(id)serializer;
- (void)removeAllGuides;

- (void)mouseMoved:(NSEvent *)event;

@end
