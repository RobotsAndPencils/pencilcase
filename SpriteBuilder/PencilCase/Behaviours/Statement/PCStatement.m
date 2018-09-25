//
//  PCExpressionString.m
//  Behaviours
//
//  Created by Cody Rayment on 2014-11-17.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import <AppKit/AppKit.h>
#import <GRMustache/GRMustacheTemplate.h>
#import <objc/runtime.h>

#import "PCStatement.h"
#import "PCExpressionInfo.h"
#import "PCExpression.h"
#import "PCBehavioursDataSource.h"

#import "PCToken.h"
#import "PCTokenValueDescriptor.h"
#import "PCTokenNodeDescriptor.h"

#import "PCStringExpressionInspector.h"
#import "PCPopUpExpressionInspector.h"
#import "PCPointExpressionInspector.h"
#import "PCNumberExpressionInspector.h"
#import "PCColorExpressionInspector.h"
#import "PCImageExpressionInspector.h"
#import "PCBOOLExpressionInspector.h"
#import "PCKeyboardInputExpressionInspector.h"
#import "NSAttributedString+MutationHelpers.h"

#import "PCResourceManager.h"
#import "PCStatement+Subclass.h"
#import "NSString+CamelCase.h"
#import "BehavioursStyleKit.h"

@interface PCStatement ()

@property (strong, nonatomic) NSMutableArray *chunks;
@property (strong, nonatomic) NSAttributedString *attributedString;
@property (strong, nonatomic) NSDictionary *defaultAttributes;
@property (strong, nonatomic) NSMutableArray *expressionInfos;
@property (copy, nonatomic, readwrite) NSUUID *UUID;
@property (strong, nonatomic) NSMutableArray *mutableExposedTokens;
@property (strong, nonatomic) NSMutableArray *mutableExposedTokenNames;

@end

@implementation PCStatement

- (instancetype)init {
    self = [super init];
    if (self) {
        self.UUID = [NSUUID UUID];
        self.chunks = [NSMutableArray array];
        self.expressionInfos = [NSMutableArray array];
        self.mutableExposedTokens = [NSMutableArray array];
        self.mutableExposedTokenNames = [NSMutableArray array];

        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSLeftTextAlignment;
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        self.defaultAttributes = @{
                                   NSParagraphStyleAttributeName: paragraphStyle,
                                   NSFontAttributeName: [NSFont systemFontOfSize:14]
                                   };
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    __weak typeof(self) weakSelf = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:PCExposedTokenReplacedNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        [weakSelf validateExpressions];
    }];
}

- (BOOL)validateExpressions {
    BOOL isValid = YES;
    for (PCExpressionInfo *expressionInfo in self.expressionInfos) {
        PCExpression *expression = expressionInfo.expression;

        PCToken *token = expression.token;
        if (expression.isSimpleExpression) {
            isValid &= (token != nil);
            if (!isValid) {
                PCLog(@"Behaviour validation failed because expression token was nil: %@", expression);
            }

            if (token.isReferenceType) {
                BOOL tokenIsValid = [self isToken:token validForExpression:expression];
                isValid &= tokenIsValid;
                if (!isValid) {
                    PCLog(@"Behaviour validation failed because token wasn't valid for expression: %@, %@", token, expression);
                }
                token.isInvalidReference = !tokenIsValid;
                [self invalidateAttributedString];
            }
        } else {
            for (id chunk in expression.advancedChunks) {
                if ([chunk isKindOfClass:[PCToken class]]) {
                    PCToken *chunkToken = chunk;

                    BOOL tokenIsValid = [self isToken:chunkToken validForExpression:expression];
                    isValid &= tokenIsValid;
                    if (!tokenIsValid) {
                        PCLog(@"Behaviour validation failed because chunk token wasn't valid for expression: %@, %@", chunkToken, expression);
                    }
                    chunkToken.isInvalidReference = !tokenIsValid;
                    [self invalidateAttributedString];
                }
            }
        }
    }
    return isValid;
}

- (void)setExpressionInfos:(NSMutableArray *)expressionInfos {
    _expressionInfos = expressionInfos;
    for (PCExpressionInfo *info in expressionInfos) {
        info.expression.statement = self;
    }
}

#pragma mark - MTLModel

+ (NSSet *)excludedPropertyKeys {
    return [NSSet setWithArray:@[ @"delegate" ]];
}

+ (NSSet *)propertyKeys {
    NSMutableSet *keys = [[super propertyKeys] mutableCopy];
    for (id key in [self excludedPropertyKeys]) {
        [keys removeObject:key];
    }
    return [keys copy];
}

#pragma mark - Public

- (instancetype)appendString:(NSString *)string {
    [self.chunks addObject:string];
    [self invalidateAttributedString];
    return self;
}

- (instancetype)appendEmptyExpression {
    return [self appendEmptyExpressionWithOrder:0];
}

