//
//  PCTextSelectViewController.h
//  SpriteBuilder
//
//  Created by Brendan Duddridge on 2014-03-12.
//
//

#import <Cocoa/Cocoa.h>

@interface PCTextSelectViewController : NSViewController<NSTableViewDataSource, NSTableViewDelegate>

@property (nonatomic, weak) IBOutlet NSTableView *fontTableView;

@end
