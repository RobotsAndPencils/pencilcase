//
//  InspectorPCTableCellInfo.m
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-05-09.
//
//

#import "InspectorPCTableCellInfo.h"
#import "PCTableCellInfo.h"
#import "AppDelegate.h"
#import "PCInspector.h"

@interface InspectorPCTableCellInfo () <PCInspectorDelegate>

@property (weak, nonatomic) IBOutlet NSView *inspectorsContainer;
@property (copy, nonatomic) NSArray *inspectors;
@property (strong, nonatomic) PCTableCellInfo *cellInfo;

@end

@implementation InspectorPCTableCellInfo

- (instancetype)initWithCellInfo:(PCTableCellInfo *)cellInfo {
    self = [super init];
    if (self) {
        _cellInfo = cellInfo;
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self loadInspectorViews];
}

#pragma mark - Public

#pragma mark - Actions

- (IBAction)deleteCell:(id)sender {
    [self.delgate inspectorPCTableCellInfoDeleteCell:self];
    [[AppDelegate appDelegate] updateInspectorFromSelection];
}

#pragma mark - Private

- (void)loadInspectorViews {
    __block NSInteger height = 0;
    NSMutableArray *inspectors = [NSMutableArray array];
    [self.cellInfo enumerateInspectorInfoDictionariesWithBlock:^(NSString *inspectorTitle, NSString *inspectorType, NSArray *inspectorValueInfos) {
        Class class = [self inspectorClassForType:inspectorType];
        PCInspector *inspector = [[class alloc] init];
        [inspectors addObject:inspector];
        inspector.delegate = self;
        inspector.valueInfos = inspectorValueInfos;
        [[NSBundle mainBundle] loadNibNamed:[self nibNameForClassType:inspectorType] owner:inspector topLevelObjects:nil];
        
        [inspectorValueInfos enumerateObjectsUsingBlock:^(NSDictionary *valueInfo, NSUInteger idx, BOOL *stop) {
            id value = [self.cellInfo valueForInspectorValueInfo:valueInfo];
            [inspector setValue:value forValueInfoIndex:idx];
        }];
        
        [inspector setTitle:inspectorTitle];
        
        height += inspector.view.frame.size.height;
        [self setHeight:height];
        
        CGRect frame = inspector.view.frame;
        frame.origin.y = 0;
        frame.size.width = self.inspectorsContainer.frame.size.width;
        inspector.view.frame = frame;
        [self.inspectorsContainer addSubview:inspector.view];
    }];
    self.inspectors = inspectors;
}

- (Class)inspectorClassForType:(NSString *)type {
    return NSClassFromString([self nibNameForClassType:type]);
}

- (NSString *)nibNameForClassType:(NSString *)type {
    if ([type isEqual:@"Expression"]) {
        type = @"OldExpression";
    }
    return [NSString stringWithFormat:@"PC%@Inspector", type];
}

- (void)setHeight:(NSInteger)height {
    CGRect frame = self.view.frame;
    frame.size.height = height;
    self.view.frame = frame;
}

#pragma mark - PCInspectorDelegate

- (void)inspector:(PCInspector *)inspector valueChanged:(id)newValue forValueInfoAtIndex:(NSInteger)index {
    NSDictionary *valueInfo = inspector.valueInfos[index];
    [self.cellInfo setValue:newValue forInspectorValueInfo:valueInfo];
    [self.delgate inspectorPCTableCellUpdatedCell:self];
}

@end
