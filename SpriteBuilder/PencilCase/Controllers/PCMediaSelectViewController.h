//
//  PCMediaSelectViewController.h
//  SpriteBuilder
//
//  Created by Brendan Duddridge on 2014-03-12.
//
//

#import <Cocoa/Cocoa.h>
#import "CCBImageBrowserView.h"
#import "ResourceManagerTilelessEditorManager.h"

@interface PCMediaSelectViewController : NSViewController

@property (nonatomic, weak) IBOutlet CCBImageBrowserView *imageBrowserView;
@property (nonatomic, weak) ResourceManagerTilelessEditorManager *mediaPopoverResourceManager;
@property (nonatomic, weak) IBOutlet NSButton *chooseImageButton;
@property (nonatomic, weak) IBOutlet NSScrollView *imageScrollView;
@property (nonatomic, weak) IBOutlet NSSegmentedControl *mediaTypeSegmentedControl;
@property (nonatomic, weak) IBOutlet NSSearchField *searchField;
@property (nonatomic, weak) IBOutlet NSProgressIndicator *progressIndicator;

- (IBAction)chooseMedia:(id)sender;
- (IBAction)selectMediaType:(id)sender;
- (IBAction)searchMedia:(id)sender;

@end
