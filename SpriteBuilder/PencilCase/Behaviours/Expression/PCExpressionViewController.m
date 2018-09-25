//
//  PCExpressionViewController.m
//  Behaviours
//
//  Created by Cody Rayment on 2014-11-17.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import "PCExpressionViewController.h"
#import "PCStatement.h"
#import "PCExpressionTextView.h"
#import "PCTokenAttachmentCell.h"
#import "PCExpression.h"
#import "PCExpressionInspector.h"
#import <INPopoverController/INPopoverController.h>
#import "NSColor+PCColors.h"
#import "PCBehaviourJavaScriptValidator.h"
#import "PCBehaviourJavaScriptError.h"
#import "PCLineNumberView.h"
#import "PCLineNumberErrorMarker.h"
#import "PCRunJavaScriptStatement.h"
#import "PCUndoManager.h"
#import "RPJSCodeIntel.h"
#import "NSDictionary+JSON.h"

@interface PCExpressionViewController () <NSTableViewDelegate, NSTextViewDelegate, INPopoverControllerDelegate>

@property (weak, nonatomic) IBOutlet NSScrollView *suggestedTokensScrollView;
@property (strong, nonatomic) IBOutlet PCExpressionTextView *suggestedTokensTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *suggestedTokensHeightConstraint;

@property (strong, nonatomic) IBOutlet PCExpressionTextView *textView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewHeightConstraint;

@property (weak, nonatomic) IBOutlet NSScrollView *textViewScrollView;
@property (weak, nonatomic) IBOutlet NSView *simpleInspectorContainer;
@property (weak, nonatomic) IBOutlet NSTabView *tabView;
@property (weak, nonatomic) IBOutlet NSButton *saveButton;

@property (strong, nonatomic) PCExpression *expression;
@property (strong, nonatomic) NSArray *suggestedTokens;
@property (strong, nonatomic, readwrite) NSViewController<PCExpressionInspector> *simpleInspector;
@property (assign, nonatomic) BOOL allowAdvancedEntry;
@property (strong, nonatomic) INPopoverController *errorPopover;
@property (strong, nonatomic) PCBehaviourJavaScriptValidator *javaScriptValidator;

@end

@implementation PCExpressionViewController

- (instancetype)initWithExpression:(PCExpression *)expression inspector:(NSViewController<PCExpressionInspector> *)inspector advancedAllowed:(BOOL)advancedAllowed suggestedTokens:(NSArray *)suggestedTokens {
    self = [super init];
    if (self) {
        _expression = expression;
        _simpleInspector = inspector;
        _allowAdvancedEntry = advancedAllowed;
        _suggestedTokens = suggestedTokens;
        _javaScriptValidator = [[PCBehaviourJavaScriptValidator alloc] init];
    }
    return self;
}

- (void)cleanupUndo {
    [self.undoManager removeAllActionsWithTarget:self];
    self.textView.delegate = nil;
}

- (NSString *)nibName {
    return self.allowAdvancedEntry ? @"PCExpressionViewController" : @"PCExpressionViewControllerBasic";
}

