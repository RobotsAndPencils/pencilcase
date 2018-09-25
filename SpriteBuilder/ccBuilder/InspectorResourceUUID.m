//
//  InspectorResourceUUID.m
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2015-04-16.
//
//

#import "InspectorResourceUUID.h"
#import "PCResource.h"
#import "ResourceManagerUtil.h"
#import "ResourcePropertySetter.h"
#import "AppDelegate.h"
#import "NodeInfo.h"
#import "SKNode+CocosCompatibility.h"
#import "PlugInNode.h"
#import "Constants.h"

@interface InspectorResourceUUID()

@property (weak, nonatomic) IBOutlet NSPopUpButton *popup;
@property (weak, nonatomic) IBOutlet NSTextField *resourceTypeTextField;

@end

@implementation InspectorResourceUUID

- (NSArray *)setupPropertyArrayForFontUpdating {
    return @[self.propertyName];
}

- (void)updateFonts {
    [self setFontForControl:self.popup property:self.propertyName];
}

- (void)willBeAdded {
    [self refresh];
}

- (void)refresh {
    NodeInfo *nodeInfo = self.selection.userObject;
    NSString *resourceTypeString = nodeInfo.plugIn.nodePropertiesDict[self.propertyName][@"resourceType"];
    PCResourceType resourceType = [PCResource resourceTypeFromString:resourceTypeString];
    if (resourceType == PCResourceTypeNone) {
        NSLog(@"Cannot refresh resource UUID inspector - invalid resource info in %@", nodeInfo.plugIn.nodePropertiesDict);
        return;
    }

    self.resourceTypeTextField.stringValue = [NSString stringWithFormat:@"%@:", resourceTypeString];

    id value = [self.selection valueForKey:self.propertyName];
    NSString *resourceFile = nil;
    if (!PCIsEmpty(value)) {
        PCResource *resource = [[PCResourceManager sharedManager] resourceWithUUID:value];
        resourceFile = [ResourceManagerUtil userFacingPathFromAbsolutePath:resource.filePath];
    }
    [ResourceManagerUtil populateResourcePopup:self.popup resourceType:resourceType allowSpriteFrames:YES selectedFile:resourceFile target:self];
}

- (void)selectedResource:(id)sender {
    PCResource *item = [sender representedObject];
    if (item) {
        [ResourceManagerUtil setTitle:[ResourceManagerUtil userFacingPathFromAbsolutePath:item.filePath] forPopup:self.popup];
        [ResourcePropertySetter setResourceUUID:item.uuid forProperty:self.propertyName onNode:self.selection];
        [self updateAnimateablePropertyValue:item.uuid];
    }

    [self updateAffectedProperties];
    [[AppDelegate appDelegate] saveUndoStateDidChangeProperty:self.propertyName];
    [self.selection updateNodeManagerInspectorForProperty:self.propertyName];
    [self refresh];
}

@end
