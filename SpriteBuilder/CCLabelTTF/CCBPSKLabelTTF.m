
//
//  CCBPSKLabelTTF.m
//  SpriteBuilder
//
//  Created by Brandon Evans on 2014-07-09.
//
//

#import "CCBPSKLabelTTF.h"
#import "PCResourceManager.h"
#import "SKNode+CocosCompatibility.h"
#import "NodeInfo.h"
#import "NSString+MaxSize.h"

static const NSInteger PCMaxRenderableStringWidth = 2048;

@interface CCBPSKLabelTTF()

@property (strong, nonatomic) NSArray *internalLabels;
@property (assign, nonatomic) BOOL loaded;

@end

@implementation CCBPSKLabelTTF

#pragma mark Properties

- (instancetype)init {
    self = [super init];
    if (self) {
        _internalLabels = [NSMutableArray array];
        self.color = [NSColor clearColor];
    }
    return self;
}

#pragma mark - Properties

- (void)pc_didEnterScene {
    self.loaded = YES;
    [self reloadChildLabels];
}

- (void)setHorizontalAlignment:(CCTextAlignment)alignment {
    _horizontalAlignment = alignment;
    self.anchorPoint = [self anchorPointFromAlignment];
}

- (void)setVerticalAlignment:(CCVerticalTextAlignment)alignment {
    _verticalAlignment = alignment;
    self.anchorPoint = [self anchorPointFromAlignment];
}

- (void)setString:(NSString *)string {
    if ([_string isEqualToString:string]) return;

    _string = [string copy];
    [self reloadChildLabels];
}

- (void)setFontName:(NSString *)fontName {
    if ([[PCResourceManager sharedManager] isFontAvailable:fontName] == NO) {
        fontName = @"Helvetica";
    }
    if ([_fontName isEqualToString:fontName]) return;

    _fontName = fontName;
    [self reloadChildLabels];
}

- (void)setFontSize:(CGFloat)fontSize {
    if (_fontSize == fontSize) return;

    _fontSize = fontSize;
    [self reloadChildLabels];
}

- (void)setFontColor:(NSColor *)fontColor {
    if ([_fontColor isEqualTo:fontColor]) return;

    _fontColor = fontColor;
    [self.internalLabels makeObjectsPerformSelector:@selector(setFontColor:) withObject:fontColor];
}

#pragma mark - Size

- (CGRect)frame {
    CGPoint bottomLeft = CGPointMake(self.contentSize.width * (1 - self.anchorPoint.x),
                                     self.contentSize.height * (1 - self.anchorPoint.y));
    return (CGRect){ bottomLeft, self.contentSize };
}

#pragma mark - PCFontConsuming

- (NSDictionary *)fontNamesAndSizes {
    return @{self.fontName:@[@(self.fontSize)]};
}

#pragma mark - Private

- (void)reloadChildLabels {
    if (!self.loaded) return;

    [self.internalLabels makeObjectsPerformSelector:@selector(removeFromParent)];
    NSFont *font = [NSFont fontWithName:self.fontName size:self.fontSize];
    if (!font) return;

    NSDictionary *textAttributes = @{ NSFontAttributeName : font };
    CGSize textSize = [self.string sizeWithAttributes:textAttributes];
    self.contentSize = CGSizeMake(ceil(textSize.width), ceil(textSize.height));

    NSArray *stringChunks = [self.string pc_splitIntoChunksWithMaxWidth:PCMaxRenderableStringWidth attributes:textAttributes];
    CGFloat left = -self.contentSize.width * self.anchorPoint.x;
    CGFloat bottom = -self.contentSize.height * self.anchorPoint.y;
    NSMutableArray *tempLabels = [NSMutableArray array];
    for (NSString *string in stringChunks) {
        SKLabelNode *labelNode = [[SKLabelNode alloc] initWithFontNamed:self.fontName];
        labelNode.fontSize = self.fontSize;
        labelNode.verticalAlignmentMode = SKLabelVerticalAlignmentModeBottom;
        labelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        labelNode.userObject = [[NodeInfo alloc] init];

        labelNode.text = string;
        labelNode.position = CGPointMake(left, bottom);
        labelNode.fontColor = self.fontColor;
        left += [string sizeWithAttributes:textAttributes].width;
        [self addChild:labelNode];
        [tempLabels addObject:labelNode];
    }
    self.internalLabels = [tempLabels copy];
}

- (CGPoint)anchorPointFromAlignment {
    CGPoint anchorPoint = CGPointZero;
    switch (self.horizontalAlignment) {
        case CCTextAlignmentCenter:
            anchorPoint.x = 0.5;
            break;
        case CCTextAlignmentRight:
            anchorPoint.x = 1.0;
            break;
        case CCTextAlignmentLeft:
        default:
            break;
    }
    switch (self.verticalAlignment) {
        case CCVerticalTextAlignmentCenter:
            anchorPoint.y = 0.5;
            break;
        case CCVerticalTextAlignmentTop:
            anchorPoint.y = 1.0;
            break;
        case CCVerticalTextAlignmentBottom:
        default:
            break;
    }
    return anchorPoint;
}

@end
