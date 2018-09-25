//
//  SKNodeUniqueNameTests.m
//  SpriteBuilder
//
//  Created by Orest Nazarewycz on 2014-11-03.
//
//

#import <Cocoa/Cocoa.h>
#import "SKNode+NodeInfo.h"
#import "PCStageScene.h"
#import "AppDelegate.h"
#import "NSString+NumericPostscript.h"
#import <Kiwi/Kiwi.h>

SPEC_BEGIN(SKNodeUniqueNameTests)

context(@"String test123", ^{
    __block NSString *testString;
    beforeEach(^{
        testString = @"test123";
    });

    it(@"Has numeric postscript 123", ^{
        [[[testString pc_numericPostscript] should] equal:@"123"];
    });

    it(@"is test without postscript", ^{
        [[[testString pc_stringWithoutNumericPostscript] should] equal:@"test"];
    });
});

context(@"When setting a nodes name", ^{
    __block SKNode *node;
    beforeEach(^{
        node = [SKNode node];
    });

    describe(@"to node", ^{
        describe(@"when another node named node exists", ^{
            beforeEach(^{
                SKNode *otherNode = [SKNode node];
                otherNode.displayName = @"node";
                SKNode *rootNode = [SKNode node];
                [rootNode addChild:otherNode];

                [[PCStageScene scene] stub:@selector(rootNode) andReturn:rootNode];
                node.displayName = @"node";
            });

            specify(^{
                [[node.displayName should] equal:@"node1"];
            });
        });

        describe(@"when there is no node", ^{
            beforeEach(^{
                node.displayName = @"node";
            });
            specify(^{
                [[node.displayName should] equal:@"node"];
            });
        });
    });

    describe(@"to node104", ^{
        describe(@"when another node named node104 exists", ^{
            beforeEach(^{
                SKNode *otherNode = [SKNode node];
                otherNode.displayName = @"node104";
                SKNode *rootNode = [SKNode node];
                [rootNode addChild:otherNode];

                [[PCStageScene scene] stub:@selector(rootNode) andReturn:rootNode];
                node.displayName = @"node104";
            });

            specify(^{
                [[node.displayName should] equal:@"node105"];
            });
        });

        describe(@"when node104 does not exist", ^{
            beforeEach(^{
                node.displayName = @"node104";
            });
            specify(^{
                [[node.displayName should] equal:@"node104"];
            });
        });
    });
});

SPEC_END
