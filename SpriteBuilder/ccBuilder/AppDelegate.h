/*
 * CocosBuilder: http://www.cocosbuilder.com
 *
 * Copyright (c) 2011 Viktor Lidholt
 * Copyright (c) 2012 Zynga Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

// System Frameworks
#import <Quartz/Quartz.h>
#import <SpriteKit/SpriteKit.h>

// 3rd Party
#import <HockeySDK/HockeySDK.h>
#import "SMTabBar.h"

// Project Files
#import "PCInspectorTabBar.h"
#import "PCSlidesViewController.h"
#import "PCSuppliesTableViewController.h"
#import "PCSplashWindowController.h"
#import "PCProjectSettings.h"
#import "SequencerKeyframe.h"

@class CCBDocument;
@class PCProjectSettings;
@class PlugInManager;
@class PCResourceManager;
@class ResourceManagerOutlineHandler;
@class CCBTransparentWindow;
@class CCBTransparentView;
@class TaskStatusWindow;
@class CCBPublisher;
@class PCWarningGroup;
@class SequencerHandler;
@class SequencerScrubberSelectionView;
@class MainWindow;
@class HelpWindow;
@class APIDocsWindow;
@class CCBSplitHorizontalView;
@class AboutWindow;
@class ResourceManagerPreviewView;
@class SMTabBar;
@class ResourceManagerTilelessEditorManager;
@class CCBImageBrowserView;
@class PropertyInspectorHandler;
@class LocalizationEditorHandler;
@class PhysicsHandler;
@class WarningTableViewHandler;
@class PCSlidesViewController;
@class PCSuppliesTableViewController;
@class MGSFragaria;
@class NSFlippedView;
@class PCResource;
@class AppSettingsViewController;
@class PCSKView;
@class PCNodeManager;
@class ResourceManagerOutlineView;

@interface AppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate, SMTabBarDelegate, BITHockeyManagerDelegate>

// Outlets
@property (nonatomic, weak) IBOutlet MainWindow *window;
@property (nonatomic, weak) IBOutlet NSToolbar *toolbar;

// Panels
@property (nonatomic, weak) IBOutlet NSView *leftPanel;
@property (nonatomic, weak) IBOutlet NSView *rightPanel;
@property (nonatomic, weak) IBOutlet NSSegmentedControl *panelVisibilityControl;

// NOTE: `strong` to retain even while temporarily removed from toolbar
@property (nonatomic, strong) IBOutlet NSToolbarItem *panelVisibilityToolbarItem; 

@property (nonatomic, strong) PCSKView *spriteKitView;
@property (nonatomic, weak) IBOutlet NSView *mainView;
@property (nonatomic, weak) IBOutlet CCBSplitHorizontalView *splitHorizontalView;

// Inspector tab bars
@property (nonatomic, weak) IBOutlet PCInspectorTabBar *projectViewTabs;
@property (nonatomic, weak) IBOutlet PCInspectorTabBar *resourceViewTabs;
@property (nonatomic, weak) IBOutlet NSTabView *resourceTabView;
@property (nonatomic, weak) IBOutlet NSTabView *projectTabView;
@property (nonatomic, weak) IBOutlet PCInspectorTabBar *itemViewTabs;
@property (nonatomic, weak) IBOutlet NSTabView *itemTabView;

// Timeline
@property (nonatomic, weak) IBOutlet NSOutlineView *outlineHierarchy;
@property (nonatomic, weak) IBOutlet NSOutlineView *outlineHierarchyRightPane;
@property (nonatomic, weak) IBOutlet SequencerScrubberSelectionView *scrubberSelectionView;
@property (nonatomic, weak) IBOutlet NSTextField *timeDisplay;
@property (nonatomic, weak) IBOutlet NSSlider *timeScaleSlider;
@property (nonatomic, weak) IBOutlet NSScroller *timelineScroller;
@property (nonatomic, weak) IBOutlet NSScrollView *sequenceScrollView;
@property (nonatomic, weak) IBOutlet NSPopUpButton *menuTimelinePopup;
@property (nonatomic, weak) IBOutlet NSMenu *menuTimeline;
@property (nonatomic, weak) IBOutlet NSTextField *lblTimeline;
@property (nonatomic, weak) IBOutlet NSPopUpButton *menuTimelineChainedPopup;
@property (nonatomic, weak) IBOutlet NSMenu *menuTimelineChained;
@property (nonatomic, weak) IBOutlet NSTextField *lblTimelineChained;

// Menus
@property (nonatomic, weak) IBOutlet NSMenu *menuCanvasBorder;
@property (nonatomic, weak) IBOutlet NSMenu *menuResolution;
@property (nonatomic, weak) IBOutlet NSMenu *menuContextKeyframe;
@property (nonatomic, weak) IBOutlet NSMenu *menuContextKeyframeInterpol;
@property (nonatomic, weak) IBOutlet NSMenu *menuContextResManager;
@property (nonatomic, weak) IBOutlet NSMenu *menuContextKeyframeNoselection;

@property (nonatomic, weak) IBOutlet NSScrollView *inspectorScroll;
@property (nonatomic, weak) IBOutlet ResourceManagerOutlineView *resourceOutlineView;
@property (nonatomic, weak) IBOutlet NSProgressIndicator *progressIndicator;
@property (nonatomic, weak) IBOutlet NSView *pcSlideTabView;
@property (nonatomic, weak) IBOutlet NSView *pcSuppliesTabView;
@property (nonatomic, weak) IBOutlet PropertyInspectorHandler *propertyInspectorHandler;
@property (nonatomic, weak) IBOutlet NSSegmentedControl *appSettingsToggle;
@property (nonatomic, weak) IBOutlet NSView *inspectorCodeSnippetsContainer;
@property (nonatomic, weak) IBOutlet LocalizationEditorHandler *localizationEditorHandler;
@property (nonatomic, weak) IBOutlet NSTableView *warningTableView;
@property (nonatomic, weak) IBOutlet NSSegmentedControl *segmPublishBtn;
@property (nonatomic, weak) IBOutlet NSView *previewViewContainer;
@property (nonatomic, weak) IBOutlet CCBImageBrowserView *projectImageBrowserView;
@property (nonatomic, weak) IBOutlet NSSplitView *tilelessEditorSplitView;
@property (nonatomic, weak) IBOutlet PhysicsHandler *physicsHandler;

// JavaScript bindings
@property (nonatomic, assign) BOOL jsControlled;

@property (nonatomic, strong) ResourceManagerOutlineHandler *resourceOutlineHandler;
@property (nonatomic, strong) SequencerHandler *sequenceHandler;
@property (nonatomic, strong) AppSettingsViewController *appSettingsViewController;
@property (nonatomic, strong) PCSlidesViewController *pcSlidesViewController;
@property (nonatomic, strong) PCSuppliesTableViewController *suppliesTableViewController;
@property (nonatomic, strong) CCBDocument *currentDocument;
@property (nonatomic, strong) CCBDocument *parentDocument;
@property (nonatomic, assign) BOOL hasOpenedDocument;
@property (nonatomic, assign) BOOL canEditContentSize;
@property (nonatomic, assign) BOOL defaultCanvasSize;
@property (nonatomic, assign) BOOL canEditCustomClass;
@property (nonatomic, assign) BOOL canEditStageSize;
@property (nonatomic, weak, readonly) SKNode *selectedSpriteKitNode;
@property (nonatomic, strong) PCNodeManager *nodeManager;
@property (nonatomic, strong) NSArray *selectedSpriteKitNodes;
@property (nonatomic, strong) NSMutableArray *loadedSelectedSpriteKitNodes;
@property (nonatomic, strong) CCBTransparentView *guiView;
@property (nonatomic, strong) CCBTransparentWindow *guiWindow;
@property (nonatomic, strong) PCProjectSettings *currentProjectSettings;
@property (nonatomic, strong) ResourceManagerPreviewView *previewViewOwner;
@property (nonatomic, copy) NSString *errorDescription;
@property (nonatomic, strong) NSView *inspectorDocumentView;
@property (nonatomic, strong) IBOutlet NSView *inspectorPhysicsDocumentView;
@property (nonatomic, strong) NSMutableArray *inspectors;
@property (nonatomic, strong) NSMutableArray *separators;
@property (nonatomic, strong) SequencerHandler *sequenceHandlerRightPane;
@property (nonatomic, strong) ResourceManagerTilelessEditorManager *tilelessEditorManager;
@property (nonatomic, strong) WarningTableViewHandler *warningHandler;
@property (nonatomic, strong) TaskStatusWindow *modalTaskStatusWindow;
@property (nonatomic, strong) APIDocsWindow *apiDocsWindow;
@property (nonatomic, strong) AboutWindow *aboutWindow;
@property (nonatomic, assign) BOOL playingBack;
@property (nonatomic, assign) double playbackLastFrameTime;

// popover shortcut panes
@property (nonatomic, strong) NSPopover *selectedPopover;

/**
 *  This is a current solution to multiple template nodes being created when dragging and 
 *  dropping from the shortcut pane
 *  ISSUE: There is a mouse down handler in the particle collection view and a drag handler in the SKView, I was unable
 *  to find a way to avoid both in some scenarios - (drag and drop  from shortcut pane to stage)
 */
