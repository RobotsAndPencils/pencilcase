//
//  CCBImageBrowserView.m
//  CocosBuilder
//
//  Created by Viktor on 7/25/13.
//
//

#import "CCBImageBrowserView.h"
#import "AppDelegate.h"
#import "PCResourceManager.h"
#import "ResourceManagerTilelessEditorManager.h"

@implementation CCBImageBrowserView

- (void) deselectAll
{
    [self setSelectionIndexes:[NSIndexSet indexSet] byExtendingSelection:NO];
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
    NSPasteboard *pasteboard = [sender draggingPasteboard];
    NSString *destinationBasePath = [[PCResourceManager sharedManager].rootDirectory.directoryPath stringByAppendingPathComponent:@"resources"];

    if ([[pasteboard types] containsObject:NSFilenamesPboardType]) {
		
        NSArray* filenames = [pasteboard propertyListForType:NSFilenamesPboardType];
        
        // filter array to only files with allowed extensions
        filenames = [filenames filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(pathExtension IN %@)", [PCResourceManager allowedMediaFileExtensions]]];

        if ([filenames count] == 0) return YES;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:PCDroppedFileNotification object:nil];
        BOOL result = [[PCResourceManager sharedManager] importResourcesAtAbsolutePaths:filenames intoDirectoryAtAbsolutePath:destinationBasePath appendSuffixIfFileExists:NO];

        // if we can't import any files, still fire off a resource list changed notification so the progress indicator hides in the media panel
        if (result == NO) {
            [[PCResourceManager sharedManager] notifyResourceObserversResourceListUpdated];
        }
    }
    
    return YES;
}

- (void)mouseUp:(NSEvent *)theEvent {
    int selectionIndex = [self.selectionIndexes firstIndex];
    ResourceManagerTilelessEditorManager *resourceManager = (ResourceManagerTilelessEditorManager *)self.dataSource;
    if (selectionIndex < 0 || selectionIndex >= [resourceManager.imageResources count]) return;
    
    PCResource *selectedImageresource = (PCResource *)[resourceManager.imageResources objectAtIndex:selectionIndex];
    
     AppDelegate *appDelegate = [AppDelegate appDelegate];
    switch (selectedImageresource.type) {
        case PCResourceTypeImage:
            [appDelegate.selectedPopover performClose:nil];
            [appDelegate dropAddSpriteWithUUID:selectedImageresource.relativePath];
            break;
        case PCResourceTypeVideo:
            [appDelegate.selectedPopover performClose:nil];
            [appDelegate dropAddVideoWithFile:selectedImageresource.relativePath];
            break;
        case PCResourceType3DModel:
            [appDelegate.selectedPopover performClose:nil];
            [appDelegate dropAdd3DModelWithFile:selectedImageresource.relativePath];
            break;
        default:
            break;
    }
}



@end
