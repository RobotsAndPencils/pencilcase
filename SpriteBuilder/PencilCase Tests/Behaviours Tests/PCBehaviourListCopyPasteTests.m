//
//  PCBehaviourListCopyPasteTests.m
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2014-12-18.
//
//

#import <Cocoa/Cocoa.h>
#import <Kiwi/Kiwi.h>
#import "PCBehaviourList.h"
#import "PCBehaviourListViewController.h"
#import "PCWhen.h"
#import "PCWhenInfo.h"
#import "PCWhenViewController.h"
#import "PCThen.h"
#import "PCThenInfo.h"
#import "PCThenViewController.h"
#import "PCSlide.h"
#import "PCStatement.h"
#import "PCStatement+Subclass.h"
#import "PCCreateObjectStatement.h"
#import "PCChangePropertyStatement.h"
#import "PCToken.h"
#import "PCTokenFutureNodeDescriptor.h"
#import "PCExpression.h"
#import "PCExpressionInfo.h"

@interface PCBehaviourListViewController(Test)

- (PCWhenInfo *)whenInfoForWhen:(PCWhen *)when;

@end

@interface PCStatement(Test)

@property (strong, nonatomic) NSMutableArray *expressionInfos;

@end

@interface PCWhenViewController(Test)

- (PCThenInfo *)thenInfoForThen:(PCThen *)then;

@end

SPEC_BEGIN(PCBehaviourListCopyPasteTests)

__block PCBehaviourList *behaviourList;
__block PCBehaviourListViewController *behaviourListViewController;
beforeEach(^{
    behaviourList = [[PCBehaviourList alloc] init];
    behaviourListViewController = [[PCBehaviourListViewController alloc] init];
    PCSlide *fakeSlide = [[PCSlide alloc] init];
    [fakeSlide stub:@selector(behaviourList) andReturn:behaviourList];
    [behaviourListViewController loadCard:fakeSlide];
});

context(@"When the user copies a when", ^{
    __block PCWhen *sourceWhen = nil;
    __block PCWhen *copiedWhen = nil;
    beforeEach(^{
        sourceWhen = [[PCWhen alloc] init];
        sourceWhen.statement = [[PCStatement alloc] init];
        [sourceWhen copyToPasteboard];
        copiedWhen = [PCWhen whenFromPasteboard];
    });

    it(@"equals the original when", ^{
        [[sourceWhen should] equal:copiedWhen];
    });

    describe(@"then pastes the when", ^{
        beforeEach(^{
            [behaviourListViewController pasteWhen:copiedWhen];
        });

        it(@"No longer equals the original when", ^{
            [[sourceWhen shouldNot] equal:copiedWhen];
        });
    });

    describe(@"and they paste it in an empty behaviour list", ^{
        beforeEach(^{
            [behaviourListViewController pasteWhen:copiedWhen];
        });

        it(@"Is placed first in the list.", ^{
            [[behaviourList.whens[0] should] equal:copiedWhen];
        });
    });

    describe(@"and the behaviour list has others whens", ^{
        beforeEach(^{
            for (NSInteger i = 0; i < 5; i++) {
                PCWhen *newWhen = [[PCWhen alloc] init];
                newWhen.statement = [[PCStatement alloc] init];
                [behaviourList insertWhen:newWhen atIndex:0];
            }
        });
        describe(@"but none are selected when they paste", ^{
            beforeEach(^{
                for (PCWhen *when in behaviourList.whens) {
                    PCWhenInfo *whenInfo = [behaviourListViewController whenInfoForWhen:when];
                    whenInfo.viewController.selected = NO;
                }
            });

            describe(@"and the original when is not in the list", ^{
                beforeEach(^{
                    //It's not in the list but just to be extra explicit
                    [behaviourList removeWhen:sourceWhen];
                    [behaviourListViewController pasteWhen:copiedWhen];
                });
                it(@"is placed at the end of the list", ^{
                    [[behaviourList.whens.lastObject should] equal:copiedWhen];
                });
            });

            describe(@"and the original when is still in the list when they paste", ^{
                __block NSInteger sourceWhenIndex;
                beforeEach(^{
                    sourceWhenIndex = 4;
                    [behaviourList insertWhen:sourceWhen atIndex:sourceWhenIndex];
                    PCWhenInfo *whenInfo = [behaviourListViewController whenInfoForWhen:sourceWhen];
                    whenInfo.viewController.selected = NO;
                    [behaviourListViewController pasteWhen:copiedWhen];
                });

                it(@"is placed after the original when", ^{
                    [[behaviourList.whens[sourceWhenIndex + 1] should] equal:copiedWhen];
                });
            });
        });

        describe(@"and a when is selected when they paste", ^{
            __block NSInteger selectedWhenIndex;
            beforeEach(^{
                selectedWhenIndex = 2;
                [behaviourListViewController whenInfoForWhen:behaviourList.whens[selectedWhenIndex]].viewController.selected = YES;
                [behaviourListViewController pasteWhen:copiedWhen];
            });

            it(@"is placed after the selected when", ^{
                [[behaviourList.whens[selectedWhenIndex + 1] should] equal:copiedWhen];
            });
        });
    });
});

