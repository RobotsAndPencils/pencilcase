//
//  PCRulersLayer.m
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2014-08-06.
//
//

#import "PCRulersNode.h"
#import "AppDelegate.h"
#import "PCStageScene.h"
#import "SKNode+CocosCompatibility.h"
#import "CGPointUtilities.h"

static const CGFloat PCRulerWidth = 15;

@interface PCRulersNode()

@property (weak, nonatomic) SKSpriteNode *bgHorizontal;
@property (weak, nonatomic) SKSpriteNode *bgVertical;

@property (weak, nonatomic) SKNode *marksVertical;
@property (weak, nonatomic) SKNode *marksHorizontal;

@property (weak, nonatomic) SKSpriteNode *mouseMarkHorizontal;
@property (weak, nonatomic) SKSpriteNode *mouseMarkVertical;

@property (weak, nonatomic) SKLabelNode *xLabel;
@property (weak, nonatomic) SKLabelNode *yLabel;

@property (assign, nonatomic) CGSize winSize;
@property (assign, nonatomic) CGPoint stageOrigin;
@property (assign, nonatomic) CGFloat zoom;

@end

@implementation PCRulersNode

- (id)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    [self setup];
    return self;
}

- (void) setup {
    [self removeAllChildren];
    
    NSColor *rulerBackgroundColour = [NSColor colorWithRed:231 / 255.0f green:231 / 255.0f blue:231 / 255.0f alpha:1];
    SKSpriteNode *bgVertical = [SKSpriteNode spriteNodeWithColor:rulerBackgroundColour size:CGSizeZero];
    bgVertical.anchorPoint = CGPointZero;
    self.bgVertical = bgVertical;
    
    SKSpriteNode *bgHorizontal = [SKSpriteNode spriteNodeWithColor:rulerBackgroundColour size:CGSizeZero];
    bgHorizontal.anchorPoint = CGPointZero;
    self.bgHorizontal = bgHorizontal;
    
    SKNode *marksVertical = [SKNode node];
    self.marksVertical = marksVertical;
    
    SKNode *marksHorizontal = [SKNode node];
    self.marksHorizontal = marksHorizontal;
    
    [self addChild:self.bgVertical];
    [self addChild:self.marksVertical];
    
    [self addChild:self.bgHorizontal];
    [self addChild:self.marksHorizontal];
    
    
    SKSpriteNode *mouseMarkVertical = [SKSpriteNode spriteNodeWithImageNamed:@"ruler-guide.png"];
    mouseMarkVertical.anchorPoint = CGPointZero;
    mouseMarkVertical.hidden = YES;
    self.mouseMarkVertical = mouseMarkVertical;
    [self addChild:self.mouseMarkVertical];
    
    SKSpriteNode *mouseMarkHorizontal = [SKSpriteNode spriteNodeWithImageNamed:@"ruler-guide.png"];
    mouseMarkHorizontal.zRotation = M_PI_2;
    mouseMarkHorizontal.anchorPoint = CGPointMake(0, 0.5f);
    mouseMarkHorizontal.hidden = YES;
    self.mouseMarkHorizontal = mouseMarkHorizontal;
    [self addChild:self.mouseMarkHorizontal];
    
    SKSpriteNode* xyBg = [SKSpriteNode spriteNodeWithImageNamed:@"ruler-xy.png"];
    [self addChild:xyBg];
    xyBg.anchorPoint = CGPointZero;
    xyBg.position = CGPointZero;
    xyBg.zPosition = 1;
    
    SKLabelNode *xLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
    xLabel.fontSize = 10;
    xLabel.text = @"0";
    xLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeRight;
    xLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeBaseline;
    xLabel.position = CGPointMake(47, 3);
    xLabel.fontColor = [NSColor blackColor];
    xLabel.zPosition = 2;
    xLabel.hidden = YES;
    self.xLabel = xLabel;
    [self addChild:self.xLabel];
    
    
    SKLabelNode *yLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
    yLabel.fontSize = 10;
    yLabel.text = @"0";
    yLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeRight;
    yLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeBaseline;
    yLabel.position = CGPointMake(97, 3);
    yLabel.fontColor = [NSColor blackColor];
    yLabel.zPosition = 2;
    yLabel.hidden = YES;
    self.yLabel = yLabel;
    [self addChild:self.yLabel];
    
    self.winSize = CGSizeZero;
    [[PCStageScene scene] forceRedraw];
}

- (void)updateWithSize:(CGSize)winSize stageOrigin:(CGPoint)stageOrigin zoom:(CGFloat)zoom {
    stageOrigin.x = (NSInteger)stageOrigin.x;
    stageOrigin.y = (NSInteger)stageOrigin.y;
    
    if (CGSizeEqualToSize(winSize, self.winSize) && CGPointEqualToPoint(stageOrigin, self.stageOrigin) && zoom == self.zoom) {
        return;
    }
    
    self.winSize = winSize;
    self.stageOrigin = stageOrigin;
    self.zoom = zoom;
    
    [self resizeBackgronds];
    [self addVerticalMarks];
    [self addHorizontalMarks];
}

