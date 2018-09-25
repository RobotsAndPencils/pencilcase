//
//  PropertyInspectorHandler.m
//  CocosBuilder
//
//  Created by Viktor on 7/29/13.
//
//

#import "PropertyInspectorHandler.h"
#import "AppDelegate.h"
#import "SKNode+NodeInfo.h"
#import "PCNodeManager.h"
#import "PlugInNode.h"
#import "PCTemplate.h"
#import "PlugInManager.h"
#import "PCTemplateLibrary.h"

// TODO: Move more of the property inspector code over here!

@implementation PropertyInspectorHandler

- (void)updateTemplates {
    PCNodeManager *nodeManager = [AppDelegate appDelegate].nodeManager;

    //you can only create a template with only one node selected
    BOOL enabledCreation = ([nodeManager.managedNodes count] == 1);
    [newTemplateCreateButton setEnabled:enabledCreation];
    [newTemplateName setEnabled:enabledCreation];
    [newTemplateBgColor setEnabled:enabledCreation];

    if (!nodeManager) return;
    PlugInNode *plugIn = nodeManager.plugIn;
    NSString *plugInName = plugIn.nodeClassName;

    [self updateTemplatesForNodeType:plugInName];
}

- (void)updateTemplatesForNodeType:(NSString *)plugInName {
    NSArray *templates = [templateLibrary templatesForNodeType:plugInName];

    [collectionView setContent:templates];
}

- (IBAction)addTemplate:(id)sender {
    if ([[AppDelegate appDelegate].nodeManager.managedNodes count] != 1) return; //you can only create a template with only one node selected

    SKNode *node = [[AppDelegate appDelegate].selectedSpriteKitNodes firstObject];
    if (!node) return;

    NSString *newName = newTemplateName.stringValue;

    // Make sure that the name is a valid file name
    newName = [newName stringByReplacingOccurrencesOfString:@"/" withString:@""];
    newName = [newName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (!newName || [newName isEqualToString:@""]) return;

    // Make sure it's a unique name
    if ([templateLibrary hasTemplateForNodeType:node.plugIn.nodeClassName andName:newName]) {
        [[AppDelegate appDelegate] modalDialogTitle:@"Failed to Create Template" message:@"You need to specify a unique name. Please try again."];
        return;
    }

    PCTemplate *templ = [[PCTemplate alloc] initWithNode:node name:newName bgColor:newTemplateBgColor.color];

    [templateLibrary addTemplate:templ];

    [newTemplateName setStringValue:@""];
    [self updateTemplates];

    // Resign focus for text field
    [[newTemplateName window] makeFirstResponder:[newTemplateName window]];
}

- (void)removeTemplate:(PCTemplate *)templ {
    [templateLibrary removeTemplate:templ];
    [self updateTemplates];
    [collectionView setSelectionIndexes:[NSIndexSet indexSet]];
}

- (void)applyTemplate:(PCTemplate *)templ {
    SKNode *node = [AppDelegate appDelegate].selectedSpriteKitNode;
    if (!node) return;
    if (!templ.properties) return;

    [templ applyToNode:node];
    [[AppDelegate appDelegate] saveUndoStateDidChangeProperty:@"*template"];
}

- (void)loadTemplateLibrary {
    [templateLibrary loadLibrary];

    for (NSString *nodeType in templateLibrary.nodeTypes) {
        [self updateTemplatesForNodeType:nodeType];
    }
}

- (BOOL)collectionView:(NSCollectionView *)collectionView writeItemsAtIndexes:(NSIndexSet *)indexes toPasteboard:(NSPasteboard *)pasteboard {

    [pasteboard clearContents];

    PlugInNode *particlesPluginNode = [[PlugInManager sharedManager] plugInNodeNamed:@"PCParticleSystem"];

    if (particlesPluginNode) {
        [pasteboard writeObjects:@[ particlesPluginNode ]];
    }

    NSArray *templates = [templateLibrary templatesForNodeType:particlesPluginNode.nodeClassName];

    if ([templates count] > 0) {
        PCTemplate *selectedTemplate = [templates objectAtIndex:[indexes firstIndex]];
        if (selectedTemplate) {
            NSData *templateData = [NSKeyedArchiver archivedDataWithRootObject:selectedTemplate];
            [pasteboard setData:templateData forType:PCPasteboardTypeParticleTemplate];
        }
    }

    return YES;
}

- (void)dealloc {
    collectionView.delegate = nil;
}

@end