- (instancetype)appendEmptyExpressionWithOrder:(NSInteger)order {
    PCExpression *expression = [[PCExpression alloc] init];
    return [self appendExpression:expression withOrder:0];
}

- (instancetype)appendExpression:(PCExpression *)expression {
    return [self appendExpression:expression withOrder:0];
}

- (instancetype)appendExpression:(PCExpression *)expression withOrder:(NSInteger)order {
    [self.chunks addObject:expression];

    expression.statement = self;

    PCExpressionInfo *info = [[PCExpressionInfo alloc] init];
    info.expression = expression;
    info.order = order;
    [self.expressionInfos addObject:info];

    [self invalidateAttributedString];

    return self;
}

- (NSAttributedString *)attributedString {
    if (_attributedString) return _attributedString;

    NSMutableAttributedString *statementAttributedString = [[NSMutableAttributedString alloc] init];
    NSInteger index = 0;
    for (id chunk in self.chunks) {
        if ([chunk isKindOfClass:[NSString class]]) {
            NSString *string = (NSString *)chunk;
            NSAttributedString *chunkAttributedString = [[NSAttributedString alloc] initWithString:string attributes:self.defaultAttributes];
            [statementAttributedString appendAttributedString:chunkAttributedString];
        }
        else if ([chunk isKindOfClass:[PCExpression class]]) {
            PCExpression *expression = (PCExpression *)chunk;
            PCExpressionInfo *info = [self infoForExpression:expression];
            NSAttributedString *chunkAttributedString = [self attributedStringForExpressionInfo:info];
            [statementAttributedString appendAttributedString:chunkAttributedString];
            info.range = NSMakeRange(index, [chunkAttributedString length]);
        }
        index = [statementAttributedString length];
    }
    _attributedString = [statementAttributedString copy];
    return _attributedString;
}

- (void)invalidateAttributedString {
    self.attributedString = nil;
    [self.delegate statementNeedsDisplay:self];
}

- (NSRange)rangeOfLink:(NSString *)link {
    PCExpressionInfo *info = [self expressionInfoForLink:link];
    return info.range;
}

- (PCExpression *)expressionForLink:(NSString *)link {
    PCExpressionInfo *info = [self expressionInfoForLink:link];
    return info.expression;
}

- (BOOL)matchesSearch:(NSString *)search {
    NSMutableArray *orPredicates = [NSMutableArray array];
    [orPredicates addObject:[NSPredicate predicateWithFormat:@"attributedString.string CONTAINS[cd] %@", search]];
    [orPredicates addObject:[NSPredicate predicateWithFormat:@"ANY attributedString.attachments.attachmentCell.stringValue CONTAINS[cd] %@", search]];
    NSCompoundPredicate *predicate = [NSCompoundPredicate orPredicateWithSubpredicates:orPredicates];
    return [predicate evaluateWithObject:self];
}

- (BOOL)evaluatesAsync {
    return NO;
}

- (BOOL)canRunWithPrevious {
    return YES;
}

- (BOOL)canRunWithNext {
    return YES;
}

- (NSString *)javaScriptValidationTemplate {
    return @"expression = %@";
}

- (void)regenerateUUID {
    NSUUID *oldUUID = self.UUID;
    self.UUID = [NSUUID UUID];
    NSDictionary *mapping = @{ oldUUID : self };
    for (PCToken *token in self.mutableExposedTokens) {
        if ([token.descriptor respondsToSelector:@selector(updateSourceUUIDWithMapping:)]) {
            [token.descriptor updateSourceUUIDWithMapping:mapping];
        }
    }
}

- (void)updateReferencesToNodeUUID:(NSUUID *)oldUUID toNewUUID:(NSUUID *)newUUID {
    for (PCExpressionInfo *expressionInfo in self.expressionInfos) {
        PCExpression *expression = expressionInfo.expression;
        [expression updateReferencesToNodeUUID:oldUUID toNewUUID:newUUID];
    }
}

- (void)updateSourceUUIDsWithMapping:(NSDictionary *)mapping {
    for (PCExpressionInfo *info in self.expressionInfos) {
        [info.expression updateSourceUUIDsWithMapping:mapping];
    }
    [self invalidateAttributedString];
}

+ (NSUUID *)newUUIDFrom:(NSUUID *)uuid mapping:(NSDictionary *)mapping {
    if (!uuid || !mapping[uuid]) return uuid;
    PCStatement *statement = mapping[uuid];
    return statement.UUID;
}

- (BOOL)validateEvaluatedExpressionType {
    return YES;
}

#pragma mark - Private

- (NSString *)linkForExpressionInfo:(PCExpressionInfo *)info {
    return [NSString stringWithFormat:@"pc-token://token/%@", info.UUID.UUIDString];
}