- (void)resizeBackgronds {
    // Resize backrounds
    self.bgHorizontal.contentSize = CGSizeMake(self.winSize.width, PCRulerWidth);
    self.bgVertical.contentSize = CGSizeMake(PCRulerWidth, self.winSize.height);
}

- (void)addVerticalMarks {
    [self.marksVertical removeAllChildren];
    
    NSInteger y = (NSInteger)self.stageOrigin.y - (((NSInteger)self.stageOrigin.y) / 10) * 10;
    while (y < self.winSize.height) {
        NSInteger yDistance = labs(y - (NSInteger)self.stageOrigin.y);
        
        SKSpriteNode* mark = NULL;
        BOOL addLabel = NO;
        if (yDistance == 0) {
            mark = [SKSpriteNode spriteNodeWithImageNamed:@"ruler-mark-origin.png"];
            addLabel = YES;
        } else if (yDistance % 50 == 0) {
            mark = [SKSpriteNode spriteNodeWithImageNamed:@"ruler-mark-major.png"];
            addLabel = YES;
        } else {
            mark = [SKSpriteNode spriteNodeWithImageNamed:@"ruler-mark-minor.png"];
        }
        mark.anchorPoint = CGPointMake(0, 0.5f);
        mark.position = CGPointMake(0, y);
        [self.marksVertical addChild:mark];
        
        if (addLabel) {
            NSInteger displayDist = yDistance / self.zoom;
            NSString* str = [NSString stringWithFormat:@"%ld",displayDist];
            NSInteger strLen = [str length];
            
            for (NSInteger i = 0; i < strLen; i++) {
                SKLabelNode *labelNode = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
                labelNode.fontSize = 10;
                labelNode.text = [str substringWithRange:NSMakeRange(i, 1)];
                labelNode.verticalAlignmentMode = SKLabelVerticalAlignmentModeBottom;
                labelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
                labelNode.position = CGPointMake(2, y + 1 + 11 * (strLen - i - 1));
                labelNode.zPosition = 1;
                labelNode.fontColor = [NSColor blackColor];
                [self.marksVertical addChild:labelNode];
            }
        }
        y += 10;
    }
}

- (void)addHorizontalMarks {
    [self.marksHorizontal removeAllChildren];
    // Horizontal marks
    NSInteger x = (NSInteger)self.stageOrigin.x - (((NSInteger)self.stageOrigin.x) / 10) * 10;
    while (x < self.winSize.width) {
        NSInteger xDistance = labs(x - (NSInteger)self.stageOrigin.x);
        
        SKSpriteNode *mark = NULL;
        BOOL addLabel = NO;
        if (xDistance == 0) {
            mark = [SKSpriteNode spriteNodeWithImageNamed:@"ruler-mark-origin.png"];
            addLabel = YES;
        } else if (xDistance % 50 == 0) {
            mark = [SKSpriteNode spriteNodeWithImageNamed:@"ruler-mark-major.png"];
            addLabel = YES;
        } else {
            mark = [SKSpriteNode spriteNodeWithImageNamed:@"ruler-mark-minor.png"];
        }
        mark.anchorPoint = CGPointMake(0.5, 0);
        mark.position = CGPointMake(x, PCRulerWidth / 2);
        mark.zRotation = M_PI_2;
        [self.marksHorizontal addChild:mark];
        
        if (addLabel) {
            int displayDist = xDistance / self.zoom;
            SKLabelNode *labelNode = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
            labelNode.fontSize = 10;
            labelNode.text = [NSString stringWithFormat:@"%d",displayDist];
            labelNode.verticalAlignmentMode = SKLabelVerticalAlignmentModeBottom;
            labelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
            labelNode.position = CGPointMake((x + 1), 1);
            labelNode.fontColor = [NSColor blackColor];
            labelNode.zPosition = 1;
            [self.marksHorizontal addChild:labelNode];
        }
        x += 10;
    }
}

- (void)updateMousePos:(CGPoint)pos {
    CGPoint worldPos = pc_CGPointAdd(pos, self.stageOrigin);
    self.mouseMarkHorizontal.position = CGPointMake(worldPos.x, 0);
    self.mouseMarkVertical.position = CGPointMake(0, worldPos.y);
    
    PCStageScene *stageScene = [PCStageScene scene];
    CGPoint docPos = [stageScene convertToDocSpace:pos];
    docPos = pc_CGPointMultiply(docPos, [AppDelegate appDelegate].contentScaleFactor);
    self.xLabel.text = [NSString stringWithFormat:@"%ld", (NSInteger)docPos.x];
    self.yLabel.text = [NSString stringWithFormat:@"%ld", (NSInteger)docPos.y];
}

- (void)mouseEntered:(NSEvent *)event {
    self.mouseMarkHorizontal.hidden = NO;
    self.mouseMarkVertical.hidden = NO;
    self.xLabel.hidden = NO;
    self.yLabel.hidden = NO;
}

- (void)mouseExited:(NSEvent *)event {
    self.mouseMarkHorizontal.hidden = YES;
    self.mouseMarkVertical.hidden = YES;
    self.xLabel.hidden = YES;
    self.yLabel.hidden = YES;
}


@end
