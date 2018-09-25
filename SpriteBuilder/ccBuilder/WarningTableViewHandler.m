//
//  WarningOutlineHandler.m
//  SpriteBuilder
//
//  Created by John Twigg on 2013-11-13.
//
//

#import "WarningTableViewHandler.h"
#import "PCWarningGroup.h"

@interface WarningTableViewHandler() <PCWarningGroupDelegate>

@property (weak, nonatomic) NSTableView *tableView;

@end

@implementation WarningTableViewHandler

- (instancetype)initWithTableView:(NSTableView *)tableView {
    if ((self = [super init])) {
        self.tableView = tableView;
    }
    return self;
}

#pragma mark - Properties

- (void)setTableView:(NSTableView *)tableView {
    self.tableView.delegate = nil;
    self.tableView.target = nil;
    self.tableView.dataSource = nil;
    _tableView = tableView;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.target = self;
}

- (void)setWarnings:(PCWarningGroup *)warnings {
    _warnings = warnings;
    _warnings.delegate = self;
    [self.tableView reloadData];
}

#pragma mark - NSTableViewDelegate, NSTableViewDataSource implementations


- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.warnings.warnings.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    PCWarning * warning = self.warnings.warnings[row];
    return warning.description;
}

float heightForStringDrawing(NSString *myString, NSFont *myFont, float myWidth) {
    
    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithString:myString];
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithContainerSize: NSMakeSize(myWidth, FLT_MAX)] ;
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    
    [layoutManager addTextContainer:textContainer];
    [textStorage addLayoutManager:layoutManager];
    
    [textStorage addAttribute:NSFontAttributeName value:myFont range:NSMakeRange(0, [textStorage length])];
    [textContainer setLineFragmentPadding:4.0];
    
    [layoutManager glyphRangeForTextContainer:textContainer];
    return [layoutManager usedRectForTextContainer:textContainer].size.height;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    PCWarning * warning = self.warnings.warnings[row];

    NSFont * font = [NSFont systemFontOfSize:13.0f];
    float height  = heightForStringDrawing(warning.description, font, 249.0f);
    return height + 8;
}


- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    PCWarning * warning = self.warnings.warnings[row];
    NSTextField * textField = cell;
    textField.stringValue = warning.description;
}

#pragma mark - PCWarningsDelegate implementation

- (void)warningsUpdated:(PCWarningGroup *)warnings {
    [self.tableView reloadData];
}

@end
