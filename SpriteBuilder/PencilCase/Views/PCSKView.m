//
//  PCSKView.m
//  SpriteBuilder
//
//  Created by Brandon Evans on 2014-06-16.
//
//

#import "PCSKView.h"
#import "PCStageScene.h"
#import "AppDelegate.h"
#import "PCResourceManager.h"
#import "NSPasteboard+CCB.h"

@interface PCSKView ()

@property (nonatomic, assign) BOOL wasAcceptingMouseEvents;
@property (nonatomic, assign) NSTrackingRectTag trackingRect;
@property (nonatomic, strong) id mouseMovedMonitor;

@end


@implementation PCSKView

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setup];
}

- (instancetype)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    [self registerForDraggedTypes:@[ PCPasteboardTypeTexture, PCPasteboardTypeTemplate, PCPasteboardTypeCCB, PCPasteboardTypePluginNode,PCPasteboardTypeMOV, PCPasteboardType3DModel, NSFilenamesPboardType, NSTIFFPboardType, NSPDFPboardType, NSStringPboardType ]];
}

#pragma mark Tracking rectangles

- (void)viewDidMoveToWindow {
    self.trackingRect = [self addTrackingRect:self.bounds owner:self userData:NULL assumeInside:NO];
    // We're using a local event monitor for mouse movement because we need to
    // be able to do things like update the cursor without this view necessarily
    // being the first responder.
    self.mouseMovedMonitor = [NSEvent addLocalMonitorForEventsMatchingMask:NSMouseMovedMask handler:^NSEvent *(NSEvent *event) {
        PCStageScene *stageScene = [PCStageScene scene];
        [stageScene mouseMoved:event];
        return event;
    }];
}

- (void)setFrame:(NSRect)frame {
    [super setFrame:frame];
    [self removeTrackingRect:self.trackingRect];
    self.trackingRect = [self addTrackingRect:self.bounds owner:self userData:NULL assumeInside:NO];
}

- (void)setBounds:(NSRect)bounds {
    [super setBounds:bounds];
    [self removeTrackingRect:self.trackingRect];
    self.trackingRect = [self addTrackingRect:self.bounds owner:self userData:NULL assumeInside:NO];
}

- (void)viewWillMoveToWindow:(NSWindow *)newWindow {
    if ([self window] && self.trackingRect) {
        [self removeTrackingRect:self.trackingRect];
        [NSEvent removeMonitor:self.mouseMovedMonitor];
    }
}

#pragma mark - NSResponder

- (void)scrollWheel:(NSEvent *)theEvent {
    PCStageScene *stageScene = [PCStageScene scene];

    CGPoint newOffset = CGPointZero;
    
    CGFloat dx = roundf([theEvent deltaX]);
    CGFloat dy = roundf(-[theEvent deltaY]);
    
    newOffset.x = stageScene.scrollOffset.x + dx;
    newOffset.y = stageScene.scrollOffset.y + dy;
    
    stageScene.scrollOffset = newOffset;
}

- (void)magnifyWithEvent:(NSEvent *)event {
    PCStageScene *stageScene = [PCStageScene scene];
    stageScene.stageZoom = stageScene.stageZoom + [event magnification];
}

- (void)rightMouseDown:(NSEvent *)theEvent {
    PCStageScene *stageScene = [PCStageScene scene];
    [stageScene rightMouseDown:theEvent];
}

- (void)mouseDown:(NSEvent *)theEvent {
    PCStageScene *stageScene = [PCStageScene scene];
    [stageScene mouseDown:theEvent];
    [self.window makeFirstResponder:self];
}

- (void)mouseDragged:(NSEvent *)theEvent {
    PCStageScene *stageScene = [PCStageScene scene];
    [stageScene mouseDragged:theEvent];
}

- (void)mouseUp:(NSEvent *)theEvent {
    PCStageScene *stageScene = [PCStageScene scene];
    [stageScene mouseUp:theEvent];
    [self.window setAcceptsMouseMovedEvents:YES];
    [self.window makeFirstResponder:self];
}

// Note: if the mouse enters this view while participating in another event, for
// example when the mouse is down when it enters the view, and then the mouse is
// let go, then mouseEntered: is called and mouseUp: isn't
- (void)mouseEntered:(NSEvent *)theEvent {
    self.wasAcceptingMouseEvents = [[self window] acceptsMouseMovedEvents];
    [[PCStageScene scene] mouseEntered:theEvent];
    [self.window setAcceptsMouseMovedEvents:YES];
}

