//
//  PCWhen.m
//  MacTestApp
//
//  Created by Cody Rayment on 2014-11-10.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import <AppKit/AppKit.h>
#import <Underscore.m/Underscore.h>
#import <GRMustache/GRMustacheTemplate.h>

#import "PCWhen.h"
#import "PCThen.h"
#import "PCStatement.h"
#import "PCToken.h"
#import "PCBehavioursDataSource.h"
#import "PCExpression.h"

@interface PCWhen () <PCStatementDelegate>

@property (strong, nonatomic) NSMutableArray *mutableThens;

@end

@implementation PCWhen

- (instancetype)init {
    self = [super init];
    if (self) {
        self.mutableThens = [NSMutableArray array];
    }
    return self;
}

- (void)setMutableThens:(NSMutableArray *)mutableThens {
    _mutableThens = mutableThens;
    [mutableThens makeObjectsPerformSelector:@selector(setWhen:) withObject:self];
}

- (void)setStatement:(PCStatement *)statement {
    _statement = statement;
    statement.delegate = self;
}

#pragma mark - Public

- (NSArray *)thens {
    return [self.mutableThens copy];
}

- (void)insertThen:(PCThen *)then atIndex:(NSInteger)index {
    NSUndoManager *undoManager = [[[NSApplication sharedApplication] mainWindow] undoManager];
    [[undoManager prepareWithInvocationTarget:self] removeThen:then];
    if (![undoManager isUndoing]) [undoManager setActionName:@"Add Then"];

    then.when = self;
    [self.mutableThens insertObject:then atIndex:index];

    if (![undoManager isUndoing] && ![undoManager isRedoing]) {
        // If we are inserting between two connected thens we expect the new then to be connected
        PCThen *previousThen = [self previousThenForThen:then];
        PCThen *nextThen = [self nextThenForThen:then];
        if (previousThen && nextThen.runWithPrevious) {
            then.runWithPrevious = YES;
        }
    }

    [self validate];
    [self.delegate didAddThen:then atIndex:index];
}

- (void)removeThen:(PCThen *)then {
    NSUndoManager *undoManager = [[[NSApplication sharedApplication] mainWindow] undoManager];
    NSInteger index = [self.thens indexOfObjectIdenticalTo:then];
    [[undoManager prepareWithInvocationTarget:self] insertThen:then atIndex:index];
    if (![undoManager isUndoing]) [undoManager setActionName:@"Delete Then"];

    // Previous Then display is effected (connections)
    [[self previousThenForThen:then] invalidateUI];

    if (![undoManager isUndoing] && ![undoManager isRedoing]) {
        // If we had a bottom link but not a top link we need to break the bottom one to align with user expectation
        PCThen *nextThen = [self nextThenForThen:then];
        if (nextThen && nextThen.runWithPrevious && !then.runWithPrevious) {
            nextThen.runWithPrevious = NO;
            [[self nextThenForThen:then] invalidateUI];
        }
    }
    
    [self.mutableThens removeObjectIdenticalTo:then];
    [self validate];
    [self.delegate didRemoveThen:then];
}

- (PCThen *)nextThenForThen:(PCThen *)then {
    NSInteger index = [self.thens indexOfObjectIdenticalTo:then];
    if (index == NSNotFound || index < 0) return nil;
    index += 1;
    if (index >= self.thens.count) return nil;
    
    return self.thens[index];
}

- (PCThen *)previousThenForThen:(PCThen *)then {
    NSInteger index = [self.thens indexOfObjectIdenticalTo:then];
    if (index == NSNotFound || index < 0) return nil;
    index -= 1;
    if (index < 0) return nil;

    return self.thens[index];
}