- (PCExpressionInfo *)expressionInfoForLink:(NSString *)link {
    NSString *uuidString = [[NSURL URLWithString:link] lastPathComponent];
    for (PCExpressionInfo *info in self.expressionInfos) {
        if ([info.UUID.UUIDString isEqualToString:uuidString]) {
            return info;
        }
    }
    return nil;
}

- (NSAttributedString *)attributedStringForExpressionInfo:(PCExpressionInfo *)expressionInfo {
    NSString *link = [self linkForExpressionInfo:expressionInfo];
    PCExpression *expression = expressionInfo.expression;

    BOOL enableExpression = [self expressionInfoShouldBeEnabled:expressionInfo];

    NSDictionary *blankAttributes = @{
                                      NSForegroundColorAttributeName: (enableExpression ? [BehavioursStyleKit normalBlueColor] : [NSColor grayColor]),
                                      };
    NSAttributedString *tokenString = [[NSAttributedString alloc] initWithString:@"______" attributes:blankAttributes];

    if ([expression hasValue]) {
        tokenString = expression.isSimpleExpression ? [expression simpleAttributedStringValueWithDefaultAttributes:self.defaultAttributes] : [expression advancedAttributedStringValueWithDefaultAttributes:self.defaultAttributes highlightInvalid:YES];
    }

    NSMutableAttributedString *expressionAttributedString = [tokenString mutableCopy];

    NSMutableDictionary *attributes = [[self defaultAttributes] mutableCopy];
    if (!enableExpression) {
        [attributes addEntriesFromDictionary:@{
                                               NSCursorAttributeName: [NSCursor operationNotAllowedCursor],
                                               NSFontAttributeName: [NSFont fontWithName:@"Menlo" size:12],
                                               NSToolTipAttributeName: @"Mising Requirements",
                                               }];
    }
    else {
        [attributes addEntriesFromDictionary:@{
                                               NSLinkAttributeName: link,
                                               NSCursorAttributeName: [NSCursor pointingHandCursor],
                                               NSToolTipAttributeName: @"Click to enter a value",
                                               NSFontAttributeName: [NSFont fontWithName:@"Menlo" size:12],
                                               }];
    }

    NSRange range = NSMakeRange(0, [expressionAttributedString length]);
    [expressionAttributedString addAttributes:attributes range:range];

    return [expressionAttributedString pc_stringByRemovingLeadingAndTrailingWhitespace];
}

- (BOOL)expressionInfoShouldBeEnabled:(PCExpressionInfo *)info {
    if (info.order == 0) return YES;
    BOOL allParentsFilled = YES;
    for (PCExpressionInfo *parentInfo in [self expressionInfosWithOrder:info.order - 1]) {
        if (![parentInfo.expression hasValue]) allParentsFilled = NO;
        break;
    }
    return allParentsFilled;
}

- (NSArray *)expressionInfosWithOrder:(NSInteger)order {
    return [self.expressionInfos filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(PCExpressionInfo *info, NSDictionary *bindings) {
        return info.order == order;
    }]];
}

- (PCExpressionInfo *)infoForExpression:(PCExpression *)expression {
    for (PCExpressionInfo *info in self.expressionInfos) {
        if (info.expression == expression) {
            return info;
        }
    }
    return nil;
}

- (NSViewController<PCExpressionInspector> *)inspectorForExpression:(PCExpression *)expression {
    NSAssert(NO, @"Subclass should implement and not call super");
    return nil;
}

- (BOOL)allowAdvancedEntryForExpression:(PCExpression *)expression {
    return NO;
}

- (void)updateExpression:(PCExpression *)expression withValue:(PCToken *)value {
    if ([expression.token isEqual:value]) return;
    if (value == nil && expression.token == nil) return;

    NSUndoManager *undoManager = [[[NSApplication sharedApplication] mainWindow] undoManager];
    [[undoManager prepareWithInvocationTarget:self] updateExpression:expression withValue:expression.token];

    [self clearValuesForChangingExpression:expression toToken:value];

    expression.token = value;

    [self validateExpressions];
    [self invalidateAttributedString];
}

- (void)updateExpression:(PCExpression *)expression withAdvancedChunks:(NSArray *)chunks isSimpleMode:(BOOL)simpleMode {
    if ([chunks isEqual:expression.advancedChunks] && simpleMode == expression.isSimpleExpression) return;

    NSUndoManager *undoManager = [[[NSApplication sharedApplication] mainWindow] undoManager];
    [[undoManager prepareWithInvocationTarget:self] updateExpression:expression withAdvancedChunks:expression.advancedChunks isSimpleMode:expression.isSimpleExpression];

    [self clearValuesForChangingExpression:expression advancedChunks:chunks simpleMode:simpleMode];

    expression.advancedChunks = chunks;
    expression.isSimpleExpression = simpleMode;

    [self validateExpressions];
    [self invalidateAttributedString];
}

- (NSArray *)availableTokensForExpression:(PCExpression *)expression {
    NSArray *availableTokens = [self.delegate statementAvailableTokens:self];
    return [PCToken filterTokens:availableTokens evaluationTypes:expression.suggestedTokenTypes];
}