context(@"When the user copies a when with a token with a future token descriptor that is referenced by a subsequent then", ^{
    __block PCWhen *sourceWhen = nil;
    __block PCWhen *copiedWhen = nil;
    beforeEach(^{
        sourceWhen = [[PCWhen alloc] init];
        sourceWhen.statement = [[PCStatement alloc] init];

        PCStatement *createObjectStatement = [[PCCreateObjectStatement alloc] init];
        PCThen *createThen = [[PCThen alloc] init];
        createThen.statement = createObjectStatement;
        [sourceWhen insertThen:createThen atIndex:0];

        PCTokenFutureNodeDescriptor *futureNodeDescriptor = [PCTokenFutureNodeDescriptor descriptorWithType:PCNodeTypeButton variableName:@"name" sourceUUID:createObjectStatement.UUID];
        PCToken *futureToken = [PCToken tokenWithDescriptor:futureNodeDescriptor];
        PCStatement *editObjectStatement = [[PCChangePropertyStatement alloc] init];
        [editObjectStatement updateExpression:[editObjectStatement valueForKey:@"objectExpression"] withValue:futureToken];
        PCThen *editThen = [[PCThen alloc] init];
        editThen.statement = editObjectStatement;
        [sourceWhen insertThen:editThen atIndex:1];

        [sourceWhen copyToPasteboard];
        copiedWhen = [PCWhen whenFromPasteboard];
    });

    describe(@"and they paste the when", ^{
        __block NSUUID *newSourceUUID = nil;
        beforeEach(^{
            [behaviourListViewController pasteWhen:copiedWhen];

            PCThen *createThen = copiedWhen.thens[0];
            newSourceUUID = createThen.statement.UUID;
        });

        it(@"references the newly pasted future token, not the original one.", ^{
            PCThen *editObjectThen = copiedWhen.thens[1];
            for (PCExpressionInfo *info in editObjectThen.statement.expressionInfos) {
                if (info.expression.token && [info.expression.token.descriptor isKindOfClass:[PCTokenFutureNodeDescriptor class]]) {
                    [[info.expression.token.sourceUUID should] equal:newSourceUUID];
                }
            }
        });
    });
});

