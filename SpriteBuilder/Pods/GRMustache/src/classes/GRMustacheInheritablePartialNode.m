// The MIT License
//
// Copyright (c) 2014 Gwendal Roué
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "GRMustacheInheritablePartialNode_private.h"
#import "GRMustachePartialNode_private.h"
#import "GRMustacheASTVisitor_private.h"

@implementation GRMustacheInheritablePartialNode
@synthesize ASTNodes=_ASTNodes;
@synthesize partialNode=_partialNode;

+ (instancetype)inheritablePartialNodeWithPartialNode:(GRMustachePartialNode *)partialNode ASTNodes:(NSArray *)ASTNodes
{
    return [[[self alloc] initWithPartialNode:partialNode ASTNodes:ASTNodes] autorelease];
}

- (void)dealloc
{
    [_partialNode release];
    [_ASTNodes release];
    [super dealloc];
}


#pragma mark - GRMustacheASTNode

- (BOOL)acceptVisitor:(id<GRMustacheASTVisitor>)visitor error:(NSError **)error
{
    return [visitor visitInheritablePartialNode:self error:error];
}

- (id<GRMustacheASTNode>)resolveASTNode:(id<GRMustacheASTNode>)ASTNode
{
    // look for the last inheritable ASTNode in inner ASTNodes
    for (id<GRMustacheASTNode> innerASTNode in _ASTNodes) {
        ASTNode = [innerASTNode resolveASTNode:ASTNode];
    }
    return ASTNode;
}


#pragma mark - Private

- (instancetype)initWithPartialNode:(GRMustachePartialNode *)partialNode ASTNodes:(NSArray *)ASTNodes
{
    self = [super init];
    if (self) {
        _partialNode = [partialNode retain];
        _ASTNodes = [ASTNodes retain];
    }
    return self;
}

@end
