/*
 * CocosBuilder: http://www.cocosbuilder.com
 *
 * Copyright (c) 2012 Zynga Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

// Header
#import "ResourceManagerOutlineHandler.h"

// System
#import <QuickLook/QuickLook.h>

// 3rd Party
#import <Underscore.m/Underscore.h>

// Project
#import "ImageAndTextCell.h"
#import "ResourceManagerUtil.h"
#import "AppDelegate.h"
#import "ResourceManagerPreviewView.h"
#import "NSPasteboard+CCB.h"
#import "PCWarningGroup.h"
#import "PCProjectSettings.h"
#import "PCResource.h"


@interface ResourceManagerOutlineHandler()

@property (nonatomic, strong) NSMutableArray *filteredResources;

@end


@implementation ResourceManagerOutlineHandler

- (void) reload
{
    [self.resourceList reloadData];
}

- (id) initWithOutlineView:(NSOutlineView *)outlineView resType:(enum PCResourceType)rt
{
    return [self initWithOutlineView:outlineView resType:rt preview:NULL];
}

- (id) initWithOutlineView:(NSOutlineView*)outlineView resType:(enum PCResourceType)rt preview:(ResourceManagerPreviewView*)p
{
    self = [super init];
    if (!self) return NULL;
    
    resManager = [PCResourceManager sharedManager];
    [resManager addResourceObserver:self];
    
    self.resourceList = outlineView;
    self.imagePreview = p;
    //lblNoPreview = [lbl retain];
    self.resType = rt;
    
    ImageAndTextCell* imageTextCell = [[ImageAndTextCell alloc] init];
    [imageTextCell setEditable:YES];
    [[self.resourceList outlineTableColumn] setDataCell:imageTextCell];
    [[self.resourceList outlineTableColumn] setEditable:YES];
    
    [self.resourceList setDataSource:self];
    [self.resourceList setDelegate:self];
    [self.resourceList setTarget:self];
    [self.resourceList setDoubleAction:@selector(doubleClicked:)];

    [outlineView registerForDraggedTypes:@[ PCPasteboardTypeResource, NSFilenamesPboardType ]];
    
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleDroppedFile:)
												 name:PCDroppedFileNotification
											   object:nil];	
    return self;
}

- (void)handleDroppedFile:(NSNotification *)notification {
	[self.progressIndicator setHidden:NO];
	[self.progressIndicator startAnimation:self];
    [[AppDelegate appDelegate] reloadResources];
}

- (IBAction)searchAction:(id)sender {
	NSString *searchTerm = [sender stringValue];
	
	if ([searchTerm length] > 0) {
		NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"%K.lastPathComponent contains[cd] %@", @"filePath", searchTerm];
		NSArray *allResources = [PCResourceManager sharedManager].allResources;
		self.filteredResources = [[allResources filteredArrayUsingPredicate:searchPredicate] mutableCopy];
		
		[self.resourceList reloadData];
		
	} else {
		self.filteredResources = nil;
		[[PCResourceManager sharedManager] notifyResourceObserversResourceListUpdated];
	}
	
}

#pragma mark - NSOutlineViewDataSource

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    // If we're filtering, just return the number of filtered resources.
    if ([self.filteredResources count] > 0) {
        return [self.filteredResources count];
    }

    // Do not display directories if only one directory is used
    if (!item) {
        item = resManager.rootResourceDirectory;
    }

    // Handle base nodes
    if (!item) return 0;

    // Fetch the data object of directory resources and use it as the item object
    if ([item isKindOfClass:[PCResource class]]) {
        PCResource *res = item;
        if (res.type == PCResourceTypeDirectory) {
            item = res.data;
        }
    }

    // Handle different nodes
    if ([item isKindOfClass:[PCResourceDirectory class]]) {
        PCResourceDirectory *dir = item;

        NSArray *children = Underscore.filter([dir any], ^BOOL(PCResource *resource) {
            return ((resource.type == self.resType) || self.resType == PCResourceTypeNone) && [resource visibleToUser];
        });

        return [children count];
    }

    return 0;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    // we're filtering from the search field, so we'll only be displaying the
    // filtered results with no hierarchy

    if (self.filteredResources.count > 0) {
        return self.filteredResources[index];
    }

    // Do not display directories if only one directory is used
    if (!item) {
        item = resManager.rootResourceDirectory;
    }

    // Fetch the data object of directory resources and use it as the item object
    if ([item isKindOfClass:[PCResource class]]) {
        PCResource *res = item;
        if (res.type == PCResourceTypeDirectory) {
            item = res.data;
        }
    }

    // Return children for different nodes
    if ([item isKindOfClass:[PCResourceDirectory class]]) {
        PCResourceDirectory *dir = item;
        NSArray *children = Underscore.filter([dir any], ^BOOL(PCResource *resource) {
            return ((resource.type == self.resType) || self.resType == PCResourceTypeNone) && [resource visibleToUser];
        });

        return children[index];
    }

    return nil;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
	// we don't display the expansion arrow if we're filtering.
	
	if ([self.filteredResources count] > 0) {
		return NO;
	}
	
    // Do not display directories if only one directory is used
    if (!item) {
        item = resManager.rootResourceDirectory;
    }
    
    if ([item isKindOfClass:[PCResourceDirectory class]])
    {
        return YES;
    }
    else if ([item isKindOfClass:[PCResource class]])
    {
        PCResource * res = item;
        if (res.type == PCResourceTypeDirectory) return YES;
    }
    
    return NO;
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
    PCResource *resource = item;
    if (resource.type == PCResourceTypeDirectory) {
        PCResourceDirectory *directory = item;
        return [directory.directoryPath lastPathComponent];
    }
    else if ([resource isKindOfClass:[PCResource class]]) {
        return [resource.filePath lastPathComponent];
    }
    return nil;
}

- (void)outlineView:(NSOutlineView *)outlineView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
    if ([item isKindOfClass:[PCResource class]]) {
        PCResource *resource = item;
        if (!resource.filePath) return;

        NSString *oldPath = resource.filePath;
        NSString *oldExt = [[oldPath pathExtension] lowercaseString];

        NSString *newName = object;
        NSString *newExt = [[newName pathExtension] lowercaseString];

        // Make sure we have a valid extension
        if (resource.type != PCResourceTypeDirectory && !PCIsEmpty(oldExt) && ![oldExt isEqualTo:newExt]) {
            newName = [newName stringByAppendingPathExtension:oldExt];
        }

        // Make sure that the name is a valid file name
        newName = [newName stringByReplacingOccurrencesOfString:@"/" withString:@""];

        if (!PCIsEmpty(newName)) {
            // Rename the file
            [[PCResourceManager sharedManager] renameResourceFile:oldPath toNewName:newName];
        }
    }

    [self.resourceList deselectAll:nil];
}

#pragma mark - NSOutlineViewDelegate

- (void)outlineView:(NSOutlineView *)outlineView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
    AppDelegate* ad = [AppDelegate appDelegate];
    PCProjectSettings * settings = ad.currentProjectSettings;
	[cell setTruncatesLastVisibleLine:YES];
	[cell setLineBreakMode:NSLineBreakByTruncatingMiddle];
	
    NSImage* icon = NULL;
    NSImage* warningIcon = NULL;
    
    if ([item isKindOfClass:[PCResource class]])
    {
        PCResource *resource = item;
        switch (resource.type) {
            case PCResourceTypeImage:
                icon = [self smallIconForFileType:@"png"];
                break;
            case PCResourceTypeBMFont:
                icon = [self smallIconForFileType:@"ttf"];
                break;
            default:
                icon = [self smallIconForFile:resource.filePath];
                break;
        }
        // Add warning sign if there is a warning related to this file
        if ([settings.lastWarnings warningsForRelatedFile:resource.relativePath])
        {
            warningIcon = [NSImage imageNamed:@"editor-warning.png"];
        }
    }
    [cell setImage:icon];
    [cell setImageAlt:warningIcon];
}

#pragma mark -

- (NSImage *)smallIconForFile:(NSString *)file {
    NSImage *icon = [[NSWorkspace sharedWorkspace] iconForFile:file];
    icon.size = NSMakeSize(16, 16);
    return icon;
}

- (NSImage *)smallIconForFileType:(NSString *)type {
    NSImage *icon = [[NSWorkspace sharedWorkspace] iconForFileType:type];
    icon.size = NSMakeSize(16, 16);
    return icon;
}

#pragma mark - Dragging and dropping

- (NSImage *)dragImageForSelectedRow:(NSIndexSet *)dragRows {
	NSImage *dragImage = nil;
	
	if ([dragRows count] > 1) {
		NSMutableArray *resources = [NSMutableArray array];
		
		[dragRows enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
			id resource = [self.resourceList itemAtRow:dragRows.firstIndex];
			
			if ([resource isKindOfClass:[PCResource class]]) {
				PCResource *fileResource = (PCResource *)resource;
				[resources addObject:fileResource.filePath];
			}
			
		}];
		
		// copying because NSImage imageNamed caches the image and we want
		// to draw our badge on a copy, not the original. Otherwise we'd get
		// the badge drawn multiple times for different dragRows counts.
		dragImage = [[NSImage imageNamed:@"Photos" ] copy];
		
		NSDictionary *attributes = @{NSFontAttributeName : [NSFont userFontOfSize:11],
									 NSForegroundColorAttributeName : [NSColor whiteColor]};
		
		NSInteger numberOfItems = dragRows.count;
		NSInteger strokeWidth = 1;
		
		NSAttributedString *numbers = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%lu",numberOfItems] attributes:attributes];
		[dragImage lockFocus];
		
		NSRect numbersSurroundRect = NSMakeRect(1, dragImage.size.height - 15, MAX(numbers.size.width + 5, 14), 14);
		
		NSShadow *shadow = [[NSShadow alloc] init];
		shadow.shadowBlurRadius = 2;
		shadow.shadowOffset = NSMakeSize(1, -1);
		shadow.shadowColor = [NSColor colorWithCalibratedWhite:0.000 alpha:0.300];
		[shadow set];
		
		NSBezierPath *circle = [NSBezierPath bezierPathWithRoundedRect:numbersSurroundRect xRadius:8.0 yRadius:8.0];
		[[NSColor colorWithCalibratedRed:0.800 green:0.000 blue:0.000 alpha:1.000] set];
		[circle fill];
		[[NSColor whiteColor] set];
		[circle setLineWidth:strokeWidth];
		[circle stroke];

		numbersSurroundRect.origin.x = (numbersSurroundRect.size.width / 2) - (numbers.size.width / 2) + 1;
		numbersSurroundRect.origin.y = dragImage.size.height - 15;
		[numbers drawInRect:numbersSurroundRect];
		[dragImage unlockFocus];
		
		
	} else {
		id resource = [self.resourceList itemAtRow:dragRows.firstIndex];
		
		if ([resource isKindOfClass:[PCResource class]]) {
			PCResource *fileResource = (PCResource *)resource;
			//		image = [[NSWorkspace sharedWorkspace] iconForFile:fileResource.filePath];
			
			NSURL *fileURL = [NSURL fileURLWithPath:fileResource.filePath];
			
			NSDictionary *quickLookOptions = [[NSDictionary alloc] initWithObjectsAndKeys:
											  (id)kCFBooleanTrue, (id)kQLThumbnailOptionScaleFactorKey,
											  nil];
			
			CGImageRef quickLookIcon = QLThumbnailImageCreate(NULL, (__bridge CFURLRef)fileURL, CGSizeMake(64, 64), (__bridge CFDictionaryRef)quickLookOptions);
			if (quickLookIcon != NULL) {
				dragImage = [[NSImage alloc] initWithCGImage:quickLookIcon size:NSZeroSize];
				
				CFRelease(quickLookIcon);
			}
			
			
		}
	}
	
	return dragImage;
}

- (BOOL) outlineView:(NSOutlineView *)outlineView writeItems:(NSArray *)items toPasteboard:(NSPasteboard *)pasteboard
{
    [pasteboard clearContents];
    
    NSMutableArray* pbItems = [NSMutableArray array];
    
    for (id item in items)
    {
        if ([item isKindOfClass:[PCResource class]])
        {
            [pbItems addObject:item];
        }
    }
    
    if ([pbItems count] > 0)
    {
        [pasteboard writeObjects:pbItems];
        return YES;
    }
    
    return NO;
}

- (NSDragOperation)outlineView:(NSOutlineView *)outlineView validateDrop:(id<NSDraggingInfo>)info proposedItem:(id)item proposedChildIndex:(NSInteger)index
{
    if (!item) return NSDragOperationGeneric;
    if (![item isKindOfClass:[PCResource class]] || ![PCResourceManager sharedManager].rootResourceDirectory) return NSDragOperationNone;

    PCResource *resource = item;
    return (resource.type == PCResourceTypeDirectory) ? NSDragOperationGeneric : NSDragOperationNone;
}

- (BOOL) outlineView:(NSOutlineView *)outlineView acceptDrop:(id<NSDraggingInfo>)info item:(id)item childIndex:(NSInteger)index
{
    if (!item && ![PCResourceManager sharedManager].rootResourceDirectory) return NO;
    
    // Get dropped items
    NSPasteboard *pasteBoard = [info draggingPasteboard];
    
    // Find out the destination directory
    NSString *destinationDirectoryPath = nil;
    if ([item isKindOfClass:[PCResource class]]) {
        PCResource *resource = item;
        destinationDirectoryPath = resource.filePath;
    } else if ([item isKindOfClass:[PCResourceDirectory class]]) {
        PCResourceDirectory *directory = item;
        destinationDirectoryPath = directory.directoryPath;
    } else if (!item) {
        PCResourceDirectory * directory = [PCResourceManager sharedManager].rootResourceDirectory;
        destinationDirectoryPath = directory.directoryPath;
    }
    
    BOOL movedFile = NO;
    
    // Move files
    NSArray* pasteBoardResources = [pasteBoard propertyListsForType:PCPasteboardTypeResource];
    for (NSDictionary *resourceDictionary in pasteBoardResources) {
        NSString *sourcePath = resourceDictionary[@"filePath"];
        NSInteger type = [resourceDictionary[@"type"] intValue];

        movedFile |= [[PCResourceManager sharedManager] moveResourceFile:sourcePath ofType:type toDirectory:destinationDirectoryPath];
    }
    
	
    // Import files
	
	BOOL importedFile = NO;

    [[NSNotificationCenter defaultCenter] postNotificationName:PCDroppedFileNotification object:nil];

    NSArray *pasteBoardFilenames = [pasteBoard propertyListForType:NSFilenamesPboardType];
    importedFile = [[PCResourceManager sharedManager] importResourcesAtAbsolutePaths:pasteBoardFilenames intoDirectoryAtAbsolutePath:destinationDirectoryPath appendSuffixIfFileExists:NO];
    [[PCResourceManager sharedManager] notifyResourceObserversResourceListUpdated];

    if (movedFile) {
        [self.resourceList deselectAll:nil];
    }
    
    return importedFile || movedFile;
}

#pragma mark Selections and edit

- (void) outlineViewSelectionDidChange:(NSNotification *)notification
{
    [self updateSelectionPreview];
}

- (void) updateSelectionPreview
{
    id selection = [self.resourceList itemAtRow:[self.resourceList selectedRow]];
    [self.imagePreview setPreviewFile:selection];
    [self.resourceList setNeedsDisplay];
}

- (void) doubleClicked:(id)sender {
    id item = [self.resourceList itemAtRow:[self.resourceList clickedRow]];
    
    if ([item isKindOfClass:[PCResource class]]) {
        PCResource * res = (PCResource *) item;

        AppDelegate *appDelegate = [AppDelegate appDelegate];
        switch (res.type) {
            case PCResourceTypeImage:
                [appDelegate dropAddSpriteWithUUID:res.uuid];
                break;
            case PCResourceTypeVideo:
                [appDelegate dropAddVideoWithFile:res.relativePath];
                break;
            case PCResourceType3DModel:
                [appDelegate dropAdd3DModelWithFile:res.relativePath];
                break;
            default:
                break;
        }
    }
}

- (BOOL) outlineView:(NSOutlineView *)outlineView shouldEditTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
    if (!item) return NO;
    if ([item isKindOfClass:[PCResource class]])
    {
        return YES;
    }
    return NO;
}

- (void)resourceListUpdated
{
    [self.resourceList reloadData];
	[self.progressIndicator stopAnimation:self];
	[self.progressIndicator setHidden:YES];
}

- (void)setResType:(enum PCResourceType)resourceType
{
    _resType = resourceType;
    [self.resourceList reloadData];
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
