//
//  PCOverlayWindow.h
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-05-12.
//
//

#import <Cocoa/Cocoa.h>

@interface PCOverlayWindow : NSWindow

@property (copy, nonatomic) dispatch_block_t mouseDownHandler;

@end
