//
//  PCThen.m
//  MacTestApp
//
//  Created by Cody Rayment on 2014-11-10.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import "PCThen.h"
#import "PCStatement.h"
#import "PCWhen.h"
#import "PCExpression.h"
#import "PCToken.h"

@interface PCThen () <PCStatementDelegate>

@end

@implementation PCThen

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)setStatement:(PCStatement *)statement {
    _statement = statement;
    statement.delegate = self;
}

- (void)setRunWithPrevious:(BOOL)runWithPrevious {
    if (_runWithPrevious == runWithPrevious) return;

    _runWithPrevious = runWithPrevious;
    [self.when validate];
    
    [self invalidateUI];
    [[self.when previousThenForThen:self] invalidateUI];

    NSUndoManager *undoManager = [[[NSApplication sharedApplication] mainWindow] undoManager];
    [[undoManager prepareWithInvocationTarget:self] setRunWithPrevious:!runWithPrevious];
    if ([undoManager.undoActionName length] == 0 && ![undoManager isUndoing]) {
        if (runWithPrevious) {
            [undoManager setActionName:@"Link Thens"];
        }
        else {
            [undoManager setActionName:@"Un-Link Thens"];
        }
    }
}

- (BOOL)canRunWithPrevious {
    return self.statement.canRunWithPrevious;
}

- (BOOL)canRunWithNext {
    return self.statement.canRunWithNext;
}

+ (NSSet *)excludedPropertyKeys {
    return [NSSet setWithArray:@[ @"when", @"delegate" ]];
}

+ (NSSet *)propertyKeys {
    NSMutableSet *keys = [[super propertyKeys] mutableCopy];
    for (id key in [self excludedPropertyKeys]) {
        [keys removeObject:key];
    }
    return [keys copy];
}

- (BOOL)matchesSearch:(NSString *)search {
    return [self.statement matchesSearch:search];
}

- (void)invalidateUI {
    [self.delegate thenNeedsDisplay:self];
}

- (void)invalidate {
    [self.statement invalidateAttributedString];
}

- (BOOL)validate {
    return [self.statement validateExpressions];
}

- (BOOL)evaluatesAsync {
    return self.statement.evaluatesAsync;
}

- (void)regenerateUUIDs {
    [self.statement regenerateUUID];
}

- (void)updateReferencesToNodeUUID:(NSUUID *)oldUUID toNewUUID:(NSUUID *)newUUID {
    [self.statement updateReferencesToNodeUUID:oldUUID toNewUUID:newUUID];
}

- (void)copyToPasteboard {
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    [pasteboard declareTypes:@[PCPasteboardTypeBehavioursThen] owner:nil];
    [pasteboard setData:[NSKeyedArchiver archivedDataWithRootObject:self] forType:PCPasteboardTypeBehavioursThen];
}

+ (PCThen *)thenFromPasteboard {
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    NSString *type = [pasteboard availableTypeFromArray:@[PCPasteboardTypeBehavioursThen]];
    if (!type) return nil;

    return [NSKeyedUnarchiver unarchiveObjectWithData:[pasteboard dataForType:type]];
}

#pragma mark - PCStatementDelegate

- (NSArray *)statementAvailableTokens:(PCStatement *)statement {
    return [self.when availableTokensForThen:self];
}

- (void)statementNeedsDisplay:(PCStatement *)statement {
    [self invalidateUI];
}

#pragma mark - JavaScriptRepresentable

- (NSString *)javaScriptRepresentation {
    return [self.statement javaScriptRepresentation];
}

@end