- (void)mouseExited:(NSEvent *)theEvent {
    [[self window] setAcceptsMouseMovedEvents:self.wasAcceptingMouseEvents];
    [[PCStageScene scene] mouseExited:theEvent];
}

- (IBAction)deleteBackward:(id)sender {
    [[AppDelegate appDelegate] deleteSelection];
}

// Overriding this to call interpretKeyEvents because SKView wasn't handling the delete key event by default
- (void)flagsChanged:(NSEvent *)theEvent {
    [[PCStageScene scene] flagsChanged:theEvent];
}

- (void)keyDown:(NSEvent *)theEvent {
    if ([[PCStageScene scene] handleKeyDown:theEvent]) return;
    if ([self handleKeyDown:theEvent]) return;
    [self interpretKeyEvents:@[ theEvent ]];
}

- (BOOL)handleKeyDown:(NSEvent *)event {
    switch (event.keyCode) {
        case 51: //delete
        case 117: //secondary delete
        {
            [self deleteBackward:event];
            return YES;
        }
    }
    return NO;
}

#pragma mark Drag Operations

- (NSDragOperation)draggingSourceOperationMaskForLocal:(BOOL)isLocal {
    return(isLocal ? NSDragOperationMove : NSDragOperationAll);
}

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender {
    return NSDragOperationGeneric;
}

- (BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender {
    return YES;
}

- (BOOL)importAndDropFinderFilesFromPasteboard:(NSPasteboard *)pasteBoard atPoint:(CGPoint)dragPoint {
    //Finder Files
    NSArray *pasteBoardFiles = [pasteBoard propertyListForType:NSFilenamesPboardType];
    if ([pasteBoardFiles count] == 0) return NO;

    NSString *resourcesPath = [NSString stringWithFormat:@"%@/resources/", [AppDelegate appDelegate].currentProjectSettings.absoluteResourcePaths.firstObject];

    NSString *daeFilePath = nil;
    if ([[PCResourceManager sharedManager] importDaeFiles:pasteBoardFiles outResultFilePath:&daeFilePath]) {
        [[AppDelegate appDelegate] dropAdd3DModelWithFile:daeFilePath at:dragPoint];
    } else {
        for (NSString *filepath in pasteBoardFiles) {
            PCResource *droppedResource = [[PCResourceManager sharedManager] importResourceAtAbsolutePath:filepath intoDirectoryAtAbsolutePath:resourcesPath appendSuffixIfFileExists:YES];
            NSString *fileType = [droppedResource.filePath pathExtension];
            if ([fileType isEqualToString:@"png"] || [fileType isEqualToString:@"jpg"] || [fileType isEqualToString:@"jpeg"]) {
                [[AppDelegate appDelegate] dropAddSpriteWithUUID:droppedResource.uuid at:dragPoint parent:nil];
            } else if ([fileType isEqualToString:@"mov"] || [fileType isEqualToString:@"mp4"]) {
                [[AppDelegate appDelegate] dropAddVideoWithFile:droppedResource.relativePath at:dragPoint];
            }
        }
    }

    [[AppDelegate appDelegate] reloadResources];
    return YES;
}

- (BOOL)importAndDropWebFilesFromPasteboard:(NSPasteboard *)pasteBoard atPoint:(CGPoint)dragPoint {
    NSArray *webUrls = [pasteBoard propertyListForType:NSURLPboardType];
    if ([webUrls count] == 0) return NO;
    NSString *resourcesPath = [NSString stringWithFormat:@"%@/resources/", [AppDelegate appDelegate].currentProjectSettings.absoluteResourcePaths.firstObject];
    for (NSString *imageUrl in webUrls) {
        NSString *imageType = [imageUrl pathExtension];

        if ([imageType isEqualToString:@"png"] || [imageType isEqualToString:@"jpeg"] || [imageType isEqualToString:@"jpg"]) {
            NSString *fileName = [NSString stringWithFormat:@"%@", [imageUrl lastPathComponent]];
            NSImage *nsImg = [[NSImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]]];
            NSBitmapImageRep *imgRep = (NSBitmapImageRep *)[[nsImg representations] objectAtIndex:0];
            NSData *data = [imgRep representationUsingType:NSPNGFileType properties:@{}];
            NSString *imageAbsolutePath = [NSString stringWithFormat:@"%@%@", resourcesPath, fileName];
            [data writeToFile:imageAbsolutePath atomically:NO];
            PCResource *resource = [[PCResourceManager sharedManager] addResourceWithAbsoluteFilePath:imageAbsolutePath];
            [[PCResourceManager sharedManager] notifyResourceObserversResourceListUpdated];
            [[AppDelegate appDelegate] dropAddSpriteWithUUID:resource.uuid at:dragPoint parent:nil];
        }
    }
    return YES;
}

