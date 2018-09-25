//
//  PCSKMultiViewCellNode.m
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-07-09.
//
//

#import "PCSKMultiViewCellNode.h"
#import "SKNode+CocosCompatibility.h"
#import "SKNode+NodeInfo.h"
#import "AppDelegate.h"
#import "CCBReaderInternal.h"
#import "NodeInfo.h"
#import "SKNode+LifeCycle.h"
#import "SKNode+CoordinateConversion.h"
#import "CGPointUtilities.h"
#import "SKCropNode+Nesting.h"
#import "SKNode+CropNodeNesting.h"
#import "PCMathUtilities.h"

@interface PCSKMultiViewCellNode ()<PCNestedCropNodeContainer>

@property (strong, nonatomic) SKCropNode *cropNode;
@property (strong, nonatomic) SKSpriteNode *maskNode;

@end

@implementation PCSKMultiViewCellNode

- (instancetype)init {
    self = [super init];
    if (self) {
        self.cropNode = [SKCropNode node];
        self.cropNode.userObject = [NodeInfo nodeInfoWithPlugIn:nil];
        self.cropNode.hideFromUI = YES;
        
        self.cropNode.position = CGPointZero;
        self.cropNode.anchorPoint = CGPointZero;
        [self addChild:self.cropNode];
    }
    return self;
}

- (void)pc_didMoveToParent {
    [super pc_didMoveToParent];
    [self updateCropNode];
}

- (void)pc_didEnterScene {
    [super pc_didEnterScene];
    [self updateCropNode];
}

- (void)updateCropNode {
    SKSpriteNode *maskNode = [SKSpriteNode node];
    maskNode.color = [NSColor blueColor];
    maskNode.contentSize = self.contentSize;
    maskNode.position = CGPointZero;
    maskNode.anchorPoint = CGPointZero;
    self.cropNode.maskNode = [self.cropNode constrainMaskToParentCropNodes:maskNode inScene:self.cropNode.scene];
    [self alertChildrenToUpdateCropNode];
}

- (void)pc_firstTimeSetup {
    self.position = CGPointZero;
    self.size = self.parent.contentSize;
    [self addDefaultContent];
}

- (void)addDefaultContent {
    NSArray *multiviewImageFrames = @[@"Graphics/Bowling Ball.png", @"Graphics/Bowling Pin.png", @"Graphics/Gold Coin.png"];

    NSInteger cellIndex = [[self.parent children] indexOfObject:self];
    SKSpriteNode *sprite = (SKSpriteNode *)[[AppDelegate appDelegate] addSpriteKitPlugInNodeNamed:@"PCSprite" asChild:YES toParent:self atIndex:0 followInsertionNode:YES];

    NSString *resourcesImagePath = [@"resources" stringByAppendingPathComponent:multiviewImageFrames[cellIndex % [multiviewImageFrames count]]];
    [CCBReaderInternal setProp:@"spriteFrame" ofType:@"SpriteFrame" toValue:resourcesImagePath forSpriteKitNode:sprite parentSize:CGSizeZero];

    sprite.position = CGPointMake(CGRectGetWidth(self.frame) * 0.5, CGRectGetHeight(self.frame) * 0.5);
}

- (void)setSize:(CGSize)size {
    [super setSize:size];
    if (!self.maskNode.texture) {
        self.maskNode.size = self.size;
        self.maskNode.position = CGPointZero;
    } else {
        [self updateCropNode];
    }
    self.cropNode.position = CGPointZero;
}

#pragma mark - PCNodeChildInsertion

- (SKNode *)insertionNode {
    return self.cropNode;
}

#pragma mark - PCNodeChildExport

- (NSArray *)exportChildren {
    return self.cropNode.children;
}

@end