@property (nonatomic, assign) BOOL nodeIsBeingCreatedFromShortCutCollectionViewPane;

+ (AppDelegate*) appDelegate;

- (IBAction)searchResourceAction:(id)sender;
- (IBAction)physicsPanelAction:(id)sender;

- (IBAction)pressedToolSelection:(id)sender;
- (IBAction)pressedPanelVisibility:(id)sender;

// PlugIns and properties
- (void) refreshProperty:(NSString*) name;

- (void) refreshPropertiesOfType:(NSString*)type;

- (void) updateTimelineMenu;
- (void) updateInspectorFromSelection;
- (void)updateInspectorFromSelection:(BOOL)forceUpdate;

- (void)createNewSlide;

- (BOOL)saveAndCloseProject;

// Updating animation
- (void)updateSpriteKitNode:(SKNode *)node withAnimateablePropertyValue:(id)value propName:(NSString *)propertyName type:(CCBKeyframeType)type;
- (BOOL) isDisabledProperty:(NSString*)name animatable:(BOOL)animatable;

// Menu options
- (IBAction)menuTimelineSettings:(id)sender;
- (IBAction)menuNudgeObject:(id)sender;
- (IBAction)menuMoveObject:(id)sender;
- (IBAction)menuDeselect:(id)sender;
- (IBAction)menuSetStateOriginCentered:(id)sender;
- (IBAction)menuQuit:(id)sender;
- (IBAction)menuEditCustomPropSettings:(id)sender;
- (IBAction)menuSetCanvasBorder:(id)sender;
- (IBAction)menuZoomIn:(id)sender;
- (IBAction)menuZoomOut:(id)sender;
- (IBAction)menuOpenResourceManager:(id)sender;
- (IBAction)menuAbout:(id)sender;
- (IBAction)menuPasteKeyframes:(id)sender;
- (IBAction)menuActionDelete:(id)sender;
- (IBAction)menuActionNewFolder:(NSMenuItem *)sender;

