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

#import "ResourceManagerOutlineView.h"
#import "AppDelegate.h"
#import "PCResourceManager.h"
#import "ResourceManagerUtil.h"
#import "ResourceManagerOutlineHandler.h"
#import "PCResourceDirectory.h"

@implementation ResourceManagerOutlineView

- (NSMenu *)menuForEvent:(NSEvent *)theEvent {
    NSPoint point = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    int row = [self rowAtPoint:point];
    
    id clickedItem = [self itemAtRow:row];
    
    NSMenu *menu = [AppDelegate appDelegate].menuContextResManager;
    menu.autoenablesItems = NO;
    NSArray *items = menu.itemArray;
    for (NSMenuItem *item in items) {
        if (item.action == @selector(menuActionDelete:)) {
            item.tag = row;
            item.title = @"Delete";
            item.enabled = NO;
            
            if ([clickedItem isKindOfClass:[PCResource class]]) {
                PCResource *selectedResource = (PCResource *)clickedItem;
                if ([[selectedResource.filePath lastPathComponent] isEqualToString:@"resources"]) {
                    item.enabled = NO;
                } else {
                    item.enabled = YES;
                }
            }
        } else if (item.action == @selector(menuActionNewFolder:)) {
            item.title = @"New Folder";
            item.tag = row;
        }
    }
    // TODO: Update menu
    return menu;
}

- (void)deleteSelectedResource {
    if(self.selectedRow == -1) {
        NSBeep();
        return;
    }

    [self abortEditing];

    // Confirm remove of items
    NSAlert* alert = [NSAlert alertWithMessageText:@"Are you sure you want to delete the selected files?" defaultButton:@"Cancel" alternateButton:@"Delete" otherButton:NULL informativeTextWithFormat:@"You cannot undo this operation."];
    NSInteger result = [alert runModal];
    
    if (result == NSAlertDefaultReturn) {
        return;
    }
    
    // Iterate through rows
    NSIndexSet *selectedRows = self.selectedRowIndexes;
    NSUInteger row = [selectedRows firstIndex];
    
    NSMutableArray *resourcesToDelete = [[NSMutableArray alloc] init];
    
    while (row != NSNotFound) {
        id selectedItem = [self itemAtRow:row];
        if ([selectedItem isKindOfClass:[PCResource class]]) {
            [resourcesToDelete addObject:selectedItem];
        }
        
        row = [selectedRows indexGreaterThanIndex:row];
    }

    for (PCResource *resource in resourcesToDelete) {
        [[PCResourceManager sharedManager] removeResource:resource];
    }
    
    [self deselectAll:nil];
}

- (void) keyDown:(NSEvent *)theEvent
{
    unichar key = [[theEvent charactersIgnoringModifiers] characterAtIndex:0];
    if(key == NSDeleteCharacter)
    {
        
        [self deleteSelectedResource];
        return;
    }
    
    [super keyDown:theEvent];
}

- (NSImage *)dragImageForRowsWithIndexes:(NSIndexSet *)dragRows tableColumns:(NSArray *)tableColumns event:(NSEvent *)dragEvent offset:(NSPointPointer)dragImageOffset {
	
	NSImage *dragImage = nil;
	
	if ([self.delegate respondsToSelector:@selector(dragImageForSelectedRow:)]) {
		dragImage = [self.delegate performSelector:@selector(dragImageForSelectedRow:) withObject:dragRows];
	}
	
	if (!dragImage) {
		dragImage = [super dragImageForRowsWithIndexes:dragRows
										  tableColumns:tableColumns
												 event:dragEvent
												offset:dragImageOffset];
	}
		
	return dragImage;
}

- (PCResourceDirectory *)selectedResourceDirectory {
    PCResourceDirectory *result = [PCResourceManager sharedManager].rootResourceDirectory;

    if(self.selectedRowIndexes.count != 1) {
        return result;
    }

    NSIndexSet *selectedRows = self.selectedRowIndexes;
    NSUInteger row = [selectedRows firstIndex];

    if (row != NSNotFound) {
        id selectedItem = [self itemAtRow:row];
        if ([selectedItem isKindOfClass:[PCResource class]]) {
            PCResource *resource = selectedItem;
            result = [[PCResourceManager sharedManager] resourceDirectoryForPath:resource.directoryPath];
        }
    }

    return result;
}

@end