- (BOOL)containsThenMatching:(PCThen *)then {
    for (PCThen *thenToMatch in self.thens) {
        if ([then isEqualTo:thenToMatch]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)matchesSearch:(NSString *)search {
    if ([self.statement matchesSearch:search]) return YES;
    for (PCThen *then in self.thens) {
        if ([then matchesSearch:search]) return YES;
    }
    return NO;
}

- (NSArray *)availableTokensForThen:(PCThen *)then {
    NSMutableArray *tokens = [NSMutableArray array];

    // Climb to the first `Then` that isn't linked with a previous `Then` (first `Then` above and outside our group)
    PCThen *firstUnlinkedThen = then;
    while (firstUnlinkedThen.runWithPrevious && firstUnlinkedThen) {
        firstUnlinkedThen = [self previousThenForThen:firstUnlinkedThen];
    }
    if (firstUnlinkedThen) {
        // All thens above the found then are valid
        PCThen *validThen = [self previousThenForThen:firstUnlinkedThen];
        while (validThen) {
            [tokens addObjectsFromArray:validThen.statement.exposedTokens];
            validThen = [self previousThenForThen:validThen];
        }
    }

    [tokens addObjectsFromArray:self.statement.exposedTokens];

    [tokens addObjectsFromArray:[PCBehavioursDataSource allGlobalTokens]];

    return [tokens copy];
}

- (BOOL)validate {
    BOOL isValid = YES;
    isValid &= [self.statement validateExpressions];
    for (PCThen *then in self.thens) {
        isValid &= [then validate];
    }
    return isValid;
}

- (void)invalidate {
    [self.statement invalidateAttributedString];
    [self.thens makeObjectsPerformSelector:@selector(invalidate)];
}

- (void)regenerateUUIDs {
    NSDictionary *uuidMapping = [self uuidMappingDictionary];
    [self.statement regenerateUUID];
    [self.thens makeObjectsPerformSelector:@selector(regenerateUUIDs)];
    [self updateSourceUUIDsWithMapping:uuidMapping];
}

- (void)updateReferencesToNodeUUID:(NSUUID *)oldUUID toNewUUID:(NSUUID *)newUUID {
    [self.statement updateReferencesToNodeUUID:oldUUID toNewUUID:newUUID];
    for (PCThen *then in self.thens) {
        [then updateReferencesToNodeUUID:oldUUID toNewUUID:newUUID];
    }
}

- (void)copyToPasteboard {
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    [pasteboard declareTypes:@[PCPasteboardTypeBehavioursWhen] owner:nil];
    [pasteboard setData:[NSKeyedArchiver archivedDataWithRootObject:self] forType:PCPasteboardTypeBehavioursWhen];
}

+ (PCWhen *)whenFromPasteboard {
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    NSString *type = [pasteboard availableTypeFromArray:@[PCPasteboardTypeBehavioursWhen]];
    if (!type) return nil;

    return [NSKeyedUnarchiver unarchiveObjectWithData:[pasteboard dataForType:type]];
}

#pragma mark - Private

- (NSDictionary *)uuidMappingDictionary {
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    result[self.statement.UUID] = self.statement;
    for (PCThen *then in self.thens) {
        result[then.statement.UUID] = then.statement;
    }
    return [result copy];
}

- (void)updateSourceUUIDsWithMapping:(NSDictionary *)mapping {
    NSArray *allStatements = [[self.thens valueForKey:@"statement"] arrayByAddingObject:self.statement];
    [allStatements makeObjectsPerformSelector:@selector(updateSourceUUIDsWithMapping:) withObject:mapping];
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


#pragma mark - PCStatementDelegate

- (NSArray *)statementAvailableTokens:(PCStatement *)statement {
    // In the future we could add predicate tokens from thens inside other whens. i.e. Create object in another When - use here.
    return [PCBehavioursDataSource allGlobalTokens];
}

- (void)statementNeedsDisplay:(PCStatement *)statement {
    [self.delegate whenNeedsDisplay:self];
}

#pragma mark - JavaScriptRepresentable

- (NSString *)javaScriptRepresentation {
    if (![self validate]) return @"";

    NSString *thensJS = [self allJavaScriptForThens:self.thens];

    // We need to wrap the then code in a generator function, and then call it with co() so it runs async code with sync syntax.
    // This all goes inside the when callback, and after the early return code, so that a plain function (and not a typeof === "object", which RSVP.Promise is, and co returns a promise...) is passed as the EventEmitter listener. Passing an object as a listener invokes different behaviour in EE's API.
    // We're doing it here to avoid needing to do it in every statement.
    thensJS = [NSString stringWithFormat:@"co(function *() {\n%@\n});", thensJS];

    NSDictionary *values = @{ @"thens": thensJS };
    return [self.statement javaScriptRepresentationWithValues:values];
}

- (NSString *)allJavaScriptForThens:(NSArray *)thens {
    // Append ; and newline after each representation
    NSString *thensBlock = [[[self javascriptRepresentationsOfThens:thens] componentsJoinedByString:@";\n"] stringByAppendingString:@";"];
    thensBlock = [@"var yieldResult;\n" stringByAppendingString:thensBlock];
    return thensBlock;
}

- (NSArray *)javascriptRepresentationsOfThens:(NSArray *)thens {
    NSArray *groupedThens = [self groupParallelThens:thens];
    NSArray *thenScripts = Underscore.arrayMap(groupedThens, ^NSString *(id thenOrArray) {
        // Map thens or arrays of thens into their script representations
        BOOL itemIsGroupedThens = [thenOrArray isKindOfClass:[NSArray class]];
        if (itemIsGroupedThens) {
            return [self javascriptRepresentationOfParallelThens:thenOrArray];
        }

        PCThen *then = (PCThen *)thenOrArray;
        NSString *thenRepresentation = [thenOrArray javaScriptRepresentation];

        if (then.evaluatesAsync) {
            thenRepresentation = [@"yield " stringByAppendingString:thenRepresentation];
        }

        // If the then exposes a token then assign that returned value to a named variable
        NSString *firstExposedTokenRepresentation = [then.statement.exposedTokens.firstObject javaScriptRepresentation];
        if (!PCIsEmpty(firstExposedTokenRepresentation)) {
            thenRepresentation = [NSString stringWithFormat:@"var %@ = %@", firstExposedTokenRepresentation, thenRepresentation];
        }
        return thenRepresentation;
    });

    return thenScripts;
}

- (NSString *)javascriptRepresentationOfParallelThens:(NSArray *)thens {
    NSArray *scripts = Underscore.arrayMap(thens, ^NSString *(PCThen *then) {
        // For each group of parallel-evaluating thens, we want the desired script `yield [ then1(), then2() ];`
        // In order for this to work with thens that evaluate immediately, they need to be wrapped in a Promise that resolves immediately.
        // Most thens will evaluate immediately, but some hypothetical examples that wouldn't would be timeline playback and web requests
        NSString *javaScriptRepresentation = [then javaScriptRepresentation];
        if (!then.evaluatesAsync) {
            javaScriptRepresentation = [NSString stringWithFormat:@"Promise.resolve(%@)", javaScriptRepresentation];
        }
        return javaScriptRepresentation;
    });
    NSString *parallelThenScripts = [NSString stringWithFormat:@"yieldResult = yield [%@]", [scripts componentsJoinedByString:@", "]];
    
    // For each yielded result, expose it as a named variable by unpacking from the returned array
    // The JS representation of future node descriptors should be a unique name
    for (NSUInteger valueIndex = 0; valueIndex < thens.count; valueIndex += 1) {
        PCThen *then = thens[valueIndex];
        NSString *firstExposedTokenRepresentation = [then.statement.exposedTokens.firstObject javaScriptRepresentation];
        if (!PCIsEmpty(firstExposedTokenRepresentation)) {
            parallelThenScripts = [parallelThenScripts stringByAppendingFormat:@";\nvar %@ = yieldResult[%ld]", firstExposedTokenRepresentation, valueIndex];
        }
    }
    
    return parallelThenScripts;
}

- (NSArray *)groupParallelThens:(NSArray *)thens {
    // Group parallel thens together into arrays within the array of all thens
    NSArray *groupedThens = Underscore.reduce(self.thens, @[], ^NSArray *(NSArray *memo, PCThen *then) {
        if (!then.runWithPrevious) {
            return [memo arrayByAddingObject:then];
        }

        BOOL lastThenIsWrapped = [memo.lastObject isKindOfClass:[NSArray class]];
        // If this then runs with the previous then and the previous one is already wrapped in an array, add this one to that array
        if (lastThenIsWrapped) {
            NSArray *arrayOfParallelThens = (NSArray *)memo.lastObject;
            memo = [memo mtl_arrayByRemovingLastObject];
            arrayOfParallelThens = [arrayOfParallelThens arrayByAddingObject:then];
            memo = [memo arrayByAddingObject:arrayOfParallelThens];
        }
        // If this then runs with the previous then and the previous one is not wrapped in an array, add the previous and this one to an array
        else {
            PCThen *previousThen = (PCThen *)memo.lastObject;
            memo = [memo mtl_arrayByRemovingLastObject];
            memo = [memo arrayByAddingObject:@[ previousThen, then ]];
        }

        return memo;
    });
    return groupedThens;
}

@end
