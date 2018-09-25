//
//  PCSlidesViewController.m
//  SpriteBuilder
//
//  Created by Orest Nazarewycz on 1/23/2014.
//
//

#import "PCSlidesViewController.h"
#import "PCSlideTableCellView.h"
#import "AppDelegate.h"
#import "PCUndoManager.h"

static NSString * const SlideDragType = @"com.robotsandpencils.PencilCase.PCSlide";
NSString * const PCSlidePasteboardType = @"PCSlidePasteboardType";
NSString * const PCSlideRawPasteboardType = @"PCSlideRawPasteboardType";

NSString * const PCSlideTableViewUpdatedNotification = @"PCSlideTableViewUpdatedNotification";

@interface PCSlidesViewController ()

@property (weak, nonatomic) IBOutlet NSTableView *pcSlideTableView;
@property (strong, nonatomic) IBOutlet NSArrayController *slideArrayController;

@property (weak, nonatomic) NSUndoManager *undoManager; // weak as we are using a shared undo manager

@end

@implementation PCSlidesViewController

#pragma mark - NSViewController

- (void)loadView {
    [super loadView];
    [self.pcSlideTableView setHeaderView:nil];
    self.pcSlideTableView.delegate = self;
    self.pcSlideTableView.dataSource = self;
    [self.pcSlideTableView registerForDraggedTypes:@[ SlideDragType ]];
    [self.pcSlideTableView setPostsFrameChangedNotifications:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateRowHeightForTableView:) name:NSViewFrameDidChangeNotification object:self.pcSlideTableView];
    [self.view addObserver:self forKeyPath:@"nextResponder" options:0 context:NULL];
    self.undoManager = [PCUndoManager sharedPCUndoManager];
    
    [[NSNotificationCenter defaultCenter] addObserver:[AppDelegate appDelegate] selector:@selector(selectCardsTabItemForUndo) name:PCSlideTableViewUpdatedNotification object:nil];
}

- (BOOL)acceptsFirstResponder {
    return NO;
}

- (void)keyDown:(NSEvent *)theEvent {
    if ([theEvent modifierFlags] & NSDeleteFunctionKey) {
        [self interpretKeyEvents:@[theEvent]];
    } else {
        [super keyDown:theEvent];
    }
}

- (void)deleteBackward:(id)sender {
    NSInteger selectedRow = [self selectedSlideIndex];
    if (selectedRow != -1) {
        PCSlide *slide = [self selectedSlide];
        [self deleteSlide:slide atIndex:selectedRow];
        return;
    }

    [super deleteBackward:sender];
}

- (void)dealloc {
    [self.view removeObserver:self forKeyPath:@"nextResponder"];
}

#pragma mark - Public

- (void)addSlide:(PCSlide *)slide {
    NSInteger selectedIndex = [self selectedSlideIndex];
    NSInteger insertionIndex = selectedIndex + 1;
    if (selectedIndex < 0) {
        insertionIndex = [[self.slideArrayController arrangedObjects] count] + 1;
    }
    [self addSlide:slide atIndex:insertionIndex];
}

- (void)selectSlideAtIndex:(NSInteger)index {
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:index];
    [self.pcSlideTableView selectRowIndexes:indexSet byExtendingSelection:NO];
}

- (void)selectSlideAtIndexNumber:(NSNumber *)index{    
    // nothing to do if the current selected row is the same as the new one
    if ([self.pcSlideTableView.selectedRowIndexes firstIndex] == [index integerValue]) return;
    
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:[index integerValue]];
    
    // set the selected row indexes and make sure to call the seleciton change manually
    // as it does not fire the notificaiton right away
    [self.pcSlideTableView selectRowIndexes:indexSet byExtendingSelection:NO];
    [self tableViewSelectionDidChange];
}

- (NSInteger)selectedSlideIndex {
    return [self.pcSlideTableView selectedRow];
}

- (void)deselectAll {
    [self.pcSlideTableView deselectAll:nil];
}

- (BOOL)isFirstResponder {
    return [self.view.window.firstResponder isEqual:self.pcSlideTableView];
}

#pragma mark - Actions

- (IBAction)contextMenuNewCard:(id)sender {
    [[AppDelegate appDelegate] createNewSlide];
}

- (IBAction)contextMenuDeleteCard:(id)sender {
    NSInteger index = 0;
    PCSlide *slide = [self clickedSlide:&index];
    if (slide) {
        [self deleteSlide:slide atIndex:index];
    }
}

- (IBAction)copy:(id)sender {
    [self copySlide];
}