// Drag and drop
- (void)dropAddSpriteWithUUID:(NSString *)uuid at:(CGPoint)pt parent:(SKNode *)parent;
- (void)dropAddSpriteWithUUID:(NSString *)uuid at:(CGPoint)pt;
- (void)dropAddSpriteWithUUID:(NSString *)uuid;
- (void)dropAddVideoWithFile:(NSString *)videoFile;
- (void)dropAdd3DModelWithFile:(NSString *)modelFile; 
- (void)dropAddPlugInNodeNamed:(NSString *)nodeName userInfo:(NSDictionary *)userInfo;
- (void)dropAddVideoWithFile:(NSString *)videoFilePath at:(CGPoint)pt;
- (void)dropAdd3DModelWithFile:(NSString *)modelFile at:(CGPoint)pt; 
- (void)dropAddResource;

// Copy and paste
- (void)paste;
- (IBAction)pasteAsChild:(id)sender;

// File menu
- (void)newProjectWithDeviceTarget:(PCDeviceTargetType)target withOrientation:(PCDeviceTargetOrientation)orientation;
- (IBAction)openProjectWithPanel:(id)sender;
- (void)showOpenProjectPanelWithCompletion:(void(^)(BOOL cancelled, BOOL convertProjectCancelled))completion;
- (void)openProject:(NSString *)fileName autoUpgrade:(BOOL)autoUpgrade success:(void(^)(void))success failure:(void(^)(BOOL convertProjectCancelled, NSError *error))failure;
- (void)closeProject;
- (void)saveFile:(NSString *)fileName withPreview:(BOOL)savePreview;
- (void)switchToDocument:(CCBDocument *)document;
- (void)switchToDocument:(CCBDocument *)document forceReload:(BOOL)forceReload;
- (void)closeLastDocument;
- (void)openDocument:(CCBDocument *)document parentDocument:(CCBDocument *)parentDocument;
- (void)openFile:(NSString *)fileName parentDocument:(CCBDocument *)parentDocument;

