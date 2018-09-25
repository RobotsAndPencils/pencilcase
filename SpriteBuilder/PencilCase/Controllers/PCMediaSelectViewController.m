//
//  PCMediaSelectViewController.m
//  SpriteBuilder
//
//  Created by Brendan Duddridge on 2014-03-12.
//
//

#import "PCMediaSelectViewController.h"
#include "PCResource.h"
#import "NSOpenPanel+PCImport.h"

@interface PCMediaSelectViewController ()

@end

@implementation PCMediaSelectViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
		self.imageScrollView.scrollerStyle = NSScrollerStyleOverlay;
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(handleDroppedFile:)
													 name:PCDroppedFileNotification
												   object:nil];
		
		[[PCResourceManager sharedManager] addResourceObserver:self];
    }
    return self;
}

- (IBAction)chooseMedia:(id)sender {
    [NSOpenPanel showImportResourcesDialog:^(BOOL success) {
        [self resourceListUpdated];
    } toResourceDirectory:[PCResourceManager sharedManager].rootResourceDirectory];
}

- (IBAction)selectMediaType:(id)sender {
	enum PCResourceType selectedResourceType = PCResourceTypeImage;
	switch (self.mediaTypeSegmentedControl.selectedSegment) {
		case 0:
			selectedResourceType = PCResourceTypeImage;
			break;
		case 1:
			selectedResourceType = PCResourceTypeVideo;
			break;
		case 2:
			selectedResourceType = PCResourceTypeAudio;
			break;
		default:
			break;
	}
	self.mediaPopoverResourceManager.resourceTypeSelection = selectedResourceType;
	[[PCResourceManager sharedManager] notifyResourceObserversResourceListUpdated];
    [self searchMedia:self.searchField];
}

- (IBAction)searchMedia:(id)sender {
	[self.mediaPopoverResourceManager searchResources:[sender stringValue]];
}

- (void)handleDroppedFile:(NSNotification *)notification {
	[self.progressIndicator setHidden:NO];
	[self.progressIndicator startAnimation:self];
}

- (void)resourceListUpdated {
	[self.progressIndicator stopAnimation:self];
	[self.progressIndicator setHidden:YES];
}

- (void)dealloc {
	[[PCResourceManager sharedManager] removeResourceObserver:self];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	self.imageBrowserView.delegate = nil;
}

@end
