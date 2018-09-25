//
//  PCTextSelectViewController.m
//  SpriteBuilder
//
//  Created by Brendan Duddridge on 2014-03-12.
//
//

#import "PCTextSelectViewController.h"
#import "PlugInNode.h"
#import "PlugInManager.h"
#import "AppDelegate.h"
#import "PCResourceManager.h"
#import "Constants.h"

@interface PCTextSelectViewController ()

@end

@implementation PCTextSelectViewController

- (void)loadView {
	[super loadView];
	
	[self.fontTableView reloadData];
}

#pragma mark - NSTableView delegate and data source

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [PCResourceManager sharedManager].supportedFonts.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSFont *font = [PCResourceManager sharedManager].supportedFonts[row];
	return font.familyName;
}

- (void)tableView:(NSTableView *)tableView willDisplayCell:(NSCell *)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSFont *font = [PCResourceManager sharedManager].supportedFonts[row];
	cell.font = font;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
	return 36;
}

#pragma mark - Drag & Drop

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    NSInteger selectedIndex = [self.fontTableView selectedRow];
    NSFont *draggedFont = [PCResourceManager sharedManager].supportedFonts[selectedIndex];
    
    AppDelegate *appDelegate = [AppDelegate appDelegate];
    NSDictionary *userInfo = @{@"defaultFont": draggedFont};

    [appDelegate dropAddPlugInNodeNamed:@"PCTextView" userInfo:userInfo];
    [appDelegate.selectedPopover performClose:nil];
}

- (BOOL)tableView:(NSTableView *)tableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard *)pboard {
	NSFont *draggedFont = [PCResourceManager sharedManager].supportedFonts[rowIndexes.firstIndex];

    [pboard declareTypes:@[ PCPasteboardTypeFont ] owner:self];
	
	NSData *fontData = [NSKeyedArchiver archivedDataWithRootObject:draggedFont];
    [pboard setData:fontData forType:PCPasteboardTypeFont];
	
	PlugInNode *textViewPlugIn = [[PlugInManager sharedManager] plugInNodeNamed:@"PCTextView"];
	if (draggedFont) {
		textViewPlugIn.nodePropertiesDict[@"defaultFont"] = draggedFont;
		[pboard writeObjects:@[textViewPlugIn]];
	}
	
	return YES;
}

- (void)dealloc {
	self.fontTableView.delegate = nil;
	self.fontTableView.dataSource = nil;
}

@end
