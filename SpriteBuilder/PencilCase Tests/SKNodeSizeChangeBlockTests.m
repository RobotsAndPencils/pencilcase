//
//  SKNodeSizeChangeBlockTests.m
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-10-23.
//
//

#import <Cocoa/Cocoa.h>
#import <Kiwi/Kiwi.h>
#import <SpriteKit/SpriteKit.h>
#import "SKNode+SizeChangeBlock.h"

SPEC_BEGIN(SKNodeSizeChangeBlockTests)

describe(@"A node with a size", ^{
    __block SKSpriteNode *spriteNode;
    __block CGSize startSize = CGSizeMake(100, 100);

    beforeEach(^{
        spriteNode = [[SKSpriteNode alloc] initWithColor:[NSColor blackColor] size:startSize];
    });

    context(@"when something registers to be notified of size changes with a block", ^{
        __block NSInteger changeBlockCallCount = 0;
        __block CGSize notifiedOldSize = CGSizeZero;
        __block CGSize notifiedNewSize = CGSizeZero;

        __block PCNodeSizeChangeBlock changeBlock = ^(CGSize oldSize, CGSize newSize) {
            notifiedOldSize = oldSize;
            notifiedNewSize = newSize;
            changeBlockCallCount += 1;
        };

        beforeEach(^{
            [spriteNode pc_registerSizeChangeBlock:changeBlock];
        });

        context(@"and the nodes size changes", ^{
            CGSize changedToSize = CGSizeMake(200, 300);
            beforeEach(^{
                spriteNode.size = changedToSize;
            });

            it(@"should call the change block one time", ^{
                [[theValue(changeBlockCallCount) should] equal:@1];
            });

            it(@"should call the change block with the correct values.", ^{
                [[theValue(notifiedOldSize) should] equal:theValue(startSize)];
                [[theValue(notifiedNewSize) should] equal:theValue(changedToSize)];
            });
        });

        context(@"and the block is released", ^{
            beforeEach(^{
                changeBlock = nil;
            });

            it(@"should not raise on size changes.", ^{
                [[theBlock(^{
                    spriteNode.size = CGSizeMake(100, 100);
                }) shouldNot] raise];

            });
        });

        it(@"should not raise when the object is released", ^{
            [[theBlock(^{
                spriteNode = nil;
            }) shouldNot] raise];
        });
        
        it(@"should not retain the block", ^{
            __weak typeof(changeBlock) weakBlock = changeBlock;
            changeBlock = nil; // Let go of our strong reference
            [[weakBlock shouldEventually] beNil];
        });

        context(@"and the block is released", ^{
            __weak __block typeof(changeBlock) weakBlock;

            beforeEach(^{
                weakBlock = changeBlock;
                changeBlock = nil; // Let go of our strong reference
            });

            it(@"should not be retaining the block", ^{
                [[weakBlock should] beNil];
            });

            it(@"should not raise on size change", ^{
                [[theBlock(^{
                    spriteNode.size = CGSizeMake(20, 20);
                }) shouldNot] raise];
            });
        });
    });

});

SPEC_END
