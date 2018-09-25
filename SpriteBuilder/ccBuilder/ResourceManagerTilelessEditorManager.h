//
//  ResourceManagerTilelessEditorManager.h
//  CocosBuilder
//
//  Created by Viktor on 7/24/13.
//
//

#import <Foundation/Foundation.h>
#import <Quartz/Quartz.h>

#import "PCResourceManager.h"
#include "PCResource.h"

@class CCBImageBrowserView;

@interface ResourceManagerTilelessEditorManager : NSViewController <NSSplitViewDelegate>

@property (strong, nonatomic) CCBImageBrowserView *browserView;
@property (strong, nonatomic) NSArray *imageResources;
@property (assign, nonatomic) enum PCResourceType resourceTypeSelection;

- (id)initWithImageBrowser:(CCBImageBrowserView*)bw;
- (void)searchResources:(NSString *)searchTerm;

@end
