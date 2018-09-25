//
//  ResourceManagerTilelessEditorManager.m
//  CocosBuilder
//
//  Created by Viktor on 7/24/13.
//
//

#import "ResourceManagerTilelessEditorManager.h"

#import <Underscore.m/Underscore.h>

#import "ResourceManagerUtil.h"
#import "CCBImageBrowserView.h"
#import "AppDelegate.h"
#import "ResourceManagerPreviewView.h"

@interface ResourceManagerTilelessEditorManager()
@property (nonatomic, strong) NSArray *allResources;
@property (nonatomic, strong) NSImage *imageIcon;
@property (nonatomic, strong) NSString *imageIconPath;
@end

@implementation ResourceManagerTilelessEditorManager

- (id) initWithImageBrowser:(CCBImageBrowserView*)bw
{
    self = [super init];
    if (!self) return NULL;
    
    // Keep track of browser
    self.browserView = bw;
    self.browserView.dataSource = self;
    self.browserView.delegate = self;

    self.browserView.intercellSpacing = CGSizeMake(2, 2);
    self.browserView.cellSize = CGSizeMake(54, 54);
    [self.browserView setValue:[NSColor controlBackgroundColor] forKey:IKImageBrowserBackgroundColorKey];

    [self.browserView setAllowsDroppingOnItems:YES];
    [self.browserView registerForDraggedTypes:[PCResourceManager allowedMediaFileExtensions]];
    
    // Title font
    NSMutableDictionary* attr = [NSMutableDictionary dictionary];
    [attr setObject:[NSFont systemFontOfSize:10] forKey:NSFontAttributeName];
    [self.browserView setValue:attr forKey:IKImageBrowserCellsTitleAttributesKey];
    [self.browserView setValue:attr forKey:IKImageBrowserCellsHighlightedTitleAttributesKey];

    // Register with resource manager
    [[PCResourceManager sharedManager] addResourceObserver:self];
    
    self.imageResources = [[NSMutableArray alloc] init];
	self.allResources = [[NSMutableArray alloc] init];
    
    return self;
}

- (BOOL)acceptsFirstResponder {
    return YES;
}

- (BOOL)resignFirstResponder {
    [super resignFirstResponder];
    [self.browserView deselectAll];
    return YES;
}

- (void)searchResources:(NSString *)searchTerm {
	if ([searchTerm length] > 0) {
		NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"%K.lastPathComponent contains[cd] %@", @"filePath", searchTerm];
		self.imageResources = [[self.allResources filteredArrayUsingPredicate:searchPredicate] mutableCopy];
		
		[self.browserView reloadData];
	} else {
		[[PCResourceManager sharedManager] notifyResourceObserversResourceListUpdated];
	}
}

#pragma mark Image Browser Data Provider

- (id) imageBrowser:(IKImageBrowserView *) aBrowser itemAtIndex:(NSUInteger)index {

    PCResource *resource = self.imageResources[index];
	
	return resource;
}

- (NSUInteger) numberOfItemsInImageBrowser:(IKImageBrowserView *) aBrowser {
    return [self.imageResources count];
}

- (NSUInteger) imageBrowser:(IKImageBrowserView *) aBrowser writeItemsAtIndexes:(NSIndexSet *) itemIndexes toPasteboard:(NSPasteboard *)pasteboard
{
		
    [pasteboard clearContents];
    
    PCResource * item = self.imageResources[[itemIndexes firstIndex]];
    
    NSMutableArray* pbItems = [NSMutableArray array];
    [pbItems addObject:item];
    
    [pasteboard writeObjects:pbItems];
    
    return 1;
}

- (void)imageBrowserSelectionDidChange:(IKImageBrowserView *)aBrowser {
    NSIndexSet *selectionIndexes = [aBrowser selectionIndexes];

	if ([selectionIndexes count] > 0) {
        PCResource *firstSelectedObject = [self.imageResources objectsAtIndexes:selectionIndexes][0];
        [[[AppDelegate appDelegate] previewViewOwner] setPreviewFile:firstSelectedObject];
	}
    else {
        [[[AppDelegate appDelegate] previewViewOwner] setPreviewFile:nil];
    }

    [[self.browserView window] makeFirstResponder:self];
}

