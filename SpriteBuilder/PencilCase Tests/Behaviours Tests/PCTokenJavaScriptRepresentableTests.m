//
//  PCTokenJavaScriptRepresentableTests.m
//  SpriteBuilder
//
//  Created by Brandon Evans on 14-12-11.
//
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import <Kiwi/Kiwi.h>
#import "PCToken.h"
#import "PCTokenNodeDescriptor.h"

SPEC_BEGIN(PCTokenJavaScriptRepresentableTests)

context(@"When asked for its JS representation", ^{
    __block PCToken *token;
    __block NSString *descriptorRepresentation;
    beforeEach(^{
        NSUUID *uuid = [NSUUID UUID];
        descriptorRepresentation = [NSString stringWithFormat:@"Creation.nodeWithUUID('%@')", [uuid UUIDString]];

        PCTokenNodeDescriptor *descriptor = [PCTokenNodeDescriptor descriptorWithNodeUUID:uuid nodeType:PCNodeTypeNode];
        [token.descriptor stub:@selector(javaScriptRepresentation) andReturn:descriptorRepresentation];
        
        token = [PCToken tokenWithDescriptor:descriptor];
    });

    it(@"should delegate to its descriptor",^{
        [[token.descriptor should] receive:@selector(javaScriptRepresentation)];
        [token javaScriptRepresentation];
    });

    it(@"should return its descriptors representation",^{
        [[[token javaScriptRepresentation] should] equal:descriptorRepresentation];
    });
});

SPEC_END


