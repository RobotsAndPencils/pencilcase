//
//  WarningOutlineHandler.h
//  SpriteBuilder
//
//  Created by John Twigg on 2013-11-13.
//
//

#import <Foundation/Foundation.h>

@class PCWarningGroup;

@interface WarningTableViewHandler : NSObject <NSTableViewDelegate, NSTableViewDataSource>

@property (strong, nonatomic) PCWarningGroup *warnings;

- (instancetype)initWithTableView:(NSTableView *)tableView;

@end