- (void)keyDown:(NSEvent *)theEvent {
    if ([theEvent modifierFlags] & NSDeleteFunctionKey) {
        [self interpretKeyEvents:@[theEvent]];
    } else {
        [super keyDown:theEvent];
    }
}

- (void)imageBrowser:(IKImageBrowserView *)aBrowser cellWasRightClickedAtIndex:(NSUInteger)index withEvent:(NSEvent *)event {
    NSMenu*  menu = [[NSMenu alloc] initWithTitle:@"menu"];
    [menu setAutoenablesItems:NO];

    NSMenuItem *item = [menu addItemWithTitle:[NSString stringWithFormat:@"Open in Preview"] action:@selector(openInPreview:) keyEquivalent:@""];
    [item setTarget:self];
    item = [menu addItemWithTitle:[NSString stringWithFormat:@"Show in Finder"] action:@selector(revealInFinder:) keyEquivalent:@""];
    [item setTarget:self];

    [NSMenu popUpContextMenu:menu withEvent:event forView:aBrowser];
}


- (void)deleteBackward:(id)sender {
    NSIndexSet *indexes = [self.browserView selectionIndexes];
    NSArray *resourcesToRemove = [self.imageResources objectsAtIndexes:indexes];

    if ([resourcesToRemove count] == 0) {
        return [super deleteBackward:sender];
    }

    for (PCResource *resource in resourcesToRemove) {
        if ([[PCResourceManager sharedManager] isResourceBeingUsed:resource]) {
            NSAlert *alert = [[NSAlert alloc] init];
            [alert addButtonWithTitle:@"Delete"];
            [alert addButtonWithTitle:@"Cancel"];
            [alert setMessageText:@"Delete this resource?"];
            [alert setInformativeText:@"This resource is currently being used. Deleted resources cannot be restored."];
            [alert setAlertStyle:NSWarningAlertStyle];

            if ([alert runModal] == NSAlertFirstButtonReturn) {
                [[AppDelegate appDelegate] clearResourceFromProject:resource];
                [[PCResourceManager sharedManager] removeResource:resource];
            }
        }
        else {
            [[AppDelegate appDelegate] clearResourceFromProject:resource];
            [[PCResourceManager sharedManager] removeResource:resource];
        }
    }
}

#pragma mark - Context Menu Actions

- (void)openInPreview:(id)sender {
    NSIndexSet *indexes = [self.browserView selectionIndexes];
    NSArray *resourcesToRemove = [self.imageResources objectsAtIndexes:indexes];
    if ([resourcesToRemove count] == 0) return;

    PCResource *selectedResource = resourcesToRemove[0];
    [[NSWorkspace sharedWorkspace] openFile:[selectedResource autoPath]];
}

- (void)revealInFinder:(id)sender {
    NSIndexSet *indexes = [self.browserView selectionIndexes];
    NSArray *resourcesToRemove = [self.imageResources objectsAtIndexes:indexes];
    if ([resourcesToRemove count] == 0) return;

    PCResource *selectedResource = resourcesToRemove[0];
    NSURL *resourceURL = [NSURL fileURLWithPath:[selectedResource autoPath]];
    [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[ resourceURL ]];
}

#pragma mark Callback from ResourceManager

- (void) resourceListUpdated
{
    self.imageResources = Underscore.array([[PCResourceManager sharedManager] allResources]).filter(^BOOL(PCResource *resource) {
        return ((resource.type == self.resourceTypeSelection) || self.resourceTypeSelection == PCResourceTypeNone) && [resource visibleToUser];
    }).unwrap;
    self.allResources = [self.imageResources copy];
    
    [self.browserView reloadData];
}

#pragma mark - NSSplitViewDelegate

- (CGFloat) splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex
{
    if (proposedMinimumPosition < 160) return 160;
    else return proposedMinimumPosition;
}

- (CGFloat) splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMaximumPosition ofSubviewAt:(NSInteger)dividerIndex
{
    float max = splitView.frame.size.height - 100;
    if (proposedMaximumPosition > max) return max;
    else return proposedMaximumPosition;
}

@end
