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

#import "GRMustacheInheritableSection_private.h"
#import "GRMustacheASTVisitor_private.h"

@implementation GRMustacheInheritableSection
@synthesize name=_name;
@synthesize ASTNodes=_ASTNodes;

+ (instancetype)inheritableSectionWithName:(NSString *)name ASTNodes:(NSArray *)ASTNodes
{
    return [[[self alloc] initWithName:name ASTNodes:ASTNodes] autorelease];
}

- (void)dealloc
{
    [_name release];
    [_ASTNodes release];
    [super dealloc];
}


#pragma mark - <GRMustacheASTNode>

- (BOOL)acceptVisitor:(id<GRMustacheASTVisitor>)visitor error:(NSError **)error
{
    return [visitor visitInheritableSection:self error:error];
}

- (id<GRMustacheASTNode>)resolveASTNode:(id<GRMustacheASTNode>)ASTNode
{
    // Inheritable section can only override inheritable section
    if (![ASTNode isKindOfClass:[GRMustacheInheritableSection class]]) {
        return ASTNode;
    }
    GRMustacheInheritableSection *otherSection = (GRMustacheInheritableSection *)ASTNode;
    
    // names must match
    if (![otherSection.name isEqual:_name]) {
        return otherSection;
    }
    
    // OK, override with self
    return self;
}


#pragma mark - Private

- (instancetype)initWithName:(NSString *)name ASTNodes:(NSArray *)ASTNodes
{
    self = [self init];
    if (self) {
        _name = [name retain];
        _ASTNodes = [ASTNodes retain];
    }
    return self;
}

@end
