//
//  InspectorPCTableCells.m
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-05-08.
//
//

#import "InspectorPCTableCells.h"
#import "PCTableCellInfo.h"
#import "InspectorPCTableCellInfo.h"
#import "AppDelegate.h"
#import <Underscore.m/Underscore.h>

NSString * const PCTableCellPasteboardType = @"com.robotsandpencils.PCTableCellPasteboardType";

@interface InspectorPCTableCells () <InspectorPCTableCellInfoDelegate, NSTableViewDataSource, NSTableViewDelegate>

@property (strong, nonatomic) NSClipView *clipView;
@property (strong, nonatomic) IBOutlet NSTableView *tableView;
@property (strong, nonatomic) NSArray *inspectors;
@property (copy, nonatomic) NSArray *cells;

@property (assign, nonatomic) CGFloat startHeight;

@end

@implementation InspectorPCTableCells

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.startHeight = self.view.frame.size.height;
    
    self.clipView = [[NSClipView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 1)];
    self.clipView.autoresizingMask = NSViewWidthSizable|NSViewHeightSizable|NSViewMinYMargin;
    self.clipView.documentView = self.tableView;
    [self.view addSubview:self.clipView];
    
    self.tableView.draggingDestinationFeedbackStyle = NSTableViewDraggingDestinationFeedbackStyleGap;
    [self.tableView registerForDraggedTypes:@[PCTableCellPasteboardType]];
    [self loadCells];
}

- (void)setPropertyForSelection:(id)value {
    [super setPropertyForSelection:value];
    [[NSNotificationCenter defaultCenter] postNotificationName:PCTableCellsChangedNotification object:self.selection];
}

- (void)refresh {
    self.cells = nil;
    [self loadCells];
}

#pragma mark - Actions

- (IBAction)showCellTypes:(NSView *)sender {
    NSMenu *menu = [[NSMenu alloc] initWithTitle:@""];
    for (NSDictionary *cellType in [PCTableCellInfo cellTypeDictionaries]) {
        NSMenuItem *item = [menu insertItemWithTitle:cellType[@"name"] action:@selector(addCell:) keyEquivalent:@"" atIndex:0];
        [item setTarget:self];
        [item setRepresentedObject:cellType];
    }
    [NSMenu popUpContextMenu:menu withEvent:[[NSApplication sharedApplication] currentEvent] forView:sender];
}

- (void)addCell:(NSMenuItem *)sender {
    NSDictionary *cellType = [sender representedObject];
    NSArray *cells = [[self cells] arrayByAddingObject:[[PCTableCellInfo alloc] initWithCellTypeName:cellType[@"name"]]];
    [self setPropertyForSelection:cells];
    [[AppDelegate appDelegate] updateInspectorFromSelection];
}

#pragma mark - Private

- (void)loadCells {
    //used as a stopgap for removing focus from the textfield cells.
    [self.view.window makeFirstResponder:nil];
    
    [self setHeight:self.startHeight];
    self.inspectors = Underscore.array([self cells]).map(^id(PCTableCellInfo *cellInfo) {
        InspectorPCTableCellInfo *cellInspector = [[InspectorPCTableCellInfo alloc] initWithCellInfo:cellInfo];
        cellInspector.delgate = self;
        [[NSBundle mainBundle] loadNibNamed:@"InspectorPCTableCellInfo" owner:cellInspector topLevelObjects:nil];
        NSInteger height = self.view.frame.size.height;
        height += cellInspector.view.frame.size.height + 2;
        [self setHeight:height];
        return cellInspector;
    }).unwrap;
    [self.tableView reloadData];
}

- (NSArray *)cells {
    if (!_cells) {
        _cells = [self propertyForSelection];
    }
    return _cells;
}

- (void)setHeight:(NSInteger)height {
    CGRect frame = self.view.frame;
    frame.size.height = height;
    self.view.frame = frame;
    self.clipView.frame = CGRectMake(0, 0, self.view.frame.size.width, height - self.startHeight);
}

#pragma mark - InspectorPCTableCellInfoDelegate

- (void)inspectorPCTableCellInfoDeleteCell:(InspectorPCTableCellInfo *)inspectorPCTableCellInfo {
    NSMutableArray *cells = [[self cells] mutableCopy];
    [cells removeObject:inspectorPCTableCellInfo.cellInfo];
    [self setPropertyForSelection:cells];
}

- (void)inspectorPCTableCellUpdatedCell:(InspectorPCTableCellInfo *)inspectorPCTableCellInfo {
    [self setPropertyForSelection:[self cells]];
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [[self inspectors] count];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    InspectorPCTableCellInfo *cellInspector = self.inspectors[row];
    return cellInspector.view;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    InspectorPCTableCellInfo *cellInspector = self.inspectors[row];
    return cellInspector.view.frame.size.height;
}

- (id<NSPasteboardWriting>)tableView:(NSTableView *)tableView pasteboardWriterForRow:(NSInteger)row {
    NSPasteboardItem *item = [[NSPasteboardItem alloc] init];
    [item setString:[@(row) stringValue] forType:PCTableCellPasteboardType];
    return item;
}

- (NSDragOperation)tableView:(NSTableView *)tableView validateDrop:(id<NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)dropOperation {
    if (dropOperation == NSTableViewDropOn) return NSDragOperationNone;
    return NSDragOperationMove;
}

- (BOOL)tableView:(NSTableView *)tableView acceptDrop:(id<NSDraggingInfo>)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)dropOperation {
    NSInteger originalRow = [[[info draggingPasteboard] stringForType:PCTableCellPasteboardType] integerValue];
    NSMutableArray *cells = [[self cells] mutableCopy];
    id object = cells[originalRow];
    [cells removeObjectAtIndex:originalRow];
    
    NSUInteger targetRow = row;
    if (targetRow > originalRow) targetRow -= 1;
    [cells insertObject:object atIndex:targetRow];
    
    [self setPropertyForSelection:[cells copy]];

    // Hard reload
    [[AppDelegate appDelegate] updateInspectorFromSelection];
    
    return YES;
}

#pragma mark - NSTableViewDelegate

@end
