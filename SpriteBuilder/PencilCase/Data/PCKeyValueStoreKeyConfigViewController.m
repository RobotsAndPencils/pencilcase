//
//  PCKeyValueStoreKeyConfigViewController.m
//  SpriteBuilder
//
//  Created by Brandon Evans on 2015-04-02.
//
//

#import "PCKeyValueStoreKeyConfigViewController.h"

@interface PCKeyValueStoreKeyConfigViewController () <NSTableViewDataSource, NSTableViewDelegate, NSControlTextEditingDelegate>

@property (nonatomic, weak) IBOutlet NSTableView *tableView;

@end

@implementation PCKeyValueStoreKeyConfigViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView reloadData];
}

- (IBAction)dismissView:(id)sender {
    [self.view.window.sheetParent endSheet:self.view.window];
}

- (void)keyDown:(NSEvent *)theEvent {
    unichar key = [[theEvent charactersIgnoringModifiers] characterAtIndex:0];
    if (key == NSDeleteCharacter) {
        if (self.tableView.selectedRow == -1) {
            NSBeep();
        }

        [self removeSelectedConfigs:self];
        return;
    }

    [super keyDown:theEvent];
}

#pragma mark - Configs

- (IBAction)addConfig:(id)sender {
    PCKeyValueStoreKeyConfig *config = [[PCKeyValueStoreKeyConfig alloc] initWithKey:@"key" keyUniquenessTest:^BOOL(PCKeyValueStoreKeyConfig *eachConfig) {
        return ![self.store configExistsWithKey:eachConfig.key collectionName:eachConfig.collectionName];
    }];
    config.type = (PCKeyValueStoreKeyType)[[Constants userSelectableKeyTypes].firstObject integerValue];

    [self.store addConfig:config];
    [self.tableView reloadData];
}

- (IBAction)removeSelectedConfigs:(id)sender {
    NSIndexSet *selectedIndices = self.tableView.selectedRowIndexes;
    NSArray *removedConfigs = [self.store.configs objectsAtIndexes:selectedIndices];

    [self.store removeConfigs:removedConfigs];
    [self.tableView reloadData];
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.store.configs.count;
}

#pragma mark - NSTableViewDelegate

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if (row < 0 || self.store.configs.count <= row) {
        return nil;
    }

    PCKeyValueStoreKeyConfig *config = self.store.configs[row];

    NSTableCellView *result = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    if ([tableColumn.identifier isEqualToString:@"keyColumn"]) {
        result.textField.stringValue = config.key ?: @"";
    }
    else if ([tableColumn.identifier isEqualToString:@"collectionColumn"]) {
        result.textField.stringValue = config.collectionName ?: @"";
    }

    else if ([tableColumn.identifier isEqualToString:@"typeColumn"]) {
        result.objectValue = [Constants stringForKeyType:config.type] ?: @"None";

        NSPopUpButton *popUpButton = result.subviews.firstObject;
        popUpButton.target = self;
        popUpButton.action = @selector(commitSelectedType:);

        [popUpButton removeAllItems];
        NSArray *titles = Underscore.arrayMap([Constants userSelectableKeyTypes], ^NSString *(NSNumber *keyTypeNumber) {
            return [Constants stringForKeyType:(PCKeyValueStoreKeyType)keyTypeNumber.integerValue];
        });
        [popUpButton addItemsWithTitles:titles];

        NSUInteger indexOfType = Underscore.indexOf([Constants userSelectableKeyTypes], @(config.type));
        if (indexOfType == NSNotFound || indexOfType >= popUpButton.itemArray.count) {
            indexOfType = 0;
        }
        [popUpButton selectItemAtIndex:indexOfType];
    }

    return result;
}

#pragma mark - NSControlTextEditingDelegate

- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor {
    NSInteger row = [self.tableView rowForView:control];
    NSTextField *textField = (NSTextField *)control;

    if (row < 0 || self.store.configs.count <= row) {
        return NO;
    }

    PCKeyValueStoreKeyConfig *config = self.store.configs[row];

    NSString *key = config.key;
    NSString *collectionName = config.collectionName;
    if ([textField.identifier isEqualToString:@"key"]) {
        key = textField.stringValue;
    }
    else if ([textField.identifier isEqualToString:@"collection"]) {
        collectionName = textField.stringValue;
    }

    return ![self.store configExistsWithKey:key collectionName:collectionName];
}

#pragma mark - Actions

- (IBAction)endEditingText:(id)sender {
    NSInteger row = [self.tableView rowForView:sender];
    NSTextField *textField = (NSTextField *)sender;

    if (row < 0 || self.store.configs.count <= row) {
        return;
    }

    PCKeyValueStoreKeyConfig *config = self.store.configs[row];
    PCKeyValueStoreKeyConfig *oldConfig = [config copy];

    if ([textField.identifier isEqualToString:@"key"]) {
        config.key = textField.stringValue;
    }
    else if ([textField.identifier isEqualToString:@"collection"]) {
        config.collectionName = textField.stringValue;
    }

    PCKeyValueStoreKeyConfig *newConfig = [config copy];
    [self postConfigChangeNotification:newConfig oldConfig:oldConfig];
}

- (IBAction)commitSelectedType:(id)sender {
    NSInteger row = [self.tableView rowForView:sender];
    NSPopUpButton *popupButton = (NSPopUpButton *)sender;

    if (row < 0 || self.store.configs.count <= row) {
        return;
    }

    PCKeyValueStoreKeyConfig *config = self.store.configs[row];
    PCKeyValueStoreKeyConfig *oldConfig = [config copy];

    NSArray *types = [Constants userSelectableKeyTypes];
    NSInteger selectedIndex = [popupButton indexOfSelectedItem];
    NSNumber *selectedTypeNumber = types[selectedIndex];
    PCKeyValueStoreKeyType keyType = (PCKeyValueStoreKeyType)selectedTypeNumber.integerValue;
    config.type = keyType;

    PCKeyValueStoreKeyConfig *newConfig = [config copy];
    [self postConfigChangeNotification:newConfig oldConfig:oldConfig];
}

#pragma mark - Helpers

- (void)postConfigChangeNotification:(PCKeyValueStoreKeyConfig *)config oldConfig:(PCKeyValueStoreKeyConfig *)oldConfig {
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    if (oldConfig) {
        info[@"old"] = oldConfig;
    }
    if (config) {
        info[@"new"] = config;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:PCKeyValueStoreKeyConfigChangedNotification object:[info copy]];
}

@end
