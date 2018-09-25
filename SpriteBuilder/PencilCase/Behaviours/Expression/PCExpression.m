//
//  PCExpression.m
//  Behaviours
//
//  Created by Cody Rayment on 2014-11-19.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import "PCExpression.h"
#import "PCStatement.h"
#import "PCToken.h"
#import "NSColor+PCColors.h"

@interface PCExpression ()

@end

@implementation PCExpression

- (instancetype)init {
    self = [super init];
    if (self) {
        self.advancedChunks = @[];
        self.supportedTokenTypes = @[];
        self.isSimpleExpression = YES;

        [self commonInitSetup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInitSetup];
    }
    return self;
}

- (void)commonInitSetup {
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Public

- (BOOL)hasValue {
    if (self.isSimpleExpression) {
        return !!self.token;
    }
    else {
        return [self.advancedChunks count] > 0;
    }
}

- (void)updateSourceUUIDsWithMapping:(NSDictionary *)mapping {
    [self.token updateSourceUUIDsWithMapping:mapping];
    for (id item in self.advancedChunks) {
        BOOL itemIsToken = [item isKindOfClass:[PCToken class]];
        if (itemIsToken) {
            PCToken *token = (id)item;
            [token updateSourceUUIDsWithMapping:mapping];
        }
    }
}

- (void)updateReferencesToNodeUUID:(NSUUID *)oldUUID toNewUUID:(NSUUID *)newUUID {
    [self.token updateReferencesToNodeUUID:oldUUID toNewUUID:newUUID];
    for (id item in self.advancedChunks) {
        BOOL itemIsToken = [item isKindOfClass:[PCToken class]];
        if (itemIsToken) {
            PCToken *token = (id)item;
            [token updateReferencesToNodeUUID:oldUUID toNewUUID:newUUID];
        }
    }
}

// Temporary validation logic.
- (NSAttributedString *)validationErrorMessageForExpressionChunks:(NSArray *)chunks {
    return nil;
}

- (NSAttributedString *)simpleAttributedStringValueWithDefaultAttributes:(NSDictionary *)attributes {
    return [self attributedStringValueWithChunks:@[ self.token ] defaultAttributes:attributes highlightInvalid:NO];
}

- (NSAttributedString *)advancedAttributedStringValueWithDefaultAttributes:(NSDictionary *)attributes highlightInvalid:(BOOL)highlightInvalid {
    return [self attributedStringValueWithChunks:self.advancedChunks defaultAttributes:attributes highlightInvalid:highlightInvalid];
}

#pragma mark - Properties

- (NSArray *)suggestedTokenTypes {
    return _suggestedTokenTypes ?: self.supportedTokenTypes;
}

#pragma mark - Private

- (NSAttributedString *)attributedStringValueWithChunks:(NSArray *)chunks defaultAttributes:(NSDictionary *)attributes highlightInvalid:(BOOL)highlightInvalid {
    // https://developer.apple.com/library/mac/documentation/cocoa/conceptual/Collections/Articles/Copying.html#//apple_ref/doc/uid/TP40010162-SW3
    chunks = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:chunks]];

    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"" attributes:attributes];
    for (id chunk in chunks) {
        if ([chunk isKindOfClass:[NSString class]]) {
            [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:chunk attributes:attributes]];
        }
        else if ([chunk isKindOfClass:[PCToken class]]) {
            PCToken *token = chunk;
            NSAttributedString *tokenAttributedString;
            if ([token respondsToSelector:@selector(attributedString)]) {
                tokenAttributedString = token.attributedString;
            }
            else {
                tokenAttributedString = [[NSAttributedString alloc] initWithString:token.displayName attributes:attributes];
            }
            [attributedString appendAttributedString:tokenAttributedString];
        }
    }

    if (highlightInvalid && [self validationErrorMessageForExpressionChunks:chunks] != nil) {
        NSDictionary *attributes = @{
                                     NSBackgroundColorAttributeName: [NSColor pc_invalidExpressionColor],
                                     NSUnderlineColorAttributeName: [NSColor redColor],
                                     };
        [attributedString addAttributes:attributes range:NSMakeRange(0, [attributedString length])];
    }

    return attributedString;
}

+ (NSSet *)excludedPropertyKeys {
    return [NSSet setWithArray:@[ @"statement" ]];
}

+ (NSSet *)propertyKeys {
    NSMutableSet *keys = [[super propertyKeys] mutableCopy];
    for (id key in [self excludedPropertyKeys]) {
        [keys removeObject:key];
    }
    return [keys copy];
}

- (NSString *)simpleStringRepresentation {
    return [NSString stringWithFormat:@"\"%@\"", self.token];
}

#pragma mark - JavaScriptRepresentable

- (NSString *)javaScriptRepresentation {
    if (self.isSimpleExpression) {
        return [self.token javaScriptRepresentation] ?: @"";
    }

    NSString *concatenatedRepresentations = Underscore.array(self.advancedChunks).map(^NSString *(id stringOrToken) {
        BOOL itemIsToken = [stringOrToken isKindOfClass:[PCToken class]];
        if (itemIsToken) {
            return [stringOrToken javaScriptRepresentation];
        }
        return stringOrToken;
    }).reduce(@"", ^NSString *(NSString *memo, NSString *chunk) {
        return [memo stringByAppendingString:chunk];
    });

    return concatenatedRepresentations;
}

@end
