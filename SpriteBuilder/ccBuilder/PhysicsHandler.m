/*
 * CocosBuilder: http://www.cocosbuilder.com
 *
 * Copyright (c) 2013 Apportable Inc
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "PhysicsHandler.h"
#import "AppDelegate.h"
#import "NodePhysicsBody.h"
#import "CCBUtil.h"
#import "PhysicsInspector.h"
#import "SKNode+CocosCompatibility.h"
#import "SKNode+CoordinateConversion.h"
#import "CGPointUtilities.h"
#import "PCMathUtilities.h"
#import "SKNode+NodeInfo.h"
#import "SKNode+PhysicsBody.h"
#import "PCOverlayView.h"

#define kCCBPhysicsHandleRadius 5
#define kCCBPhysicsLineSegmFuzz 5
#define kCCBPhysicsSnapDist 10

static const NSInteger PCNoSelectedHandleIndex = -1;

float distanceFromLineSegment(CGPoint a, CGPoint b, CGPoint c)
{
    float ax = a.x;
    float ay = a.y;
    float bx = b.x;
    float by = b.y;
    float cx = c.x;
    float cy = c.y;
    
	float r_numerator = (cx-ax)*(bx-ax) + (cy-ay)*(by-ay);
	float r_denomenator = (bx-ax)*(bx-ax) + (by-ay)*(by-ay);
	float r = r_numerator / r_denomenator;
    
    float s = ((ay-cy)*(bx-ax)-(ax-cx)*(by-ay)) / r_denomenator;
    
    float distanceSegment = 0;
	float distanceLine = fabs(s)*sqrt(r_denomenator);
    
	if ( (r >= 0) && (r <= 1) )
	{
		distanceSegment = distanceLine;
	}
	else
	{
        
		float dist1 = (cx-ax)*(cx-ax) + (cy-ay)*(cy-ay);
		float dist2 = (cx-bx)*(cx-bx) + (cy-by)*(cy-by);
		if (dist1 < dist2)
		{
			distanceSegment = sqrtf(dist1);
		}
		else
		{
			distanceSegment = sqrtf(dist2);
		}
	}
    
	return distanceSegment;
}

@interface PhysicsHandler ()

@property (strong, nonatomic) SKNode *selectedNode;

@property (assign, nonatomic) CGPoint mouseDownPosition;
@property (assign, nonatomic) NSInteger selectedHandleIndex;
@property (assign, nonatomic) CGPoint mousePositionInHandleSpace;
@property (assign, nonatomic) CGPoint handleStartPosition;

- (void)fillBodyShapeString;
@end

@implementation PhysicsHandler

#pragma mark - Lifetime

- (void) awakeFromNib {
    _selectedHandleIndex = PCNoSelectedHandleIndex;
    
    _bodyShape = PCPhysicsBodyShapePolygon;
    _radius = 0;
    
    _dynamic = YES;
    _affectedByGravity = YES;
    _allowsRotation = YES;
    _allowsUserDragging = YES;
    
    _density = 1.0f;
    _friction = 0.3f;
    _elasticity = 0.3f;
    
    self.isMixedStateDict = [NSMutableDictionary dictionary];
    self.physicsInspector = [[PhysicsInspector alloc] init];
    
    self.isMixedStateDict[@"bodyShape"] = @NO;
    self.isMixedStateDict[@"radius"] = @NO;
    self.isMixedStateDict[@"dynamic"] = @NO;
    self.isMixedStateDict[@"affectedByGravity"] = @NO;
    self.isMixedStateDict[@"allowsRotation"] = @NO;
    self.isMixedStateDict[@"allowsUserDragging"] = @NO;
    self.isMixedStateDict[@"density"] = @NO;
    self.isMixedStateDict[@"friction"] = @NO;
    self.isMixedStateDict[@"elasticity"] = @NO;
}

#pragma mark - Public

- (void)didReloadScene {
    self.selectedNodePhysicsBody = nil;
    self.selectedNode = nil;
}

- (void) willChangeSelection
{
    [self willChangeValueForKey:@"selectedNodePhysicsEnabled"];
}

- (void) didChangeSelection
{
    // Update properties
    [self didChangeValueForKey:@"selectedNodePhysicsEnabled"];
    
    [self loadSelectedNodesData];
}

- (void)togglePhysicsProperty:(id)panelItemSender
{
    NSArray *selectedNodes = [[AppDelegate appDelegate] selectedSpriteKitNodes];
    NSButtonCell *panelItem = panelItemSender;
    NSMatrix *panelMatrix = panelItemSender;
    SKNode *firstNode = selectedNodes[0];
    switch ([panelItemSender tag]) {
        case CCPhysicsEnablePhysics:
            [self setSelectedNodePhysicsEnabled:[panelItem state]];
            break;
        case CCPhysicsBodyShapePolygon:
            self.bodyShape = PCPhysicsBodyShapePolygon;
            [self fillBodyShapeString];
            for (SKNode *node in selectedNodes) {
                NodePhysicsBody *body = node.nodePhysicsBody;
                [body setupDefaultPolygonForSpriteKitNode:node];
            }
            self.isMixedStateDict[@"bodyShape"] = @NO;
            self.radius = firstNode.nodePhysicsBody.radius;
            self.isMixedStateDict[@"radius"] = @NO;
            [[AppDelegate appDelegate] saveUndoStateDidChangeProperty:@"*P*bodyShape"];
            break;
        case CCPhysicsBodyShapeCircle:
            self.bodyShape = PCPhysicsBodyShapeCircle;
            [self fillBodyShapeString];
            for (SKNode *node in selectedNodes) {
                NodePhysicsBody *body = node.nodePhysicsBody;
                [body setupDefaultCircleForSpriteKitNode:node];
            }
            self.isMixedStateDict[@"bodyShape"] = @NO;
            self.radius = firstNode.nodePhysicsBody.radius;
            self.isMixedStateDict[@"radius"] = @NO;
            for (SKNode *node in selectedNodes) {
                if (node.nodePhysicsBody.radius != self.radius) {
                    self.isMixedStateDict[@"radius"] = @YES;
                    break;
                }
            }
            [[AppDelegate appDelegate] saveUndoStateDidChangeProperty:@"*P*bodyShape"];
            break;
        case CCPhysicsBodyShapeTexture: {
            self.bodyShape = PCPhysicsBodyShapeTexture;
            [self fillBodyShapeString];
            for (SKNode *node in selectedNodes) {
                NodePhysicsBody *body = node.nodePhysicsBody;
                body.bodyShape = PCPhysicsBodyShapeTexture;
                body.radius = 0;
            }
            self.isMixedStateDict[@"bodyShape"] = @NO;
            self.radius = firstNode.nodePhysicsBody.radius;
            self.isMixedStateDict[@"radius"] = @NO;
            [[AppDelegate appDelegate] saveUndoStateDidChangeProperty:@"*P*bodyShape"];
            break;
        }
        case CCPhysicsRadius:
            self.radius = [panelItemSender floatValue];
            for (SKNode *node in selectedNodes) {
                NodePhysicsBody *body = node.nodePhysicsBody;
                [body setRadius:[panelItemSender floatValue]];
            }
            self.isMixedStateDict[@"radius"] = @NO;
            [[AppDelegate appDelegate] saveUndoStateDidChangeProperty:@"*P*radius"];
            break;
        case CCPhysicsDynamic:
            panelItem = [panelMatrix selectedCell];
            self.dynamic = [panelItem tag];
            for (SKNode *node in selectedNodes) {
                NodePhysicsBody *body = node.nodePhysicsBody;
                [body setDynamic:[panelItem tag]];
            }
            self.isMixedStateDict[@"dynamic"] = @NO;
            self.staticRadioState = !self.dynamic;
            [[AppDelegate appDelegate] saveUndoStateDidChangeProperty:@"*P*dynamic"];
            break;
        case CCPhysicsAffectedByGravity: {
            NSButton *button = panelItemSender;
            if([button state] == NSMixedState){
                [button performClick:panelItemSender];
                return;
            }

            self.affectedByGravity = [panelItem state];
            for (SKNode *node in selectedNodes) {
                NodePhysicsBody *body = node.nodePhysicsBody;
                [body setAffectedByGravity:[panelItem state]];
            }
            self.isMixedStateDict[@"affectedByGravity"] = @NO;
            [[AppDelegate appDelegate] saveUndoStateDidChangeProperty:@"*P*affectedByGravity"];
            break;
        }
        case CCPhysicsAllowsRotation: {
            NSButton *button = panelItemSender;
            if([button state] == NSMixedState){
                [button performClick:panelItemSender];
                return;
            }
            self.allowsRotation = [panelItem state];
            for (SKNode *node in selectedNodes) {
                NodePhysicsBody *body = node.nodePhysicsBody;
                [body setAllowsRotation:[panelItem state]];
            }
            self.isMixedStateDict[@"allowsRotation"] = @NO;
            [[AppDelegate appDelegate] saveUndoStateDidChangeProperty:@"*P*allowsRotation"];
            break;
        }
        case CCPhysicsAllowsUserDragging: {
            NSButton *button = panelItemSender;
            if([button state] == NSMixedState){
                [button performClick:panelItemSender];
                return;
            }
            self.allowsUserDragging = [panelItem state];
            for (SKNode *node in selectedNodes) {
                NodePhysicsBody *body = node.nodePhysicsBody;
                [body setAllowsUserDragging:[panelItem state]];
            }
            self.isMixedStateDict[@"allowsUserDragging"] = @NO;
            [[AppDelegate appDelegate] saveUndoStateDidChangeProperty:@"*P*allowsUserDragging"];
            break;
        }
        case CCPhysicsDensity:
            self.density = [panelItemSender floatValue];
            for (SKNode *node in selectedNodes) {
                NodePhysicsBody *body = node.nodePhysicsBody;
                [body setDensity:[panelItemSender floatValue]];
            }
            self.isMixedStateDict[@"density"] = @NO;
            [[AppDelegate appDelegate] saveUndoStateDidChangeProperty:@"*P*density"];
            break;
        case CCPhysicsFriction:
            self.friction = [panelItemSender floatValue];
            for (SKNode *node in selectedNodes) {
                NodePhysicsBody *body = node.nodePhysicsBody;
                [body setFriction:[panelItemSender floatValue]];
            }
            self.isMixedStateDict[@"friction"] = @NO;
            [[AppDelegate appDelegate] saveUndoStateDidChangeProperty:@"*P*friction"];
            break;
        case CCPhysicsElasticity:
            self.elasticity = [panelItemSender floatValue];
            for (SKNode *node in selectedNodes) {
                NodePhysicsBody *body = node.nodePhysicsBody;
                [body setElasticity:[panelItemSender floatValue]];
            }
            self.isMixedStateDict[@"elasticity"] = @NO;
            [[AppDelegate appDelegate] saveUndoStateDidChangeProperty:@"*P*elasticity"];
            break;

        default:
            break;
    }
    [self updatePhysicsMixedState];
}


- (void)loadSelectedNodesData {
    NSArray *selectedSpriteKitNodes = [[AppDelegate appDelegate] selectedSpriteKitNodes];
    
    if (!selectedSpriteKitNodes.count) return;
    
    SKNode *node = [selectedSpriteKitNodes firstObject];
    NodePhysicsBody *body = node.nodePhysicsBody;
    self.bodyShape = body.bodyShape;
    self.radius = body.radius;
    self.dynamic = body.dynamic;
    self.staticRadioState = !self.dynamic;
    self.affectedByGravity = body.affectedByGravity;
    self.allowsRotation = body.allowsRotation;
    self.allowsUserDragging = body.allowsUserDragging;
    self.density = body.density;
    self.friction = body.friction;
    self.elasticity = body.elasticity;
    
    self.isMixedStateDict[@"bodyShape"] = @NO;
    self.isMixedStateDict[@"radius"] = @NO;
    self.isMixedStateDict[@"dynamic"] = @NO;
    self.isMixedStateDict[@"affectedByGravity"] = @NO;
    self.isMixedStateDict[@"allowsRotation"] = @NO;
    self.isMixedStateDict[@"allowsUserDragging"] = @NO;
    self.isMixedStateDict[@"density"] = @NO;
    self.isMixedStateDict[@"friction"] = @NO;
    self.isMixedStateDict[@"elasticity"] = @NO;
    
    [self fillBodyShapeString];

    self.physicsInspectorCanEnablePhysics = YES;
    self.physicsInspectorCanSelectTextureShape = YES;
    for (SKNode *node in selectedSpriteKitNodes) {
        body = node.nodePhysicsBody;
        if (self.bodyShape != body.bodyShape) self.isMixedStateDict[@"bodyShape"] = @YES;
        if (self.radius != body.radius) self.isMixedStateDict[@"radius"] = @YES;
        if (self.dynamic != body.dynamic) self.isMixedStateDict[@"dynamic"] = @YES;
        if (self.affectedByGravity != body.affectedByGravity) self.isMixedStateDict[@"affectedByGravity"] = @YES;
        if (self.allowsRotation != body.allowsRotation) self.isMixedStateDict[@"allowsRotation"] = @YES;
        if (self.allowsUserDragging != body.allowsUserDragging) self.isMixedStateDict[@"allowsUserDragging"] = @YES;
        if (self.density != body.density) self.isMixedStateDict[@"density"] = @YES;
        if (self.friction != body.friction) self.isMixedStateDict[@"friction"] = @YES;
        if (self.elasticity != body.elasticity) self.isMixedStateDict[@"elasticity"] = @YES;

        if (![node canParticipateInPhysics]) {
            self.physicsInspectorCanEnablePhysics = NO;
        }

        if (![node pc_supportsTexturePhysicsBody]) {
            self.physicsInspectorCanSelectTextureShape = NO;
        }
    }
    
    [self updatePhysicsMixedState];
}

- (void) updateSpriteKitPhysicsEditor:(SKNode *) editorView {

    float selectionBorderWidth = 1.0 / [AppDelegate appDelegate].contentScaleFactor;

    if (self.editingPhysicsBody)
    {
        NSArray *selectedNodes = [[AppDelegate appDelegate] selectedSpriteKitNodes];

        for (SKNode *node in selectedNodes) {
            // Position physic corners
            NodePhysicsBody* body = node.nodePhysicsBody;

            if (body.bodyShape == PCPhysicsBodyShapePolygon) {
                CGPoint* points = malloc(sizeof(CGPoint)*body.points.count);

                CGMutablePathRef path = CGPathCreateMutable();
                SKShapeNode *shapeNode = [[SKShapeNode alloc] init];
                [editorView addChild:shapeNode];

                int i = 0;
                NSMutableArray *handlePoints = [[NSMutableArray alloc] init];
                for (NSValue* pointValue in body.points) {
                    // Absolute handle position

                    CGPoint handlePosition = [PhysicsHandler physicsHandlePositionFromValue:pointValue forNode:node];
                    points[i] = pc_CGPointRound(handlePosition);

                    if (0 == i) {
                        CGPathMoveToPoint(path, NULL, points[i].x, points[i].y);
                    } else {
                        CGPathAddLineToPoint(path, NULL, points[i].x, points[i].y);
                    }

                    SKSpriteNode* handle = [SKSpriteNode spriteNodeWithImageNamed:@"select-physics-corner"];
                    handle.position = handlePosition;
                    if ([node conformsToProtocol:@protocol(PCOverlayNode)]) {
                        [handlePoints addObject:[NSValue valueWithPoint:handle.position]];
                    }

                    [editorView addChild:handle];
                    i++;
                }

                CGPathAddLineToPoint(path, NULL, points[0].x, points[0].y);
                shapeNode.path = path;
                shapeNode.lineWidth = selectionBorderWidth;
                shapeNode.antialiased = NO;
                shapeNode.strokeColor = [NSColor blackColor];

                if ([node conformsToProtocol:@protocol(PCOverlayNode)]) {
                    [[PCOverlayView overlayView].physicsHandlesView drawPhysicsHandleForNode:shapeNode withPoints:handlePoints physicsShape:PCPhysicsBodyShapePolygon];
                    shapeNode.lineWidth = 0;
                }
                free(points);
            } else if (body.bodyShape == PCPhysicsBodyShapeCircle) {
                float scale = [PhysicsHandler radiusScaleFactorForNode:node];
                CGPoint center = [[body.points objectAtIndex:0] pointValue];
                center.x -= node.contentSize.width * node.anchorPoint.x;
                center.y -= node.contentSize.height * node.anchorPoint.y;
                center = [node pc_convertToWorldSpace:center];

                // TODO: Better handling of scale
                CGPoint edge = pc_CGPointAdd(center, CGPointMake(body.radius * scale, 0));


                // Circle shape
                CGPoint* points = malloc(sizeof(CGPoint)*32);

                CGMutablePathRef path = CGPathCreateMutable();

                for (int i = 0; i < 32; i++) {
                    float angle = (2.0f * M_PI * i)/32;
                    CGPoint pt = CGPointMake(cosf(angle), sinf(angle));
                    pt = pc_CGPointMultiply(pt, scale * body.radius);
                    pt = pc_CGPointAdd(pt, center);

                    points[i] = pt;

                    if (0 == i) {
                        CGPathMoveToPoint(path, NULL, points[i].x, points[i].y);
                    } else {
                        CGPathAddLineToPoint(path, NULL, points[i].x, points[i].y);
                    }
                }

                CGPathAddLineToPoint(path, NULL, points[0].x, points[0].y);
                SKShapeNode *shapeNode = [[SKShapeNode alloc] init];
                shapeNode.path = path;
                shapeNode.lineWidth = selectionBorderWidth;
                shapeNode.antialiased = NO;
                shapeNode.strokeColor = [NSColor blackColor];
                [editorView addChild:shapeNode];

                free(points);

                // Draw handles
                SKSpriteNode* centerHandle = [SKSpriteNode spriteNodeWithImageNamed:@"select-physics-corner"];
                centerHandle.position = pc_CGPointRound(center);
                [editorView addChild:centerHandle];

                SKSpriteNode* edgeHandle = [SKSpriteNode spriteNodeWithImageNamed:@"select-physics-corner"];
                edgeHandle.position = pc_CGPointRound(edge);
                [editorView addChild:edgeHandle];

                if ([node conformsToProtocol:@protocol(PCOverlayNode)]) {
                    NSMutableArray *handles = [@[[NSValue valueWithPoint:centerHandle.position], [NSValue valueWithPoint:edgeHandle.position]] mutableCopy];
                    [[PCOverlayView overlayView].physicsHandlesView drawPhysicsHandleForNode:shapeNode withPoints:handles physicsShape:PCPhysicsBodyShapeCircle];
                    shapeNode.lineWidth = 0;
                }
            }
            else if (body.bodyShape == PCPhysicsBodyShapeTexture) {
                SKTexture *texture = [node pc_textureForPhysicsBody];
                SKSpriteNode *mask = [SKSpriteNode spriteNodeWithTexture:texture size:node.contentSize];

                CIFilter *filter = [CIFilter filterWithName:@"CIColorClamp"];
                [filter setValue:[CIVector vectorWithCGRect:CGRectMake(0.957, 0.624, 0.925, 0)] forKey:@"inputMinComponents"];
                [filter setValue:[CIVector vectorWithCGRect:CGRectMake(0.957, 0.624, 0.925, 1)] forKey:@"inputMaxComponents"];

                // This doesn't work due to a bug in SK: http://stackoverflow.com/questions/19243111/spritekit-sktexture-crash
                // Brandon's testing says it works on Yosemite so we can switch to this when we no longer need Mavericks support
                // We switched to using this on Feb 23, 2015 and started getting strange drawing glitches (on all nodes using this I think). Cody saw this in thumbnails and Stephen saw it on the card itself.
                // texture = [texture textureByApplyingCIFilter:filter];
                // Use an effect node instead

                SKEffectNode *effectNode = [SKEffectNode node];
                effectNode.filter = filter;
                effectNode.shouldEnableEffects = YES;
                [effectNode addChild:mask];

                mask.position = [node.parent pc_convertToWorldSpace:node.position];
                mask.rotation = [node.parent pc_convertRotationInDegreesToWorldSpace:node.rotation];
                mask.anchorPoint = node.anchorPoint;
                CGVector scale = [node.parent pc_convertScaleToWorldSpace:CGVectorMake(node.xScale, node.yScale)];
                mask.xScale = scale.dx;
                mask.yScale = scale.dy;

                [editorView addChild:effectNode];
            }
        }
    }
}

- (void)updatePhysicsMixedState {
    if ([self.isMixedStateDict[@"dynamic"] boolValue]) {
        [self setDynamic:NSMixedState];
        [self setStaticRadioState:NSMixedState];
    }

    if ([self.isMixedStateDict[@"affectedByGravity"] boolValue]) {
        [self setAffectedByGravity:NSMixedState];
    }

    if ([self.isMixedStateDict[@"allowsRotation"] boolValue]) {
        [self setAllowsRotation:NSMixedState];
    }

    if ([self.isMixedStateDict[@"allowsUserDragging"] boolValue]) {
        [self setAllowsUserDragging:NSMixedState];
    }

    [self.physicsInspector updatePhysicsInspectorFontsWithMixedState:self.isMixedStateDict];
}

#pragma mark - Mouse Input

- (BOOL)mouseDown:(CGPoint)mousePosition event:(NSEvent *)event {
    if (!self.editingPhysicsBody) return NO;

    self.mouseDownPosition = mousePosition;
    if ([self selectNodeWithHandleUnder:mousePosition]) return YES;
    if ([self selectNodeWithLineUnder:mousePosition]) return YES;

    self.selectedNodePhysicsBody = nil;
    self.selectedNode = nil;
    self.selectedHandleIndex = PCNoSelectedHandleIndex;
    return NO;
}

- (BOOL)mouseDragged:(CGPoint)pos event:(NSEvent *)event {
    if (!self.editingPhysicsBody) return NO;
    if (self.selectedHandleIndex == PCNoSelectedHandleIndex) return NO;

    CGPoint delta = pc_CGPointSubtract(pos, self.mouseDownPosition);
    CGPoint mousePosInHandleSpace = [self.selectedNode pc_convertToNodeSpace:pos];
    CGPoint nodeDelta = pc_CGPointSubtract(mousePosInHandleSpace, self.mousePositionInHandleSpace);
    self.mousePositionInHandleSpace = mousePosInHandleSpace;

    if (self.selectedNodePhysicsBody.bodyShape == PCPhysicsBodyShapePolygon) {
        NSMutableArray *points = [self.selectedNodePhysicsBody.points mutableCopy];

        CGPoint originalPoint = [points[self.selectedHandleIndex] pointValue];
        CGPoint newPos = pc_CGPointAdd(nodeDelta, originalPoint);

        if ([event modifierFlags] & NSShiftKeyMask) {
            // Handle snapping if shift is down
            CGPoint pt0 = [points[(self.selectedHandleIndex + points.count - 1) % points.count] pointValue];
            CGPoint pt1 = [points[(self.selectedHandleIndex + 1) % points.count] pointValue];

            newPos = [self snapPoint:newPos toPt0:pt0 andPt1:pt1];
        }

        [points replaceObjectAtIndex:self.selectedHandleIndex withObject:[NSValue valueWithPoint:newPos]];
        self.selectedNodePhysicsBody.points = points;
    } else if (self.selectedNodePhysicsBody.bodyShape == PCPhysicsBodyShapeCircle) {
        if (self.selectedHandleIndex == 0) {
            CGPoint originalPoint = [self.selectedNodePhysicsBody.points[self.selectedHandleIndex] pointValue];
            CGPoint newPos = pc_CGPointAdd(nodeDelta, originalPoint);

            self.selectedNodePhysicsBody.points = @[[NSValue valueWithPoint:newPos]];
        } else if (self.selectedHandleIndex == 1) {
            // Radius handle
            self.selectedNodePhysicsBody.radius = self.handleStartPosition.x + delta.x / [PhysicsHandler radiusScaleFactorForNode:self.selectedNode];
            self.selectedNodePhysicsBody.radius = MAX(0, self.selectedNodePhysicsBody.radius);
            self.radius = self.selectedNodePhysicsBody.radius;
        }
    }

    [[AppDelegate appDelegate] saveUndoStateDidChangeProperty:@"*P*points"];
    return YES;
}

- (BOOL)mouseUp:(CGPoint)pos event:(NSEvent *)event {
    if (!self.editingPhysicsBody) return NO;
    if (self.selectedHandleIndex == PCNoSelectedHandleIndex || self.selectedNodePhysicsBody == nil) return NO;

    if (self.selectedNodePhysicsBody.bodyShape == PCPhysicsBodyShapePolygon) {
        [self makeConvexHull];
    }
    self.selectedHandleIndex = PCNoSelectedHandleIndex;
    return YES;
}


#pragma mark - Private



- (void)fillBodyShapeString {
    if (self.bodyShape == PCPhysicsBodyShapePolygon) {
        self.bodyShapeString = @"Polygon";
        self.bodyShapeSupportsRadius = NO;
    } else if (self.bodyShape == PCPhysicsBodyShapeCircle) {
        self.bodyShapeString = @"Circle";
        self.bodyShapeSupportsRadius = YES;
    } else if (self.bodyShape == PCPhysicsBodyShapeTexture) {
        self.bodyShapeString = @"Image Alpha";
        self.bodyShapeSupportsRadius = NO;
    }
}

- (void)setSelectedNodePhysicsEnabled:(NSInteger)enabled {
    NSArray *selectedNodes = [[AppDelegate appDelegate] selectedSpriteKitNodes];
    
    for (SKNode *node in selectedNodes) {
        if (enabled) {
            if (!node.nodePhysicsBody) node.nodePhysicsBody = [[NodePhysicsBody alloc] initWithSpriteKitNode:node];
        } else {
            node.nodePhysicsBody = nil;
        }
    }
    
    [self loadSelectedNodesData];
    
    self.physicsInspectorElementsEnabled = enabled;
    [[AppDelegate appDelegate] saveUndoStateDidChangeProperty:@"*P*physicsBody"];
}

- (NSCellStateValue)selectedNodePhysicsEnabled { //answer for all selected nodes
    BOOL atLeastOneEnabled = NO;
    BOOL atLeastOneDisabled = NO;
    NSArray *selectedNodes = [[AppDelegate appDelegate] selectedSpriteKitNodes];
    for (SKNode *node in selectedNodes) {
        if (!node.nodePhysicsBody) {
            atLeastOneDisabled = YES;
        } else {
            atLeastOneEnabled  = YES;
        }
    }
    
    if (atLeastOneDisabled && !atLeastOneEnabled) {
        self.physicsInspectorElementsEnabled = NO;
        return NSOffState;
    }
    else if (!atLeastOneDisabled && atLeastOneEnabled) {
        self.physicsInspectorElementsEnabled = YES;
        return NSOnState;
    }
    else {
        self.physicsInspectorElementsEnabled = NO;
        return NSMixedState;
    }
}

- (BOOL)editingPhysicsBody {
    BOOL isEditing = YES;
    BOOL physicsTabIsSelected = [[AppDelegate appDelegate] isPhysicsTabSelected];
    
    if ([self selectedNodePhysicsEnabled] != NSOnState) isEditing = NO;
    
    if (!physicsTabIsSelected) isEditing = NO;
    
    return isEditing;
}

+ (CGPoint)physicsHandlePositionFromValue:(NSValue *)pointValue forNode:(SKNode *)node {
    CGPoint pointHandlePosition = [pointValue pointValue];
    pointHandlePosition.x -= node.contentSize.width * node.anchorPoint.x;
    pointHandlePosition.y -= node.contentSize.height * node.anchorPoint.y;
    pointHandlePosition = [node pc_convertToWorldSpace:pointHandlePosition];
    return pointHandlePosition;
}

+ (SKNode *)nodeWithPhysicsHandleUnderPoint:(CGPoint)position handleIndex:(NSInteger *)handleIndex {
    NSArray *selectedNodes = [[AppDelegate appDelegate] selectedSpriteKitNodes];
    
    for (SKNode *node in selectedNodes) {
        NodePhysicsBody *body = node.nodePhysicsBody;
        
        if (body.bodyShape == PCPhysicsBodyShapePolygon) {
            NSInteger index = 0;
            for (NSValue *pointPositionValue in body.points) {
                CGPoint pointHandlePosition = [PhysicsHandler physicsHandlePositionFromValue:pointPositionValue forNode:node];
                CGFloat distance = pc_CGPointDistance(pointHandlePosition, position);
                if (distance <= kCCBPhysicsHandleRadius) {
                    *handleIndex = index;
                    return node;
                }
                index++;
            }
        } else if (body.bodyShape == PCPhysicsBodyShapeCircle) {
            CGPoint center = [self physicsHandlePositionFromValue:body.points[0] forNode:node];
            if (pc_CGPointDistance(center, position) < kCCBPhysicsHandleRadius) {
                *handleIndex = 0;
                return node;
            }

            CGPoint edge = pc_CGPointAdd(center, CGPointMake(body.radius * [PhysicsHandler radiusScaleFactorForNode:node], 0));
            if (pc_CGPointDistance(edge, position) < kCCBPhysicsHandleRadius) {
                *handleIndex = 1;
                return node;
            }
        }
    }
    
    return nil;
}

- (BOOL)selectNodeWithHandleUnder:(CGPoint)position {
    NSInteger handleIndex;
    SKNode *selectedNode = [PhysicsHandler nodeWithPhysicsHandleUnderPoint:position handleIndex:&handleIndex];
    if (!selectedNode) return NO;

    self.selectedHandleIndex = handleIndex;
    self.mousePositionInHandleSpace = [selectedNode pc_convertToNodeSpace:self.mouseDownPosition];
    self.selectedNode = selectedNode;
    self.selectedNodePhysicsBody = selectedNode.nodePhysicsBody;

    if (self.selectedNodePhysicsBody.bodyShape ==  PCPhysicsBodyShapePolygon) {
        self.handleStartPosition = [[self.selectedNodePhysicsBody.points objectAtIndex:handleIndex] pointValue];
    } else if (self.selectedNodePhysicsBody.bodyShape == PCPhysicsBodyShapeCircle) {
        self.handleStartPosition = (handleIndex == 0 ? [self.selectedNodePhysicsBody.points[0] pointValue] : CGPointMake(self.selectedNodePhysicsBody.radius, 0));
    }
    return YES;
}

- (BOOL) point:(CGPoint)pt onLineFrom:(CGPoint)start to:(CGPoint) end
{
    CGPoint left;
    CGPoint right;
    
    if (start.x <= end.x)
    {
        left = start;
        right = end;
    }
    else
    {
        left = end;
        right = start;
    }
    
    if (pt.x + kCCBPhysicsLineSegmFuzz < left.x || right.x < pt.x - kCCBPhysicsLineSegmFuzz) return NO;
    if (pt.y + kCCBPhysicsLineSegmFuzz < MIN(left.y, right.y) || MAX(left.y, right.y) < pt.y - kCCBPhysicsLineSegmFuzz) return NO;
    
    float dX = right.x - left.x;
    float dY = right.y - left.y;
    
    if (fabsf(dX) < kCCBPhysicsLineSegmFuzz || fabsf(dY) < kCCBPhysicsLineSegmFuzz) return YES;
    
    float slope = dY / dX;
    float offset = left.y - left.x * slope;
    float calcY = pt.x * slope + offset;
    
    return (pt.y - kCCBPhysicsLineSegmFuzz <= calcY && calcY <= pt.y + kCCBPhysicsLineSegmFuzz);
}

+ (SKNode *)nodeWithLineUnder:(CGPoint)position lineIndex:(NSInteger *)lineIndex {
    NSArray *selectedNodes = [[AppDelegate appDelegate] selectedSpriteKitNodes];
    
    for (SKNode *node in selectedNodes) {
        NodePhysicsBody *body = node.nodePhysicsBody;

        if (body.bodyShape != PCPhysicsBodyShapePolygon) continue;

        for (NSInteger index = 0; index < body.points.count; index++) {
            CGPoint pt0 = [PhysicsHandler physicsHandlePositionFromValue:body.points[index] forNode:node];
            CGPoint pt1 = [PhysicsHandler physicsHandlePositionFromValue:body.points[(index + 1) % [body.points count]] forNode:node];

            if (distanceFromLineSegment(pt0, pt1, position) <= kCCBPhysicsLineSegmFuzz) {
                *lineIndex = index;
                return node;
            }
        }
    }
    return nil;
}

- (BOOL)selectNodeWithLineUnder:(CGPoint)position {
    NSInteger lineIndex;
    SKNode *selectedNode = [PhysicsHandler nodeWithLineUnder:position lineIndex:&lineIndex];
    if (!selectedNode) return NO;

    self.selectedNode = selectedNode;
    self.selectedNodePhysicsBody = selectedNode.nodePhysicsBody;
    self.mousePositionInHandleSpace = [selectedNode pc_convertToNodeSpace:self.mouseDownPosition];

    // Add new control point
    CGPoint localPosition = [self.selectedNode pc_convertToNodeSpace:position];
    localPosition.x += self.selectedNode.anchorPoint.x * self.selectedNode.contentSize.width;
    localPosition.y += self.selectedNode.anchorPoint.y * self.selectedNode.contentSize.height;

    NSMutableArray *points = [self.selectedNodePhysicsBody.points mutableCopy];
    [points insertObject:[NSValue valueWithPoint:localPosition] atIndex:lineIndex + 1];
    self.selectedNodePhysicsBody.points = points;

        // Set this point as edited
    self.handleStartPosition = localPosition;
    self.selectedHandleIndex = lineIndex + 1;

    [[AppDelegate appDelegate] saveUndoStateDidChangeProperty:@"*P*points"];

    return YES;
}

- (void) makeConvexHull
{
    NSArray *selectedNodes = [[AppDelegate appDelegate] selectedSpriteKitNodes];
    
    for (SKNode *node in selectedNodes) {
        NSArray* pts = node.nodePhysicsBody.points;
        int numPts = pts.count;
        
        CGPoint *verts = malloc(sizeof(CGPoint) * numPts);
        int idx = 0;
        for (NSValue* ptVal in pts) {
            CGPoint pt = [ptVal pointValue];
            verts[idx].x = pt.x;
            verts[idx].y = pt.y;
            idx++;
        }

        int newNumPts = pc_ConvexHull(numPts, verts, verts, NULL, 0.0f);
        
        NSMutableArray* hull = [NSMutableArray array];
        for (idx = 0; idx < newNumPts; idx++) {
            [hull addObject:[NSValue valueWithPoint:CGPointMake(verts[idx].x, verts[idx].y)]];
        }
        
        node.nodePhysicsBody.points = hull;
    }
    
}

- (CGPoint) snapPoint:(CGPoint)src toPt0:(CGPoint)pt0 andPt1:(CGPoint)pt1
{
    CGPoint snapped = src;
    
    // Snap x value
    float xDist0 = fabs(src.x - pt0.x);
    float xDist1 = fabs(src.x - pt1.x);
    
    if (MIN(xDist0, xDist1) < kCCBPhysicsSnapDist)
    {
        if (xDist0 < xDist1) snapped.x = pt0.x;
        else snapped.x = pt1.x;
    }
    
    // Snap y value
    float yDist0 = fabs(src.y - pt0.y);
    float yDist1 = fabs(src.y - pt1.y);
    
    if (MIN(yDist0, yDist1) < kCCBPhysicsSnapDist)
    {
        if (yDist0 < yDist1) snapped.y = pt0.y;
        else snapped.y = pt1.y;
    }
    
    return snapped;
}

- (void) updatePhysicsEditor:(SKNode*) editorView
{
    return;
}

+ (CGFloat)radiusScaleFactorForNode:(SKNode *)node {
    CGFloat scale = 1;
    for (node = node; node; node = node.parent) {
        scale *= node.xScale;
    }
    return scale;
}

@end
