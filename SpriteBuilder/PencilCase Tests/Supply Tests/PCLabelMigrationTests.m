//
//  PCLabelMigrationTests.m
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2015-06-17.
//
//

#import <Cocoa/Cocoa.h>
#import <Kiwi/Kiwi.h>
#import "CCBPSKLabelTTF.h"

SPEC_BEGIN(PCLabelMigrationTests)

describe(@"Loading a label with alignment", ^{
    __block CCBPSKLabelTTF *label;
    beforeEach(^{
        label = [[CCBPSKLabelTTF alloc] init];
    });

    context(@"Label is left aligned", ^{
        label.horizontalAlignment = CCTextAlignmentLeft;

        it(@"Has anchor x of 0", ^{
            [[theValue(label.anchorPoint.x) should] equal:theValue(0)];
        });
    });

    context(@"Label is horizontally center aligned", ^{
        label.horizontalAlignment = CCTextAlignmentCenter;

        it(@"Has an anchor x of 0.5", ^{
            [[theValue(label.anchorPoint.x) should] equal:theValue(0.5)];
        });
    });

    context(@"Label is right aligned", ^{
        label.horizontalAlignment = CCTextAlignmentRight;

        it(@"Has an anchor x of 1", ^{
            [[theValue(label.anchorPoint.x) should] equal:theValue(1)];
        });
    });

    context(@"Label is bottom aligned", ^{
        label.verticalAlignment = CCVerticalTextAlignmentBottom;

        it(@"Has an anchor y of 0", ^{
            [[theValue(label.anchorPoint.y) should] equal:theValue(0)];
        });
    });

    context(@"Label is vertically center aligned", ^{
        label.verticalAlignment = CCVerticalTextAlignmentCenter;

        it(@"has an anchor y of 0.5", ^{
            [[theValue(label.anchorPoint.y) should] equal:theValue(0.5)];
        });
    });

    context(@"Label is top aligned", ^{
        label.verticalAlignment = CCVerticalTextAlignmentTop;

        it(@"Has an anchor y of 1", ^{
            [[theValue(label.anchorPoint.y) should] equal:theValue(1)];
        });
    });

});

SPEC_END