- (void)viewDidLoad {
    [super viewDidLoad];

    if (self.simpleInspector) {
        self.simpleInspector.view.translatesAutoresizingMaskIntoConstraints = NO;
        [self.simpleInspectorContainer addSubview:self.simpleInspector.view];
        [self.simpleInspectorContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[view]-(0)-|" options:0 metrics:@{} views:@{ @"view": self.simpleInspector.view }]];
        [self.simpleInspectorContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(0)-[view]-(0)-|" options:0 metrics:@{} views:@{ @"view": self.simpleInspector.view }]];
        [self.view invalidateIntrinsicContentSize];
    }

    for (PCToken *suggestedToken in self.suggestedTokens) {
        [self.suggestedTokensTextView.textStorage appendAttributedString:[suggestedToken attributedString]];
        [self.suggestedTokensTextView.textStorage appendAttributedString:[[NSAttributedString alloc] initWithString:@" " attributes:@{}]];
    }

    self.suggestedTokensTextView.editable = NO;
    self.suggestedTokensTextView.drawsBackground = NO;
    self.suggestedTokensTextView.selectedTextAttributes = @{};

    NSScrollView *scrollView = self.textView.enclosingScrollView;
    PCLineNumberView *lineNumberView = [[PCLineNumberView alloc] initWithScrollView:scrollView];
    lineNumberView.lineNumbersVisible = [self.expression.statement isKindOfClass:[PCRunJavaScriptStatement class]];
    lineNumberView.backgroundColor = [NSColor whiteColor];
    scrollView.verticalRulerView = lineNumberView;
    scrollView.hasVerticalRuler = YES;
    scrollView.hasHorizontalRuler = NO;
    scrollView.rulersVisible = YES;

    __weak typeof(self) weakSelf = self;
    [self.suggestedTokensTextView setTokenSelectedHandler:^(PCToken *token) {
        [weakSelf.textView insertText:token.attributedString];
    }];

    [self update];
}

- (void)updateViewConstraints {
    [super updateViewConstraints];

    self.suggestedTokensHeightConstraint.constant = self.suggestedTokensTextView.intrinsicContentSize.height + 6;
    self.suggestedTokensHeightConstraint.constant = MIN(self.suggestedTokensHeightConstraint.constant, 120);

    // I would expect to be able to use intrinsic content size of the textview but it isn't working :(
    CGFloat height = [self.textView.layoutManager usedRectForTextContainer:self.textView.textContainer].size.height;
    height += self.textView.textContainerInset.height * 2;
    height += 2; // ScrollView needs this padding somewhere
    self.textViewHeightConstraint.constant = MIN(height, 120);
}

- (void)viewDidLayout {
    [super viewDidLayout];
    if (self.didLayouthandler) self.didLayouthandler();
}

#pragma mark - Public

- (NSView *)initialFirstResponder {
    [self view]; // Force loadView
    return self.expression.isSimpleExpression ? self.simpleInspector.initialFirstResponder : self.textView;
}

- (void)save {
    BOOL simpleMode = !self.allowAdvancedEntry || [self.tabView.selectedTabViewItem.identifier isEqual:@"simple"];
    BOOL validExpression = ([self.expression validationErrorMessageForExpressionChunks:[self.textView expressionChunks]] == nil);
    BOOL valid = validExpression;

    if (!simpleMode) {
        NSArray *javaScriptErrors = [self validateChunksJavaScriptRepresentation:[self.textView expressionChunks]];
        [self updateExpressionViewErrorMarkers:javaScriptErrors];
        valid &= (javaScriptErrors.count == 0);
    }

    if (![self.simpleInspector commitEditing] || !valid) {
        return; // Validation error
    }
    NSArray *chunks = [self.textView expressionChunks] ?: @[];
    if (self.finishedHandler) self.finishedHandler(YES, self.expression, simpleMode, chunks);
}

- (BOOL)shouldClose {
    return nil == self.errorPopover;
}

#pragma mark - Actions

- (void)deleteBackward:(id)sender {
    return;
}

- (IBAction)cancel:(id)sender {
    [self.simpleInspector discardEditing];
    if (self.finishedHandler) self.finishedHandler(NO, nil, YES, nil);
}

- (IBAction)save:(id)sender {
    [self save];
}

#pragma mark - Private

- (void)update {
    [self view]; // Force loadView
    if (self.expression) {
        NSInteger tabIndex = self.expression.isSimpleExpression ? 0 : 1;
        [self.tabView selectTabViewItemAtIndex:tabIndex];

        [self.textView.textStorage setAttributedString:[self.expression advancedAttributedStringValueWithDefaultAttributes:self.textView.typingAttributes highlightInvalid:NO]];
        [self.textView.layoutManager ensureLayoutForTextContainer:self.textView.textContainer];
        [self validate];
    }
}

- (void)validate {
    BOOL simpleMode = !self.allowAdvancedEntry || [self.tabView.selectedTabViewItem.identifier isEqual:@"simple"];
    BOOL validExpression = ([self.expression validationErrorMessageForExpressionChunks:[self.textView expressionChunks]] == nil);
    BOOL valid = validExpression;

    if (!simpleMode) {
        NSArray *javaScriptErrors = [self validateChunksJavaScriptRepresentation:[self.textView expressionChunks]];
        [self updateExpressionViewErrorMarkers:javaScriptErrors];
        valid &= (javaScriptErrors.count == 0);
    }

    self.textView.backgroundColor = valid ? [NSColor whiteColor] : [NSColor pc_invalidExpressionColor];
    self.saveButton.enabled = valid;
}

- (NSArray *)validateChunksJavaScriptRepresentation:(NSArray *)chunks {
    NSArray *javaScriptErrors = [self validateChunksJavaScriptSyntax:chunks];

    NSArray *typeErrors = @[];
    if (self.expression.statement.validateEvaluatedExpressionType) {
        typeErrors = [self validateChunksJavaScriptEvaluatedType:chunks];
    }

    javaScriptErrors = [javaScriptErrors arrayByAddingObjectsFromArray:typeErrors];
    return javaScriptErrors;
}

- (void)updateExpressionViewErrorMarkers:(NSArray *)javaScriptErrors {
    PCLineNumberView *lineNumberView = (PCLineNumberView *)self.textView.enclosingScrollView.verticalRulerView;
    if (!lineNumberView) {
        return;
    }

    [lineNumberView removeAllMarkers];
    NSImage *errorImage = [NSImage imageNamed:@"PC_Mac_GutterError"];
    for (PCBehaviourJavaScriptError *error in javaScriptErrors) {
        NSString *errorMessage = [NSString stringWithFormat:@"Character %li: %@", error.column, error.errorMessage];
        PCLineNumberErrorMarker *marker = [[PCLineNumberErrorMarker alloc] initWithRulerView:lineNumberView lineNumber:error.lineNumber errorMessage:errorMessage image:errorImage imageOrigin:NSMakePoint(0, errorImage.size.height / 2.0)];
        [lineNumberView addMarker:marker];
    }
}

- (NSArray *)validateChunksJavaScriptSyntax:(NSArray *)expressionChunks {
    NSString *javaScript = [self buildJavaScriptFromExpressionChunks:expressionChunks];

    NSString *template = self.expression.statement.javaScriptValidationTemplate;
    if (!PCIsEmpty(template)) {
        javaScript = [NSString stringWithFormat:template, javaScript];
    }

    NSArray *errors = [self.javaScriptValidator validateJavaScript:javaScript];
    return errors;
}

- (NSArray *)libraryTypeDefinitions {
    static NSArray *definitions;

    if (!definitions) {
        // This is in the order of dependencies
        NSArray *filenames = @[ @"ecma5", @"ecma6", @"underscore" ];
        definitions = [Underscore.array(filenames).map(^NSDictionary *(NSString *filename) {
            return [self dictionaryFromTernDefinitionFilename:filename];
        }).reduce([NSMutableArray array], ^NSArray *(NSMutableArray *memo, NSDictionary *definition) {
            [memo addObject:definition];
            return memo;
        }) copy];
    }

    return definitions;
}

- (NSDictionary *)dictionaryFromTernDefinitionFilename:(NSString *)filename {
    NSString *path = [[NSBundle mainBundle] pathForResource:filename ofType:@"json"];
    NSError *jsonError;
    NSDictionary *definition = [NSDictionary dictionaryFromJSONFile:path error:&jsonError];
    if (jsonError) {
        PCLog(@"Error deserializing Tern definition JSON: %@, %@", filename, jsonError);
        return @{};
    }
    return definition;
}

- (NSDictionary *)suggestedTokenTypeDefinitions {
    NSDictionary *definitions = [Underscore.reduce(self.suggestedTokens, [NSMutableDictionary dictionary], ^NSMutableDictionary *(NSMutableDictionary *memo, PCToken *token) {
        NSString *type = [Constants ternTypeNameFromEvaluationType:token.descriptor.evaluationType];
        if ([[Constants ternTypeNamesRequiringPrototype] containsObject:[Constants ternTypeNameFromEvaluationType:token.descriptor.evaluationType]]) {
            type = [type stringByAppendingString:@".prototype"];
        }
        memo[token.javaScriptRepresentation] = type;
        return memo;
    }) copy];
    return definitions;
}

- (NSArray *)allTypeDefinitions {
    NSArray *libraryTypeDefinitions = [self libraryTypeDefinitions];
    NSDictionary *pencilCaseDefinitions = [self dictionaryFromTernDefinitionFilename:@"pencilcase"];
    NSDictionary *tokenTypeDefinitions = [self suggestedTokenTypeDefinitions];

    // Token types need to be merged with the PC API definitions so it has access to the defined types
    NSDictionary *environmentTypeDefinitions = Underscore.extend(pencilCaseDefinitions, tokenTypeDefinitions);

    NSArray *allTypeDefinitions = [libraryTypeDefinitions arrayByAddingObject:environmentTypeDefinitions];
    return allTypeDefinitions;
}

- (NSArray *)validateChunksJavaScriptEvaluatedType:(NSArray *)expressionChunks {
    NSString *javaScript = [self buildJavaScriptFromExpressionChunks:expressionChunks];

    RPJSCodeIntel *codeIntel = [[RPJSCodeIntel alloc] initWithScript:javaScript typeDefinitions:[self allTypeDefinitions]];
    NSError *typeInferError;
    NSDictionary *inferredTypeInfo = [codeIntel typeInformationForExpression:&typeInferError];
    NSString *typeName = inferredTypeInfo[@"name"] ?: @"Unknown";
    if ([typeName hasSuffix:@".prototype"]) {
        typeName = [typeName stringByReplacingOccurrencesOfString:@".prototype" withString:@""];
    }
    if (typeInferError) {
        PCLog(@"Error inferring the type of expression: %@\n\n%@", typeInferError, javaScript);
    }

    // If the inferred expression type is unknown, don't do anything.
    // It might be better to have a (soft) warning about this in the future.
    // If it's not unknown but isn't a supported type, return an error
    BOOL incorrectType = NO;
    incorrectType |= [self typeNameIsUnsupportedTernType:typeName];
    incorrectType |= [self typeName:typeName isUnsupportedByExpressionTypes:self.expression.supportedTokenTypes];
    // Fail functions that aren't invoked, where Tern will report the type as a function signature starting with `fn(`
    incorrectType |= [inferredTypeInfo[@"type"] containsString:@"fn("];

    NSArray *supportedObjectTypes = [self javaScriptObjectTypesFromTypes:self.expression.supportedTokenTypes];
    // Fail if it's an Object but it's not supported
    incorrectType |= ([typeName isEqualToString:@"Object"] && supportedObjectTypes.count == 0);
    // Otherwise Objects require specific checks to determine if the structure of the return value is supported
    // If we expect an Object type we also check when the inferred type is reported as Unknown, since Tern doesn't handle Objects well
    if (([typeName isEqualToString:@"Object"] || [typeName isEqualToString:@"Unknown"]) && supportedObjectTypes.count > 0) {
        for (NSNumber *typeNumber in supportedObjectTypes) {
            incorrectType |= ![codeIntel validateObjectValueOfScript:javaScript expectedType:(PCTokenEvaluationType)typeNumber.integerValue];
        }
    }
    else if (supportedObjectTypes.count > 0 && [typeName isEqualToString:@"undefined"]) {
        // Sadly, there isn't a way to check the validity of object literals in all cases right now. Tern doesn't model them and if they contain variable references to tokens or PC APIs then it's not feasible to stub those out with sample values that validateObjectValueOfScript:expectedType: could use (by just naively evaluating the expression and seeing what comes out).
        return @[];
    }

    if (incorrectType) {
        PCBehaviourJavaScriptError *error = [[PCBehaviourJavaScriptError alloc] init];
        error.lineNumber = 1;
        error.column = 1;
        NSString *supportedTypeString = Underscore.array(self.expression.supportedTokenTypes).map(^NSString *(NSNumber *tokenTypeNumber) {
            return [Constants stringFromEvaluationType:(PCTokenEvaluationType)tokenTypeNumber.integerValue];
        }).reduce(@"", ^NSString *(NSString *result, NSString *typeString) {
            return [result stringByAppendingFormat:@" %@", typeString];
        });
        error.errorMessage = [NSString stringWithFormat:@"This expression evaluates to: %@ but the statement supports these types of values: %@", typeName, supportedTypeString];
        
        return @[ error ];
    }

    return @[];
}

- (BOOL)typeNameIsUnsupportedTernType:(NSString *)typeName {
    return Underscore.any([Constants unsupportedExpressionTernTypes], ^BOOL(NSString *unsupportedTypeName) {
        return [typeName isEqualToString:unsupportedTypeName];
    });
}

- (BOOL)typeName:(NSString *)typeName isUnsupportedByExpressionTypes:(NSArray *)supportedExpressionTypes {
    return Underscore.any([Constants supportedExpressionTernTypes], ^BOOL(NSString *supportedTypeName) {
        BOOL isParticularTypeName = [typeName isEqualToString:supportedTypeName];
        BOOL supportsParticularTypeName = [supportedExpressionTypes containsObject:@([Constants evaluationTypeFromTernTypeName:supportedTypeName])];
        return isParticularTypeName && !supportsParticularTypeName;
    });
}

- (NSArray *)javaScriptObjectTypesFromTypes:(NSArray *)tokenTypes {
    NSMutableSet *tokenTypesSet = [NSMutableSet setWithArray:tokenTypes];
    NSSet *objectTypesSet = [NSSet setWithArray:[Constants javaScriptObjectEvaluationTypes]];
    [tokenTypesSet intersectSet:objectTypesSet];
    return [tokenTypesSet allObjects];
}

- (NSString *)buildJavaScriptFromExpressionChunks:(NSArray *)expressionChunks {
    NSString *javaScript = @"";

    for (id chunk in expressionChunks) {
        if ([chunk isKindOfClass:[PCToken class]]) {
            PCToken *token = (PCToken *)chunk;
            javaScript = [javaScript stringByAppendingString:token.javaScriptRepresentation];
        }
        else if ([chunk isKindOfClass:[NSString class]]) {
            NSString *textChunk = (NSString *)chunk;
            javaScript = [javaScript stringByAppendingString:textChunk];
        }
    }

    return javaScript;
}

#pragma mark - Properties

- (void)setExpression:(PCExpression *)expression {
    _expression = expression;
    [self update];
}

#pragma mark - NSTextViewDelegate

- (BOOL)textView:(NSTextView *)textView shouldChangeTextInRange:(NSRange)affectedCharRange replacementString:(NSString *)replacementString {
    BOOL replacementStringContainsNewLine = [replacementString rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]].location != NSNotFound;
    BOOL multiLineEditingAllowed = [self.expression.statement isKindOfClass:[PCRunJavaScriptStatement class]];

    if (replacementStringContainsNewLine) {
        return multiLineEditingAllowed;
    }
    return YES;
}

- (void)textDidChange:(NSNotification *)notification {
    if (notification.object == self.textView) {
        [self.view setNeedsUpdateConstraints:YES];
        [self validate];
    }
}

- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem {
    [self validate];
}

#pragma mark - INPopoverControllerDelegate

- (void)popoverDidClose:(INPopoverController *)popover {
    if (popover == self.errorPopover) {
        self.errorPopover = nil;
    }
}

@end
