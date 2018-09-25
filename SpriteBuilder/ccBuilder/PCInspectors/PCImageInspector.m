//
//  PCColorInspector.m
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-05-14.
//
//

#import "PCImageInspector.h"
#import "PCResourceManager.h"
#import "ResourceManagerUtil.h"

@interface PCImageInspector ()

@property (weak, nonatomic) IBOutlet NSPopUpButton *popupButton;

@property (strong, nonatomic) NSString *selectedImageUUID;
@property (weak, nonatomic) IBOutlet NSTextField *inspectorLabel;

@end

@implementation PCImageInspector

- (void)awakeFromNib {
    [super awakeFromNib];
    [ResourceManagerUtil populateResourcePopup:self.popupButton resourceType:PCResourceTypeImage allowSpriteFrames:YES selectedFile:@"" target:self];
}

- (void)setValue:(id)value forValueInfoIndex:(NSInteger)index {
    if (!value) value = @"";
    self.selectedImageUUID = value;
    [self refresh];
    [self dispatchValueChange];
}

- (void)refresh {
    PCResource *resource = [[PCResourceManager sharedManager] resourceWithUUID:self.selectedImageUUID];
    NSString *spriteFrameFile = [ResourceManagerUtil relativePathFromAbsolutePath:resource.filePath];

    [ResourceManagerUtil populateResourcePopup:self.popupButton resourceType:PCResourceTypeImage allowSpriteFrames:YES selectedFile:spriteFrameFile target:self];
}

#pragma mark - Private

- (id)value {
    return self.selectedImageUUID;
}

- (void)dispatchValueChange {
    [self.delegate inspector:self valueChanged:self.selectedImageUUID forValueInfoAtIndex:0];
}

#pragma mark - Menu Item Selected

- (void)selectedResource:(id)sender {
    id item = [sender representedObject];
    if ([item isKindOfClass:[PCResource class]]) {
        PCResource *res = item;
        if (res.type == PCResourceTypeImage) {
            self.selectedImageUUID = res.uuid;
        }
    }
    [self refresh];
    [self dispatchValueChange];
}

@end
