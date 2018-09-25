//
//  PCShapeSelectViewController.m
//  SpriteBuilder
//
//  Created by Brendan Duddridge on 2014-03-12.
//
//

#import "PCShapeSelectViewController.h"
#import "PlugInManager.h"
#import "PlugInNode.h"
#import "AppDelegate.h"

@interface PCShapeSelectViewController () <NSDraggingSource, NSPasteboardWriting>

@property (nonatomic, strong) NSImageView *selectedShapeImageView;

@end

@implementation PCShapeSelectViewController

- (void)mouseDragged:(NSEvent *)theEvent {
    id clickedObject = [self.view hitTest:[theEvent locationInWindow]];
    if (![clickedObject isKindOfClass:[NSImageView class]]) return;

    // Store the image view so we can access it from other methods after the drag initiates
    self.selectedShapeImageView = (NSImageView *)clickedObject;

    NSDraggingItem *draggingItem = [[NSDraggingItem alloc] initWithPasteboardWriter:self];
    NSImage *image = self.selectedShapeImageView.image;
    // Center the image on the mouse when dragging
    CGRect draggingFrame = CGRectMake(CGRectGetMidX(self.selectedShapeImageView.frame) - image.size.width / 2, CGRectGetMidY(self.selectedShapeImageView.frame) - image.size.height / 2, image.size.width, image.size.height);
    [draggingItem setDraggingFrame:draggingFrame contents:self.selectedShapeImageView.image];

    NSDraggingSession *session = [self.view beginDraggingSessionWithItems:@[ draggingItem ] event:theEvent source:self];
    session.animatesToStartingPositionsOnCancelOrFail = YES;
}

- (void)mouseUp:(NSEvent *)theEvent {
    id clickedObject = [self.view hitTest:[theEvent locationInWindow]];
    if (![clickedObject isKindOfClass:[NSImageView class]]) return;

    self.selectedShapeImageView = (NSImageView *)clickedObject;
    PlugInNode *shapePluginNode = [[PlugInManager sharedManager] plugInNodeNamed:@"PCShapeNode"];
    
    AppDelegate *appDelegate = [AppDelegate appDelegate];
    [appDelegate dropAddPlugInNodeNamed:shapePluginNode.nodeClassName userInfo:@{ @"shapeType": @(self.selectedShapeImageView.tag) }];
    [appDelegate.selectedPopover performClose:nil];
}

#pragma mark - NSDraggingSource

- (NSDragOperation)draggingSession:(NSDraggingSession *)session sourceOperationMaskForDraggingContext:(NSDraggingContext)context {
    return NSDragOperationEvery;
}

#pragma mark - NSPasteboardWriting

- (NSArray *)writableTypesForPasteboard:(NSPasteboard *)pasteboard {
    return @[ PCPasteboardTypePluginNode ];
}

- (id)pasteboardPropertyListForType:(NSString *)type {
    return @{ @"shapeType": @(self.selectedShapeImageView.tag), @"nodeClassName": @"PCShapeNode" };
}

@end
