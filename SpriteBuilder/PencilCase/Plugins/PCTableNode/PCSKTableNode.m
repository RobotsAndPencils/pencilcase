//
//  PCSKTableNode.m
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-07-21.
//
//

#import "PCSKTableNode.h"
#import "SKNode+CocosCompatibility.h"
#import "SKNode+NodeInfo.h"

@interface PCSKTableNode ()

@property (strong, nonatomic) NSColor *backgroundColor;
@property (strong, nonatomic) SKSpriteNode *background;
@property (strong, nonatomic) SKLabelNode *numberOfCellsLabel;

@end

@implementation PCSKTableNode

- (PCEditorResizeBehaviour)editorResizeBehaviour {
    return PCEditorResizeBehaviourContentSize;
}

#pragma mark - CCNode

- (id)init {
    self = [super init];
    if (self) {
        _backgroundColor = [NSColor lightGrayColor];
        _background = [SKSpriteNode node];
        _background.color = _backgroundColor;
        _background.position = CGPointMake(0, 0);
        _numberOfCellsLabel = [[SKLabelNode alloc] init];
        _numberOfCellsLabel.fontColor = [NSColor blackColor];
        [self addChild:_background];
        [self addChild:_numberOfCellsLabel];
        [self updateCellsLabel:0];
    }
    return self;
}

#pragma mark - Private

#pragma mark - Properties

- (void)setSize:(CGSize)size {
    [super setSize:size];
    [self.background setContentSize:[self contentSize]];
    CGFloat fontSize = MIN(self.contentSize.width, self.contentSize.height);
    self.numberOfCellsLabel.fontSize = fontSize / 5;
}

- (void)setBackgroundColor:(NSColor *)backgroundColor {
    _backgroundColor = backgroundColor;
    self.background.color = _backgroundColor;
    self.background.alpha = backgroundColor.alphaComponent;
}

- (NSArray *)cells {
    return [self extraPropForKey:@"cells"] ?: @[];
}

- (void)setCells:(NSArray *)cells {
    [self setExtraProp:cells forKey:@"cells"];
    [self updateCellsLabel:cells.count];
}

- (void)updateCellsLabel:(NSInteger)numberOfCells {
    NSString *cellString = @"cell";
    if (numberOfCells == 1) {
        cellString = @"cell";
    } else {
        cellString = @"cells";
    }
    self.numberOfCellsLabel.text = [NSString stringWithFormat:@"%lu %@", numberOfCells, cellString];
}

@end
