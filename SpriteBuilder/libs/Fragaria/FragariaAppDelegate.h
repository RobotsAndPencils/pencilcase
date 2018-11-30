//
//  FragariaAppDelegate.h
//  Fragaria
//
//  Created by Jonathan on 30/04/2010.
//  Copyright 2010 mugginsoft.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SMLTextView;
@class MGSFragaria;

@interface FragariaAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
	IBOutlet NSView *editView;
	MGSFragaria *fragaria;
	BOOL isEdited;
}

- (IBAction)showPreferencesWindow:(id)sender;
- (IBAction)copyToPasteBoard:(id)sender;
- (IBAction)reloadString:(id)sender;
@property (assign) IBOutlet NSWindow *window;

- (void)setSyntaxDefinition:(NSString *)name;
- (NSString *)syntaxDefinition;

@end
