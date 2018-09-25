//
//  PCSuppliesTableView.m
//  SpriteBuilder
//
//  Created by Orest Nazarewycz on 2014-06-12.
//
//

#import "PCSuppliesTableViewController.h"
#import "PCSuppliesTableCellView.h"
#import "AppDelegate.h"
#import "PlugInManager.h"
#import "PlugInNode.h"

@interface PCSuppliesTableViewController() <NSTableViewDelegate, NSTableViewDataSource>

@property (strong, nonatomic) IBOutlet NSTableView *suppliesListTableView;

@end


@implementation PCSuppliesTableViewController

- (void)loadView {
    [super loadView];
    self.suppliesListTableView.delegate = self;
    self.suppliesListTableView.dataSource = self;
    self.suppliesListTableView.target = self;
    [self.suppliesListTableView setDoubleAction:@selector(doubleClick:)];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
    return [PlugInManager sharedManager].plugInsNodeNames.count;
}

- (void)keyDown:(NSEvent *)event {
    unichar key = [[event charactersIgnoringModifiers] characterAtIndex:0];
    if(key == NSEnterCharacter || key == NSCarriageReturnCharacter ) {
        NSString *selectedSupply = [[PlugInManager sharedManager].plugInsNodeNames objectAtIndex:self.suppliesListTableView.selectedRow];
        [[AppDelegate appDelegate] dropAddPlugInNodeNamed:selectedSupply userInfo:nil];
    }
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    PCSuppliesTableCellView *cell = [tableView makeViewWithIdentifier:@"supplyCell" owner:self];
    NSString *nodeKey = [[PlugInManager sharedManager].plugInsNodeNames objectAtIndex:row];
    PlugInNode *supply = [[PlugInManager sharedManager] plugInNodeNamed:nodeKey];
    cell.textField.stringValue = supply.displayName;
    cell.descriptionLabel.stringValue = supply.descr;
    cell.imageView.image = supply.icon;
    return cell;
}

- (void)doubleClick:(id)sender {
    NSString *selectedSupply = [[PlugInManager sharedManager].plugInsNodeNames objectAtIndex:self.suppliesListTableView.selectedRow];
    [[AppDelegate appDelegate] dropAddPlugInNodeNamed:selectedSupply userInfo:nil];
    [self.suppliesListTableView deselectRow:self.suppliesListTableView.selectedRow];
}

- (BOOL)tableView:(NSTableView *)tableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard*)pboard {
    [pboard clearContents];
    NSString *nodeKey = [[PlugInManager sharedManager].plugInsNodeNames objectAtIndex:rowIndexes.firstIndex];
    PlugInNode *supply = [[PlugInManager sharedManager] plugInNodeNamed:nodeKey];
    NSDictionary *dict = @{@"nodeClassName":supply.nodeClassName};
    return [pboard setPropertyList:dict forType:PCPasteboardTypePluginNode];
}

@end
