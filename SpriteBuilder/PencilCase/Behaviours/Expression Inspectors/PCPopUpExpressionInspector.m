//
//  PCPopUpExpressionInspector.m
//  Behaviours
//
//  Created by Cody Rayment on 2014-11-24.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import "PCPopUpExpressionInspector.h"
#import "PCExpressionTextView.h"

@interface PCPopUpExpressionInspector () <NSMenuDelegate>

@property (weak, nonatomic) IBOutlet NSPopUpButton *popUpButton;
@property (strong, nonatomic) id highlightedItem;
@property (assign, nonatomic) NSInteger selectedItemIndex;

@end

@implementation PCPopUpExpressionInspector

@synthesize saveHandler = _saveHandler;

- (NSView *)initialFirstResponder {
    return self.popUpButton;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self updateMenu];
}

- (IBAction)selectItem:(NSPopUpButton *)sender {
    self.selectedItem = self.items[[sender indexOfSelectedItem]];
}

#pragma mark - Properties

- (void)setItems:(NSArray *)items {
    _items = items;
    [self updateMenu];
}

- (void)setSelectedItem:(id)selectedItem {
    self.highlightedItem = nil;
    NSInteger index = [self.items indexOfObject:selectedItem];
    if (self.selectedItemIndex == index || index < 0 || index == NSNotFound) return;
    self.selectedItemIndex = index;
    [self updateSelectedValue];
}

- (id)selectedItem {
    NSInteger index = [self.popUpButton indexOfSelectedItem];
    if (index < 0 || index >= self.items.count) return nil;
    return self.items[[self.popUpButton indexOfSelectedItem]];
}

#pragma mark - Private

- (void)updateMenu {
    if (!self.popUpButton) return;

    [self.popUpButton removeAllItems];
    for (id item in self.items) {
        NSMenuItem *menuItem = [[NSMenuItem alloc] init];
        menuItem.attributedTitle = self.displayStringForItemHandler(item);
        [self.popUpButton.menu addItem:menuItem];
    }
    [self updateSelectedValue];
}

- (void)updateSelectedValue {
    NSInteger index = self.selectedItemIndex;
    if (index != NSNotFound && index > 0 && index < self.items.count) {
        if (index != self.popUpButton.indexOfSelectedItem) {
            [self.popUpButton selectItemAtIndex:index];
        }
    }
}

- (void)menu:(NSMenu *)menu willHighlightItem:(NSMenuItem *)menuItem {
    if (!self.highlightItemHandler) return;
    id item = [self itemForMenuItem:menuItem];
    if (item == self.highlightedItem) return;
    self.highlightedItem = item;
}

- (void)menuDidClose:(NSMenu *)menu {
    self.highlightedItem = nil;
}

- (id)itemForMenuItem:(NSMenuItem *)item {
    if (!item) return nil;
    NSInteger index = [self.popUpButton.menu indexOfItem:item];
    return self.items[index];
}

- (void)setHighlightedItem:(id)highlightedItem {
    if (_highlightedItem) self.highlightItemHandler(_highlightedItem, NO);
    _highlightedItem = highlightedItem;
    if (_highlightedItem) self.highlightItemHandler(_highlightedItem, YES);
}

@end
