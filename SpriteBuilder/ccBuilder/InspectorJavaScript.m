//
//  InspectorJavaScript
//  SpriteBuilder
//
//  Created by brandon on 2/4/2014.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import "InspectorJavaScript.h"
#import "StringPropertySetter.h"
#import "AppDelegate.h"
#import "MGSFragaria.h"

static void *InspectorJavaScriptContext = &InspectorJavaScriptContext;

@interface InspectorJavaScript ()

@property (strong, nonatomic) MGSFragaria *editorView;

@end

@implementation InspectorJavaScript

- (id)initWithSelection:(PCNodeManager *)s andPropertyName:(NSString *)pn andSetterName:(NSString *)sn andDisplayName:(NSString *)dn andExtra:(NSString *)e placeholderKey:(NSString *)placeholderKey {
    self = [super initWithSelection:s andPropertyName:pn andSetterName:sn andDisplayName:dn andExtra:e placeholderKey:placeholderKey];
    if (self) {
        [[NSUserDefaults standardUserDefaults] setValue:@YES forKey:MGSFragariaPrefsAutocompleteSuggestAutomatically];
        [[NSUserDefaults standardUserDefaults] setValue:@0.5 forKey:MGSFragariaPrefsAutocompleteAfterDelay];

        self.editorView = [[MGSFragaria alloc] init];
        [self.editorView setObject:self forKey:MGSFODelegate];
        [self.editorView setObject:@"Javascript" forKey:MGSFOSyntaxDefinitionName];
        [self.editorView setObject:self forKey:MGSFOSyntaxColouringDelegate];
    }
    return self;
}

- (void)willBeAdded {
    if (self.view) {
        [self.editorView embedInView:self.view];
        [self.editorView setString:self.script];
    }
}

- (void)setScript:(NSString *)script {
    
    if (!script) {
        script = @"";
    }

    [StringPropertySetter setString:script forNode:self.selection andProp:self.propertyName];

    [self updateAffectedProperties];
    [[AppDelegate appDelegate] saveUndoStateDidChangeProperty:self.propertyName];
}

- (NSString *)script {
    return [StringPropertySetter stringForNode:self.selection andProp:self.propertyName];
}

- (void)refresh {
    [self willChangeValueForKey:@"script"];
    [self didChangeValueForKey:@"script"];

    [self.selection willChangeValueForKey:self.propertyName];
    [self.selection didChangeValueForKey:self.propertyName];
}

#pragma mark - MGSFragaria Delegate

- (void)textDidChange:(NSNotification *)notification {
    NSTextView *textView = [notification object];
    NSString *script = [[[textView textStorage] string] copy];
    self.script = script;
}

@end
