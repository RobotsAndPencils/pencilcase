//
//  PCJSContextTests.m
//  PencilCaseLauncherDemo
//
//  Created by Brandon Evans on 2014-12-17.
//  Copyright (c) 2014 Robots & Pencils. All rights reserved.
//

#import <Kiwi/Kiwi.h>

#import "PCJSContext.h"

SPEC_BEGIN(PCJSContextTests)

__block PCJSContext *context;
beforeEach(^{
    context = [PCJSContext new];
});

describe(@"Triggering a global event without arguments", ^{
    beforeEach(^{
        [context evaluateScript:@"var sentinel = false; Event.on('Test', function() { sentinel = true; });"];
        [context triggerEventWithName:@"Test"];
    });

    it(@"should be recieved by listeners", ^{
        [[expectFutureValue(theValue([context[@"sentinel"] toBool])) shouldEventually] beYes];
    });
});

describe(@"Triggering a global event with arguments", ^{
    beforeEach(^{
        [context evaluateScript:@"var sentinel; Event.on('Test', function() { sentinel = arguments[1]; });"];
        [context triggerEventWithName:@"Test" arguments:@[ @10, @15 ]];
    });

    it(@"should be recieved by listeners", ^{
        [[expectFutureValue([context[@"sentinel"] toNumber]) shouldEventually] equal:@15];
    });
});

describe(@"Triggering an instance event without arguments", ^{
    beforeEach(^{
        [context evaluateScript:@"var node = new BaseObject(); var sentinel = false; node.on('Test', function() { sentinel = true; });"];
        [context triggerEventOnJavaScriptRepresentation:@"node" eventName:@"Test"];
    });

    it(@"should be recieved by listeners", ^{
        [[expectFutureValue(theValue([context[@"sentinel"] toBool])) shouldEventually] beYes];
    });
});

describe(@"Triggering an instance event with arguments", ^{
    beforeEach(^{
        [context evaluateScript:@"var node = new BaseObject(); var sentinel; node.on('Test', function() { sentinel = arguments[1]; });"];
        [context triggerEventOnJavaScriptRepresentation:@"node" eventName:@"Test" arguments:@[ @10, @15 ]];
    });

    it(@"should be recieved by listeners", ^{
        [[expectFutureValue([context[@"sentinel"] toNumber]) shouldEventually] equal:@15];
    });
});

SPEC_END