- (BOOL)isToken:(PCToken *)token validForExpression:(PCExpression *)expression {
    NSArray *tokens = [self availableTokensForExpression:expression];
    BOOL isValid = [PCToken tokens:tokens containsTokenReferenceEqual:token];
    return isValid;
}

- (NSString *)uniqueTokenNameForName:(NSString *)name {
    NSArray *tokens = [self.delegate statementAvailableTokens:self];
    NSInteger number = 1;
    NSString *proposedName = name;
    while ([self tokenWithDisplayName:proposedName inList:tokens]) {
        number += 1;
        NSString *suffix = [NSString stringWithFormat:@"%li", (long)number];
        proposedName = [name stringByAppendingString:suffix];
    }
    return proposedName;
}

- (PCToken *)tokenWithDisplayName:(NSString *)name inList:(NSArray *)tokens {
    for (PCToken *token in tokens) {
        if ([token.displayName isEqual:name]) return token;
    }
    return nil;
}

- (void)clearValuesForChangingExpression:(PCExpression *)expression toToken:(PCToken *)token {
    PCExpressionInfo *changedInfo = [self infoForExpression:expression];
    [self clearValuesForExpressionsWithOrderLaterThan:changedInfo];
}

- (void)clearValuesForChangingExpression:(PCExpression *)expression advancedChunks:(NSArray *)chunks simpleMode:(BOOL)simpleMode {
    PCExpressionInfo *changedInfo = [self infoForExpression:expression];
    [self clearValuesForExpressionsWithOrderLaterThan:changedInfo];
}

- (void)clearValuesForExpressionsWithOrderLaterThan:(PCExpressionInfo *)changedInfo {
    NSUndoManager *undoManager = [[[NSApplication sharedApplication] mainWindow] undoManager];
    if ([undoManager isUndoing] || [undoManager isRedoing]) return;

    for (PCExpressionInfo *info in self.expressionInfos) {
        if (info.order > changedInfo.order) {
            [self updateExpression:info.expression withValue:nil];
            [self updateExpression:info.expression withAdvancedChunks:@[] isSimpleMode:info.expression.isSimpleExpression];
        }
    }
}

#pragma mark Exposed Tokens

- (NSArray *)exposedTokens {
    return [self.mutableExposedTokens copy];
}

- (void)exposeToken:(PCToken *)token {
    [self exposeToken:token key:[token.displayName pc_lowerCamelCaseString]];
}

- (void)exposeToken:(PCToken *)token key:(id<NSCopying>)key {
    // A non-empty key is required
    if (PCIsEmpty(key)) return;

    // This needs to track a "set" of exposed tokens that are ordered (so they're deterministically exposed to JS context) and with a key for uniqueness
    PCToken *existingToken = [self.mutableExposedTokenNames containsObject:key] ? token : nil;

    // A nil token indicates to remove the existing token for the given key
    if (!token) {
        [self.mutableExposedTokens removeObject:token];
        [self.mutableExposedTokenNames removeObject:key];
    }
    // Replace the existing token with the new, non-nil one
    else if (existingToken) {
        NSUInteger existingIndex = [self.mutableExposedTokenNames indexOfObject:key];
        self.mutableExposedTokens[existingIndex] = token;
    }
    // Add the token for a new key
    else {
        [self.mutableExposedTokens addObject:token];
        [self.mutableExposedTokenNames addObject:key];
    }

    if (existingToken) {
        [[NSNotificationCenter defaultCenter] postNotificationName:PCExposedTokenReplacedNotification object:existingToken userInfo:@{ }];
    }

    NSUndoManager *undoManager = [[[NSApplication sharedApplication] mainWindow] undoManager];
    // exposeToken: undo doesn't stand on it's own - requires being triggered by an undoable action.
    if (undoManager.groupingLevel > 0) {
        [[undoManager prepareWithInvocationTarget:self] exposeToken:existingToken key:key];
    }
}

#pragma mark Inspector Factories

- (NSViewController<PCExpressionInspector> *)createPopupInspectorForExpression:(PCExpression *)expression withItems:(NSArray *)items onSave:(dispatch_block_t)saveHandler {
    PCPopUpExpressionInspector *inspector = [[PCPopUpExpressionInspector alloc] init];
    inspector.items = items;

    PCToken *token = (id)expression.token;
    NSUInteger selectedIndex = [items indexOfObjectPassingTest:^BOOL(PCToken *each, NSUInteger idx, BOOL *stop) {
        return [each isEqualReferenceToToken:token];
    }];
    if (selectedIndex < items.count) {
        inspector.selectedItem = items[selectedIndex];
    }

    [inspector setDisplayStringForItemHandler:^NSAttributedString *(PCToken *token) {
        return token.attributedString;
    }];

    __weak typeof(inspector) weakInspector = inspector;
    __weak typeof(self) weakSelf = self;
    [inspector setSaveHandler:^() {
        PCToken *token = weakInspector.selectedItem;
        [weakSelf updateExpression:expression withValue:token];
        if (saveHandler) saveHandler();
    }];

    [inspector setHighlightItemHandler:^(PCToken *token, BOOL highlight) {
        if ([token wantsHover]) {
            [token setHovered:highlight];
        }
    }];
    return inspector;
}

