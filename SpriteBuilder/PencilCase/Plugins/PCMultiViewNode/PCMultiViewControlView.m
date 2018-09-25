
//
//  PCMultiViewControlView.m
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-06-18.
//
//

#import "PCMultiViewControlView.h"

@interface PCMultiViewControlView ()

@property (weak) IBOutlet NSTextField *infoTextField;

@end

@implementation PCMultiViewControlView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.layer.backgroundColor = [NSColor lightGrayColor].CGColor;
    self.layer.cornerRadius = 10;
}

+ (instancetype)create {
    NSArray *topLevelObjects = nil;
    [[NSBundle bundleForClass:self] loadNibNamed:NSStringFromClass(self) owner:nil topLevelObjects:&topLevelObjects];
    PCMultiViewControlView *view = [[topLevelObjects filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return [evaluatedObject isKindOfClass:[PCMultiViewControlView class]];
    }]] firstObject];
    return view;
}

#pragma mark - Actions

- (IBAction)previousCell:(id)sender {
    if (self.previousCellHandler) self.previousCellHandler();
}

- (IBAction)nextCell:(id)sender {
    if (self.nextCellHandler) self.nextCellHandler();
}

- (IBAction)removeCell:(id)sender {
    if (self.removeCellHandler) self.removeCellHandler();
}

- (IBAction)addCell:(id)sender {
    if (self.addCellHandler) self.addCellHandler();
}

#pragma mark - Private

- (void)updateInfoTextField {
    self.infoTextField.stringValue = [NSString stringWithFormat:@"%@/%@", @(self.currentCellIndex), @(self.numberOfCells)];
}

#pragma mark - Properties

- (void)setNumberOfCells:(NSInteger)numberOfCells {
    _numberOfCells = numberOfCells;
    [self updateInfoTextField];
}

- (void)setCurrentCellIndex:(NSInteger)currentCellIndex {
    _currentCellIndex = currentCellIndex;
    [self updateInfoTextField];
}

@end