- (void)dropResourcesFromPasteboard:(NSPasteboard *)pasteBoard atPoint:(CGPoint)dragPoint {
    // Textures
    NSArray *pbTextures = [pasteBoard propertyListsForType:PCPasteboardTypeTexture];
    for (NSDictionary *dict in pbTextures) {
        [[AppDelegate appDelegate] dropAddSpriteWithUUID:dict[@"spriteFile"] at:dragPoint parent:nil];
    }

    NSArray *pbMovies = [pasteBoard propertyListsForType:PCPasteboardTypeMOV];
    for (NSDictionary *dict in pbMovies) {
        [[AppDelegate appDelegate] dropAddVideoWithFile:dict[@"movFile"] at:dragPoint];
    }

    // 3D Model Files
    NSArray *pbModels = [pasteBoard propertyListsForType:PCPasteboardType3DModel];
    for (NSDictionary *dict in pbModels) {
        [[AppDelegate appDelegate] dropAdd3DModelWithFile:dict[@"daeFile"] at:dragPoint];
    }
}

- (void)dropPluginsFromPasteboard:(NSPasteboard *)pasteBoard atPoint:(CGPoint) dragPoint {
    // PlugInNode
    NSArray *pasteboardPluginNodes = [pasteBoard propertyListsForType:PCPasteboardTypePluginNode];
    for (NSDictionary *pluginDict in pasteboardPluginNodes) {
        NSString *nodeClassName = pluginDict[@"nodeClassName"];
        NSDictionary *userInfo = nil;
        if ([nodeClassName isEqualToString:@"PCTextView"]) {
            NSData *fontData = [pasteBoard dataForType:PCPasteboardTypeFont];
            if (fontData) {
                NSFont *font = [NSKeyedUnarchiver unarchiveObjectWithData:fontData];
                userInfo = @{ @"defaultFont" : font };
            }
        } else if ([nodeClassName isEqualToString:@"PCParticleSystem"]) {
            NSData *particleTemplate = [pasteBoard dataForType:PCPasteboardTypeParticleTemplate];
            if ([AppDelegate appDelegate].nodeIsBeingCreatedFromShortCutCollectionViewPane) {
                [AppDelegate appDelegate].nodeIsBeingCreatedFromShortCutCollectionViewPane = NO;
                return;
            }

            if (particleTemplate) {
                NSDictionary *template = [NSKeyedUnarchiver unarchiveObjectWithData:particleTemplate];
                userInfo = @{ @"particleTemplate" : template };
            }
        } else if ([nodeClassName isEqualToString:@"PCShapeNode"]) {
            NSNumber *shapeType = pluginDict[@"shapeType"];
            if (shapeType) {
                userInfo = @{ @"shapeType" : shapeType };
            }
        }
        [[AppDelegate appDelegate] dropAddPlugInNodeNamed:nodeClassName at:dragPoint userInfo:userInfo];
    }
    if ([[AppDelegate appDelegate] respondsToSelector:@selector(dropAddResource)]) {
        [[AppDelegate appDelegate] dropAddResource];
    }
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender {
    NSPoint dragPoint = [self convertPoint:[sender draggingLocation] fromView:nil];
    dragPoint = [[PCStageScene scene] convertPointFromView:dragPoint];

    NSPasteboard *pasteBoard = [sender draggingPasteboard];
    if ([self importAndDropFinderFilesFromPasteboard:pasteBoard atPoint:dragPoint]) {
        return YES;
    }

    if ([self importAndDropWebFilesFromPasteboard:pasteBoard atPoint:dragPoint]) {
        return YES;
    }

    [self dropResourcesFromPasteboard:pasteBoard atPoint:dragPoint];
    [self dropPluginsFromPasteboard:pasteBoard atPoint:dragPoint];

    return YES;
}

@end