- (IBAction)paste:(id)sender {
    if ([self pasteSlide]) return;
    [[AppDelegate appDelegate] paste];
}

- (IBAction)duplicate:(id)sender {
    [self duplicateSlide:[self selectedSlide]];
}

- (NSString *)uuidForSlideAtIndex:(NSInteger)index {
    PCSlide *slide = [[self.slideArrayController arrangedObjects] objectAtIndex:index];
    return slide.uuid;
}

#pragma mark - Private

- (void)duplicateSlide:(PCSlide *)slide {
    NSInteger index = [[self.slideArrayController arrangedObjects] indexOfObject:slide];
    if (index == NSNotFound) return;
    [[AppDelegate appDelegate] saveFile:[slide absoluteFilePath] withPreview:YES];
    PCSlide *dup = [slide duplicate];
    [self addSlide:dup atIndex:index+1];
}

- (PCSlide *)selectedSlide {
    return [[self.slideArrayController selectedObjects] firstObject];
}

// From Brandon: This looks weird. Is it that much slower to find the index in the arrangedObjects after if we need it instead of using an outvar?
- (PCSlide *)clickedSlide:(NSInteger *)outIndex {
    NSArray *slides = [self.slideArrayController arrangedObjects];
    NSInteger index = [self.pcSlideTableView clickedRow];
    if (index < 0 || index > [slides count]) {
        return nil;
    }
    if (outIndex) *outIndex = index;
    return slides[index];
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
    if (menuItem.action == @selector(duplicate:)) {
        return [self selectedSlide] != nil;
    }
    if (menuItem.action == @selector(contextMenuDeleteCard:)) {
        return [self clickedSlide:NULL] != nil;
    }
    return YES;
}

- (void)addSlide:(PCSlide *)slide atIndex:(NSInteger)index {
    index = MAX(0, index);
    index = MIN([[self.slideArrayController arrangedObjects] count], index);
    
    [[self.undoManager prepareWithInvocationTarget:self] deleteSlide:slide atIndex:index];

    if (!self.undoManager.isUndoing) {
        [self.undoManager setActionName:@"Add Slide"];
    }
    else {
        [[NSNotificationCenter defaultCenter] postNotificationName:PCSlideTableViewUpdatedNotification object:nil];
    }

    
    [self.slideArrayController insertObject:slide atArrangedObjectIndex:index];
    [self.slideArrayController setSelectionIndex:index];

    [[AppDelegate appDelegate] saveFile:[slide absoluteFilePath] withPreview:YES];
}

- (void)convertPasteboardToRawDataIfNecessaryForSlide:(PCSlide *)slide {
    NSString *absoluteFilePath = [slide absoluteFilePath];
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    
    NSString *type = [pasteboard availableTypeFromArray:@[ PCSlidePasteboardType ]];
    if (!type) return;
    
    NSData *data = [pasteboard dataForType:type];
    NSDictionary *info = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    if (!info || ![info isKindOfClass:[NSDictionary class]]) return;
        
    NSString *filePath = info[@"filePath"];
    if ([filePath caseInsensitiveCompare:absoluteFilePath] != NSOrderedSame) return;
    
    NSData *rawFileData = [NSData dataWithContentsOfFile:absoluteFilePath];
    if (!rawFileData) return;
    
    [pasteboard declareTypes:@[ PCSlideRawPasteboardType ] owner:self];
    [pasteboard setData:rawFileData forType:PCSlideRawPasteboardType];
}

- (void)removeSlideAtIndex:(NSInteger)index {
    if (index > [self.slideArrayController.arrangedObjects count] || index < 0) return;
    
    PCSlide *slide = self.slideArrayController.arrangedObjects[index];
    [self deleteSlide:slide atIndex:index];
}

- (void)deleteSlide:(PCSlide *)slide atIndex:(NSInteger)index {
    
    [[self.undoManager prepareWithInvocationTarget:self] addSlide:slide atIndex:index];
    
    if (!self.undoManager.isUndoing){
        [self.undoManager setActionName:@"Delete Slide"];
    }
    else {
        [[NSNotificationCenter defaultCenter] postNotificationName:PCSlideTableViewUpdatedNotification object:nil];
    }

    if ([[self.slideArrayController arrangedObjects] count] == 1) { [[AppDelegate appDelegate] createNewSlide];}
    
    [self convertPasteboardToRawDataIfNecessaryForSlide:slide];
    
    [slide deleteDocument];
    [self.slideArrayController removeObjectAtArrangedObjectIndex:index];
    NSInteger prev = MAX(index - 1, 0);
    if (prev < [[self.slideArrayController arrangedObjects] count]) {
        [self.slideArrayController setSelectionIndex:prev];
    }
    else {
        [[AppDelegate appDelegate] openDocument:nil parentDocument:nil];
    }
}