- (NSViewController <PCExpressionInspector> *)createValueInspectorForPropertyType:(PCPropertyType)propertyType expression:(PCExpression *)expression name:(NSString *)name {
    switch (propertyType) {
        case PCPropertyTypeString: {
            return [self createStringInspectorForExpression:expression];
        }
        case PCPropertyTypeJavaScript: {
            return [self createJavaScriptInspectorForExpression:expression];
        }
        case PCPropertyTypePoint: {
            if ([name isEqualToString:PCPropertyNameGravity]) return [self createGravityInspectorForExpression:expression];
            return [self createPointInspectorForExpression:expression];
        }
        case PCPropertyTypeVector: {
            return [self createVectorInspectorForExpression:expression];
        }
        case PCPropertyTypeSize: {
            return [self createSizeInspectorForExpression:expression];
        }
        case PCPropertyTypeScale: {
            return [self createScaleInspectorForExpression:expression];
        }
        case PCPropertyTypeFloat: {
            return [self createFloatInspectorForExpression:expression];
        }
        case PCPropertyTypeInteger: {
            return [self createIntegerInspectorForExpression:expression];
        }
        case PCPropertyTypeColor: {
            return [self createColorInspectorForExpression:expression];
        }
        case PCPropertyTypeTexture: {
            return [self createTextureInspectorForExpression:expression];
        }
        case PCPropertyTypeImage: {
            return [self createImageInspectorForExpression:expression];
        }
        case PCPropertyTypeBool: {
            return [self createBOOLInspectorForExpression:expression name:name];
        }
        case PCPropertyTypeKeyboardInput: {
            return [self createKeyboardInputInspectorForExpression:expression];
        }
        case PCPropertyTypeNode: {
            return [self createNodeInspectorForExpression:expression];
        }
        default: {
            return nil;
        }
    }
}

- (NSViewController <PCExpressionInspector> *)createValueInspectorForPropertyType:(PCPropertyType)propertyType expression:(PCExpression *)expression {
    return [self createValueInspectorForPropertyType:propertyType expression:expression name:nil];
}

- (PCStringExpressionInspector *)createStringInspectorForExpression:(PCExpression *)expression {
    PCStringExpressionInspector *inspector = [[PCStringExpressionInspector alloc] init];
    PCToken *token = expression.token;
    PCTokenValueDescriptor *descriptor = (PCTokenValueDescriptor *)token.descriptor;
    inspector.string = (NSString *)descriptor.value;
    __weak typeof(inspector) weakInspector = inspector;
    __weak typeof(self) weakSelf = self;
    [inspector setSaveHandler:^{
        PCTokenValueDescriptor *descriptor = [PCTokenValueDescriptor descriptorWithName:nil evaluationType:PCTokenEvaluationTypeString value:weakInspector.string];
        PCToken *token = [PCToken tokenWithDescriptor:descriptor];
        [weakSelf updateExpression:expression withValue:token];
    }];
    return inspector;
}

- (PCStringExpressionInspector *)createJavaScriptInspectorForExpression:(PCExpression *)expression {
    PCStringExpressionInspector *inspector = [[PCStringExpressionInspector alloc] init];
    PCToken *token = expression.token;
    PCTokenValueDescriptor *descriptor = (PCTokenValueDescriptor *)token.descriptor;
    inspector.string = (NSString *)descriptor.value;
    __weak typeof(inspector) weakInspector = inspector;
    __weak typeof(self) weakSelf = self;
    [inspector setSaveHandler:^{
        PCToken *token = nil;
        if (weakInspector.string) {
            PCTokenValueDescriptor *descriptor = [PCTokenValueDescriptor descriptorWithName:nil evaluationType:PCTokenEvaluationTypeJavaScript value:weakInspector.string];
            token = [PCToken tokenWithDescriptor:descriptor];
        }
        [weakSelf updateExpression:expression withValue:token];
    }];
    return inspector;
}

