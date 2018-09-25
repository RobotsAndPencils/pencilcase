//
//  InspectorPCTableCellInfo.h
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-05-09.
//
//

#import <Foundation/Foundation.h>

@class PCTableCellInfo;
@class InspectorPCTableCellInfo;

@protocol InspectorPCTableCellInfoDelegate <NSObject>

- (void)inspectorPCTableCellInfoDeleteCell:(InspectorPCTableCellInfo *)inspectorPCTableCellInfo;
- (void)inspectorPCTableCellUpdatedCell:(InspectorPCTableCellInfo *)inspectorPCTableCellInfo;

@end

@interface InspectorPCTableCellInfo : NSObject

- (instancetype)initWithCellInfo:(PCTableCellInfo *)cellInfo;

@property (weak, nonatomic) IBOutlet id<InspectorPCTableCellInfoDelegate> delgate;
@property (strong, nonatomic) IBOutlet NSView *view;
@property (strong, nonatomic, readonly) PCTableCellInfo *cellInfo;

@end
