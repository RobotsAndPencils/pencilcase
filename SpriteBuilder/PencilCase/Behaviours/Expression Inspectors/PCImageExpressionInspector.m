//
//  PCImageExpressionInspector.m
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-12-07.
//
//

#import "PCImageExpressionInspector.h"
#import "PCResource.h"
#import "PCResourceManager.h"
#import "ResourceManagerUtil.h"

@interface PCImageExpressionInspector ()

@property (weak, nonatomic) IBOutlet NSPopUpButton *popUpButton;

@end

@implementation PCImageExpressionInspector

@synthesize saveHandler = _saveHandler;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self refresh];
}

#pragma mark - Public

- (void)setSelectedResource:(PCResource *)selectedResource {
    _selectedResource = selectedResource;
    [self refresh];
}

#pragma mark - Actions

- (void)selectedResource:(NSMenuItem *)sender {
    id item = [sender representedObject];
    if ([item isKindOfClass:[PCResource class]]) {
        PCResource *resource = item;
        if (resource.type == PCResourceTypeImage) {
            self.selectedResource = resource;
        }
    }
    [self refresh];
}

#pragma mark - Private

- (void)refresh {
    NSString *spriteFrameFile = [ResourceManagerUtil relativePathFromAbsolutePath:self.selectedResource.filePath];
    [ResourceManagerUtil populateResourcePopup:self.popUpButton resourceType:PCResourceTypeImage allowSpriteFrames:YES selectedFile:spriteFrameFile target:self];
}

#pragma mark - PCExpressionInspector

- (NSView *)initialFirstResponder {
    return self.popUpButton;
}

@end