- (PCPointExpressionInspector *)createPointInspectorForExpression:(PCExpression *)expression evaluationType:(enum PCTokenEvaluationType)evaluationType firstValueKey:(NSString *)firstValueKey secondValueKey:(NSString *)secondValueKey firstValueDefault:(NSNumber *)firstValueDefault secondValueDefault:(NSNumber *)secondValueDefault {
    PCPointExpressionInspector *inspector = [[PCPointExpressionInspector alloc] init];
    PCToken *token = expression.token;
    PCTokenValueDescriptor *descriptor = (PCTokenValueDescriptor *) token.descriptor;
    NSDictionary *value = (NSDictionary *)descriptor.value;
    if (value) {
        inspector.firstValue = value[firstValueKey];
        inspector.secondValue = value[secondValueKey];
    }
    else {
        inspector.firstValue = firstValueDefault;
        inspector.secondValue = secondValueDefault;
    }
    __weak typeof(inspector) weakInspector = inspector;
    [inspector setSaveHandler:^{
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        if (weakInspector.firstValue) dictionary[firstValueKey] = weakInspector.firstValue;
        if (weakInspector.secondValue) dictionary[secondValueKey] = weakInspector.secondValue;
        PCTokenValueDescriptor *descriptor = [PCTokenValueDescriptor descriptorWithName:nil
                                                                         evaluationType:evaluationType
                                                                                  value:dictionary];
        PCToken *token = [PCToken tokenWithDescriptor:descriptor];
        [self updateExpression:expression withValue:token];
    }];
    return inspector;
}

- (PCPointExpressionInspector *)createPointInspectorForExpression:(PCExpression *)expression {
    return [self createPointInspectorForExpression:expression
                                    evaluationType:PCTokenEvaluationTypePoint
                                     firstValueKey:@"x"
                                    secondValueKey:@"y"
                                 firstValueDefault:@100
                                secondValueDefault:@100];
}

- (PCPointExpressionInspector *)createVectorInspectorForExpression:(PCExpression *)expression {
    return [self createPointInspectorForExpression:expression
                                    evaluationType:PCTokenEvaluationTypeVector
                                     firstValueKey:@"dx"
                                    secondValueKey:@"dy"
                                 firstValueDefault:@100
                                secondValueDefault:@100];
}

- (PCPointExpressionInspector *)createSizeInspectorForExpression:(PCExpression *)expression {
    return [self createPointInspectorForExpression:expression
                                    evaluationType:PCTokenEvaluationTypeSize
                                     firstValueKey:@"width"
                                    secondValueKey:@"height"
                                 firstValueDefault:@100
                                secondValueDefault:@100];
}

- (PCPointExpressionInspector *)createScaleInspectorForExpression:(PCExpression *)expression {
    return [self createPointInspectorForExpression:expression
                                    evaluationType:PCTokenEvaluationTypeScale
                                     firstValueKey:@"x"
                                    secondValueKey:@"y"
                                 firstValueDefault:@1.0
                                secondValueDefault:@1.0];
}

- (PCPointExpressionInspector *)createGravityInspectorForExpression:(PCExpression *)expression {
    return [self createPointInspectorForExpression:expression
                                    evaluationType:PCTokenEvaluationTypePoint
                                     firstValueKey:@"x"
                                    secondValueKey:@"y"
                                 firstValueDefault:@0.0
                                secondValueDefault:@-9.81];
}

- (PCNumberExpressionInspector *)createIntegerInspectorForExpression:(PCExpression *)expression {
    return [self createNumberInspectorForExpression:expression allowFloats:NO];
}

- (PCNumberExpressionInspector *)createFloatInspectorForExpression:(PCExpression *)expression {
    return [self createNumberInspectorForExpression:expression allowFloats:YES];
}

- (PCNumberExpressionInspector *)createNumberInspectorForExpression:(PCExpression *)expression allowFloats:(BOOL)allowFloats {
    PCNumberExpressionInspector *inspector = [[PCNumberExpressionInspector alloc] init];
    inspector.allowFloats = allowFloats;
    PCToken *token = expression.token;
    PCTokenValueDescriptor *descriptor = (PCTokenValueDescriptor *)token.descriptor;
    inspector.number = (NSNumber *)descriptor.value;
    inspector.increment = allowFloats ? 0.1 : 1;
    __weak typeof(inspector) weakInspector = inspector;
    [inspector setSaveHandler:^{
        PCTokenValueDescriptor *descriptor = [PCTokenValueDescriptor descriptorWithName:nil evaluationType:PCTokenEvaluationTypeNumber value:weakInspector.number];
        PCToken *token = [PCToken tokenWithDescriptor:descriptor];
        [self updateExpression:expression withValue:token];
    }];
    return inspector;
}

- (PCColorExpressionInspector *)createColorInspectorForExpression:(PCExpression *)expression {
    PCColorExpressionInspector *inspector = [[PCColorExpressionInspector alloc] init];
    PCToken *token = expression.token;
    if (token) {
        PCTokenValueDescriptor *descriptor = (PCTokenValueDescriptor *)token.descriptor;
        inspector.color = (NSColor *)descriptor.value;
    }
    else {
        inspector.color = [NSColor orangeColor];
    }
    __weak typeof(inspector) weakInspector = inspector;
    __weak typeof(self) weakSelf = self;
    [inspector setSaveHandler:^{
        PCTokenValueDescriptor *descriptor = [PCTokenValueDescriptor descriptorWithName:nil evaluationType:PCTokenEvaluationTypeColor value:weakInspector.color];
        PCToken *token = [PCToken tokenWithDescriptor:descriptor];
        [weakSelf updateExpression:expression withValue:token];
    }];
    return inspector;
}

