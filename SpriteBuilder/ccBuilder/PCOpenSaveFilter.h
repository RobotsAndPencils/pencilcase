//
//  PCOpenSaveFilter.h
//  SpriteBuilder
//
//  Created by Michael Beauregard on 2015-01-07.
//
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@interface PCOpenSaveFilter : NSObject <NSOpenSavePanelDelegate>

@property (assign, nonatomic) BOOL allowFileSelection;
@property (assign, nonatomic) BOOL allowDirectorySelection;
@property (assign, nonatomic) BOOL allowFilePackageSelection;

- (BOOL)panelShouldEnableURL:(NSURL *)url;

@end