context(@"When the user copies a then", ^{
    __block PCWhen *sourceWhen;
    __block PCThen *sourceThen;
    __block PCThen *copiedThen;

    beforeEach(^{
        sourceWhen = [[PCWhen alloc] init];
        sourceWhen.statement = [[PCStatement alloc] init];

        sourceThen = [[PCThen alloc] init];
        sourceThen.statement = [[PCStatement alloc] init];
        [sourceWhen insertThen:sourceThen atIndex:0];

        [sourceThen copyToPasteboard];
        copiedThen = [PCThen thenFromPasteboard];
    });

    it(@"should equal the original then", ^{
        [[sourceThen should] equal:copiedThen];
    });

    describe(@"and they paste it", ^{
        beforeEach(^{
            [behaviourList insertWhen:sourceWhen atIndex:0];
            [behaviourListViewController pasteThen:copiedThen];
        });

        it(@"should not equal the original then", ^{
            [[sourceThen shouldNot] equal:copiedThen];
        });
    });

    describe(@"and they paste it in an empty behaviour list", ^{
        beforeEach(^{
            [behaviourListViewController pasteThen:copiedThen];
        });
        it(@"is not pasted", ^{
            [[theValue(behaviourList.whens.count) should] equal:theValue(0)];
        });
    });

    describe(@"and they paste it in a behaviour list with multiple whens", ^{
        beforeEach(^{
            for (NSInteger i = 0; i < 5; i++) {
                PCWhen *when = [[PCWhen alloc] init];
                when.statement = [[PCStatement alloc] init];

                for (NSInteger j = 0; j < 5; j++) {
                    PCThen *then = [[PCThen alloc] init];
                    then.statement = [[PCStatement alloc] init];
                    [when insertThen:then atIndex:j];
                }
                [behaviourList insertWhen:when atIndex:i];
            }
        })
        ;
        describe(@"but nothing is selected", ^{
            beforeEach(^{
                for (PCWhen *when in behaviourList.whens) {
                    PCWhenInfo *whenInfo = [behaviourListViewController whenInfoForWhen:when];
                    whenInfo.viewController.selected = NO;
                }
            });
            describe(@"and the source when still exists", ^{
                __block NSUInteger originalThenCount;
                beforeEach(^{
                    originalThenCount = sourceWhen.thens.count;
                    [behaviourList insertWhen:sourceWhen atIndex:0];
                    [behaviourListViewController pasteThen:copiedThen];
                });

                it(@"increases the source when's then count", ^{
                    [[theValue(sourceWhen.thens.count) should] equal:theValue(originalThenCount + 1)];
                });

                it(@"is pasted at the end of the source when.", ^{
                    [[sourceWhen.thens.lastObject should] equal:copiedThen];
                });
            });

            describe(@"and the source when has been removed", ^{
                __block NSUInteger originalTotalThenCount = 0;
                beforeEach(^{
                    originalTotalThenCount = 0;
                    for (PCWhen *when in behaviourList.whens) {
                        originalTotalThenCount += when.thens.count;
                    }

                    [behaviourListViewController pasteThen:copiedThen];
                });

                it(@"fails to paste", ^{
                    NSInteger newTotalThenCount = 0;
                    for (PCWhen *when in behaviourList.whens) {
                        newTotalThenCount += when.thens.count;
                    }
                    [[theValue(newTotalThenCount) should] equal:theValue(originalTotalThenCount)];
                });
            });
        });

        describe(@"and a when is selected", ^{
            __block NSInteger selectedWhenIndex;
            beforeEach(^{
                selectedWhenIndex = 2;
                [behaviourListViewController whenInfoForWhen:behaviourList.whens[selectedWhenIndex]].viewController.selected = YES;
                [behaviourListViewController pasteThen:copiedThen];
            });
            it(@"is pasted at the end of the selected when", ^{
                PCWhen *selectedWhen = behaviourList.whens[selectedWhenIndex];
                [[selectedWhen.thens.lastObject should] equal:copiedThen];
            });
        });

        describe(@"and a then is selected", ^{
            __block PCWhen *selectedWhen;
            __block NSInteger selectedThenIndex;
            beforeEach(^{
                selectedThenIndex = 1;
                selectedWhen = behaviourList.whens[3];
                PCThen *selectedThen = selectedWhen.thens[selectedThenIndex];
                PCWhenViewController *whenViewController = [behaviourListViewController whenInfoForWhen:selectedWhen].viewController;
                [whenViewController thenInfoForThen:selectedThen].viewController.selected = YES;

                [behaviourListViewController pasteThen:copiedThen];
            });

            it(@"is pasted after the selected then", ^{
                [[selectedWhen.thens[selectedThenIndex + 1] should] equal:copiedThen];
            });
        });
    });
});


SPEC_END