- (PCImageExpressionInspector *)createTextureInspectorForExpression:(PCExpression *)expression {

    PCImageExpressionInspector *inspector = [[PCImageExpressionInspector alloc] init];

    PCToken *token = expression.token;
    if (token) {
        PCTokenValueDescriptor *descriptor = (id)token.descriptor;
        NSUUID *imageUUID = (NSUUID *)descriptor.value;
        PCResource *resource = [[PCResourceManager sharedManager] resourceWithUUID:[imageUUID UUIDString]];
        inspector.selectedResource = resource;
    }

    __weak typeof(inspector) weakInspector = inspector;
    __weak typeof(self) weakSelf = self;
    [inspector setSaveHandler:^{
        PCToken *token = nil;
        if (weakInspector.selectedResource) {
            PCTokenValueDescriptor *descriptor = [PCTokenValueDescriptor descriptorWithName:[weakInspector.selectedResource.filePath lastPathComponent] evaluationType:PCTokenEvaluationTypeTexture value:[[NSUUID alloc] initWithUUIDString:weakInspector.selectedResource.uuid]];
            token = [PCToken tokenWithDescriptor:descriptor];
        }
        [weakSelf updateExpression:expression withValue:token];
    }];
    return inspector;
}

- (PCImageExpressionInspector *)createImageInspectorForExpression:(PCExpression *)expression {
    
    PCImageExpressionInspector *inspector = [[PCImageExpressionInspector alloc] init];
    
    PCToken *token = expression.token;
    if (token) {
        PCTokenValueDescriptor *descriptor = (id)token.descriptor;
        NSUUID *imageUUID = (NSUUID *)descriptor.value;
        PCResource *resource = [[PCResourceManager sharedManager] resourceWithUUID:[imageUUID UUIDString]];
        inspector.selectedResource = resource;
    }
    
    __weak typeof(inspector) weakInspector = inspector;
    __weak typeof(self) weakSelf = self;
    [inspector setSaveHandler:^{
        PCToken *token = nil;
        if (weakInspector.selectedResource) {
            PCTokenValueDescriptor *descriptor = [PCTokenValueDescriptor descriptorWithName:[weakInspector.selectedResource.filePath lastPathComponent] evaluationType:PCTokenEvaluationTypeImage value:[[NSUUID alloc] initWithUUIDString:weakInspector.selectedResource.uuid]];
            token = [PCToken tokenWithDescriptor:descriptor];
        }
        [weakSelf updateExpression:expression withValue:token];
    }];
    return inspector;
}

- (PCBOOLExpressionInspector *)createBOOLInspectorForExpression:(PCExpression *)expression name:(NSString *)name {

    PCBOOLExpressionInspector *inspector = [[PCBOOLExpressionInspector alloc] init];

    PCToken *token = expression.token;
    if (token) {
        PCTokenValueDescriptor *descriptor = (id)token.descriptor;
        BOOL value = [(NSNumber *)descriptor.value integerValue];
        inspector.value = value;
    }
    inspector.name = name;

    __weak typeof(inspector) weakInspector = inspector;
    __weak typeof(self) weakSelf = self;
    [inspector setSaveHandler:^{
        BOOL value = weakInspector.value;
        NSString *name = value ? @"true" : @"false";
        PCTokenValueDescriptor *descriptor = [PCTokenValueDescriptor descriptorWithName:name evaluationType:PCTokenEvaluationTypeBOOL value:@(value)];
        PCToken *token = [PCToken tokenWithDescriptor:descriptor];
        [weakSelf updateExpression:expression withValue:token];
    }];
    return inspector;
}

- (id)createKeyboardInputInspectorForExpression:(PCExpression *)expression {
    PCKeyboardInputExpressionInspector *inspector = [[PCKeyboardInputExpressionInspector alloc] init];

    PCToken *token = expression.token;
    if (token) {
        PCTokenValueDescriptor *descriptor = (id)token.descriptor;
        NSDictionary *value = (NSDictionary *)descriptor.value;
        if (value) {
            inspector.keycode = value[@"keycode"];
            inspector.keycodeModifier = value[@"keycodeModifier"];
        }
    }

    __weak __typeof(inspector) weakInspector = inspector;
    __weak __typeof(self) weakSelf = self;
    [inspector setSaveHandler:^{
        if (!weakInspector.keycode || !weakInspector.keycodeModifier) return;

        NSDictionary *value = @{ @"keycode" : weakInspector.keycode, @"keycodeModifier" : weakInspector.keycodeModifier };
        NSString *name = [weakInspector shortcutDescription];
        PCTokenValueDescriptor *descriptor = [PCTokenValueDescriptor descriptorWithName:name evaluationType:PCTokenEvaluationTypeKeyboardInput value:value];
        PCToken *token = [PCToken tokenWithDescriptor:descriptor];
        [weakSelf updateExpression:expression withValue:token];
    }];

    return inspector;
}