- (BOOL)copySlide {
    PCSlide *slide = [self selectedSlide];
    if (!slide) return NO;

    [[AppDelegate appDelegate] saveFile:[slide absoluteFilePath] withPreview:YES];

    NSData *slideData = [slide pasteboardData];
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    [pasteboard declareTypes:@[ PCSlidePasteboardType ] owner:self];
    [pasteboard setData:slideData forType:PCSlidePasteboardType];
    
    return YES;
}

- (BOOL)pasteSlide {
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    NSString *type = [pasteboard availableTypeFromArray:@[ PCSlidePasteboardType, PCSlideRawPasteboardType]];
    if (!type) return NO;

    NSData *data = [pasteboard dataForType:type];
    PCSlide *slide = nil;
    if ([type isEqualToString:PCSlidePasteboardType]) {
        slide = [PCSlide createFromPasteboardData:data];
    } else if ([type isEqualToString:PCSlideRawPasteboardType]) {
        slide = [PCSlide createFromRawData:data];
    }
    if (slide) {
        [self addSlide:slide atIndex:self.slideArrayController.selectionIndex+1];
    }
    return slide != nil;
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"nextResponder"]) {
        // When we get called due to setting next responder as ourselves we ignore it (could also unobserve right before and re-observe right after...)
        if ([self.view nextResponder] != self) {
            [self setNextResponder:[self.view nextResponder]];
            [self.view setNextResponder:self];
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - NSTableViewDelegate

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    PCSlideTableCellView *slideCell = [tableView makeViewWithIdentifier:@"SlideCell" owner:self];
    slideCell.slideIndex = row + 1;

    return slideCell;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    // TODO: remove these magic numbers
    static CGFloat ratio = 150.0 / 217.0;
    return CGRectGetWidth(self.pcSlideTableView.frame) * ratio;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    [self tableViewSelectionDidChange];
}

- (void)tableViewSelectionDidChange {
    [[NSNotificationCenter defaultCenter] postNotificationName:PCSlideTableViewUpdatedNotification object:nil];
    
    PCSlide *selectedSlide = [self selectedSlide];
    
    if (selectedSlide) {
        [[AppDelegate appDelegate] openDocument:selectedSlide.document parentDocument:nil];
    }
    [[self.pcSlideTableView window] makeFirstResponder:self.pcSlideTableView];
    
}

- (NSDragOperation)tableView:(NSTableView *)aTableView validateDrop:(id <NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)operation {
    NSDragOperation result = NSDragOperationNone;

    if (operation == NSTableViewDropAbove) {
        result = NSDragOperationMove;
    }

    return result;
}

- (BOOL)tableView:(NSTableView *)aTableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard *)pboard {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:rowIndexes];
    [pboard declareTypes:[NSArray arrayWithObject:SlideDragType] owner:self];
    [pboard setData:data forType:SlideDragType];

    return YES;
}

- (BOOL)tableView:(NSTableView *)aTableView acceptDrop:(id <NSDraggingInfo>)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)operation {
    NSPasteboard *pasteboard = [info draggingPasteboard];
    NSData *rowData = [pasteboard dataForType:SlideDragType];
    NSIndexSet *rowIndexes = [NSKeyedUnarchiver unarchiveObjectWithData:rowData];
    NSUInteger startRow = [rowIndexes firstIndex];
    PCSlide *slide = [self.slideArrayController arrangedObjects][startRow];

    [self.pcSlideTableView beginUpdates];
    [self.slideArrayController removeObjectAtArrangedObjectIndex:startRow];
    // Subtracting 1 if we're removing an object before where it'll end up
    NSUInteger targetRow = row;
    if (targetRow > startRow && operation == NSTableViewDropAbove) {
        targetRow -= 1;
    }
    [self.slideArrayController insertObject:slide atArrangedObjectIndex:targetRow];
    [self.pcSlideTableView endUpdates];

    return YES;
}

#pragma mark - NSViewFrameDidChangeNotification

- (void)updateRowHeightForTableView:(NSNotification *)notification {
    NSTableView *tableView = (NSTableView *)notification.object;

    NSRange visibleRows = [tableView rowsInRect:tableView.bounds];
    NSIndexSet *allRows = [NSIndexSet indexSetWithIndexesInRange:visibleRows];
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:0];
    [tableView noteHeightOfRowsWithIndexesChanged:allRows];
    [NSAnimationContext endGrouping];
}

@end