// Snapping
- (BOOL)guideSnappingEnabled;
- (void)setGuideSnappingEnabled:(BOOL)snappingEnabled;
- (BOOL)objectSnappingEnabled;
- (void)setObjectSnappingEnabled:(BOOL)snappingEnabled;

/**
Opens a file that is considered to be internal content relative to a slide. An example would be the contents
of a scroll view.
@param the absolute path to the file in question
*/
- (void)openInternalFile:(NSString *)fileName;

- (void) renamedDocumentPathFrom:(NSString*)oldPath to:(NSString*)newPath;
- (void) clearResourceFromProject:(PCResource *)resource;

- (BOOL)addSpriteKitNode:(SKNode *)node toParent:(SKNode *)parent atIndex:(NSInteger)index followInsertionNode:(BOOL)followInsertion;
- (SKNode *)addSpriteKitPlugInNodeNamed:(NSString *)name asChild:(BOOL)asChild toParent:(SKNode *)parent atIndex:(int)index followInsertionNode:(BOOL)followInsertion;
- (void)dropAddPlugInNodeNamed:(NSString *)nodeName at:(CGPoint)pt userInfo:(NSDictionary *)userInfo;
- (void)dropAddPlugInNodeNamed:(NSString *)nodeName parent:(SKNode *)node index:(int)idx;

- (void)setSelectedNode:(SKNode *)node;

- (CCBDocument *)newFile:(NSString *)fileName type:(int)type resolutions:(NSMutableArray *)resolutions;

#pragma mark - Undo

/**
 * Make sure to the select the first tab (assuming its the card item) in the project view
 * whenever there is a notification that the undo is updating the cards (add/delete/select)
 */
- (void)selectCardsTabItemForUndo;

#pragma mark - Deleting

/**
 *  Deletes the current selection based on what might be the first responder
 *
 *  An improvement should be made to this so each responder manages the deletion of its own objects
 */
- (void)deleteSelection;

/**
 *  Convenience method to delete just one node
 *
 *  @param node A node
 */
- (void)deleteNode:(SKNode *)node;

#pragma mark -

- (PCCanvasSize)orientedDeviceTypeForSize:(CGSize)size;
- (void)updateCanvasBorderMenu;
- (void)reloadResources;

/**
 Returns the scale factor of the current resolution in use. Meant to mimic CC2D behaviour; in-app, we were setting CCDirectors scale in the same way
 this is being used.
 */
- (CGFloat)contentScaleFactor;

// Undo / Redo
- (IBAction)undo:(id)sender;
- (IBAction)redo:(id)sender;
- (void)updateDirtyMark;
- (void)saveUndoState;
- (void)saveUndoStateDidChangeProperty:(NSString*)prop;
- (void)saveUndoStateDidChangePropertySkipSameCheck:(NSString*)prop; 
- (void)saveUndoStateToCacheForComparison;

// Recents Pane
- (IBAction)showRecentsWindow:(id)sender;

// Publishing & running
- (IBAction) menuPublishProjectAndRun:(id)sender;

// For warning messages
- (void)modalDialogTitle:(NSString *)title message:(NSString *)msg;

// Modal status messages (progress)
- (void)modalStatusWindowStartWithTitle:(NSString *)title;
- (void)modalStatusWindowStartWithTitle:(NSString *)title onCancelled:(dispatch_block_t)cancellationCallback;
- (void)modalStatusWindowFinish;
- (void)modalStatusWindowUpdateStatusText:(NSString *) text;

- (NSInteger)currentSlideIndex;

// Instant Alpha
- (BOOL)instantAlphaIsEnabled;
- (BOOL)isShowingInstantAlpha;

- (void)assignUuidToNode:(SKNode *)addedNode;
- (void)assignUniqueNameToNode:(SKNode *)addedNode;

- (BOOL)isPhysicsTabSelected;

@end