- (NSViewController <PCExpressionInspector> *)createNodeInspectorForExpression:(PCExpression *)expression {
    return [self createPopupInspectorForExpression:expression withItems:[PCBehavioursDataSource objectTokens] onSave:nil];
}

#pragma mark - JavaScriptRepresentable

- (NSString *)javaScriptRepresentation {
    return [self javaScriptRepresentationWithValues:nil];
}

- (NSString *)javaScriptRepresentationWithValues:(NSDictionary *)upstreamValues {
    NSError *renderError;
    // Map the @{ NSString: PCExpression } dictionary to @{ NSString: NSString } of their JS representations
    NSDictionary *expressionRepresentations = Underscore.dictMap([self templateVariableToExpressionMapping], ^NSString *(NSString *key, PCExpression *expression) {
        return [expression javaScriptRepresentation];
    });
    NSArray *exposedTokenRepresentations = Underscore.array(self.mutableExposedTokens).map(^NSString *(PCToken *token) {
        return [token javaScriptRepresentation];
    }).unwrap;
    NSString *exposedTokensString = [exposedTokenRepresentations componentsJoinedByString:@", "];

    NSDictionary *object = Underscore.dict(expressionRepresentations).extend(@{ @"exposedTokens": exposedTokensString }).extend(upstreamValues).unwrap;
    NSString *representation = [self.representationTemplate renderObject:object error:&renderError];
    if (renderError) {
        PCLog(@"%@", renderError);
    }
    return representation;
}

- (NSString *)representationTemplateString {
    NSString *configurationPath = [[NSBundle bundleForClass:[self class]] pathForResource:NSStringFromClass([self class]) ofType:@"plist"];
    NSDictionary *configuration = [NSDictionary dictionaryWithContentsOfFile:configurationPath];
    NSString *templateString = configuration[@"representationTemplate"];

    // Editing plists in Xcode will escape whitespace characters
    templateString = [templateString stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
    templateString = [templateString stringByReplacingOccurrencesOfString:@"\\t" withString:@"\t"];

    if (PCIsEmpty(templateString)) {
        templateString = @"";
    }
    return templateString;
}

- (GRMustacheTemplate *)representationTemplate {
    NSString *templateString = [self representationTemplateString];
    GRMustacheTemplate *template = [GRMustacheTemplate templateFromString:templateString error:NULL];
    return template;
}

/// Determines if an objc_property_t matches a class passed in.
/// Based on logic in: http://stackoverflow.com/a/8380836
bool isPropertyOfClassType(objc_property_t property, Class class) {
    const char *attributes = property_getAttributes(property);
    if (!attributes) return false;

    NSString *propertyAttributes = [NSString stringWithCString:attributes encoding:[NSString defaultCStringEncoding]];
    NSArray *allAttributes = [propertyAttributes componentsSeparatedByString:@","];
    for (NSString *attribute in allAttributes) {
        //The attribute including the class looks like this: `T@"ClassName"`. As such, it must be at least 4 characters long and contain `T@"` and a trailing `"` to include the class name.
        if (attribute.length < 4 || ![attribute hasPrefix:@"T@\""] || ![attribute hasSuffix:@"\""]) continue;

        //Isolate the class name by removing the leading `T@"` and the trailing `"`
        NSString *className = [attribute substringWithRange:NSMakeRange(3, attribute.length - 4)];
        return (bool)[className isEqualToString:NSStringFromClass(class)];
    }
    return false;
}

/**
 *  Map the template variable names to the expressions that should provide their JS representations for that variable. This mapping, along with some of the configuration of expressions, might be better off in a configuration file for each statement.
 *
 *  @return A dictionary of variable names to expression properties
 */
- (NSDictionary *)templateVariableToExpressionMapping {
    NSMutableDictionary *mapping = [NSMutableDictionary dictionary];

    // Find all of the PCExpression properties for this class and add them to the mapping as @{ @"someExpression" = self.someExpression }
    unsigned int outCount;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    for (NSUInteger propertyIndex = 0; propertyIndex < outCount; propertyIndex += 1) {
        objc_property_t property = properties[propertyIndex];

        if (!isPropertyOfClassType(property, [PCExpression class])) continue;

        const char *propertyNameCString = property_getName(property);
        if (!propertyNameCString) continue;

        NSString *propertyName = [NSString stringWithCString:propertyNameCString encoding:[NSString defaultCStringEncoding]];
        mapping[propertyName] = [self valueForKeyPath:propertyName];
    }
    free(properties);

    return mapping;
}

@end
