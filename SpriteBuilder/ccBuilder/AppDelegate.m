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

// Header
#import "AppDelegate.h"

// System Frameworks
#import <ExceptionHandling/NSExceptionHandler.h>
#import "NSFlippedView.h"

// 3rd Party
#import <Sparkle/Sparkle.h>
#import <RPInstantAlpha/RPInstantAlphaViewController.h>
#import <RPInstantAlpha/RPInstantAlphaImageView.h>
#import <Underscore.m/Underscore.h>
#import "SMTabBarItem.h"
#import "OALSimpleAudio.h"

// Categories
#import "SKNode+CocosCompatibility.h"
#import "SKNode+CoordinateConversion.h"
#import "SKNode+Sequencer.h"
#import "SKNode+LifeCycle.h"
#import "SKNode+NodeInfo.h"
#import "SKNode+JavaScript.h"
#import "SKNode+Movement.h"
#import "NSError+PencilCaseErrors.h"
#import "PCResourceManager+Migration.h"
#import "PCResourceManager+ProjectTemplate.h"

// Protocol
#import "PCNodeChildrenManagement.h"

// Project Files
#import "CCBWriterInternal.h"
#import "CCBReaderInternal.h"
#import "CCBUtil.h"
#import "StageSizeWindow.h"
#import "PlugInManager.h"
#import "InspectorPosition.h"
#import "NodeInfo.h"
#import "PlugInNode.h"
#import "PlugInExport.h"
#import "PositionPropertySetter.h"
#import "PCResourceManager.h"
#import "PCRulersNode.h"
#import "CCBTransparentWindow.h"
#import "CCBTransparentView.h"
#import "PCDeviceResolutionSettings.h"
#import "PCProjectSettings.h"
#import "ResourceManagerOutlineHandler.h"
#import "CCBPublisher.h"
#import "PCWarningGroup.h"
#import "TaskStatusWindow.h"
#import "SequencerHandler.h"
#import "MainWindow.h"
#import "SequencerNodeProperty.h"
#import "SequencerSequence.h"
#import "SequencerSettingsWindowController.h"
#import "SequencerDurationWindow.h"
#import "SequencerKeyframe.h"
#import "SequencerKeyframeEasing.h"
#import "SequencerKeyframeEasingWindow.h"
#import "SequencerUtil.h"
#import "SequencerStretchWindow.h"
#import "SequencerSoundChannel.h"
#import "SequencerCallbackChannel.h"
#import "SoundFileImageController.h"
#import "CustomPropSettingsWindow.h"
#import "CustomPropSetting.h"
#import "InspectorSeparator.h"
#import "APIDocsWindow.h"
#import "NodeGraphPropertySetter.h"
#import "CCBSplitHorizontalView.h"
#import "AboutWindow.h"
#import "ResourceManagerPreviewView.h"
#import "ResourceManagerUtil.h"
#import "ResourceManagerTilelessEditorManager.h"
#import "CCBImageBrowserView.h"
#import "PropertyInspectorHandler.h"
#import "LocalizationEditorHandler.h"
#import "PhysicsHandler.h"
#import "PCProjectSetupHelper.h"
#import "WarningTableViewHandler.h"
#import "PCSKVideoPlayer.h"
#import "PCSKTextView.h"
#import "PCSKShapeNode.h"
#import "PCTemplate.h"
#import "AppSettingsViewController.h"
#import "PCPublisher.h"
#import "PCShapeSelectViewController.h"
#import "PCTextSelectViewController.h"
#import "PCMediaSelectViewController.h"
#import "PCParticleSelectViewController.h"
#import "CCBSplitVerticalView.h"
#import "PCDeploymentMenuItemView.h"
#import "PCDeploymentMenuItem.h"
#import "SequencerScrubberSelectionView.h"
#import "PCStageScene.h"
#import "PCSKView.h"
#import "PCSnapNode.h"
#import "PCTextStepperProtocol.h"
#import "CGPointUtilities.h"
#import "PCSKTextView.h"
#import "PCGuidesNode.h"
#import "PCUndoManager.h"
#import "SKNode+IsEqualFix.h"
#import "PCDeploymentMenuItem.h"
#import "PC3DNode.h"
#import "ResourcePropertySetter.h"
#import "PCBehaviourListViewController.h"
#import "NSUUID+UUIDWithString.h"
#import "PCWhen.h"
#import "PCThen.h"
#import "PCOpenSaveFilter.h"
#import "PCProjectTemplate.h"
#import "PCZipHelper.h"
#import "PCUserProjectDocuments.h"
#import "PCApplicationSupport.h"
#import "PCTemplateLibrary.h"
#import "NSOpenPanel+PCImport.h"
#import "PCTextFieldStepper.h"
#import "PCKeyValueStoreKeyConfigViewController.h"
#import "PCBehavioursDataSource.h"
#import "PCDeviceResolutionSettings.h"
#import "PCSplashController.h"
#import "PCResourceLibrary.h"

static void *AppDelegateContext = &AppDelegateContext;

static AppDelegate *sharedAppDelegate;

const NSInteger sequencerCallBackTimelineRow = 0;

static NSString *const systemVersionPath = @"/System/Library/CoreServices/SystemVersion.plist";
static NSString *const pcPropertyOperationsFilename = @"PCPropertyOperations.plist";
static NSString *const PCSnappingToObjectsEnabledKey = @"PCSnappingToObjectsEnabledKey";
static NSString *const PCSnappingToGuidesEnabledKey = @"PCSnappingToGuidesEnabledKey";

#define PCPointNil CGPointMake(HUGE_VALF, HUGE_VALF)
#define PCPointIsNil(point) CGPointEqualToPoint(point, PCPointNil)

@interface AppDelegate () <NSPopoverDelegate, NSTextFieldDelegate> {
    CGSize defaultCanvasSizes[PCCanvasSizeCount + 1];
    NSMutableArray *selectedSpriteKitNodes;
    NSMutableArray *loadedSelectedSpriteKitNodes;
}

@property (nonatomic, strong) NSView *drawingView;
@property (nonatomic, strong) NSView *appSettingsView;

@property (nonatomic, strong) NSAlert *shareAlert;
@property (nonatomic, assign) BOOL openedProjectWithCreationFile;

@property (nonatomic, weak) IBOutlet CCBSplitVerticalView *mainVerticalSplitView;
@property (nonatomic, weak) IBOutlet NSMenuItem *duplicateMenuItem;
@property (nonatomic, weak) IBOutlet NSMenuItem *snappingMenuItem;
@property (nonatomic, weak) IBOutlet NSMenuItem *snapToObjectsMenuItem;
@property (nonatomic, weak) IBOutlet NSMenuItem *snapToGuidesMenuItem;
@property (nonatomic, weak) IBOutlet NSMenuItem *keyValueStoreMenuItem;
@property (nonatomic, weak) IBOutlet NSTabViewItem *behavioursTabViewItem; // Strong because removed on feature switch

@property (nonatomic, strong) NSMutableDictionary *pasteboardSlideCascadeNumbers;

@property (nonatomic, strong) PCPublisher *publisher;

@property (nonatomic, strong) NSPopover *shapesPopover;
@property (nonatomic, strong) NSPopover *mediaPopover;
@property (nonatomic, strong) NSPopover *textPopover;
@property (nonatomic, strong) NSPopover *particlesPopover;
@property (nonatomic, weak) IBOutlet NSToolbarItem *shapesButton;
@property (nonatomic, weak) IBOutlet NSToolbarItem *mediaButton;
@property (nonatomic, weak) IBOutlet NSToolbarItem *textButton;
@property (nonatomic, weak) IBOutlet NSToolbarItem *particlesButton;
@property (nonatomic, strong) ResourceManagerTilelessEditorManager *mediaPopoverResourceManager;
@property (nonatomic, weak) IBOutlet NSPopUpButton *deploymentPopupButton;

@property (nonatomic, weak) IBOutlet NSView *templatesEnabledView;
@property (nonatomic, weak) IBOutlet NSView *templatesDisabledView;
@property (nonatomic, weak) IBOutlet NSTextField *templatesDisabledTitleLabel;
@property (nonatomic, weak) IBOutlet NSTextField *templatesDisabledMessageLabel;

@property (nonatomic, weak) IBOutlet NSView *physicsEnabledView;
@property (nonatomic, weak) IBOutlet NSView *physicsDisabledView;
@property (nonatomic, weak) IBOutlet NSTextField *physicsDisabledTitleLabel;
@property (nonatomic, weak) IBOutlet NSTextField *physicsDisabledMessageLabel;
@property (nonatomic, weak) IBOutlet NSView *sceneContainerView;

@property (nonatomic, strong) IBOutlet NSView *behavioursContainer;
@property (strong, nonatomic) PCBehaviourListViewController *behaviourListViewController;
@property (strong, nonatomic) NSWindowController *shareWindowController;

@property (nonatomic, assign) NSPoint savedInspectorScrollPoint;
@property (nonatomic, assign) NSInteger nodePasteOffset;

@property (nonatomic, strong) NSDictionary *propertyCategoryToViewMapping;

// Instant Alpha
@property (nonatomic, strong) RPInstantAlphaViewController *instantAlphaViewController;

@property (nonatomic, strong) PCNodeManager *currentInspectorNodeManager;

@property (nonatomic, strong) NSMutableDictionary *cachedInspectors;
@property (nonatomic, strong) NSMutableArray *cachedSeparators;

@property (nonatomic, strong) PCOpenSaveFilter *openSaveFilter;

@property (nonatomic, strong) PCKeyValueStoreKeyConfigViewController *configViewController;

@property (nonatomic, strong) PCSplashController *splashController;

@property (nonatomic, copy) NSString *filenameToOpenOnLaunch;

@end

typedef NS_ENUM(NSInteger, PCRunTargetType) {
    PCRunTargetSimulator,
    PCRunTargetExportToXCode
};

typedef NS_ENUM(NSInteger, kCCBNewDocType) {
    kCCBNewDocTypeNone = -1,
    kCCBNewDocTypeScene = 0,
    kCCBNewDocTypeNode,
    kCCBNewDocTypeLayer,
    kCCBNewDocTypeSprite,
    kCCBNewDocTypeParticleSystem,
    kCCBNewDocTypePCSlide,
};

// The "Insert Keyframe" menu items in 'MainMenu.xib' are tagged so that they can be identified
typedef NS_ENUM(NSInteger, PCInsertKeyframeMenuTag) {
    PCInsertKeyframeMenuTagVisible = 0,
    PCInsertKeyframeMenuTagPosition = 1,
    PCInsertKeyframeMenuTagScale = 2,
    PCInsertKeyframeMenuTagRotation = 3,
    PCInsertKeyframeMenuTagSpriteFrame = 4,
    PCInsertKeyframeMenuTagOpacity = 5,
    PCInsertKeyframeMenuTagColor = 6,
    PCInsertKeyframeMenuTagXRotation3D = 7,
    PCInsertKeyframeMenuTagYRotation3D = 8,
    PCInsertKeyframeMenuTagZRotation3D = 9,
};

typedef NS_ENUM(NSInteger, ValidateProjectDictionaryFileVersionInfoStatus) {
    ValidateProjectDictionaryFileVersionInfoStatusValid,
    ValidateProjectDictionaryFileVersionInfoStatusNotValid,
    ValidateProjectDictionaryFileVersionInfoStatusCancelledConvertProject,
    ValidateProjectDictionaryFileVersionInfoStatusAcceptedConvertProject,
    ValidateProjectDictionaryFileVersionInfoStatusAcceptedConvertAndRegenerateJS
};

@implementation AppDelegate

@synthesize selectedSpriteKitNodes;
@synthesize loadedSelectedSpriteKitNodes;

+ (AppDelegate *)appDelegate {
    return sharedAppDelegate;
}

#pragma mark NSApplicationDelegate

// This method is called before application:openFile(s):, which are called before applicationDidFinishLaunching:
// We need to initialize as much as possible in this method to prepare for opening files
- (void)applicationWillFinishLaunching:(NSNotification *)notification {
    if (!IS_TEST_TARGET) {
        [self setupHockeyApp];
        [self setupSparkle];
        [[NSExceptionHandler defaultExceptionHandler] setExceptionHandlingMask: NSLogUncaughtExceptionMask | NSLogUncaughtSystemExceptionMask | NSLogUncaughtRuntimeErrorMask];
    }

    [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:@"ApplePersistenceIgnoreState"];

    selectedSpriteKitNodes = [[NSMutableArray alloc] init];
    loadedSelectedSpriteKitNodes = [[NSMutableArray alloc] init];

    sharedAppDelegate = self;

    // iOS
    defaultCanvasSizes[PCCanvasSizeIPhoneLandscape] = CGSizeMake(480, 320);
    defaultCanvasSizes[PCCanvasSizeIPhonePortrait] = CGSizeMake(320, 480);
    defaultCanvasSizes[PCCanvasSizeIPhone5Landscape] = CGSizeMake(568, 320);
    defaultCanvasSizes[PCCanvasSizeIPhone5Portrait] = CGSizeMake(320, 568);
    defaultCanvasSizes[PCCanvasSizeIPadLandscape] = CGSizeMake(1024, 768);
    defaultCanvasSizes[PCCanvasSizeIPadPortrait] = CGSizeMake(384, 512);

    // Fixed
    defaultCanvasSizes[PCCanvasSizeFixedLandscape] = CGSizeMake(568, 384);
    defaultCanvasSizes[PCCanvasSizeFixedPortrait] = CGSizeMake(384, 568);

    // Android
    defaultCanvasSizes[PCCanvasSizeAndroidXSmallLandscape] = CGSizeMake(320, 240);
    defaultCanvasSizes[PCCanvasSizeAndroidXSmallPortrait] = CGSizeMake(240, 320);
    defaultCanvasSizes[PCCanvasSizeAndroidSmallLandscape] = CGSizeMake(480, 340);
    defaultCanvasSizes[PCCanvasSizeAndroidSmallPortrait] = CGSizeMake(340, 480);
    defaultCanvasSizes[PCCanvasSizeAndroidMediumLandscape] = CGSizeMake(800, 480);
    defaultCanvasSizes[PCCanvasSizeAndroidMediumPortrait] = CGSizeMake(480, 800);

    self.nodeIsBeingCreatedFromShortCutCollectionViewPane = NO;
    self.pasteboardSlideCascadeNumbers = [[NSMutableDictionary alloc] init];

    [self setupSequenceHandler];
    [[NSColorPanel sharedColorPanel] setShowsAlpha:YES];
    [[PlugInManager sharedManager] loadPlugIns];
    [self setupResourceManager];

    [self addObserver:self forKeyPath:@"currentDocument.isDirty" options:0 context:AppDelegateContext];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadObjectHierarchy) name:ReloadObjectHierarchyNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleProjectFailedToOpenNotification:) name:PCProjectFailedToOpenNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleProjectOpenedNotification:) name:PCProjectOpenedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleUndoManagerCheckpointNotification:) name:NSUndoManagerCheckpointNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didStartImportingResources:) name:PCDroppedFileNotification object:nil];

    // ----- UI Initialization

    [SKNode pc_setupLifecycleCallbacks];

    // This needs to happen before the recent projects window is possibly shown so that it overlays the main window
    [self.window makeKeyWindow];

    [self setupPencilCaseViews];

    self.drawingView = self.window.contentView;
    self.appSettingsViewController = [[AppSettingsViewController alloc] initWithNibName:@"AppSettingsView" bundle:nil];
    [self.appSettingsViewController bind:@"representedObject" toObject:self withKeyPath:@"currentProjectSettings" options:nil];
    self.appSettingsView = self.appSettingsViewController.view;

    [self updateSmallTabBarsEnabled];
    [self setupProjectTilelessEditor];
    [self setupProjectViewTabBar];
    [self setupItemViewTabBar];
    [self setupDeploymentMenu];
    [self setupResourcesViewTabBar];
    [self updateCanvasBorderMenu];

    [self setupInspectorPane];
    [self setupInspectorCaches];
    [self setupBehavioursPane];
    [self updateInspectorFromSelection];
    [self.window setDelegate:self];

    [[PCResourceManager sharedManager] addResourceObserver:self];
    [self setupMenuFromSettings];
    
    self.openedProjectWithCreationFile = NO;
    [self.projectViewTabs setEnabled:NO];
    [self.itemViewTabs setEnabled:NO];
}


// PencilCase only supports one document open at a time, so just open the first project
- (void)application:(NSApplication *)sender openFiles:(NSArray *)filenames {
    self.openedProjectWithCreationFile = YES;
    [self openProjectDocumentWithFileName:filenames.firstObject];
}

- (void)openProjectDocumentWithFileName:(NSString *)fileName {
    if (!self.spriteKitView) { // We haven't finished launching - defer
        self.filenameToOpenOnLaunch = fileName;
        return;
    }
    
    [self openProject:fileName autoUpgrade:NO success:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:PCProjectOpenedNotification object:self userInfo:nil];
    } failure:^(BOOL convertProjectCancelled, NSError *error) {
        NSMutableDictionary *info = [NSMutableDictionary dictionary];
        if (error) {
            info[@"error"] = error;
            [[NSNotificationCenter defaultCenter] postNotificationName:PCProjectFailedToOpenNotification object:self userInfo:info];
        }
    }];
}

// This method should be reserved for initialization or actions that need to occur after a project has potentially been opened at launch
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    if (IS_TEST_TARGET) {
        return;
    }
    
    // This is only needed before the following code, not in applicationwillFinishLaunching:
    self.splashController = [[PCSplashController alloc] initWithSaveNewProjectBlock:^(PCDeviceTargetType type, PCDeviceTargetOrientation orientation) {
        [self newProjectWithDeviceTarget:type withOrientation:orientation];
    } openRecentProjectBlock:^(NSURL *url) {
        [self openProject:[url path] autoUpgrade:NO success:^{
            [[NSApp mainWindow] makeKeyAndOrderFront:self];
            [[NSNotificationCenter defaultCenter] postNotificationName:PCProjectOpenedNotification object:self userInfo:nil];
        }         failure:^(BOOL convertProjectCancelled, NSError *error) {
            if (convertProjectCancelled) {
                [self.splashController showRecents];
            }
            else if (error) {
                [[NSNotificationCenter defaultCenter] postNotificationName:PCProjectFailedToOpenNotification object:self userInfo:@{ @"error" : error }];
                [self.splashController showRecents];
            }
        }];
    } openOtherProjectBlock:^() {
        [[AppDelegate appDelegate] showOpenProjectPanelWithCompletion:^(BOOL cancelled, BOOL convertProjectCancelled) {
            if (cancelled) {
                [self.splashController showRecents];
            }
            else if (convertProjectCancelled) {
                [self.splashController openOtherProject];
            }
        }];
        [[NSApp mainWindow] makeKeyAndOrderFront:self];
    }];

    [self registerForUndoCallbacks];
    
    [self showAppropriateStartupView];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self setupSpriteKitView];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (self.filenameToOpenOnLaunch) {
                [self openProjectDocumentWithFileName:self.filenameToOpenOnLaunch];
            }
        });
    });
}

- (void)showAppropriateStartupView {
    if (self.openedProjectWithCreationFile) return;

    if (self.currentDocument) {
        [self refreshUIForOpenedProject];
    } else {
        [self.splashController showRecents];
    }
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:[BITSystemProfile sharedSystemProfile]];
}

#pragma mark Setup functions

- (void) setupInspectorPane
{
    //propertyInspectorHandl= [[PropertyInspectorHandler alloc] init];

    self.inspectors = [NSMutableArray array];
    
    self.inspectorDocumentView = [[NSFlippedView alloc] initWithFrame:NSMakeRect(0, 0, [self.inspectorScroll contentSize].width, 1)];
    [self.inspectorDocumentView setAutoresizesSubviews:YES];
    [self.inspectorDocumentView setAutoresizingMask:NSViewWidthSizable];
    [self.inspectorScroll setDocumentView:self.inspectorDocumentView];

    self.propertyCategoryToViewMapping = @{ PCPropertyCategoryPhysics : self.inspectorPhysicsDocumentView,
                                            PCPropertyCategoryDefault : self.inspectorDocumentView };
}

- (void)setupBehavioursPane {
    self.behaviourListViewController = [[PCBehaviourListViewController alloc] init];
    self.behaviourListViewController.view.frame = self.behavioursContainer.bounds;
    NSView *view = self.behaviourListViewController.view;
    [self.behavioursContainer addSubview:view];
    [self.behavioursContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(16)-[view]-(0)-|" options:0 metrics:nil views:@{@"view": view}]];
    [self.behavioursContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[view]-(0)-|" options:0 metrics:nil views:@{@"view": view}]];
}

- (void)setupSpriteKitView {
    self.spriteKitView = [[PCSKView alloc] initWithFrame:self.sceneContainerView.bounds];
    self.spriteKitView.autoresizingMask = NSViewHeightSizable|NSViewWidthSizable;
    [self.sceneContainerView addSubview:self.spriteKitView];
    [self.spriteKitView presentScene:[PCStageScene sceneWithAppDelegate:self]];
}

- (void) setupSequenceHandler
{
    self.sequenceHandlerRightPane = [[SequencerHandler alloc] initWithOutlineView:self.outlineHierarchyRightPane];
    self.sequenceHandlerRightPane.displayTimeline = NO;
    self.sequenceHandler = [[SequencerHandler alloc] initWithOutlineView:self.outlineHierarchy];
    self.sequenceHandler.displayTimeline = YES;
    self.sequenceHandler.scrubberSelectionView = self.scrubberSelectionView;
    self.sequenceHandler.timeDisplay = self.timeDisplay;
    self.sequenceHandler.timeScaleSlider = self.timeScaleSlider;
    self.sequenceHandler.scroller = self.timelineScroller;
    self.sequenceHandler.scrollView = self.sequenceScrollView;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSoundImages:) name:kSoundFileImageLoaded object:nil];
    
    [self updateTimelineMenu];
    [self.sequenceHandler updateScaleSlider];
    [self showHideTimelineView:nil];
}

-(void)reloadObjectHierarchy {
    [self.outlineHierarchy reloadData];
    [self.outlineHierarchyRightPane reloadData];
    [self reorderZChildrenOfNode:[PCStageScene scene].rootNode];
    [[PCOverlayView overlayView] updateTrackingViewsFromZOrder];
}

- (CGFloat)reorderZChildrenOfNode:(SKNode *)node {
    CGFloat zPosition = 0;
    for (NSUInteger nodeIndex = 0; nodeIndex < node.children.count; nodeIndex++) {
        SKNode *childNode = node.children[nodeIndex];
        childNode.zPosition = zPosition;
        zPosition += [self reorderZChildrenOfNode:childNode] + 1;
    }
    return zPosition;
}

-(void)updateSoundImages:(NSNotification*)notice
{
    [self reloadObjectHierarchy];
}

- (void) setupProjectViewTabBar
{
    NSMutableArray* items = [NSMutableArray array];
    
    NSImage* imgSlidesList = [NSImage imageNamed:@"ToolbarCardsTemplate"];
    SMTabBarItem* itemSlideList = [[SMTabBarItem alloc] initWithImage:imgSlidesList tag:PCProjectTabTagSlides];
    itemSlideList.toolTip = @"Cards";
    itemSlideList.keyEquivalent = @"";
    [items addObject:itemSlideList];
    
    NSImage* imgObjs = [NSImage imageNamed:@"ToolbarMediaTemplate"];
    SMTabBarItem* itemObjs = [[SMTabBarItem alloc] initWithImage:imgObjs tag:PCProjectTabTagMedia];
    itemObjs.toolTip = @"Media";
    itemObjs.keyEquivalent = @"";
    [items addObject:itemObjs];
    
    NSImage* imgNodes = [NSImage imageNamed:@"ToolbarSuppliesTemplate"];
    [imgNodes setTemplate:YES];
    SMTabBarItem* itemNodes = [[SMTabBarItem alloc] initWithImage:imgNodes tag:PCProjectTabTagSupplies];
    itemNodes.toolTip = @"Supplies";
    itemNodes.keyEquivalent = @"";
    [items addObject:itemNodes];
    
    NSImage* imgWarnings = [NSImage imageNamed:@"ToolbarMessagesTemplate"];
    [imgWarnings setTemplate:YES];
    SMTabBarItem* itemWarnings = [[SMTabBarItem alloc] initWithImage:imgWarnings tag:PCProjectTabTagWarnings];
    itemWarnings.toolTip = @"Messages";
    itemWarnings.keyEquivalent = @"";
    [items addObject:itemWarnings];

    self.projectViewTabs.items = items;
    self.projectViewTabs.delegate = self;
}

- (void) setupResourcesViewTabBar
{
    NSMutableArray* items = [NSMutableArray array];
    
    NSImage* imgObjs = [NSImage imageNamed:@"NSIconViewTemplate"];
    [imgObjs setTemplate:YES];
    SMTabBarItem* itemObjs = [[SMTabBarItem alloc] initWithImage:imgObjs tag:1];
    itemObjs.toolTip = @"Show items as icons";
    itemObjs.keyEquivalent = @"";
    [items addObject:itemObjs];
    
    NSImage* imgNodes = [NSImage imageNamed:@"NSListViewTemplate"];
    [imgNodes setTemplate:YES];
    SMTabBarItem* itemNodes = [[SMTabBarItem alloc] initWithImage:imgNodes tag:2];
    itemNodes.toolTip = @"Show items in a list";
    itemNodes.keyEquivalent = @"";
    [items addObject:itemNodes];
	
    self.resourceViewTabs.items = items;
    self.resourceViewTabs.delegate = self;
}


- (void)setupItemViewTabBar {
    NSMutableArray* items = [NSMutableArray array];

    NSImage* imgProps = [NSImage imageNamed:@"ToolbarPropertiesTemplate"];
    SMTabBarItem* itemProps = [[SMTabBarItem alloc] initWithImage:imgProps tag:PCInspectorTabTagItemProperties];
    itemProps.toolTip = @"Properties";
    itemProps.keyEquivalent = @"";
    [items addObject:itemProps];

    NSImage* behavioursIcon = [NSImage imageNamed:@"ToolbarEventsTemplate"];
    SMTabBarItem *behaviourProps = [[SMTabBarItem alloc] initWithImage:behavioursIcon tag:PCInspectorTabTagBehaviours];
    behaviourProps.toolTip = @"Behaviors";
    behaviourProps.keyEquivalent = @"";
    [items addObject:behaviourProps];
    if (![self.itemTabView.tabViewItems containsObject:self.behavioursTabViewItem]) {
        [self.itemTabView insertTabViewItem:self.behavioursTabViewItem atIndex:1];
    }

    NSImage* imgPhysics = [NSImage imageNamed:@"ToolbarPhysicsTemplate"];
    SMTabBarItem* itemPhysics = [[SMTabBarItem alloc] initWithImage:imgPhysics tag:PCInspectorTabTagPhysics];
    itemPhysics.toolTip = @"Physics";
    itemPhysics.keyEquivalent = @"";
    [items addObject:itemPhysics];

    NSImage* imgTemplate = [NSImage imageNamed:@"ToolbarTemplatesTemplate"];
    SMTabBarItem* itemTemplate = [[SMTabBarItem alloc] initWithImage:imgTemplate tag:PCInspectorTabTagTemplates];
    itemTemplate.toolTip = @"Templates";
    itemTemplate.keyEquivalent = @"";
    [items addObject:itemTemplate];

    if (!self.itemViewTabs.items) { // Only do this the first setup call
        self.itemViewTabs.delegate = self;

        [self addObserver:self forKeyPath:@"selectedNode" options:0 context:AppDelegateContext];
        [self addObserver:self forKeyPath:@"selectedSpriteKitNode" options:0 context:AppDelegateContext];
    }

    self.itemViewTabs.items = items;
}

- (void)setupDeploymentMenu {
    self.deploymentPopupButton.frame = CGRectInset(self.deploymentPopupButton.frame, 0.0, -3.0);
    NSInteger selectionTag = 0;
    for (PCDeploymentMenuItem *menuItem in self.deploymentPopupButton.menu.itemArray) {
        PCDeploymentMenuItemView *view = [[PCDeploymentMenuItemView alloc] initWithFrame:CGRectMake(0, 0, 300.0f, 44.0f)];
        view.autoresizingMask = NSViewWidthSizable;
        [view.titleLabel setStringValue:menuItem.title];
        [view.subtitleLabel setStringValue:menuItem.subtitle];
        view.imageView.image = menuItem.image;
        [view.imageView.image setTemplate:YES];
        menuItem.tag = selectionTag;
        [menuItem setView:view];
        selectionTag ++;
    }

    [self.deploymentPopupButton selectItem:self.deploymentPopupButton.menu.itemArray.firstObject];
}

- (void)tabBar:(SMTabBar *)tb didSelectItem:(SMTabBarItem *)item {
    if (tb == self.projectViewTabs) {
        [self.projectTabView selectTabViewItemAtIndex:[self.projectViewTabs.items indexOfObject:item]];
    }
    else if (tb == self.itemViewTabs) {
        // Reload the template tab view's template library (since there's more than one instance and the persistence is in a single file)
        if (tb.selectedItem.tag == PCInspectorTabTagTemplates) {
            [self.propertyInspectorHandler loadTemplateLibrary];
        }

        NSString *identifier = [@(self.itemViewTabs.selectedItem.tag) stringValue];
        [self.itemTabView selectTabViewItemWithIdentifier:identifier];
    } else if (tb == self.resourceViewTabs) {
        [self.resourceTabView selectTabViewItemAtIndex:[self.resourceViewTabs.items indexOfObject:item]];
    }
}

- (SMTabBarItem *)inspectorItemWithTag:(NSInteger)tag {
    return Underscore.array(self.itemViewTabs.items).find(^BOOL(SMTabBarItem *item){
        return item.tag == tag;
    });
}

- (BOOL)isPhysicsTabSelected {
    return self.itemViewTabs.selectedItem == [self inspectorItemWithTag:PCInspectorTabTagPhysics];
}

- (void)selectInspectorTabWithTag:(PCInspectorTabTag)tag {
    SMTabBarItem *tabBarItem = [self inspectorItemWithTag:tag];
    [self.itemViewTabs setSelectedItem:tabBarItem];
    NSString *identifier = [@(self.itemViewTabs.selectedItem.tag) stringValue];
    [self.itemTabView selectTabViewItemWithIdentifier:identifier];
}

- (void)updateSmallTabBarsEnabled {
    // Set enable for open project
    BOOL allEnable = (self.currentProjectSettings != nil);
    
    if (!allEnable) {
        // If project isn't open, set selected tab to the first one
        [self.projectViewTabs setSelectedItem:self.projectViewTabs.items[0]];
        [self.projectTabView selectTabViewItemAtIndex:3];

        [self selectInspectorTabWithTag:PCInspectorTabTagItemProperties];

		[self.resourceViewTabs setSelectedItem:self.resourceViewTabs.items[0]];
		[self.resourceTabView selectTabViewItemAtIndex:0];
    }
    
    // Update enable for project
    for (SMTabBarItem *item in self.projectViewTabs.items) {
        item.enabled = allEnable;
    }

    // Update enable depending on if resources tab is selected
    for (SMTabBarItem *item in self.resourceViewTabs.items) {
        item.enabled = allEnable;
    }

    for (SMTabBarItem *item in self.itemViewTabs.items) {
        item.enabled = allEnable;
    }

    [self updatePhysicsTabEnabledState];
    [self updateTemplatesTabEnabledState];
}

- (void)updatePhysicsTabEnabledState {
    BOOL physicsEnabled = (self.selectedSpriteKitNode.canParticipateInPhysics || [self.selectedSpriteKitNode hasPhysicsProperties]);
    self.physicsEnabledView.hidden = !physicsEnabled;
    self.physicsDisabledView.hidden = physicsEnabled;
    if (!physicsEnabled) {
        if (PCIsEmpty(self.selectedSpriteKitNodes)) {
            self.physicsDisabledTitleLabel.stringValue = NSLocalizedString(@"PhysicsTabNoSelection", nil);
            self.physicsDisabledMessageLabel.stringValue = @"";
        } else {
            self.physicsDisabledTitleLabel.stringValue = NSLocalizedString(@"PhysicsTabInvalidSelectionTitle", nil);
            self.physicsDisabledMessageLabel.stringValue = NSLocalizedString(@"PhysicsTabInvalidSelectionMessage", nil);
        }
    }
}

- (void)updateTemplatesTabEnabledState {
    BOOL templateEnable = self.selectedSpriteKitNode.plugIn.supportsTemplates;
    self.templatesDisabledView.hidden = templateEnable;
    self.templatesEnabledView.hidden = !templateEnable;
    if (!templateEnable) {
        if (PCIsEmpty(self.selectedSpriteKitNodes)) {
            self.templatesDisabledTitleLabel.stringValue = NSLocalizedString(@"TemplatesTabNoSelection", nil);
            self.templatesDisabledMessageLabel.stringValue = @"";
        } else {
            self.templatesDisabledTitleLabel.stringValue = NSLocalizedString(@"TemplatesTabUnsupportedSelectionTitle", nil);
            self.templatesDisabledMessageLabel.stringValue = NSLocalizedString(@"TemplatesTabUnsupportedSelectionMessage", nil);
        }
    }
}

- (void)setupProjectTilelessEditor {
    self.tilelessEditorManager = [[ResourceManagerTilelessEditorManager alloc] initWithImageBrowser:self.projectImageBrowserView];
    self.tilelessEditorSplitView.delegate = self.tilelessEditorManager;
}

- (void)setupResourceManager {
    // Load resource manager
	[PCResourceManager sharedManager];
		
    // Setup preview
    self.previewViewOwner = [[ResourceManagerPreviewView alloc] init];
    
    NSArray* topLevelObjs = NULL;
    [[NSBundle mainBundle] loadNibNamed:@"ResourceManagerPreviewView" owner:self.previewViewOwner topLevelObjects:&topLevelObjs];

    for (id obj in topLevelObjs)
    {
        if ([obj isKindOfClass:[NSView class]])
        {
            NSView* view = obj;
            view.frame = self.previewViewContainer.bounds;
            [self.previewViewContainer addSubview:view];
        }
    }
    
    [self.previewViewOwner setPreviewFile:NULL];
    
	// setup resource outline view handler
	
	self.resourceOutlineHandler = [[ResourceManagerOutlineHandler alloc] initWithOutlineView:self.resourceOutlineView resType:PCResourceTypeNone preview:self.previewViewOwner];

	
    //Setup warnings outline
    self.warningHandler = [[WarningTableViewHandler alloc] initWithTableView:self.warningTableView];
    [self updateWarningsOutline];
}

- (void)setupMenuFromSettings {
    // If missing values for snapping, default them to YES
    if (![[NSUserDefaults standardUserDefaults] objectForKey:PCSnappingToGuidesEnabledKey]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:PCSnappingToGuidesEnabledKey];
    }
    if (![[NSUserDefaults standardUserDefaults] objectForKey:PCSnappingToObjectsEnabledKey]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:PCSnappingToObjectsEnabledKey];
    }
    [self setGuideSnappingEnabled:[[NSUserDefaults standardUserDefaults] boolForKey:PCSnappingToGuidesEnabledKey]];
    [self setObjectSnappingEnabled:[[NSUserDefaults standardUserDefaults] boolForKey:PCSnappingToObjectsEnabledKey]];
}

- (void)setupInspectorCaches {
    self.separators = [NSMutableArray array];
    self.cachedSeparators = [NSMutableArray array];
    self.cachedInspectors = [NSMutableDictionary dictionary];
}

#pragma mark - Application setup

- (void)setupHockeyApp {
    NSString *appID = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"HockeyApp ID"];
    if (!appID) {
        PCLog(@"HockeyApp ID missing, aborting HockeyApp setup");
        return;
    }
    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:appID companyName:@"Robots and Pencils" delegate:self];
    [[BITHockeyManager sharedHockeyManager] startManager];
    [[BITHockeyManager sharedHockeyManager].crashManager setAutoSubmitCrashReport: YES];
}

- (void)setupSparkle {
    Class updaterClass = NSClassFromString(@"SUUpdater");
    if (!updaterClass) return;

    [updaterClass sharedUpdater].sendsSystemProfile = YES;
    NSNotificationCenter *defaultNotificationCenter = [NSNotificationCenter defaultCenter];
    BITSystemProfile *profile = [BITSystemProfile sharedSystemProfile];
    [defaultNotificationCenter addObserver:profile selector:@selector(startUsage) name:NSApplicationDidBecomeActiveNotification object:nil];
    [defaultNotificationCenter addObserver:profile selector:@selector(stopUsage) name:NSApplicationWillTerminateNotification object:nil];
    [defaultNotificationCenter addObserver:profile selector:@selector(stopUsage) name:NSApplicationWillResignActiveNotification object:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context != AppDelegateContext) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }

    if (self.currentDocument.isDirty) {
        [self updateDirtyMark];
    }

    if ([keyPath isEqualToString:@"showGuides"]) {
        [PCStageScene scene].guideLayer.hidden = ![[object valueForKeyPath:keyPath] boolValue];
    }
}

- (void) setupPencilCaseViews{
    self.pcSlidesViewController = [[PCSlidesViewController alloc] initWithNibName:@"PCSlidesView" bundle:nil] ;
    self.pcSlidesViewController.view.frame = self.pcSlideTabView.bounds;
    [self.pcSlideTabView addSubview:self.pcSlidesViewController.view];
    [self.duplicateMenuItem setTarget:self.pcSlidesViewController];
    [self.duplicateMenuItem setAction:@selector(duplicate:)];
    [self setupSuppliesList];
}


- (void) setupSuppliesList {
    self.suppliesTableViewController = [[PCSuppliesTableViewController alloc] initWithNibName:@"PCSuppliesTableView" bundle:nil];
    self.suppliesTableViewController.view.frame = self.pcSuppliesTabView.bounds;
    [self.pcSuppliesTabView addSubview:self.suppliesTableViewController.view];
}

#pragma mark Notifications to user

- (void)modalDialogTitle:(NSString *)title message:(NSString *)msg {
    NSAlert *alert = [NSAlert alertWithMessageText:title defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"%@", msg];
    [alert runModal];
}

- (void)modalStatusWindowStartWithTitle:(NSString *)title {
    [self modalStatusWindowStartWithTitle:title onCancelled:nil];
}

- (void)modalStatusWindowStartWithTitle:(NSString *)title onCancelled:(dispatch_block_t)cancellationCallback {
    if (!self.modalTaskStatusWindow) {
        self.modalTaskStatusWindow = [[TaskStatusWindow alloc] initWithWindowNibName:@"TaskStatusWindow"];
    }
    
    self.modalTaskStatusWindow.window.title = title;
    [self.modalTaskStatusWindow.window center];
    [self.modalTaskStatusWindow setCancelButtonVisible:cancellationCallback != nil];
    self.modalTaskStatusWindow.cancellationCallback = cancellationCallback;
    [self.modalTaskStatusWindow.window makeKeyAndOrderFront:self];
    [self modalStatusWindowProgress:-1];

    [[NSApplication sharedApplication] runModalForWindow:self.modalTaskStatusWindow.window];
}

- (void)modalStatusWindowFinish {
    [[NSApplication sharedApplication] stopModal];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.modalTaskStatusWindow.window orderOut:self];
    });
}

- (void)modalStatusWindowUpdateStatusText:(NSString *) text {
    self.modalTaskStatusWindow.status = text;
}

- (void)modalStatusWindowSetOnCancel:(dispatch_block_t)cancellationCallback {
    [self.modalTaskStatusWindow setCancelButtonVisible:cancellationCallback != nil];
    self.modalTaskStatusWindow.cancellationCallback = cancellationCallback;
}

- (void)modalStatusWindowProgress:(double)progress {
    [self.modalTaskStatusWindow setProgress:progress];
}

#pragma mark Handling selections

- (SKNode *)selectedSpriteKitNode {
    if ([self.selectedSpriteKitNodes count] > 0) {
        if (!self.nodeManager || ![self.nodeManager isManagingNodes:self.selectedSpriteKitNodes]) {
            self.nodeManager = [[PCNodeManager alloc] initWithNodes:self.selectedSpriteKitNodes uuid:[self.currentProjectSettings.nodeManagerUUID UUIDString]];
        }
    } else {
        self.nodeManager = nil;
    }
    return self.nodeManager;
}

- (void)setSelectedNode:(SKNode *)node {
    if (!node) return;
    self.selectedSpriteKitNodes = @[ node ];
}

- (void)setSelectedSpriteKitNodes:(NSArray *)selection {
    if ([selection isEqualToArray:self.selectedSpriteKitNodes]) return;
    
    [self willChangeValueForKey:@"selectedSpriteKitNode"];
    [self willChangeValueForKey:@"selectedSpriteKitNodes"];
    [self.physicsHandler willChangeSelection];

    [[PCStageScene scene] conditionallyEndFocusedNodeBasedOnSelectedNodes:selection];
    
    // Close the color picker
    [[NSColorPanel sharedColorPanel] close];
    
    if ([[self window] firstResponder] != self.sequenceHandler.outlineHierarchy && ![self.pcSlidesViewController isFirstResponder] && [[self window] firstResponder] != self.outlineHierarchyRightPane) {
        // Finish editing inspector
        if (![[self window] makeFirstResponder:[self window]]) return;
    }
    
    // Update selection
    NSMutableArray *mutableSelection = [NSMutableArray arrayWithArray:selection];
    [selectedSpriteKitNodes removeAllObjects];
    if (mutableSelection && mutableSelection.count > 0) {
        [selectedSpriteKitNodes addObjectsFromArray:mutableSelection];
        
        // Make sure all nodes have the same parent
        SKNode* lastNode = selectedSpriteKitNodes[selectedSpriteKitNodes.count - 1];
        SKNode* parent = lastNode.parent;
        
        for (int i = selectedSpriteKitNodes.count -1; i >= 0; i--) {
            SKNode* node = selectedSpriteKitNodes[i];
            if (node.parent != parent) {
                [selectedSpriteKitNodes removeObjectAtIndex:i];
            }
        }
    }
    
    [self.sequenceHandler updateOutlineViewSelection];
    [self.sequenceHandlerRightPane updateOutlineViewSelection];

    // just changing selection in the ouline view shouldn't add to undo, save a current copy to cache
    [self saveUndoStateToCacheForComparison];

    // Handle undo/redo
    //if (self.currentDocument) self.currentDocument.lastEditedProperty = nil;
    
    [self updateSmallTabBarsEnabled];
    [self.propertyInspectorHandler updateTemplates];
    
    [self didChangeValueForKey:@"selectedSpriteKitNode"];
    [self didChangeValueForKey:@"selectedSpriteKitNodes"];
    
    [self.physicsHandler didChangeSelection];
    
    [self updateInspectorFromSelection];
}

#pragma mark Window Delegate

- (void)windowDidResignMain:(NSNotification *)notification {
    if (notification.object == self.window) {
        [PCStageScene scene].paused = YES;
    }
}

- (void)windowDidBecomeMain:(NSNotification *)notification {
    if (notification.object == self.window) {
        [PCStageScene scene].paused = NO;
    }
}

- (void)windowDidResignKey:(NSNotification *)notification
{
    if (notification.object == self.guiWindow)
    {
        [self.guiView setSubviews:[NSArray array]];
    }
}

- (void) windowDidResize:(NSNotification *)notification
{
    [self.sequenceHandler updateScroller];
}


#pragma mark Populate Inspector

- (void) refreshProperty:(NSString*) name
{
    if (!self.selectedSpriteKitNode) return;
    
    [self.nodeManager updateNodeManagerInspectorForProperty:name];

    InspectorValue *inspectorValue = Underscore.array(self.inspectors).find(^BOOL(InspectorValue *inspector) {
        return [inspector.propertyName isEqualToString:name];
    });

    if (inspectorValue)
    {
        [inspectorValue refresh];
    }
}

- (void) refreshPropertiesOfType:(NSString*)type
{
    if (!self.selectedSpriteKitNode) return;

    for (InspectorValue *inspectorValue in self.inspectors) {
        if ([inspectorValue.propertyType isEqualToString:type]) {
            [inspectorValue refresh];
        }
    }
}

/**
 *  Refreshes all property inspectors "in place" as opposed to reloading the whole view hierarchy
 */
- (void)refreshAllProperties {
    NSArray *sortedInspectors = self.inspectors;

    InspectorSeparator *sectionSeparator = nil;
    NSMutableDictionary *offsets = [NSMutableDictionary dictionary];
    for (InspectorValue *inspector in sortedInspectors) {
        if ([inspector isKindOfClass:[InspectorSeparator class]]) {
            sectionSeparator = (InspectorSeparator *)inspector;
        }

        NSString *category = inspector.propertyCategory;
        if (PCIsEmpty(category) || !self.propertyCategoryToViewMapping[category]) {
            category = PCPropertyCategoryDefault;
        }
        CGFloat currentOffset = [offsets[category] floatValue];

        [self.nodeManager updateNodeManagerInspectorForProperty:inspector.propertyName];
        [inspector refresh];

        [inspector.view setFrameOrigin:NSMakePoint(0, currentOffset)];
        BOOL hide = sectionSeparator && inspector != sectionSeparator && ![sectionSeparator isExpanded];
        inspector.view.hidden = hide;
        if (!hide) {
            currentOffset += CGRectGetHeight(inspector.view.frame);
            offsets[category] = @(currentOffset);
        }
    }

    NSString *privateFunction = [NSString stringWithFormat:@"%@%@%@", @"_setDefault",@"KeyView",@"Loop"];
    SEL privateSelector = NSSelectorFromString(privateFunction);

    for (NSString *key in [offsets allKeys]) {
        NSView *view = self.propertyCategoryToViewMapping[key];
        [view setFrameSize:NSMakeSize([self.inspectorScroll contentSize].width, [offsets[key] floatValue])];
        //Undocumented function that resets the KeyViewLoop.
        if([view respondsToSelector:privateSelector]) {
            [view performSelector:privateSelector withObject:nil];
        }
    }
}

static InspectorValue* lastInspectorValue;
static BOOL hideAllToNextSeparator;

- (InspectorValue *)createInspectorOfType:(NSString *)type propertyName:(NSString *)prop setter:(NSString *)setterName displayName:(NSString *)displayName extra:(NSString *)e placeholderKey:(NSString *)placeholderKey {
    NSString* inspectorNibName = [NSString stringWithFormat:@"Inspector%@",type];

    // Create inspector
    InspectorValue* inspectorValue = [InspectorValue inspectorOfType:type withSelection:self.nodeManager andPropertyName:prop andSetterName:setterName andDisplayName:displayName andExtra:e placeholderKey:placeholderKey];
    NSAssert3(inspectorValue, @"property '%@' (%@) not found in class %@", prop, type, NSStringFromClass([self.selectedSpriteKitNode class]));
    // Load it's associated view
    [[NSBundle mainBundle] loadNibNamed:inspectorNibName owner:inspectorValue topLevelObjects:nil];
    return inspectorValue;
}

- (NSInteger)addInspectorPropertyOfType:(NSString *)type name:(NSString *)prop setterName:(NSString *)setterName placeholderKey:(NSString *)placeholderKey displayName:(NSString *)displayName extra:(NSString *)e readOnly:(BOOL)readOnly affectsProps:(NSArray *)affectsProps stepAmount:(CGFloat)stepAmount minimum:(CGFloat)minimum maximum:(CGFloat)maximum multiplier:(CGFloat)multiplier atOffset:(NSInteger)offset inspectorCategory:(NSString *)category{

    InspectorValue *inspectorValue = [self dequeueCachedInspectorForType:type propertyName:prop setter:setterName displayName:displayName extra:e placeholderKey:placeholderKey];
    if (!inspectorValue) {
        inspectorValue = [self createInspectorOfType:type propertyName:prop setter:setterName displayName:displayName extra:e placeholderKey:placeholderKey];
    }

    inspectorValue.inspectorValueBelow = nil;
    lastInspectorValue.inspectorValueBelow = inspectorValue;
    lastInspectorValue = inspectorValue;
    inspectorValue.readOnly = readOnly;
    inspectorValue.propertyCategory = category;
    
    // Save a reference in case it needs to be updated
    [self.inspectors addObject:inspectorValue];
    inspectorValue.affectsProperties = affectsProps;

    NSView* view = inspectorValue.view;
    
    [inspectorValue updateFonts];
    [inspectorValue willBeAdded];
    
    //if its a separator, check to see if it isExpanded, if not set all of the next non-separator InspectorValues to hidden and don't touch the offset
    if ([inspectorValue isKindOfClass:[InspectorSeparator class]]) {
        InspectorSeparator* inspectorSeparator = (InspectorSeparator*)inspectorValue;
        hideAllToNextSeparator = NO;
        if (!inspectorSeparator.isExpanded) {
            hideAllToNextSeparator = YES;
        }
        // Reset isExpanded property to itself so it will reset the binding and update the discloure arrow
        inspectorSeparator.isExpanded = inspectorSeparator.isExpanded;
        NSRect frame = [view frame];
        [view setFrame:NSMakeRect(0, offset, frame.size.width, frame.size.height)];
        offset += frame.size.height;
    }
    else {
        view.hidden = hideAllToNextSeparator;
        if (!hideAllToNextSeparator) {
            NSRect frame = [view frame];
            [view setFrame:NSMakeRect(0, offset, frame.size.width, frame.size.height)];
            offset += frame.size.height;
        }
    }

    NSView *inspectorDocumentView = self.propertyCategoryToViewMapping[category] ? : self.inspectorDocumentView;
    // Add view to inspector and place it at the bottom
    [inspectorDocumentView addSubview:view];
    [view setFrameSize:NSMakeSize(CGRectGetWidth(inspectorDocumentView.frame), CGRectGetHeight(view.frame))];
    [view setAutoresizingMask:NSViewWidthSizable];

    [PCTextFieldStepper setFormatterFor:maximum inspectorValue:inspectorValue multiplier:multiplier stepAmount:stepAmount minimum:minimum];

    return offset;
}

- (NSInteger)addInspectorPropertyOfType:(NSString *)type name:(NSString *)prop setterName:(NSString *)setterName placeholderKey:(NSString *)placeholderKey displayName:(NSString *)displayName extra:(NSString *)e readOnly:(BOOL)readOnly affectsProps:(NSArray *)affectsProps atOffset:(int)offset inspectorCategory:(NSString *)category {
    return [self addInspectorPropertyOfType:type name:prop setterName:setterName placeholderKey:placeholderKey displayName:displayName extra:e readOnly:readOnly affectsProps:affectsProps stepAmount:PCUseDefaultTextStepAmount atOffset:offset inspectorCategory:category];
}

- (NSInteger)addInspectorPropertyOfType:(NSString *)type name:(NSString *)prop setterName:(NSString *)setterName placeholderKey:(NSString *)placeholderKey displayName:(NSString *)displayName extra:(NSString *)e readOnly:(BOOL)readOnly affectsProps:(NSArray *)affectsProps stepAmount:(CGFloat)stepAmount atOffset:(NSInteger)offset inspectorCategory:(NSString *)category {
    return [self addInspectorPropertyOfType:type name:prop setterName:setterName placeholderKey:placeholderKey displayName:displayName extra:e readOnly:readOnly affectsProps:affectsProps stepAmount:stepAmount minimum:-CGFLOAT_MAX maximum:CGFLOAT_MAX multiplier:1.0 atOffset:offset inspectorCategory:category];
}

- (IBAction)cannotClickMixedState:(id)sender {
    if ([sender isKindOfClass:[NSButton class]]) {
        NSButton *button = sender;
        if([button state] == NSMixedState){
            [button performClick:sender];
            return;
        }
    }
}

- (void)updateSpriteKitNode:(SKNode *)node withAnimateablePropertyValue:(id)value propName:(NSString *)propertyName type:(CCBKeyframeType)type {
    SequencerHandler *sequencerHandler = [SequencerHandler sharedHandler];

    NodeInfo *nodeInfo = node.userObject;
    PlugInNode *plugIn = nodeInfo.plugIn;

    if ([plugIn isAnimatableProperty:propertyName spriteKitNode:node]) {
        SequencerSequence *currentSequence = sequencerHandler.currentSequence;
        int seqId = currentSequence.sequenceId;
        SequencerNodeProperty *sequencerNodeProperty = [node sequenceNodeProperty:propertyName sequenceId:seqId];

        if (sequencerNodeProperty) {
            SequencerKeyframe *keyframe = [sequencerNodeProperty keyframeAtTime:currentSequence.timelinePosition];
            if (keyframe) {
                keyframe.value = value;
            }
            else {
                keyframe = [[SequencerKeyframe alloc] init];
                keyframe.time = currentSequence.timelinePosition;
                keyframe.value = value;
                keyframe.type = type;
                keyframe.name = sequencerNodeProperty.propName;

                [sequencerNodeProperty addKeyframe:keyframe];
                [self updateInspectorFromSelection];
            }

            BOOL sequenceIsDefault = (currentSequence.sequenceId == CardDefaultSequenceId);
            BOOL keyframeIsFirst = ([sequencerNodeProperty.keyframes indexOfObject:keyframe] == 0);
            if (sequenceIsDefault && keyframeIsFirst) {
                nodeInfo.baseValues[propertyName] = value;
            }

            [sequencerHandler redrawTimeline];
        } else {
            nodeInfo.baseValues[propertyName] = value;
        }
    }
}

- (BOOL) isDisabledProperty:(NSString*)name animatable:(BOOL)animatable
{
    // Only animatable properties can be disabled
    if (!animatable) return NO;
    
    SequencerSequence* seq = [SequencerHandler sharedHandler].currentSequence;
    
    SequencerNodeProperty* seqNodeProp = [self.selectedSpriteKitNode sequenceNodeProperty:name sequenceId:seq.sequenceId];
    
    // Do not disable if animation hasn't been enabled
    if (!seqNodeProp) return NO;
    
    // Disable visiblilty if there are keyframes
    if (seqNodeProp.keyframes.count > 0 && [name isEqualToString:@"visible"]) return YES;
    
    // Do not disable if we are currently at a keyframe

    if ([seqNodeProp hasKeyframeAtTime: seq.timelinePosition]) return NO;
    // Between keyframes - disable
    return YES;
}

- (void)updateInspectorFromSelection {
    [self updateInspectorFromSelection:NO];
}

- (void)cacheInspector:(InspectorValue *)inspector {
    NSMutableArray *cacheArray = self.cachedInspectors[inspector.className];
    if (!cacheArray) {
        cacheArray = [NSMutableArray array];
        self.cachedInspectors[inspector.className] = cacheArray;
    }
    [cacheArray addObject:inspector];
}

- (InspectorValue *)dequeueCachedInspectorForType:(NSString *)type propertyName:(NSString *)propertyName setter:(NSString *)setterName displayName:(NSString *)displayName extra:(NSString *)extra placeholderKey:(NSString *)placeholderKey {
    NSString *inspectorClass = [NSString stringWithFormat:@"Inspector%@", type];
    NSMutableArray *cacheArray = self.cachedInspectors[inspectorClass];
    if (PCIsEmpty(cacheArray)) return nil;
    InspectorValue *result = cacheArray.firstObject;
    [cacheArray removeObjectAtIndex:0];
    [result setSelection:(PCNodeManager *)self.selectedSpriteKitNode propertyName:propertyName setterName:setterName displayName:displayName extra:extra placeholderKey:placeholderKey];
    [result refresh];
    return result;
}

- (void)updateInspectorFromSelection:(BOOL)forceUpdate {
    if (self.currentInspectorNodeManager && self.currentInspectorNodeManager == self.nodeManager && !forceUpdate) {
        [self refreshAllProperties];
        return;
    }

    self.currentInspectorNodeManager = self.nodeManager;
    
    self.savedInspectorScrollPoint = self.inspectorScroll.contentView.bounds.origin;

    // Notifiy panes that they will be removed
    for (InspectorValue *inspector in self.inspectors) {
        [inspector willBeRemoved];
        [self cacheInspector:inspector];
    }
    
    // Remove all old inspector panes
    [self.separators makeObjectsPerformSelector:@selector(willBeRemoved)];
    [self.cachedSeparators addObjectsFromArray:self.separators];
    [self.separators removeAllObjects];
    [self.inspectors removeAllObjects];

    NSMutableDictionary *propertyCategoryToPaneOffsetMapping = [NSMutableDictionary dictionary];

    for (NSView *propertyCategoryView in [self.propertyCategoryToViewMapping allValues]) {
        [propertyCategoryView setFrameSize:NSMakeSize(233, 1)];
        [[propertyCategoryView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }

    // Add show panes according to selections
    if (!self.selectedSpriteKitNode) {
        CGFloat paneOffset = [self addInspectorPropertyOfType:@"NoSelection" name:@"NoSelection" setterName:@"NoSelection" placeholderKey:nil displayName:@"No Selection" extra:nil readOnly:NO affectsProps:nil atOffset:0 inspectorCategory:PCPropertyCategoryDefault];
        [self.inspectorDocumentView setFrameSize:NSMakeSize([self.inspectorScroll contentSize].width, paneOffset)];
        return;
    }

    NodeInfo* info = self.selectedSpriteKitNode.userObject;
    PlugInNode* plugIn = info.plugIn;
    
    BOOL isCCBSubFile = [plugIn.nodeClassName isEqualToString:@"CCBFile"];
    
    // Add panes for each property
    if (plugIn) {
        for (NSDictionary *propInfo in plugIn.nodeProperties) {
            NSString *type = propInfo[@"type"];
            NSString *inspectorType = propInfo[@"inspectorType"] ?: type;
            NSString *editorName = propInfo[@"editorName"];
            NSString *name = propInfo[@"name"];
            NSString *placeholderKey = propInfo[@"placeholderKey"];
            NSString *displayName = propInfo[@"displayName"];
            BOOL readOnly = [propInfo[@"readOnly"] boolValue];
            NSArray *affectsProps = propInfo[@"affectsProperties"];
            NSString *extra = propInfo[@"extra"];
            NSString *propertyCategory = propInfo[@"propertyCategory"];
            BOOL hidden = [propInfo[@"hidden"] boolValue];
            CGFloat stepAmount = [propInfo[@"stepAmount"] floatValue];
            CGFloat maximum =[propInfo[@"maximum"] floatValue];
            CGFloat minimum =[propInfo[@"minimum"] floatValue];
            CGFloat multiplier =[propInfo[@"multiplier"] floatValue];
            
            if ([self.selectedSpriteKitNode shouldDisableProperty:name]) readOnly = YES;
            
            // Handle Flash skews
            BOOL usesFlashSkew = [self.selectedSpriteKitNode usesFlashSkew];
            if (usesFlashSkew && [name isEqualToString:@"rotation"]) continue;
            if (!usesFlashSkew && [name isEqualToString:@"rotationX"]) continue;
            if (!usesFlashSkew && [name isEqualToString:@"rotationY"]) continue;
            if (hidden) continue;
            
            // Handle read only for locked nodes, animated properties can be edited
            if (self.selectedSpriteKitNode.locked)
            {
                readOnly = YES;
            }
            
            //For the separators; should make this a part of the definition
            if (!name) {
                name = displayName;
            }

            if (!self.propertyCategoryToViewMapping[propertyCategory]) {
                propertyCategory = PCPropertyCategoryDefault;
            }
            CGFloat currentOffset = [propertyCategoryToPaneOffsetMapping[propertyCategory] floatValue];
            CGFloat updatedOffset = [self addInspectorPropertyOfType:inspectorType name:name setterName:editorName ? : name placeholderKey:placeholderKey displayName:displayName extra:extra readOnly:readOnly affectsProps:affectsProps stepAmount:stepAmount minimum:minimum maximum:maximum multiplier:multiplier atOffset:currentOffset inspectorCategory:propertyCategory];
            propertyCategoryToPaneOffsetMapping[propertyCategory] = @(updatedOffset);
        }
    }
    else {
        NSLog(@"WARNING info:%@ plugIn:%@ selectedSpriteKitNode: %@", info, plugIn, self.selectedSpriteKitNode);
    }

    // Custom properties
    NSString* customClass = [self.selectedSpriteKitNode extraPropForKey:@"customClass"];
    NSArray* customProps = self.selectedSpriteKitNode.customProperties;
    if (customClass && ![customClass isEqualToString:@""]) {
        if ([customProps count] || !isCCBSubFile) {
            CGFloat currentOffset = [propertyCategoryToPaneOffsetMapping[PCPropertyCategoryDefault] floatValue];
            CGFloat newOffset = [self addInspectorPropertyOfType:@"Separator" name:[self.selectedSpriteKitNode extraPropForKey:@"customClass"] setterName:nil placeholderKey:nil displayName:[self.selectedSpriteKitNode extraPropForKey:@"customClass"] extra:nil readOnly:YES affectsProps:nil atOffset:currentOffset inspectorCategory:PCPropertyCategoryDefault];
            propertyCategoryToPaneOffsetMapping[PCPropertyCategoryDefault] = @(newOffset);
        }
        
        for (CustomPropSetting* setting in customProps) {
            CGFloat currentOffset = [propertyCategoryToPaneOffsetMapping[PCPropertyCategoryDefault] floatValue];
            CGFloat newOffset = [self addInspectorPropertyOfType:@"Custom" name:setting.name setterName:setting.name placeholderKey:nil displayName:setting.name extra:nil readOnly:NO affectsProps:NULL atOffset:currentOffset inspectorCategory:PCPropertyCategoryDefault];
            propertyCategoryToPaneOffsetMapping[PCPropertyCategoryDefault] = @(newOffset);
        }
        
        if (!isCCBSubFile) {
            CGFloat currentOffset = [propertyCategoryToPaneOffsetMapping[PCPropertyCategoryDefault] floatValue];
            CGFloat newOffset = [self addInspectorPropertyOfType:@"CustomEdit" name:nil setterName:nil placeholderKey:nil displayName:@"" extra:nil readOnly:NO affectsProps:nil atOffset:currentOffset inspectorCategory:PCPropertyCategoryDefault];
            propertyCategoryToPaneOffsetMapping[PCPropertyCategoryDefault] = @(newOffset);
        }
    }
    
    hideAllToNextSeparator = NO;

    for (NSString *inspectorKey in [propertyCategoryToPaneOffsetMapping allKeys]) {
        NSView *documentView = self.propertyCategoryToViewMapping[inspectorKey];
        [documentView setFrameSize:NSMakeSize([self.inspectorScroll contentSize].width, [propertyCategoryToPaneOffsetMapping[inspectorKey] floatValue])];
    }

    [self.propertyInspectorHandler updateTemplates];
    
    NSString * privateFunction = [NSString stringWithFormat:@"%@%@%@", @"_setDefault",@"KeyView",@"Loop"];
    SEL privateSelector = NSSelectorFromString(privateFunction);
    
    //Undocumented function that resets the KeyViewLoop.
    if([self.inspectorDocumentView respondsToSelector:privateSelector]) {
        [self.inspectorDocumentView performSelector:privateSelector withObject:nil];
    }

    [[self.inspectorScroll documentView] scrollPoint:self.savedInspectorScrollPoint];
}

#pragma mark Populating menus

- (void) updateResolutionMenu
{
    if (!self.currentDocument) return;
    
    // Clear the menu
    [self.menuResolution removeAllItems];
    
    // Add all new resolutions
    int i = 0;
    for (PCDeviceResolutionSettings* resolution in self.currentDocument.resolutions)
    {
        NSString* keyEquivalent = @"";
        if (i < 10) keyEquivalent = [NSString stringWithFormat:@"%d",i+1];
        
        NSMenuItem* item = [[NSMenuItem alloc] initWithTitle:resolution.name action:@selector(menuResolution:) keyEquivalent:keyEquivalent];
        item.target = self;
        item.tag = i;
        
        [self.menuResolution addItem:item];
        if (i == self.currentDocument.currentResolution) item.state = NSOnState;
        
        i++;
    }
}

- (void) updateTimelineMenu
{
    if (!self.currentDocument)
    {
        self.lblTimeline.stringValue = @"";
        self.lblTimelineChained.stringValue = @"";
        [self.menuTimelinePopup setEnabled:NO];
        [self.menuTimelineChainedPopup setEnabled:NO];
        return;
    }
    
    [self.menuTimelinePopup setEnabled:YES];
    [self.menuTimelineChainedPopup setEnabled:YES];
    
    // Clear menu
    [self.menuTimeline removeAllItems];
    [self.menuTimelineChained removeAllItems];
    
    int currentId = self.sequenceHandler.currentSequence.sequenceId;
    int chainedId = self.sequenceHandler.currentSequence.chainedSequenceId;
    
    // Add dummy item
    NSMenuItem* itemDummy = [[NSMenuItem alloc] initWithTitle:@"Dummy" action:NULL keyEquivalent:@""];
    [self.menuTimelineChained addItem:itemDummy];
    
    // Add empty option for chained seq
    NSMenuItem* itemCh = [[NSMenuItem alloc] initWithTitle: @"No Chained Timeline" action:@selector(menuSetChainedSequence:) keyEquivalent:@""];
    itemCh.target = self.sequenceHandler;
    itemCh.tag = -1;
    if (chainedId == -1) [itemCh setState:NSOnState];
    [self.menuTimelineChained addItem:itemCh];
    
    // Add separator item
    [self.menuTimelineChained addItem:[NSMenuItem separatorItem]];
    
    for (SequencerSequence* seq in self.currentDocument.sequences)
    {
        // Add to sequence selector
        NSMenuItem* item = [[NSMenuItem alloc] initWithTitle:seq.name action:@selector(menuSetSequence:) keyEquivalent:@""];
        item.target = self.sequenceHandler;
        item.tag = seq.sequenceId;
        if (currentId == seq.sequenceId) [item setState:NSOnState];
        [self.menuTimeline addItem:item];
        
        // Add to chained sequence selector
        itemCh = [[NSMenuItem alloc] initWithTitle: seq.name action:@selector(menuSetChainedSequence:) keyEquivalent:@""];
        itemCh.target = self.sequenceHandler;
        itemCh.tag = seq.sequenceId;
        if (chainedId == seq.sequenceId) [itemCh setState:NSOnState];
        [self.menuTimelineChained addItem:itemCh];
    }
    
    if (self.sequenceHandler.currentSequence) self.lblTimeline.stringValue = self.sequenceHandler.currentSequence.name;
    if (chainedId == -1)
    {
        self.lblTimelineChained.stringValue = @"No chained timeline";
    }
    else
    {
        for (SequencerSequence* seq in self.currentDocument.sequences)
        {
            if (seq.sequenceId == chainedId)
            {
                self.lblTimelineChained.stringValue = seq.name;
                break;
            }
        }
    }
}

#pragma mark Document handling

- (IBAction)searchResourceAction:(id)sender {
	[self.resourceOutlineHandler searchAction:sender];
}

- (IBAction)importResourceAction:(id)sender {
    [NSOpenPanel showImportResourcesDialog:^(BOOL success) {
        [self.progressIndicator stopAnimation:self];
        [self.progressIndicator setHidden:YES];
    } toResourceDirectory:self.resourceOutlineView.selectedResourceDirectory];
}

- (void)didStartImportingResources:(NSNotification *)notification {
    [self.progressIndicator setHidden:NO];
    [self.progressIndicator startAnimation:self];
}

- (BOOL) hasDirtyDocument
{
    for (PCSlide *slide in self.currentProjectSettings.slideList) {
        if (slide.document.isDirty) return YES;
    }
    for (CCBDocument *document in self.currentProjectSettings.subcontentDocuments) {
        if (document.isDirty) return YES;
    }
    if (self.currentProjectSettings.isDirty) {
        return YES;
    }
    if ([[NSDocumentController sharedDocumentController] hasEditedDocuments]) {
        return YES;
    }
    return NO;
}

- (void) updateDirtyMark
{
    [self.window setDocumentEdited:[self hasDirtyDocument]];
}

- (void)prepareForDocumentSwitch {
    [self.window makeKeyWindow];

    PCStageScene *stageScene = [PCStageScene scene];

    if (![self hasOpenedDocument]) return;
    [self.currentDocument updateWithCurrentDocumentState];
    self.currentDocument.stageZoom = stageScene.stageZoom;
    self.currentDocument.stageScrollOffset = stageScene.scrollOffset;
    
    PCSlide *slide = [self slideWithDocumentPath:self.currentDocument.fileName];
    if (slide) {
        [self saveFile:[slide absoluteFilePath] withPreview:YES];
    }
}

- (NSMutableArray*) updateResolutions:(NSMutableArray*) resolutions forDocDimensionType:(int) type
{
    NSMutableArray* updatedResolutions = [NSMutableArray array];
    
    if (type == kCCBDocDimensionsTypeNode)
    {
        if (self.currentProjectSettings.deviceResolutionSettings.designTarget == PCDesignTargetFlexible)
        {
            [updatedResolutions addObject:[PCDeviceResolutionSettings settingIPhone]];
            [updatedResolutions addObject:[PCDeviceResolutionSettings settingIPad]];
        }
        else
        {
            [updatedResolutions addObject:[PCDeviceResolutionSettings settingFixed]];
        }
    }
    else if (type == kCCBDocDimensionsTypeLayer)
    {
        PCDeviceResolutionSettings* settingDefault = resolutions.firstObject;
        
        if (self.currentProjectSettings.deviceResolutionSettings.designTarget == PCDesignTargetFixed)
        {
            settingDefault.name = @"Fixed";
            settingDefault.scale = 2;
            settingDefault.ext = @"tablet phonehd";
            [updatedResolutions addObject:settingDefault];
        }
        else if (self.currentProjectSettings.deviceResolutionSettings.designTarget == PCDesignTargetFlexible)
        {
            settingDefault.name = @"Phone";
            settingDefault.scale = 1;
            settingDefault.ext = @"phone";
            [updatedResolutions addObject:settingDefault];
            
            PCDeviceResolutionSettings* settingTablet = [settingDefault copy];
            settingTablet.name = @"Tablet";
            settingTablet.scale = self.currentProjectSettings.tabletPositionScaleFactor;
            settingTablet.ext = @"tablet phonehd";
            [updatedResolutions addObject:settingTablet];
        }
    }
    else if (type == kCCBDocDimensionsTypeFullScreen)
    {
        if (self.currentProjectSettings.deviceResolutionSettings.deviceOrientation == PCDeviceTargetOrientationLandscape)
        {
            // Full screen landscape
            if (self.currentProjectSettings.deviceResolutionSettings.designTarget == PCDesignTargetFixed)
            {
                [updatedResolutions addObject:[PCDeviceResolutionSettings settingFixedLandscape]];
            }
            else if (self.currentProjectSettings.deviceResolutionSettings.designTarget == PCDesignTargetFlexible)
            {
                [updatedResolutions addObject:[PCDeviceResolutionSettings settingIPhone6PlusLandscape]];
                [updatedResolutions addObject:[PCDeviceResolutionSettings settingIPadLandscape]];
                [updatedResolutions addObject:[PCDeviceResolutionSettings settingIPhoneLandscape]];
            }
        }
        else
        {
            // Full screen portrait
            if (self.currentProjectSettings.deviceResolutionSettings.designTarget == PCDesignTargetFixed)
            {
                [updatedResolutions addObject:[PCDeviceResolutionSettings settingFixedPortrait]];
            }
            else if (self.currentProjectSettings.deviceResolutionSettings.designTarget == PCDesignTargetFlexible)
            {
                [updatedResolutions addObject:[PCDeviceResolutionSettings settingIPhone6PlusPortrait]];
                [updatedResolutions addObject:[PCDeviceResolutionSettings settingIPadPortrait]];
                [updatedResolutions addObject:[PCDeviceResolutionSettings settingIPhonePortrait]];
            }
        }
    }
    
    return updatedResolutions;
}

- (void)replaceDocumentData:(NSMutableDictionary *)doc {
    [self replaceDocumentData:doc document:self.currentDocument reloadInspectors:YES];
}

- (void)replaceDocumentData:(NSMutableDictionary*)documentData document:(CCBDocument *)document reloadInspectors:(BOOL)reloadInspectors {
    if ([self isShowingInstantAlpha]) {
        [self.instantAlphaViewController cancel];
    }
    
    [loadedSelectedSpriteKitNodes removeAllObjects];

    self.jsControlled = [documentData[@"jsControlled"] boolValue];
    [[PCStageScene scene] setStageBorder:self.currentProjectSettings.stageBorderType];
    NSInteger documentDimensionsType = [documentData[@"docDimensionsType"] intValue];
    self.canEditStageSize = (documentDimensionsType == kCCBDocDimensionsTypeLayer);

    [document loadResolutionDataFromDocumentData:documentData forProject:self.currentProjectSettings documentDimensionsType:documentDimensionsType];
    [document loadSequencesFromDocumentData:documentData];
    self.sequenceHandler.currentSequence = [document currentSequence];

    PCDeviceResolutionSettings *resolution = document.resolutions[document.currentResolution];
    // !!! selectedSpriteKitNodes MUST be set before [[PCStageScene scene] removeRootNode] is called, at it has a side effect of saving the card state, which will ERASE THE CARD when changing cards if done after removeRootNode is called.
    self.selectedSpriteKitNodes = nil;
    [[PCStageScene scene] removeRootNode];
    SKNode *loadedSpriteKitRootNode = [CCBReaderInternal spriteKitNodeGraphFromDocumentDictionary:documentData parentSize:CGSizeMake(resolution.width, resolution.height)];
    [[PCStageScene scene] replaceRootNodeWith:loadedSpriteKitRootNode];
    self.currentDocument = document;

    [self reloadObjectHierarchy];
    [self.sequenceHandler updateOutlineViewSelection];
    if (reloadInspectors) {
        [self updateInspectorFromSelection];
    }

    [self.sequenceHandler updateExpandedForNode:[PCStageScene scene].rootNode];
    [[PCStageScene scene].guideLayer loadSerializedGuides:documentData[@"guides"]];
    self.selectedSpriteKitNodes = loadedSelectedSpriteKitNodes;

    [self updateCanvasBorderMenu];
    [self updatePositionScaleFactor];
    [self updateResolutionMenu];
    [self.behaviourListViewController validate];
    [self.physicsHandler didReloadScene];
}

- (void)switchToDocument:(CCBDocument *)document forceReload:(BOOL)forceReload {
    [self switchToDocument:document forceReload:forceReload reloadInspectors:YES];
}

- (void)switchToDocument:(CCBDocument *)document forceReload:(BOOL)forceReload reloadInspectors:(BOOL)reloadInspectors {
    if (!forceReload && [document.fileName isEqualToString:self.currentDocument.fileName]) return;

    [self prepareForDocumentSwitch];

    NSMutableDictionary *documentData = document.docData;

    @try {
        [self replaceDocumentData:documentData document:document reloadInspectors:reloadInspectors];
    }
    @catch (NSException *exception) {
        NSLog(@"Failed to load document: %@", exception);
        return;
    }

    [self updateResolutionMenu];
    [self updateTimelineMenu];

    [self.behaviourListViewController loadCard:[self slideWithDocument:document]];
    
    // Make sure timeline is up to date
    [self.sequenceHandler updatePropertiesToTimelinePosition];
}

- (void) switchToDocument:(CCBDocument*) document
{
    [self switchToDocument:document forceReload:NO];
}

- (void)closeLastDocument {
    self.selectedSpriteKitNodes = nil;
    [[PCStageScene scene] replaceRootNodeWith:nil];
    [[PCStageScene scene] setStageSize:CGSizeMake(0, 0) centeredOrigin:YES];
    [[PCStageScene scene].guideLayer removeAllGuides];
    [[PCStageScene scene].rulerLayer mouseExited:nil];

    self.currentDocument = nil;
    self.sequenceHandler.currentSequence = nil;

    [self updateTimelineMenu];
    [self reloadObjectHierarchy];

    //[resManagerPanel.window setIsVisible:NO];

    self.hasOpenedDocument = NO;
}

- (BOOL)saveAndCloseProject {
    if (![self promptUserToSave]) return NO;
    [self closeProject];
    return YES;
}

- (void)closeProject
{
    // Purging unused images is no longer done during every save since doing so can cause images to be
    // deleted out from under the undo/redo stack. Delaying until the project is closed allows the edited
    // images to live as long as the undo manager for the project. This fixes instant-alph undo/redo.
    //
    // Since purging unused images necessarily involves saving, we don't purge if the document is still
    // dirty. If the document were still dirty at this point, it would mean that the user had indicated
    // that the current changes should not be saved prior to closing.
    if (self.currentDocument && !self.currentDocument.isDirty) {
        [self removeUnusedEditedImagesInCurrentProject];
        [self saveAllDocuments:nil];
    }

    [[PCResourceLibrary sharedLibrary] clearLibrary];

    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    [self.window setTitle:[info objectForKey:@"CFBundleName"]];
    [self.window setRepresentedURL:nil];
    
    [self.currentProjectSettings removeObserver:self forKeyPath:@"showGuides"];
    // Remove resource paths
    self.currentProjectSettings = nil;
    [[PCResourceManager sharedManager] closeProject];
    
    // Remove language file
    self.localizationEditorHandler.managedFile = nil;
    
    [self updateWarningsButton];
    [self updateSmallTabBarsEnabled];
    
    [self closeLastDocument];
    
    [[PCUndoManager sharedPCUndoManager] removeAllActions];    
}

#pragma mark Opening Projects

- (IBAction)openProjectWithPanel:(id)sender {
    [self showOpenProjectPanelWithCompletion:^(BOOL cancelled, BOOL convertProjectCancelled) {
        if (convertProjectCancelled) {
            //If we've just cancelled the convertProject popup, then we'll still want the open panel to reopen
            [self openProjectWithPanel:nil];
        }
    }];
}

- (void)showOpenProjectPanelWithCompletion:(void(^)(BOOL cancelled, BOOL convertProjectCancelled))completion {
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    openPanel.canChooseFiles = YES;
    openPanel.allowedFileTypes = @[ @"pcase", @"pencilcase" ];
    openPanel.canChooseDirectories = NO;
    openPanel.allowsMultipleSelection = NO;
    
    [openPanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        if (result != NSOKButton) {
            if (completion) completion(YES, NO);
            return;
        }

        //Hide the panel so that if we get any prompts and we need to reopen the openPanel, the animation flow is cleaner
        [openPanel orderOut:nil];
        
        for (NSURL *fileURL in openPanel.URLs) {
            NSString *fileName = [fileURL path];
            
            [self openProject:fileName autoUpgrade:NO success:^{
                [self refreshUIForOpenedProject];
                if (completion) completion(NO, NO);
            } failure:^(BOOL convertProjectCancelled, NSError *error) {
                if (error) {
                    [self displayAlertForOpenProjectError:error];
                }
                
                if (completion) {
                    completion(NO, convertProjectCancelled);
                }
                
                return;
            }];
        }
    }];
}

- (ValidateProjectDictionaryFileVersionInfoStatus)validateProjectDictionaryFileVersionInfo:(NSDictionary *)projectDictionary autoUpgrade:(BOOL)autoUpgrade error:(NSError **)error {
    NSError *projectSettingsError;
    PCSerializationStatus status = [PCProjectSettings validateSerialization:projectDictionary error:&projectSettingsError];
    if (error) {
        *error = projectSettingsError;
    }

    switch (status) {
        case PCSerializationStatusNeedsUpdateAndJSRegeneration:
        case PCSerializationStatusNeedsUpdate: {
            if (!autoUpgrade) {
                NSAlert *alert = [NSAlert alertWithMessageText:@"Convert Project" defaultButton:@"Cancel" alternateButton:@"Convert" otherButton:nil informativeTextWithFormat:@"This project needs to be converted to a newer version of PencilCase to be opened. You will no longer be able to open this project in older versions of PencilCase"];
                NSInteger result = [alert runModal];
                if (result == NSAlertDefaultReturn) {
                    return ValidateProjectDictionaryFileVersionInfoStatusCancelledConvertProject;
                }
            };

            if (PCSerializationStatusNeedsUpdate == status) {
                return ValidateProjectDictionaryFileVersionInfoStatusAcceptedConvertProject;
            } else {
                return ValidateProjectDictionaryFileVersionInfoStatusAcceptedConvertAndRegenerateJS;
            }
        }
        case PCSerializationStatusUnsupportedFileType:
        case PCSerializationStatusUnsupportedVersion:
            return ValidateProjectDictionaryFileVersionInfoStatusNotValid;
        case PCSerializationStatusValid:
        default:
            return ValidateProjectDictionaryFileVersionInfoStatusValid;
    }
}

// This method should *not* do anything other than open a project. Any UI changes should happen in refreshUIForOpenedProject.
- (void)openProject:(NSString *)packagePath autoUpgrade:(BOOL)autoUpgrade success:(void(^)(void))success failure:(void(^)(BOOL convertProjectCancelled, NSError *error))failure {
    if (![self promptUserToSave]) {
        if (failure) failure (NO, nil);
        return;
    }

    // Convert folder to actual project file
    NSString *projectPath = [self findProject:packagePath];

    [self loadProjectDictionaryOrBackupWithFileName:projectPath autoUpgrade:autoUpgrade success:^(NSDictionary *projectDictionary, ValidateProjectDictionaryFileVersionInfoStatus status) {
        [self loadProjectFromValidProjectDictionary:projectDictionary packagePath:packagePath projectPath:projectPath projectSettingsValidationStatus:status success:success failure:^(NSError *error) {
            if (failure) failure(NO, error);
        }];
    } failure:failure];
}

- (void)loadProjectFromValidProjectDictionary:(NSDictionary *)projectDictionary packagePath:(NSString *)packagePath projectPath:(NSString *)projectPath projectSettingsValidationStatus:(ValidateProjectDictionaryFileVersionInfoStatus)projectSettingsValidationStatus success:(void(^)(void))success failure:(void(^)(NSError *error))failure  {
    [self backupProjectData:projectDictionary withOriginalFileName:projectPath];

    // Add to recent list of opened documents
    NSURL *fileURL = [NSURL fileURLWithPath:packagePath];
    [[NSDocumentController sharedDocumentController] noteNewRecentDocumentURL:fileURL];
    [[PCUserProjectDocuments userDocuments] addProjectToUserDocumentsList:fileURL.path isFavorite:NO];

    PCProjectSettings *projectSettings = [[PCProjectSettings alloc] initWithValidSerialization:projectDictionary fromPackageURL:fileURL];

    // Close currently open project
    [self closeProject];

    if ([projectSettings.appName length] == 0) projectSettings.appName = [[projectPath lastPathComponent] stringByDeletingPathExtension];
    projectSettings.projectFileReferenceURL = [[NSURL fileURLWithPath:projectPath isDirectory:NO] fileReferenceURL];

    self.currentProjectSettings = projectSettings;
    [projectSettings watchOwnDirtyingProperties];
    // Move this to right after the project is set since the removeObserver is called for all closedProject even ones that may have failed to open succesfully
    [self.currentProjectSettings addObserver:self forKeyPath:@"showGuides" options:NSKeyValueObservingOptionInitial context:AppDelegateContext];

    self.nodeManager.uuid = [self.currentProjectSettings.nodeManagerUUID UUIDString];

    // If the user is still using the old file format, migrate the resource paths
    [[PCResourceManager sharedManager] migrateDirectoriesFromProjectSettingsDictionary:projectDictionary];
    if (![[PCResourceManager sharedManager] reloadForProject:projectSettings]) {
        [self closeProject]; // Since its set as the current project already, make sure to close it
        if (failure) failure ([NSError pc_invalidProjectError]);
        return;
    }

    // We're doing this here (it would have otherwise occured when we initialized the project settings from the
    // dictionary) because the resource manager wasn't set up at that time, and slide deserialization (which will
    // also deserialize the behaviours and thus tokens) relies on paths and resources from that manager.
    // I've left the slideList initialization in that method for now because it *does* make more sense for it to be
    // there, but this is a quick workaround until further untangling of PCProjectSettings and PCResourceManager can
    // take place.
    projectSettings.slideList = [projectSettings deserializeSlideListInDictionary:projectDictionary key:@"slideList"];

    // Load or create language file
    NSString *langFile = [[PCResourceManager sharedManager].rootDirectory.directoryPath stringByAppendingPathComponent:@"Strings.ccbLang"];
    self.localizationEditorHandler.managedFile = langFile;

    [self loadProjectFromSettings:projectSettings projectSettingsValidationStatus:projectSettingsValidationStatus];

    [self removeOldPublishDirectoryFromProjectAtURL:fileURL];
    [self.propertyInspectorHandler loadTemplateLibrary];
    [self.projectViewTabs setEnabled:YES];
    [self.itemViewTabs setEnabled:YES];
    
    if (success) success();
    return;
}

- (void)loadProjectFromSettings:(PCProjectSettings *)projectSettings projectSettingsValidationStatus:(ValidateProjectDictionaryFileVersionInfoStatus)projectSettingsValidationStatus {
    NSArray *resourcePaths = projectSettings.absoluteResourcePaths;
    if (resourcePaths.count == 0) {
        return;
    }

    NSString *firstResourcePath = resourcePaths.firstObject;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *directoryContentsError;
    NSArray *firstResourceDirectoryContents = [fileManager contentsOfDirectoryAtPath:firstResourcePath error:&directoryContentsError];
    if (!firstResourceDirectoryContents) {
        PCLog(@"Error getting contents of resource directory with path %@: %@", firstResourcePath, directoryContentsError);
    }

    NSString *ccbFilePath;
    NSInteger numberOfCCBFiles = 0;
    for (NSString *filePath in firstResourceDirectoryContents) {
        if ([filePath hasSuffix:@".ccb"]) {
            ccbFilePath = filePath;
            numberOfCCBFiles += 1;
            if (numberOfCCBFiles > 1) break;
        }
    }

    // Setup the slide for the CCB that comes with the template
    if (numberOfCCBFiles == 1 && [self.currentProjectSettings.slideList count] == 0) {
        PCSlide *defaultTemplateSlide = [[PCSlide alloc] init];

        // Move the template .ccb and .ccb.ppng files to the path that matches the PCSlide UUID
        NSString *ccbPath = [firstResourcePath stringByAppendingPathComponent:ccbFilePath];
        NSString *newPath = [[[ccbPath stringByDeletingLastPathComponent] stringByAppendingPathComponent:defaultTemplateSlide.uuid] stringByAppendingPathExtension:@"ccb"];

        NSError *fileMoveError;
        BOOL moveSuccess = [fileManager moveItemAtPath:ccbPath toPath:newPath error:&fileMoveError];
        if (!moveSuccess) {
            PCLog(@"Error moving CCB file at path %@: %@", ccbPath, fileMoveError);
            fileMoveError = nil;
        }
        moveSuccess = [fileManager moveItemAtPath:[ccbPath stringByAppendingPathExtension:@"ppng"] toPath:[newPath stringByAppendingPathExtension:@"ppng"] error:&fileMoveError];
        if (!moveSuccess) {
            PCLog(@"Error moving card rendering file at path %@: %@", ccbPath, fileMoveError);
            fileMoveError = nil;
        }
        moveSuccess = [fileManager moveItemAtPath:[[ccbPath stringByAppendingString:PCSlideThumbnailSuffix] stringByAppendingPathExtension:@"ppng"] toPath:[[newPath stringByAppendingString:PCSlideThumbnailSuffix] stringByAppendingPathExtension:@"ppng"] error:&fileMoveError];
        if (!moveSuccess) {
            PCLog(@"Error moving card thumbnail file at path %@: %@", ccbPath, fileMoveError);
        }

        [self.currentProjectSettings insertObject:defaultTemplateSlide inSlideListAtIndex:0];
    }

    // Load all of the documents for the slides
    [self.currentProjectSettings.slideList enumerateObjectsUsingBlock:^(PCSlide *slide, NSUInteger slideIndex, BOOL *stop) {
        slide.document = [[CCBDocument alloc] initWithFile:[slide absoluteFilePath]];
        [slide updateThumbnail];

        // Update JS file from latest templates. This is really slow so we only do this if we cannot assume backwards compatibility.
        if (projectSettingsValidationStatus == ValidateProjectDictionaryFileVersionInfoStatusAcceptedConvertAndRegenerateJS) {
            [PCBehavioursDataSource performWithMockedDocument:slide.document block:^{
                [slide saveBehavioursJSFileWithIndex:slideIndex];
            }];
        }
    }];
}

- (NSString *)projectSettingsBackupForFile:(NSString *)file {
    return [file stringByAppendingPathExtension:@"bak"];
}

///When loading a file, after we have ascertained that it is valid, we back it up so that next time we try to load the file, if the project file has gone missing or invalid somehow, we have a safe checkpoint.
- (void)backupProjectData:(NSDictionary *)projectData withOriginalFileName:(NSString *)fileName {
    NSString *newFileName = [self projectSettingsBackupForFile:fileName];
    [projectData writeToFile:newFileName atomically:YES];
}

- (void)loadAndValidateProjectDictionaryWithFilename:(NSString *)fileName autoUpgrade:(BOOL)autoUpgrade success:(void(^)(NSDictionary *, ValidateProjectDictionaryFileVersionInfoStatus))success failure:(void(^)(BOOL convertProjectCancelled, NSError *error))failure {
    // Load the project file
    NSMutableDictionary *projectDictionary = [NSMutableDictionary dictionaryWithContentsOfFile:fileName];
    if (!projectDictionary) {
        if (failure) failure (NO, [NSError pc_invalidProjectError]);
        return;
    }

    NSError *projectSettingsError;
    ValidateProjectDictionaryFileVersionInfoStatus status = [self validateProjectDictionaryFileVersionInfo:projectDictionary autoUpgrade:autoUpgrade error:&projectSettingsError];
    if (status == ValidateProjectDictionaryFileVersionInfoStatusNotValid) {
        if (failure) failure (NO, projectSettingsError);
        return;
    } else if (status == ValidateProjectDictionaryFileVersionInfoStatusCancelledConvertProject) {
        if (failure) failure (YES, projectSettingsError);
        return;
    }
    if (success) success(projectDictionary, status);
}

- (void)loadProjectDictionaryOrBackupWithFileName:(NSString *)fileName autoUpgrade:(BOOL)autoUpgrade success:(void(^)(NSDictionary *, ValidateProjectDictionaryFileVersionInfoStatus))success failure:(void(^)(BOOL convertProjectCancelled, NSError *error))failure {
    [self loadAndValidateProjectDictionaryWithFilename:fileName autoUpgrade:autoUpgrade success:success failure:^(BOOL convertProjectCancelled, NSError *error) {
        if (convertProjectCancelled) {
            failure(YES, error);
            return;
        }

        // Don't try to load backup project if the error is that we are on a too old version of PencilCase.
        if (error.code == PCErrorCodeUnsupportedProjectVersion) {
            failure(NO, error);
            return;
        }
        
        NSString *backupFileName = [self projectSettingsBackupForFile:fileName];
        if (![[NSFileManager defaultManager] fileExistsAtPath:backupFileName]) {
            if (failure) failure(NO, error);
            return;
        }

        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = NSLocalizedString(@"There was a problem loading your project. Would you like to load the last available backup?", @"Message shown when users project is corrupted but a backup exists.");
        [alert addButtonWithTitle:NSLocalizedString(@"OK", nil)];
        [alert addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
        [alert beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse response) {
            if (response == NSAlertFirstButtonReturn) {
                [self loadAndValidateProjectDictionaryWithFilename:backupFileName autoUpgrade:autoUpgrade success:success failure:failure];
            } else {
                if (failure) failure(convertProjectCancelled, error);
            }
        }];
    }];
}

// This method should be called after a new project is opened
- (void)refreshUIForOpenedProject {
    [self openDocument:((PCSlide *)self.currentProjectSettings.slideList.firstObject).document parentDocument:nil];
    
    // Set the title of the main window
    NSString *projectDirectory = self.currentProjectSettings.projectDirectory;
    [self.window setTitleWithRepresentedFilename:[projectDirectory stringByDeletingPathExtension]];
    NSURL *projectPackageReferenceURL = [[NSURL fileURLWithPath:projectDirectory isDirectory:YES] fileReferenceURL];
    self.window.representedURL = projectPackageReferenceURL;

    [self updateWarningsButton];
    [self updateSmallTabBarsEnabled];
    [self.projectViewTabs selectBarButtonIndex:PCProjectTabTagSlides];

    [self.pcSlidesViewController selectSlideAtIndex:0];

    // Setup resource outline view handler
    self.resourceOutlineHandler = [[ResourceManagerOutlineHandler alloc] initWithOutlineView:self.resourceOutlineView resType:PCResourceTypeNone preview:self.previewViewOwner];
    self.resourceOutlineHandler.progressIndicator = self.progressIndicator;

    [self menuZoomToFit:nil];
}


#pragma mark - NSNotifications

- (void)handleProjectFailedToOpenNotification:(NSNotification *)notification {
    [self displayAlertForOpenProjectError:notification.userInfo[@"error"]];
}

- (void)handleProjectOpenedNotification:(NSNotification *)notification {
    [self refreshUIForOpenedProject];
}

- (void)handleUndoManagerCheckpointNotification:(NSNotification *)checkpointNotification {
    NSUndoManager *undoManager = checkpointNotification.object;
    self.currentDocument.isDirty = undoManager.canUndo;
}


- (void)displayAlertForOpenProjectError:(NSError *)error {
    NSString *title = NSLocalizedString(@"LoadProjectGenericErrorTitle", nil);
    if (error.code == PCErrorCodeUnsupportedProjectType) {
        title = NSLocalizedString(@"LoadProjectUnsupportedTypeErrorTitle", nil);
    }
    else if (error.code == PCErrorCodeUnsupportedProjectType) {
        title = NSLocalizedString(@"LoadProjectUnsupportedVersionErrorTitle", nil);
    }
    [self modalDialogTitle:title message:error.localizedDescription ?: @""];
}

#pragma mark -

/**
 We used to publish directly into the .pcase bundle under Source/Resources/Published-iOS. This lead to larger project files than necessary. Remove this Source directory if it exists.
 
 @param fileURL The url to the .pcase project.
 */
- (void)removeOldPublishDirectoryFromProjectAtURL:(NSURL *)fileURL {
    NSURL *oldPublishURL = [fileURL URLByAppendingPathComponent:@"Source"];
    [[NSFileManager defaultManager] removeItemAtURL:oldPublishURL error:nil];
}

- (void)openDocument:(CCBDocument *)document parentDocument:(CCBDocument *)parentDocument {
    self.parentDocument = parentDocument;
    if (!document) {
        [self closeLastDocument];
        return;
    }

    [self switchToDocument:document];

    self.hasOpenedDocument = YES;

    // Remove selections
    self.physicsHandler.selectedNodePhysicsBody = nil;
    self.selectedSpriteKitNodes = nil;

    [self setSelectedSpriteKitNodes:nil];
}

- (void)openFile:(NSString *)fileName parentDocument:(CCBDocument *)parentDocument
{
    CCBDocument *document = [[CCBDocument alloc] initWithFile:fileName];
    [self openDocument:document parentDocument:parentDocument];
}

- (void)openInternalFile:(NSString *)fileName {
    CCBDocument *parentDocument = self.currentDocument;
    [self.pcSlidesViewController deselectAll];
    
    for (CCBDocument *document in self.currentProjectSettings.subcontentDocuments) {
        if ([[document.fileName lastPathComponent] isEqualToString:[fileName lastPathComponent]]) {
            [self openDocument:document parentDocument:parentDocument];
            return;
        }
    }
    //Couldn't find the file for some reason - open it and store it in the project settings
    [self openFile:fileName parentDocument:parentDocument];
    [self.currentProjectSettings insertSubcontentDocument:self.currentDocument];
}

- (void)saveFile:(NSString*)fileName withPreview:(BOOL)savePreview
{
    self.currentDocument.fileName = [fileName lastPathComponent];
    [self.currentDocument updateWithCurrentDocumentState];
    [self.currentDocument writeToFile:fileName];

    self.currentDocument.isDirty = NO;
    [self updateDirtyMark];

    // disable this as we are using a shared NSUndoManager, so no need to clear all actions
    //[self.currentDocument.undoManager removeAllActions];
    
    self.currentDocument.lastEditedProperty = NULL;
    
    // Generate preview
    
    // Reset to first frame in first timeline in first resolution
    float currentTime = self.sequenceHandler.currentSequence.timelinePosition;
    int currentResolution = self.currentDocument.currentResolution;
    SequencerSequence* currentSeq = self.sequenceHandler.currentSequence;
    
    self.currentDocument.currentResolution = self.currentDocument.currentResolution;
    self.sequenceHandler.currentSequence = self.currentDocument.sequences.firstObject;
    self.sequenceHandler.currentSequence.timelinePosition = 0;

    // Save preview
    if (savePreview) {
        [[PCStageScene scene] savePreviewToFile:[fileName stringByAppendingPathExtension:@"ppng"] completion:^{
            [[self currentSlide] updateThumbnail];
        }];

    }
    
    // Restore resolution and timeline
    self.currentDocument.currentResolution = currentResolution;
    self.sequenceHandler.currentSequence = currentSeq;
    self.sequenceHandler.currentSequence.timelinePosition = currentTime;
    
    [self.resourceOutlineHandler updateSelectionPreview];

    [self.currentSlide saveDocument];
}

- (PCSlide *)currentSlide {
    return [self slideWithDocument:[self currentDocument]];
}

- (NSInteger)currentSlideIndex {
    return [[self.currentProjectSettings slideList] indexOfObject:[self currentSlide]];
}

- (PCSlide *)slideWithDocument:(CCBDocument *)document {
    return [self.currentProjectSettings.slideList filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"document = %@", document]].firstObject;
}

- (CCBDocument *)newFile:(NSString *)fileName type:(int)type resolutions:(NSMutableArray *)resolutions
{
    BOOL centered = NO;
    if (type == kCCBNewDocTypeNode ||
        type == kCCBNewDocTypeParticleSystem ||
        type == kCCBNewDocTypeSprite) centered = YES;
    
    int docDimType = kCCBDocDimensionsTypeNode;
    if (type == kCCBNewDocTypeScene || type == kCCBNewDocTypePCSlide) docDimType = kCCBDocDimensionsTypeFullScreen;
    else if (type == kCCBNewDocTypeLayer) docDimType = kCCBDocDimensionsTypeLayer;
    
    NSString *className;
    switch (type) {
        case kCCBNewDocTypeNode:
        case kCCBNewDocTypeLayer:
            className = @"PCNode";
            break;
        case kCCBNewDocTypeScene:
            className = @"PCNodeColor";
            break;
        case kCCBNewDocTypePCSlide:
            className = @"PCSlideNode";
            break;
        case kCCBNewDocTypeSprite:
            className = @"PCSprite";
            break;
        case kCCBNewDocTypeParticleSystem:
            className = @"PCParticleSystem";
            break;
        default:
            break;
    }
    
    resolutions = [self updateResolutions:resolutions forDocDimensionType:docDimType];
    PCDeviceResolutionSettings* resolution = [resolutions objectAtIndex:self.currentProjectSettings.deviceResolutionSettings.deviceTarget];

    CGSize stageSize = CGSizeMake(resolution.width, resolution.height);

    [self prepareForDocumentSwitch];

    self.selectedSpriteKitNodes = nil;
    [[PCStageScene scene] setStageSize:stageSize centeredOrigin:centered];

    if (type == kCCBNewDocTypeScene || type == kCCBNewDocTypePCSlide)
    {
        [[PCStageScene scene] setStageBorder:PCStageBorderTypeTransparent];
    }
    else
    {
        [[PCStageScene scene] setStageBorder:1];
    }
    
    // Create new node
    SKSpriteNode *rootNode = (SKSpriteNode *)[[PlugInManager sharedManager] createDefaultSpriteKitNodeOfType:className andConfigureWithBlock:^(SKNode *node) {
        SKSpriteNode *spriteNode = (SKSpriteNode *)node;
        if (type == kCCBNewDocTypeScene) {
            spriteNode.color = [NSColor whiteColor];
        }
        else if (type == kCCBNewDocTypePCSlide) {
            spriteNode.size = [PCStageScene scene].stageSize;
            spriteNode.anchorPoint = CGPointZero;
            spriteNode.color = [NSColor whiteColor];
        }
    }];

    [[PCStageScene scene] replaceRootNodeWith:rootNode];
    
    [self reloadObjectHierarchy];
    [self.sequenceHandler updateOutlineViewSelection];
    [self updateInspectorFromSelection];
    
    self.currentDocument = [[CCBDocument alloc] init];
    self.currentDocument.resolutions = resolutions;
    self.currentDocument.currentResolution = self.currentProjectSettings.deviceResolutionSettings.deviceTarget;
    self.currentDocument.docDimensionsType = docDimType;
    [self updateResolutionMenu];

    [self saveFile:fileName withPreview:type == kCCBNewDocTypePCSlide];
    
    // Setup a default timeline
    NSMutableArray* sequences = [NSMutableArray array];
    
    SequencerSequence* seq = [[SequencerSequence alloc] init];
    seq.name = @"Default Timeline";
    seq.sequenceId = CardDefaultSequenceId;
    seq.autoPlay = YES;
    [sequences addObject:seq];
    
    self.currentDocument.sequences = sequences;
    self.sequenceHandler.currentSequence = seq;
    
    
    self.hasOpenedDocument = YES;
    
    //[self updateStateOriginCenteredMenu];
    
    [[PCStageScene scene] setStageZoom:1];
    [[PCStageScene scene] setScrollOffset:CGPointZero];

    return self.currentDocument;
}

- (NSString*) findProject:(NSString*) path
{
	NSString* projectFile = nil;
	NSFileManager* fm = [NSFileManager defaultManager];
    
	NSArray* files = [fm contentsOfDirectoryAtPath:path error:NULL];
	for( NSString* file in files )
	{
		if( [file hasSuffix:@".ccbproj"] )
		{
			projectFile = [path stringByAppendingPathComponent:file];
			break;
		}
	}
	return projectFile;
}

#pragma mark - Undo

- (void)revertToState:(id)state
{
    [self saveUndoState];
    [self replaceDocumentData:state];
}

/**
 *  Save an updated copy of the current document for comparison with the next undo action.
 */
- (void)saveUndoStateToCacheForComparison {
    UndoDebugLog(@"saveUndoStateToCacheForComparison");
    if (self.currentDocument == nil) return;
    [self.currentDocument updateWithCurrentDocumentState];
}

/**
 *  Save the current action to the undo and with option to disregard if we can actually saving to the same property
 *
 *  @param prop     Property we are saving
 */
- (void)saveUndoStateDidChangePropertySkipSameCheck:(NSString*)prop {
    //UndoDebugLog(@"saveUndoStateDidChangePropertySkipSameCheck");
    if (self.currentDocument == nil) return;
    self.currentDocument.lastEditedProperty = nil; 
    [self saveUndoStateDidChangeProperty:prop];
}

- (void)registerForUndoCallbacks {
    [PCUndoManager sharedPCUndoManager].undoCommittedBlock = ^{
        [self updateDirtyMark];
    };
    [PCUndoManager sharedPCUndoManager].revertSelectionBlock = ^(NSArray *nodes) {
        [self reselectSKNodesAfterDocumentReload:nodes];
    };
    [PCUndoManager sharedPCUndoManager].revertStateBlock = ^(NSDictionary *state) {
        [self revertToState:state];
    };
}

- (void)saveUndoStateDidChangeProperty:(NSString*)prop
{
    [[PCUndoManager sharedPCUndoManager] saveUndoStateDidChangeProperty:prop inDocument:self.currentDocument selectedNodes:self.selectedSpriteKitNodes slideController:self.pcSlidesViewController];
    return;
}

- (void)saveUndoState
{
    [self saveUndoStateDidChangeProperty:NULL];
}

- (void)selectCardsTabItemForUndo {
    [self.projectViewTabs setSelectedItem:self.projectViewTabs.items[0]];
    [self.projectTabView selectFirstTabViewItem:nil];
}

/**
 *  Recursively search the children of the root node to find nodes with the same uuid as the previous seleciton
 *
 *  @param previousSelection Array of SKNodes currently selected
 */
- (void)reselectSKNodesAfterDocumentReload: (NSArray *) previousSelection {
    
    NSMutableArray *newSelection = [NSMutableArray array];
    
    for (NSString *skNodeUuid in previousSelection){
        SKNode *node = [[PCStageScene scene].rootNode recursiveChildNodeWithUUID:skNodeUuid];
        if (node != nil) [newSelection addObject:node];
    }
    
    // If we can't find anything, select the whole card
    if ([newSelection count] == 0) {
        [newSelection addObject:[PCStageScene scene].rootNode];
    }
    
    // set the new selection
    [self setSelectedSpriteKitNodes:newSelection];
    
}

#pragma mark - Menu options
- (void)hideSelectedPopover {
   // [self.selectedPopover performClose:sender];
}

- (IBAction)showShapesPopover:(id)sender {
	if (self.selectedPopover.isShown) {
        BOOL shouldHidePopover = [self.selectedPopover.contentViewController isKindOfClass:[PCShapeSelectViewController class]];
        [self.selectedPopover performClose:sender];
        if (shouldHidePopover) return;
	}
	
	PCShapeSelectViewController *controller = [[PCShapeSelectViewController alloc] initWithNibName:@"PCShapeSelectView" bundle:nil];
	NSPopover *popover = [[NSPopover alloc] init];
	popover.delegate = self;
	popover.behavior = NSPopoverBehaviorSemitransient;
	[popover setContentViewController:controller];
	[popover setAnimates:NO];
	self.selectedPopover = popover;
	
	[self.selectedPopover showRelativeToRect:[[self.shapesButton view] bounds] ofView:[self.shapesButton view] preferredEdge:NSMaxYEdge];
}

- (IBAction)showTextPopover:(id)sender {
	if (self.selectedPopover.isShown) {
        BOOL shouldHidePopover = [self.selectedPopover.contentViewController isKindOfClass:[PCTextSelectViewController class]];
        [self.selectedPopover performClose:sender];
        if (shouldHidePopover) return;
	}
	
	PCTextSelectViewController *controller = [[PCTextSelectViewController alloc] initWithNibName:@"PCTextSelectView" bundle:nil];
	NSPopover *popover = [[NSPopover alloc] init];
	popover.delegate = self;
	popover.behavior = NSPopoverBehaviorSemitransient;
	[popover setContentViewController:controller];
	[popover setAnimates:NO];
	self.selectedPopover = popover;
	
	[self.selectedPopover showRelativeToRect:[[self.textButton view] bounds] ofView:[self.textButton view] preferredEdge:NSMaxYEdge];
}

- (IBAction)showMediaPopover:(id)sender {
	if (self.selectedPopover.isShown) {
        BOOL shouldHidePopover = [self.selectedPopover.contentViewController isKindOfClass:[PCMediaSelectViewController class]];
        [self.selectedPopover performClose:sender];
        if (shouldHidePopover) return;
	}
	
	PCMediaSelectViewController *controller = [[PCMediaSelectViewController alloc] initWithNibName:@"PCMediaSelectView" bundle:nil];
	NSPopover *popover = [[NSPopover alloc] init];
	popover.delegate = self;
	popover.behavior = NSPopoverBehaviorSemitransient;
	[popover setContentViewController:controller];
	[popover setAnimates:NO];
	self.selectedPopover = popover;
	
	[self.selectedPopover showRelativeToRect:[[self.mediaButton view] bounds] ofView:[self.mediaButton view] preferredEdge:NSMaxYEdge];
	
	self.mediaPopoverResourceManager = [[ResourceManagerTilelessEditorManager alloc] initWithImageBrowser:controller.imageBrowserView];
	self.mediaPopoverResourceManager.resourceTypeSelection = PCResourceTypeImage;
	controller.mediaPopoverResourceManager = self.mediaPopoverResourceManager;
	
	[[PCResourceManager sharedManager] notifyResourceObserversResourceListUpdated];
	
}

- (IBAction)showParticlesPopover:(id)sender {
	if (self.selectedPopover.isShown) {
        BOOL shouldHidePopover = [self.selectedPopover.contentViewController isKindOfClass:[PCParticleSelectViewController class]];
        [self.selectedPopover performClose:sender];
        if (shouldHidePopover) return;
	}
	
	PCParticleSelectViewController *controller = [[PCParticleSelectViewController alloc] initWithNibName:@"PCParticleSelectView" bundle:nil];
	controller.propertyInspectorHandler = self.propertyInspectorHandler;
	
	NSPopover *popover = [[NSPopover alloc] init];
	popover.delegate = self;
	popover.behavior = NSPopoverBehaviorSemitransient;
	[popover setContentViewController:controller];
	[popover setAnimates:NO];
	self.selectedPopover = popover;
	
	[self.selectedPopover showRelativeToRect:[[self.particlesButton view] bounds] ofView:[self.particlesButton view] preferredEdge:NSMaxYEdge];
}

// clean up
- (void)popoverDidClose:(NSNotification *)notification {
	self.mediaPopoverResourceManager = nil;
	self.selectedPopover = nil;
}

- (IBAction)showKeyValueStoreConfigView:(id)sender {
    if (self.configViewController) {
        return;
    }

    self.configViewController = [[PCKeyValueStoreKeyConfigViewController alloc] initWithNibName:@"PCKeyValueStoreKeyConfigView" bundle:nil];
    self.configViewController.store = self.currentProjectSettings.keyConfigStore ?: [[PCKeyValueStoreKeyConfigStore alloc] init];

    NSWindow *configWindow = [[NSWindow alloc] initWithContentRect:self.configViewController.view.bounds styleMask:NSTitledWindowMask backing:NSBackingStoreBuffered defer:NO];
    configWindow.contentView = self.configViewController.view;

    __weak __typeof(self) weakSelf = self;
    [self.window beginSheet:configWindow completionHandler:^(NSModalResponse returnCode){
        weakSelf.configViewController = nil;
    }];
}

- (SKNode *)addPlugInSpriteKitNodeNamed:(NSString *)name asChild:(BOOL)asChild {
    return [self addSpriteKitPlugInNodeNamed:name asChild:asChild toParent:nil atIndex:0 followInsertionNode:YES];
}

- (void)dropAddPlugInNodeNamed:(NSString *)nodeName userInfo:(NSDictionary *)userInfo {
    [self dropAddPlugInNodeNamed:nodeName at:PCPointNil userInfo:userInfo];
}

#pragma mark - Copy / Paste

- (CGPoint)pasteboardCascadeDelta {
    NSString *currentSlideUUID = [self.pcSlidesViewController uuidForSlideAtIndex:self.currentSlideIndex];
    NSInteger slideCascadeNumber = [[self.pasteboardSlideCascadeNumbers objectForKey:currentSlideUUID] integerValue];
    if (slideCascadeNumber) {
        CGPoint delta = pc_CGPointMultiply(CGPointMake(10, -10), slideCascadeNumber);
        slideCascadeNumber++;
        [self.pasteboardSlideCascadeNumbers setObject:@(slideCascadeNumber) forKey:currentSlideUUID];
        return delta;
    } else {
        [self.pasteboardSlideCascadeNumbers setObject:@(1) forKey:currentSlideUUID];
        return CGPointZero;
    }
}

- (void)copyCurrentWarning {
    PCWarning  *warning = self.currentProjectSettings.lastWarnings.warnings[_warningTableView.selectedRow];
    NSString *stringToWrite = warning.description;
    NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];

    [pasteBoard declareTypes:@[NSStringPboardType] owner:nil];
    [pasteBoard setString:stringToWrite forType:NSStringPboardType];
}

- (IBAction) copy:(id) sender {

    //Copy warnings.
    if([[self window] firstResponder] == _warningTableView) {
        [self copyCurrentWarning];
        return;
    }
    
    // Copy keyframes
    NSArray *keyframes = [self.sequenceHandler selectedKeyframesForCurrentSequence];
    if ([keyframes count] > 0)
    {
        NSMutableSet* propsSet = [NSMutableSet set];
        NSMutableSet *seqsSet = [NSMutableSet set];
        BOOL duplicatedProps = NO;
        BOOL hasNodeKeyframes = NO;
        BOOL hasChannelKeyframes = NO;
        
        for (int i = 0; i < keyframes.count; i++)
        {
            SequencerKeyframe* keyframe = [keyframes objectAtIndex:i];
            
            NSValue *seqVal = [NSValue valueWithPointer:(__bridge const void *)(keyframe.parent)];
            if (![seqsSet containsObject:seqVal])
            {
                NSString *propName = keyframe.name;
                
                if (propName)
                {
                    if ([propsSet containsObject:propName])
                    {
                        duplicatedProps = YES;
                        break;
                    }
                    [propsSet addObject:propName];
                    [seqsSet addObject:seqVal];
                    
                    hasNodeKeyframes = YES;
                }
                else
                {
                    hasChannelKeyframes = YES;
                }
            }
        }
        
        if (duplicatedProps)
        {
            [self modalDialogTitle:@"Failed to Copy" message:@"You can only copy keyframes from one node."];
            return;
        }
        
        if (hasChannelKeyframes && hasNodeKeyframes)
        {
            [self modalDialogTitle:@"Failed to Copy" message:@"You cannot copy sound/callback keyframes and node keyframes at once."];
            return;
        }
        
        NSString *clipType = kClipboardKeyFrames;
        if (hasChannelKeyframes)
        {
            clipType = kClipboardChannelKeyframes;
        }
        
        // Serialize keyframe
        NSMutableArray *serKeyframes = [NSMutableArray array];
        for (SequencerKeyframe* keyframe in keyframes)
        {
            [serKeyframes addObject:[keyframe serialization]];
        }
        NSData* clipData = [NSKeyedArchiver archivedDataWithRootObject:serKeyframes];
        NSPasteboard *cb = [NSPasteboard generalPasteboard];
        [cb declareTypes:[NSArray arrayWithObject:clipType] owner:self];
        [cb setData:clipData forType:clipType];
        
        return;
    }
    
    // Copy node
    if (!self.selectedSpriteKitNode && [self.selectedSpriteKitNodes count] == 0) return;
    
    // Serialize selected node
    NSMutableArray *selectedNodesList = [NSMutableArray arrayWithArray:self.selectedSpriteKitNodes];
    NSMutableArray *selectedNodesDataList = [[NSMutableArray alloc] init];
    
    for (SKNode *node in selectedNodesList) {
        if (node == [PCStageScene scene].rootNode) continue;
        NSMutableDictionary *clipDict = [CCBWriterInternal dictionaryFromSKNode:node];
        
        CGPoint worldPosition = [node.parent convertPoint:node.position toNode:[PCStageScene scene].contentLayer];
        [clipDict setObject:[NSValue valueWithPoint:worldPosition] forKey:@"worldPosition"];
        
        CGFloat worldRotation = [node.parent pc_convertRotationInDegreesToWorldSpace:node.rotation];
        [clipDict setObject:[NSNumber numberWithFloat:worldRotation] forKey:@"worldRotation"];
        
        // Use the same size, but find the scale in world space to make sure the node is the same "visual size"
        [clipDict setObject:[NSValue valueWithSize:node.size] forKey:@"worldSize"];
        
        CGVector worldScale = [node.parent pc_convertScaleToWorldSpace:CGVectorMake(node.scaleX, node.scaleY)];
        CGSize worldScaleAsSize = CGSizeMake(worldScale.dx, worldScale.dy); // Just to stuff it in the dictionary
        clipDict[@"worldScale"] = [NSValue valueWithSize:worldScaleAsSize];

        clipDict[@"sequencerOrder"] = [self.currentDocument.sequences valueForKey:@"sequenceId"];
        clipDict[@"sequencerNames"] = [self.currentDocument.sequences valueForKey:@"name"];

        [selectedNodesDataList addObject:clipDict];
    }
    
    NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
    NSData *clipData = [NSKeyedArchiver archivedDataWithRootObject:selectedNodesDataList];
    [pasteBoard declareTypes:@[ PCPasteboardTypeNode ] owner:self];
    [pasteBoard setData:clipData forType:PCPasteboardTypeNode];
    [self.pasteboardSlideCascadeNumbers removeAllObjects];
    NSString *currentSlideUUID = [self.pcSlidesViewController uuidForSlideAtIndex:self.currentSlideIndex];
    [self.pasteboardSlideCascadeNumbers setObject:@(1) forKey:currentSlideUUID];
}

-(IBAction)duplicate:(id)sender {
    [self copy:nil];
    [self paste:nil];
}

- (void) doPasteAsChild:(BOOL)asChild
{
    NSPasteboard* cb = [NSPasteboard generalPasteboard];
    NSString* type = [cb availableTypeFromArray:@[ PCPasteboardTypeNode ]];
    NSMutableArray *pastedObjects = [NSMutableArray array];
    if (type)
    {
        NSData* clipData = [cb dataForType:type];
        NSMutableArray *clipArray = [NSKeyedUnarchiver unarchiveObjectWithData:clipData];
        
        CGSize parentSize;
        // We can only paste into one node, and also can't paste into the node manager, so just take the first of the selection
        SKNode *firstSelectedNode = self.selectedSpriteKitNodes.firstObject;
        if (!firstSelectedNode) {
            firstSelectedNode = [PCStageScene scene].rootNode;
        }
        if (asChild) parentSize = firstSelectedNode.contentSize;
        else parentSize = firstSelectedNode.parent.contentSize;
        
        CGPoint delta = [self pasteboardCascadeDelta];
        for (NSMutableDictionary *nodeDict in clipArray) {
        
            SKNode* clipNode = [CCBReaderInternal spriteKitNodeGraphFromDictionary:nodeDict parentSize:parentSize];

            [self assignUuidToNode:clipNode];
            [clipNode ensureDisplayNameIsUnique];
            [self addSpriteKitNode:clipNode asChild:asChild];

            NSArray *sequencerOrder = nodeDict[@"sequencerOrder"];
            NSArray *sequencerNames = nodeDict[@"sequencerNames"];
            [self.currentDocument updateKeyframesForNode:clipNode givenSequencerOrder:sequencerOrder sequencerNames:sequencerNames];
            [self updateTimelineMenu];

            SKNode *parentNode = asChild ? firstSelectedNode : firstSelectedNode.parent;
            
            CGPoint worldPosition = pc_CGPointAdd([nodeDict[@"worldPosition"] pointValue], delta);
            CGPoint nodePosition = [parentNode convertPoint:worldPosition fromNode:[PCStageScene scene].contentLayer];
            
            CGFloat worldRotation = [nodeDict[@"worldRotation"] floatValue];
            CGFloat nodeRotation = [parentNode pc_convertRotationInDegreesToNodeSpace:worldRotation];
            
            // Note that size doesn't need to be transformed, scale is instead
            CGSize nodeSize = [nodeDict[@"worldSize"] sizeValue];
            
            CGSize worldScaleAsSize = [nodeDict[@"worldScale"] sizeValue];
            CGVector worldScale = CGVectorMake(worldScaleAsSize.width, worldScaleAsSize.height); // Get it out of the dictionary as a vector
            CGVector nodeScale = [parentNode pc_convertScaleToNodeSpace:worldScale];
            
            PCEditorResizeBehaviour sizeType = clipNode.editorResizeBehaviour;
            if (sizeType == PCEditorResizeBehaviourScale) {
                clipNode.size = nodeSize;
            }
            
            clipNode.scaleX = nodeScale.dx;
            clipNode.scaleY = nodeScale.dy;
            clipNode.rotation = nodeRotation;

            [PositionPropertySetter setPosition:nodePosition forSpriteKitNode:clipNode prop:@"position"];
            [pastedObjects addObject:clipNode];
            [self.sequenceHandler updatePropertiesToTimelinePosition];
        }
    }
    self.selectedSpriteKitNodes = pastedObjects;
    
    //Because we're updating the properties of selected nodes bottom-up (i.e. of the underlying nodes instead of from the node manager down) we need to manually force the update of the node manager's values in order for them to update in the inspectors
    for (NSString *propertyName in @[ @"position", @"rotation", @"contentSize", @"scale" ]) {
        [self.nodeManager updateNodeManagerInspectorForProperty:propertyName];
    }
    
    [self refreshAllProperties];
}

- (void)paste {
    [self paste:nil];
}

- (BOOL)pasteKeyframesIfCopied {
    // Paste keyframes
    NSPasteboard *clipboard = [NSPasteboard generalPasteboard];
    NSString *type = [clipboard availableTypeFromArray:@[kClipboardKeyFrames, kClipboardChannelKeyframes]];

    if (!type) return YES;

    if (!self.selectedSpriteKitNode && [type isEqualToString:kClipboardKeyFrames]) {
        [self modalDialogTitle:@"Paste Failed" message:@"You need to select a node to paste keyframes"];
        return NO;
    }

    // Unarchive keyframes
    NSData *clipData = [clipboard dataForType:type];
    NSMutableArray *serializedKeyframes = [NSKeyedUnarchiver unarchiveObjectWithData:clipData];
    NSMutableArray *keyframes = [NSMutableArray array];

    // Save keyframes and find time of first kf
    float firstTime = MAXFLOAT;
    for (id serializedKeyframe in serializedKeyframes) {
        SequencerKeyframe *keyframe = [[SequencerKeyframe alloc] initWithSerialization:serializedKeyframe];
        if (keyframe.time < firstTime) {
            firstTime = keyframe.time;
        }
        [keyframes addObject:keyframe];
    }

    // Adjust times and add keyframes
    SequencerSequence *sequence = self.sequenceHandler.currentSequence;

    for (SequencerKeyframe *keyframe in keyframes) {
        // Adjust time
        keyframe.time = [sequence alignTimeToResolution:keyframe.time - firstTime + sequence.timelinePosition];

        // Add the keyframe
        if ([type isEqualToString:kClipboardKeyFrames]) {
            for (SKNode *node in self.selectedSpriteKitNodes) {
                [node addKeyframe:keyframe forProperty:keyframe.name atTime:keyframe.time sequenceId:sequence.sequenceId];
            }
        } else if ([type isEqualToString:kClipboardChannelKeyframes]) {
            if (keyframe.type == kCCBKeyframeTypeCallbacks) {
                [sequence.callbackChannel.seqNodeProp addKeyframe:keyframe];
            } else if (keyframe.type == kCCBKeyframeTypeSoundEffects) {
                [sequence.soundChannel.seqNodeProp addKeyframe:keyframe];
            }
            [keyframe.parent deleteKeyframesAfterTime:sequence.timelineLength];
            [[SequencerHandler sharedHandler] redrawTimeline];
        }

        [[SequencerHandler sharedHandler] deleteDuplicateKeyframesForCurrentSequence];
    }
    return YES;
}

- (BOOL)pasteWhens {
    PCWhen * when = [PCWhen whenFromPasteboard];
    if (!when) return NO;
    [self.behaviourListViewController pasteWhen:when];
    return YES;
}

- (BOOL)pasteThens {
    PCThen *then = [PCThen thenFromPasteboard];
    if (!then) return NO;
    [self.behaviourListViewController pasteThen:then];
    return YES;
}

- (IBAction)paste:(id)sender {
    if (!self.currentDocument) return;
    if (![self pasteKeyframesIfCopied]) return;
    if ([self pasteWhens]) return;
    if ([self pasteThens]) return;

    [self doPasteAsChild:NO];
}

- (IBAction)pasteAsChild:(id)sender {
    [self doPasteAsChild:YES];
}

#pragma mark - Deleting

- (void)deleteSelection {
    // Only attempt to delete selected keyframes if the timeline is visible
    // This is just a small hack optimization since keyframe deletion currently traverses the entire node graph
    // Ideally this would check the first responder, but the code isn't ready for that
    if (self.splitHorizontalView.isBottomViewVisible) {
        if ([self.sequenceHandler deleteSelectedKeyframesForCurrentSequence]) return;
    }

    // Then delete the selected node
    [self deleteNodes:self.selectedSpriteKitNodes];
}

- (void)deleteNode:(SKNode *)node {
    [self deleteNodes:@[ node ]];
}

/**
 *  Deletes an array of nodes from the node graph
 *
 *  Avoids deleting the root node
 *
 *  @param nodes An array of nodes
 */
- (void)deleteNodes:(NSArray *)nodes {
    if (PCIsEmpty(nodes)) return;
    
    BOOL selectedNodeIsRootNode = Underscore.array(nodes).any(^BOOL(SKNode *node){
        return (node == [PCStageScene scene].rootNode);
    });
    if (selectedNodeIsRootNode) return;
    
    SKNode *firstNode = nodes.firstObject;
    SKNode *parentToSelect = [self selectableParentForNode:firstNode.parent];
    
    for (SKNode *node in nodes) {
        [[NSNotificationCenter defaultCenter] postNotificationName:PCNodeDeletedNotification object:nil userInfo:@{ @"nodeUUID": [NSUUID pc_UUIDWithString:node.uuid] }];
        [node removeFromParent];
    }
    
    [self saveUndoStateDidChangeProperty:@"*objectHiearchyChange"];
    
    [self reloadObjectHierarchy];
    
    [self.sequenceHandler updateOutlineViewSelection];

    if (parentToSelect) {
        self.selectedSpriteKitNodes = @[ parentToSelect ];
    }
    else {
        self.selectedSpriteKitNodes = nil;
    }

    [self.behaviourListViewController validate];
}

/**
 *  This method remains for old cases where the app delegate needs to be in the responder chain to catch events
 *  An example of this would be for deleting nodes selected in the object list.
 *  An improvement could be made to have the sequencer handler handle this instead.
 *
 *  @param sender The event sender
 */
- (IBAction)deleteBackward:(id)sender {
    [self deleteSelection];
}

#pragma mark -

- (SKNode *)selectableParentForNode:(SKNode *)node {
    while (node && (node.hideFromUI || !node.selectable)) {
        node = node.parent;
    }
    return node;
}

// So we can insert nodes with no plugin (SKCropNode). Search up for the nearest plugin.
- (PlugInNode *)pluginNodeForNode:(SKNode *)node {
    SKNode *pluginNode = [self nodeWithPluginForNode:node];
    return pluginNode.plugIn;
}

- (SKNode *)nodeWithPluginForNode:(SKNode *)node {
    SKNode *nodeWithPlugin = node;
    while (!nodeWithPlugin.plugIn && nodeWithPlugin.parent) {
        nodeWithPlugin = nodeWithPlugin.parent;
    }
    return nodeWithPlugin;
}

- (IBAction) cut:(id) sender {
    [self cutSelectedNode];
}

- (void)cutSelectedNode {
    SKNode *firstNode = self.selectedSpriteKitNodes.firstObject;
    
    if (firstNode == [PCStageScene scene].rootNode) {
        [self modalDialogTitle:@"Failed to cut object" message:@"The root node cannot be removed"];
        return;
    }
    [self copy:nil];
    [self deleteSelection];
}

- (IBAction) menuNudgeObject:(id)sender
{
    [SKNode pc_nudgeNodes:self.selectedSpriteKitNodes inDirection:[sender tag]];
}

- (IBAction) menuMoveObject:(id)sender
{
    [SKNode pc_moveNodes:self.selectedSpriteKitNodes inDirection:[sender tag]];
}

- (IBAction)saveProjectAs:(id)sender
{
    if (!self.currentDocument) return;

    NSSavePanel* saveDlg = [NSSavePanel savePanel];
    [saveDlg setAllowedFileTypes:[NSArray arrayWithObject:@"pcase"]];

    [saveDlg beginSheetModalForWindow:self.window completionHandler:^(NSInteger result){
        if (result == NSOKButton) {
            __block NSError *error;
            NSString *filename = [[saveDlg URL] path];

            // Using a NSOpenSavePanelDelegate to filter the current document out of the list doesn't actually
            // work for some reason. The undesired item still appears to the user, they are still able to select
            // it and press Save. The panel even asks if they want to replace the selected file which doesn't
            // make any sense considering the delegate has explicitly said that file should not be enabled.
            //
            // As a workaround, ignore when the user tries to save the current document over itself.
            if ([filename isEqualToString:self.currentProjectSettings.projectDirectory]) return;

            if ([[NSFileManager defaultManager] fileExistsAtPath:filename isDirectory:nil]) {
                [[NSFileManager defaultManager] removeItemAtPath:filename error:nil];
            }

            [self showModalProgressWindowWithTitle:NSLocalizedString(@"Saving Project", nil) whilePerformingLongRunningAction:^{
                [self saveAllDocuments:nil];

                if (![[NSFileManager defaultManager] copyItemAtPath:self.currentProjectSettings.projectDirectory toPath:filename error:&error]) {
                    NSLog(@"Unable to copy project to %@", filename);
                    [self modalDialogTitle:@"Failed to Save Project" message:@"Failed to save the project, make sure you are saving it to a writable directory."];
                    return;
                }
            }];

            if (!error) {
                [self openProject:filename autoUpgrade:NO success:^{
                    [self refreshUIForOpenedProject];
                } failure:^(BOOL convertProjectCancelled, NSError *error) {
                    if (error) {
                        [self displayAlertForOpenProjectError:error];
                    }
                    
                    [self refreshUIForOpenedProject];
                }];
                
            }
        }
    }];
}

- (IBAction) saveDocument:(id)sender
{
    // Finish editing inspector
    if (![[self window] makeFirstResponder:[self window]]) return;

    [self.currentProjectSettings store];
    if (self.currentDocument && self.currentDocument.fileName)
    {
        PCSlide *slide = [self slideWithDocumentPath:self.currentDocument.fileName];
        if (slide) {
            [self saveFile:[slide absoluteFilePath] withPreview:YES];
        } else {
            NSString *fullFileName = [CCBDocument absolutePathForSubcontentDocumentWithFilename:self.currentDocument.fileName];
            [self saveFile:fullFileName withPreview:NO];
        }
    }
    else
    {
        [self saveProjectAs:sender];
    }
}

- (IBAction)saveAllDocuments:(id)sender {
    if (![NSThread isMainThread]) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self saveAllDocuments:sender];
        });
        return;
    }

    if ([self isShowingInstantAlpha]) {
        [self.instantAlphaViewController cancel];
    }
    
    [[PCStageScene scene] endFocusedNode];

    // Save all JS files
    //[[NSDocumentController sharedDocumentController] saveAllDocuments:sender]; //This API have no effects
    NSArray* JSDocs = [[NSDocumentController sharedDocumentController] documents];
    for (int i = 0; i < [JSDocs count]; i++)
    {
        NSDocument* doc = [JSDocs objectAtIndex:i];
        if (doc.isDocumentEdited)
        {
            [doc saveDocument:sender];
        }
    }
    
    // Save all CCB files
    CCBDocument *currentDocument = self.currentDocument;
    for (CCBDocument *document in self.currentProjectSettings.subcontentDocuments) {
        if (document.isDirty) {
            [self switchToDocument:document forceReload:NO reloadInspectors:NO];
            [self saveDocument:sender];
        }
    }
    for (PCSlide *slide in self.currentProjectSettings.slideList) {
         if (slide.document.isDirty) {
             [self switchToDocument:slide.document forceReload:NO reloadInspectors:NO];
             [self saveDocument:sender];
         }
    }

    [self switchToDocument:currentDocument forceReload:NO reloadInspectors:NO];
    
    [self.currentProjectSettings store];
}

// This is potentially slow on large documents (i.e. some combination of lots of cards and lots of edited images)
// Haven't seen that yet, but it's certainly one place to look if things are slow on project save
// - Brandon
- (void)removeUnusedEditedImagesInCurrentProject {
    NSPredicate *editedImagePredicate = [NSPredicate predicateWithFormat:@"filePath CONTAINS %@", PCEditedImageSuffix];
    NSArray *editedImages = [[[PCResourceManager sharedManager] allResources] filteredArrayUsingPredicate:editedImagePredicate];
    for (PCResource *editedImage in editedImages) {
        BOOL imageReferenced = NO;
        for (PCSlide *slide in self.currentProjectSettings.slideList) {
            imageReferenced |= [self recursivelySearchNodeGraph:slide.document.docData[@"nodeGraph"] forReferenceToResource:editedImage];
        }
        if (!imageReferenced) {
            [[PCResourceManager sharedManager] removeResource:editedImage];
        }
    }
}

// Walk the nodeGraph value recursively until we find a reference to the resource filename
- (BOOL)recursivelySearchNodeGraph:(NSDictionary *)dictionary forReferenceToResource:(PCResource *)resource {
    BOOL isSprite = [dictionary[@"baseClass"] isEqualToString:@"PCSprite"];
    NSDictionary *spriteFrameInfo = Underscore.array(dictionary[@"properties"]).filter(^BOOL(NSDictionary *propertyInfo) {
        return [propertyInfo[@"name"] isEqualToString:@"spriteFrame"];
    }).first;
    
    BOOL hasCorrectSpriteFrame = NO;
    if (spriteFrameInfo) {
        // Using the second index is just the CCB data format
        hasCorrectSpriteFrame = [resource.uuid isEqualToString:[[PCResourceManager sharedManager] resourceWithUUID:spriteFrameInfo[@"value"]].uuid];
    }
    if (isSprite && hasCorrectSpriteFrame) return YES;
    
    for (NSDictionary *childDictionary in dictionary[@"children"]) {
        BOOL found = [self recursivelySearchNodeGraph:childDictionary forReferenceToResource:resource];
        if (found) return found;
    }
    return NO;
}

- (void)saveAllPromptWithTitle:(NSString *)title message:(NSString *)message {
    if ([self hasDirtyDocument]) {
        NSAlert* alert = [NSAlert alertWithMessageText:title defaultButton:@"Save All" alternateButton:@"Cancel" otherButton:@"Don't Save" informativeTextWithFormat:@"%@", message];
        [alert setAlertStyle:NSWarningAlertStyle];
        NSInteger result = [alert runModal];
        switch (result) {
            case NSAlertDefaultReturn:
                [self saveAllDocuments:nil];
                break;
            default:
                break;
        }
    }
}

- (void)publish:(void (^)(BOOL))completion {
    [self publishToURL:nil completion:completion];
}

- (void)publishToURL:(NSURL *)url completion:(void (^)(BOOL))completion {
    [self clearWarnings];

    if (!self.currentProjectSettings.publishEnabledAndroid
        && !self.currentProjectSettings.publishEnablediPhone
        && !self.currentProjectSettings.publishEnabledHTML5)
    {
        [self modalDialogTitle:@"Published Failed" message:@"There are no configured publish target platforms. Please check your Publish Settings."];
        return;
    }

    // Check if there are unsaved documents
    if ([self hasDirtyDocument]) {
        [self saveAllDocuments:nil];
    }
    
    PCWarningGroup* warnings = [[PCWarningGroup alloc] init];
    warnings.warningsDescription = @"Publisher Warnings";

    self.publisher = [[PCPublisher alloc] initWithProjectSettings:self.currentProjectSettings warnings:warnings];
    [self.publisher publishToURL:url completion:^(BOOL success) {
        if (completion) completion(success);
    } statusBlock:^(NSString *message, double progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self modalStatusWindowUpdateStatusText:message];
            [self modalStatusWindowProgress:progress];
        });
    }];

    [self modalStatusWindowStartWithTitle:@"Publishing"];
}

- (void)publishAndRun {
    if (![PCPublisher xcodeIsInstalled]) {
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = NSLocalizedString(@"XcodeRequiredErrorTitle", nil);
        alert.informativeText = NSLocalizedString(@"XcodeRequiredErrorDescription", nil);
        NSButton *openXcodeButton = [alert addButtonWithTitle:NSLocalizedString(@"XcodeLinkButtonTitle", nil)];
        [openXcodeButton setTarget:self];
        [openXcodeButton setAction:@selector(openXCodeAppStorePage)];
        [alert addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
        [alert runModal];
        return;
    }

    [self publish:^(BOOL success) {
        if (success) {
            [self.publisher run];
        }
        [self finishPublishWithWarnings:self.publisher.warnings];
    }];
}

- (void)openXCodeAppStorePage {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://itunes.apple.com/ca/app/xcode/id497799835?mt=12"]];
}

- (void)publishToXcodeProject {
    [self publish:^(BOOL success) {
        if (!success) {
            [self finishPublishWithWarnings:self.publisher.warnings];
            return;
        }

        [self.publisher publishToXcode:^{
            [self finishPublishWithWarnings:self.publisher.warnings];
        }];
    }];
}

- (BOOL)guideSnappingEnabled {
    return [[NSUserDefaults standardUserDefaults] boolForKey:PCSnappingToGuidesEnabledKey];
}

- (void)setGuideSnappingEnabled:(BOOL)snappingEnabled {
    [[NSUserDefaults standardUserDefaults] setBool:snappingEnabled forKey:PCSnappingToGuidesEnabledKey];
    self.snapToGuidesMenuItem.state = snappingEnabled;
    if (snappingEnabled) {
        self.currentProjectSettings.showGuides = YES;
    }
    PCStageScene *stageScene = [PCStageScene scene];
    stageScene.snapNode.snappingToGuidesEnabled = snappingEnabled;
}

- (BOOL)objectSnappingEnabled {
    return [[NSUserDefaults standardUserDefaults] boolForKey:PCSnappingToObjectsEnabledKey];
}

- (void)setObjectSnappingEnabled:(BOOL)snappingEnabled {
    [[NSUserDefaults standardUserDefaults] setBool:snappingEnabled forKey:PCSnappingToObjectsEnabledKey];
    self.snapToObjectsMenuItem.state = snappingEnabled;
    PCStageScene *stageScene = [PCStageScene scene];
    stageScene.snapNode.snappingToObjectsEnabled = snappingEnabled;
    if (!snappingEnabled) {
        [stageScene.snapNode removeSnapLines];
    }
}


- (IBAction)toggleSnapToGuides:(id)sender {
    [self setGuideSnappingEnabled:!self.snapToGuidesMenuItem.state];
}

- (IBAction)toggleSnapToObjects:(id)sender {
    [self setObjectSnappingEnabled:!self.snapToObjectsMenuItem.state];
}

- (void)clearWarnings {
    self.currentProjectSettings.lastWarnings = nil;
    [self updateWarningsButton];
}

- (void)finishPublishWithWarnings:(PCWarningGroup *)warnings {
    [self modalStatusWindowFinish];
    
    // Update project view
    self.currentProjectSettings.lastWarnings = warnings;
    [self reloadObjectHierarchy];
    // Update warnings button in toolbar
    [self updateWarningsButton];
    
    if (warnings.warnings.count)
    {
        [self.projectViewTabs selectBarButtonIndex:PCProjectTabTagWarnings];
    }
}

- (IBAction)publishToFile:(id)sender {
    NSSavePanel *publishPanel = [NSSavePanel savePanel];
    publishPanel.allowedFileTypes = @[ PCCreationExtension ];
    publishPanel.nameFieldStringValue = self.currentProjectSettings.appName;
    publishPanel.title = @"Publish";
    publishPanel.prompt = @"Publish";
    
    [publishPanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result){
        if (result == NSModalResponseOK) {
            [publishPanel orderOut:nil];
            [self publishToURL:[publishPanel URL] completion:^(BOOL success) {
                [self finishPublishWithWarnings:self.publisher.warnings];
            }];
        }
    }];
}

- (IBAction)menuPublishToXcode:(id)sender {
    self.openSaveFilter = [[PCOpenSaveFilter alloc] init];
    self.openSaveFilter.allowDirectorySelection = YES;
    self.openSaveFilter.allowFileSelection = NO;
    self.openSaveFilter.allowFilePackageSelection = NO;

    NSOpenPanel *publishPanel = [NSOpenPanel openPanel];
    publishPanel.canChooseDirectories = YES;
    publishPanel.canCreateDirectories = YES;
    publishPanel.nameFieldStringValue = self.currentProjectSettings.appName;
    publishPanel.title = @"Publish";
    publishPanel.prompt = @"Publish";
    publishPanel.delegate = self.openSaveFilter;

    [publishPanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        if (result == NSOKButton) {
            [publishPanel orderOut:nil];
            self.currentProjectSettings.xcodeProjectExportPath = [publishPanel URL].path;
            [self publishToXcodeProject];
        }
    }];
}

- (IBAction)menuPublishToPDF:(id)sender {
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = NSLocalizedString(@"Coming Soon", nil);
    [alert runModal];
}

- (IBAction)menuPublishProject:(id)sender {
    [self publish:^(BOOL success) {}];
}

- (IBAction)menuPublishProjectAndRun:(id)sender {
    [self publishAndRun];
}

- (IBAction) menuCloseProject:(id)sender
{
    [self saveAndCloseProject];
}

- (void)newProjectWithDeviceTarget:(PCDeviceTargetType)target withOrientation:(PCDeviceTargetOrientation)orientation {
    // Accepted create document, prompt for place for file
    NSSavePanel* saveDlg = [NSSavePanel savePanel];
    [saveDlg setAllowedFileTypes:[NSArray arrayWithObject:@"pcase"]];
    //saveDlg.message = @"Save your project file in the same directory as your projects resources.";

    [saveDlg beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        if (result == NSOKButton) {
            if (![[AppDelegate appDelegate] saveAndCloseProject]) {
                [self.splashController showNewProject];
                return;
            }

            NSString *projectPackageFilePath = [[saveDlg URL] path];
            NSString *projectPackageFilePathRaw = [projectPackageFilePath stringByDeletingPathExtension];

            // Create directory
            if ([[NSFileManager defaultManager] fileExistsAtPath:projectPackageFilePath isDirectory:nil]) {
                [[NSFileManager defaultManager] removeItemAtPath:projectPackageFilePath error:nil];
            }
            [[NSFileManager defaultManager] createDirectoryAtPath:projectPackageFilePath withIntermediateDirectories:NO attributes:NULL error:NULL];

            // Create project file
            NSString *projectName = [projectPackageFilePathRaw lastPathComponent];
            NSString *projectFilePath = [[projectPackageFilePath stringByAppendingPathComponent:projectName] stringByAppendingPathExtension:@"ccbproj"];
            self.currentProjectSettings.deviceResolutionSettings.deviceTarget = target;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0), dispatch_get_main_queue(), ^{
                if ([PCProjectSetupHelper createDefaultProjectAtPath:projectFilePath]) {
                    NSString *filename = [projectPackageFilePathRaw stringByAppendingPathExtension:@"pcase"];
                    __block BOOL openedProjectSuccessfully = NO;
                    [self openProject:filename autoUpgrade:YES success:^{
                        openedProjectSuccessfully = YES;
                        
                        [self.currentProjectSettings newProjectSetupWithDeviceTarget:target withOrientation:orientation];
                        
                        NSString *templateFilePath = [[NSBundle mainBundle] pathForResource:@"DefaultProjectTemplate" ofType:@"plist"];
                        PCProjectTemplate *template = [[PCProjectTemplate alloc] initWithFile:templateFilePath];
                        [self showModalProgressWindowWithTitle:NSLocalizedString(@"Initializing Project", nil) whilePerformingLongRunningAction:^{
                            [self loadProjectTemplate:template forDeviceType:target resourceManager:[PCResourceManager sharedManager]];
                        }];
                        
                        [self refreshUIForOpenedProject];
                    } failure:^(BOOL convertProjectCancelled, NSError *error) {
                        if (error) {
                            [self displayAlertForOpenProjectError:error];
                        }
                    }];
                    
                    if (!openedProjectSuccessfully) {
                        return;
                    }
                }
                else {
                    [self modalDialogTitle:@"Failed to Create Project" message:@"Failed to create the project, make sure you are saving it to a writable directory."];
                }
                
                // Remove the first template card from the newly created project, We do this to ensure that the first card is
                // the proper device type, resolution, and device orientation.
                [self.pcSlidesViewController removeSlideAtIndex:0];

                // make sure to clear the undo/redo stack after a project is first created
                [[PCUndoManager sharedPCUndoManager] removeAllActions];
            });
        } else if (result == NSCancelButton) {
            [self.splashController showNewProject];
        }
    }];
}

- (void)showModalProgressWindowWithTitle:(NSString *)progressWindowTitle whilePerformingLongRunningAction:(dispatch_block_t)longRunningAction {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        //Leaving this method here so that if/when we increase what a project template contains, it's easy to find the entry point for loading from it
        longRunningAction();
        [self modalStatusWindowFinish];
    });
    [self modalStatusWindowStartWithTitle:progressWindowTitle];
}

- (void)loadProjectTemplate:(PCProjectTemplate *)projectTemplate forDeviceType:(PCDeviceTargetType)device resourceManager:(PCResourceManager *)resourceManager {
    [resourceManager loadResourcesFromProjectTemplate:projectTemplate forDeviceType:device];

    PCTemplateLibrary *templateLibrary = [PCTemplateLibrary new];
    [templateLibrary loadLibrary];
    for (NSString *nodeType in templateLibrary.nodeTypes) {
        NSArray *currentTemplates = [templateLibrary templatesForNodeType:nodeType];
        [resourceManager loadResourcesForParticleTemplates:currentTemplates];
    }
    [templateLibrary store];
}



/**
 *  Prompts the user with the save dialog to save there current project if it is dirty. Returns BOOL if you should
 *  cancel the current operation.
 *
 *  @return returns BOOL you should cancel the current operation.
 */
- (BOOL)promptUserToSave {
    if (self.currentDocument && self.currentDocument.isDirty) {
        NSString *alertMessage = [NSString stringWithFormat:@"Save changes to the creation \"%@\" before closing it?", self.currentProjectSettings.appName];
        NSAlert *alert = [NSAlert alertWithMessageText:alertMessage defaultButton:@"Save" alternateButton:@"Don't Save" otherButton:@"Cancel" informativeTextWithFormat:@""];
        NSInteger alertResult = [alert runModal];
        switch (alertResult) {
            case NSAlertDefaultReturn:
                [self saveAllDocuments:nil];
                return YES;
            case NSAlertAlternateReturn:
                return YES;
            case NSAlertOtherReturn:
                return NO;
            default:
                 return NO;
        }
    } else {
        return YES;
    }
}

- (IBAction)newFolder:(id)sender {
	[self newFolderWithName:@"Untitled Folder" outlineRow:[sender tag]];
}

- (void)newFolderWithName:(NSString *)folderName outlineRow:(NSInteger)selectedRow {
    PCResourceDirectory *parentDirectory = [PCResourceManager sharedManager].rootResourceDirectory;
    if (!parentDirectory) return;

    if (selectedRow >= 0 && self.currentProjectSettings) {
        id<PCFileSystemResource> selectedItem = [self.resourceOutlineView itemAtRow:selectedRow];
        NSString *directoryPath = [selectedItem directoryPath];
        parentDirectory = [[PCResourceManager sharedManager] resourceDirectoryForPath:directoryPath];
    }

    NSError *error;
    PCResource *newDirectory = [[PCResourceManager sharedManager] addDirectoryNamed:folderName toDirectory:parentDirectory addingSuffixOnNameCollision:YES error:&error];
    if (error) {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Could not create directory" defaultButton:@"Ok" alternateButton:nil otherButton:nil informativeTextWithFormat:@"%@", [error localizedDescription]];
        [alert beginSheetModalForWindow:self.window completionHandler:nil];
        NSLog(@"Error creating directory: %@", error);
        return;
    }

    [self reloadResources];

    PCResource *parentDirectoryResource = [[PCResourceManager sharedManager] resourceForPath:parentDirectory.directoryPath];
    [self.resourceOutlineView expandItem:parentDirectoryResource];
    [self.resourceOutlineView editColumn:0 row:[self.resourceOutlineView rowForItem:newDirectory] withEvent:nil select:YES];
}

- (IBAction)newSlide:(id)sender {
    [self createNewSlide];
}

- (void)createNewSlide {
    PCSlide *slide = [[PCSlide alloc] init];
    
    NSMutableArray* resolutions = [NSMutableArray array];
    [self newFile:[slide absoluteFilePath] type:kCCBNewDocTypePCSlide resolutions:resolutions];
    [self saveFile:[slide absoluteFilePath] withPreview:NO];
    
    slide.document = [[CCBDocument alloc] initWithFile:[slide absoluteFilePath]];

    [self.pcSlidesViewController addSlide:slide];
    [slide updateThumbnail];
}

- (PCSlide *)slideWithDocumentPath:(NSString *)documentPath {
    for (PCSlide *slide in self.currentProjectSettings.slideList) {
        if ([slide.document.fileName isEqualToString:documentPath]) return slide;
    }
    return nil;
}

- (void)clearResourceFromProject:(PCResource *)resource {
    SKNode *rootNode;

    for (PCSlide *slide in self.currentProjectSettings.slideList) {
        if (slide.document == self.currentDocument) {
            rootNode = [PCStageScene scene].rootNode;

            NSArray *nodesUsingResource = [self findNodesUsingResource:resource recursivelyFromNode:rootNode];

            if ([nodesUsingResource count] > 0) {
                for (SKNode *node in nodesUsingResource) {
                    [node removeFromParent];
                }
            }
        }
        else {
            // This node graph isn't the one on screen
            rootNode = [CCBReaderInternal spriteKitNodeGraphFromDocumentDictionary:slide.document.docData parentSize:CGSizeZero];
            NSArray *nodesUsingResource = [self findNodesUsingResource:resource recursivelyFromNode:rootNode];

            if ([nodesUsingResource count] > 0) {
                for (SKNode *node in nodesUsingResource) {
                    [node removeFromParent];
                }

                // Need to update the document with the other node graph we created
                NSMutableDictionary *docData = slide.document.docData;
                NSMutableDictionary *nodeGraph = [CCBWriterInternal dictionaryFromSKNode:rootNode];
                docData[@"nodeGraph"] = nodeGraph;
                slide.document.docData = docData;
            }
        }
    }
}

- (NSArray *)findNodesUsingResource:(PCResource *)resource recursivelyFromNode:(SKNode *)node {
    NSMutableArray *nodesUsingResource = [NSMutableArray array];
    if ([node isKindOfClass:[SKSpriteNode class]] && [[node extraPropForKey:@"spriteFrame"] isEqualToString:resource.uuid]) {
        [nodesUsingResource addObject:node];
    }

    if ([node.children count] > 0) {
        for (SKNode *child in node.children) {
            [nodesUsingResource addObjectsFromArray:[self findNodesUsingResource:resource recursivelyFromNode:child]];
        }
    }

    return nodesUsingResource;
}

- (void) renamedDocumentPathFrom:(NSString*)oldPath to:(NSString*)newPath
{
    PCSlide *slide = [self slideWithDocumentPath:oldPath];
    slide.document.fileName = newPath;
}

- (IBAction)menuDeselect:(id)sender {
    self.selectedSpriteKitNodes = nil;
}

- (IBAction)showInstantAlphaUIForSelectedNode:(id)sender {
    // TODO Only enable the menu item if exactly one sprite is selected
    SKNode *selectedNode = self.selectedSpriteKitNodes.firstObject;
    if (!selectedNode || ![selectedNode isKindOfClass:[SKSpriteNode class]]) return;
    
    NSString *spriteUUID = [[selectedNode extraPropForKey:@"spriteFrame"] lastPathComponent];
    PCResource *spriteResource = [[PCResourceManager sharedManager] resourceWithUUID:spriteUUID];
    NSImage *spriteImage = [[NSImage alloc] initWithContentsOfFile:[spriteResource filePath]];
    if (!spriteImage) return;

    selectedNode.visible = NO;
    
    void (^cleanup)() = ^{
        [self.instantAlphaViewController.view removeFromSuperview];
        [((RPInstantAlphaViewController *)self.instantAlphaViewController) dismissHUD];
        self.instantAlphaViewController = nil;
        
        [[PCOverlayView overlayView] disableInteractionInUIKitWindow];
        
        selectedNode.visible = YES;
    };
    
    __block dispatch_block_t updateUI;
    self.instantAlphaViewController = [[RPInstantAlphaViewController alloc] initWithImage:spriteImage completion:^(NSImage *image, BOOL cancelled) {
        updateUI = nil; // Bit of a hack to keep the block around until completion since the overlay view only keeps a weak reference
        
        if (!image || cancelled) {
            cleanup();
            return;
        }

        // Save the edited file as temp file, import it into resources and point the sprite at it, then delete the temp file
        NSString *imageNameWithoutExtension = [[spriteResource.filePath lastPathComponent] stringByDeletingPathExtension];
        NSString *baseFileName = imageNameWithoutExtension;
        NSString *separator = [NSString stringWithFormat:@"-%@-", PCEditedImageSuffix];
        if (separator && [baseFileName rangeOfString:separator].location != NSNotFound) {
            baseFileName = [[imageNameWithoutExtension componentsSeparatedByString:separator] firstObject];
        }
        NSString *editedImageFileName = [[NSString stringWithFormat:@"%@-%@-%@", baseFileName, PCEditedImageSuffix, [[NSUUID UUID] UUIDString]] stringByAppendingPathExtension:@"png"];

        NSString *temporaryImagePath = [NSTemporaryDirectory() stringByAppendingPathComponent:editedImageFileName];
        CGImageRef imageRef = [image CGImageForProposedRect:NULL context:nil hints:nil];
        NSBitmapImageRep *imageRep = [[NSBitmapImageRep alloc] initWithCGImage:imageRef];
        [imageRep setSize:[image size]];
        NSData *pngData = [imageRep representationUsingType:NSPNGFileType properties:@{}];
        [[NSFileManager defaultManager] createFileAtPath:temporaryImagePath contents:pngData attributes:nil];

        NSString *destinationDirectory = [[[PCResourceManager sharedManager].rootDirectory directoryPath] stringByAppendingPathComponent:@"resources"];
        PCResource *importedResource = [[PCResourceManager sharedManager] importResourceAtAbsolutePath:temporaryImagePath intoDirectoryAtAbsolutePath:destinationDirectory appendSuffixIfFileExists:YES];

        NSError *deleteError;
        [[NSFileManager defaultManager] removeItemAtPath:temporaryImagePath error:&deleteError];
        if (deleteError) {
            NSLog(@"Error deleting temporary instant alpha file: %@", deleteError);
            cleanup();
            return;
        }

        [ResourcePropertySetter setResource:importedResource forProperty:@"spriteFrame" onNode:selectedNode];
        [selectedNode updateAnimateablePropertyValue:importedResource.uuid propName:@"spriteFrame"];
        [[AppDelegate appDelegate] saveUndoStateDidChangeProperty:@"spriteFrame"];
        
        cleanup();
    }];
    RPInstantAlphaImageView *imageView = (RPInstantAlphaImageView *)self.instantAlphaViewController.view;
    imageView.imageScaling = NSImageScaleAxesIndependently;
    imageView.imageAlignment = NSImageAlignCenter;
    self.instantAlphaViewController.view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    
    PCView *contentView = [[PCView alloc] initWithFrame:self.instantAlphaViewController.view.frame];
    [contentView addSubview:self.instantAlphaViewController.view];
    __weak typeof(contentView) weakContentView = contentView;
    __weak typeof(selectedNode) weakSelectedNode = selectedNode;
    // From PCTextView / PCOverlayView
    updateUI = ^{
        selectedNode.visible = YES;
        [[PCOverlayView overlayView] updateView:weakContentView fromNode:weakSelectedNode];
        selectedNode.visible = NO;
        weakContentView.hidden = NO;
    };
    updateUI();

    [[PCOverlayView overlayView] addContentView:contentView withUpdateBlock:updateUI];
    [self.instantAlphaViewController showHUD];
    
    [[PCOverlayView overlayView] enableInteractionInUIKitWindow];
}

- (BOOL)isShowingInstantAlpha {
    return (self.instantAlphaViewController != nil);
}

- (BOOL)instantAlphaIsEnabled {
    return [self.selectedSpriteKitNode isKindOfClass:[SKSpriteNode class]];
}

- (IBAction) undo:(id)sender
{
    if (!self.currentDocument) return;
    [self.currentDocument.undoManager undo];
    self.currentDocument.lastEditedProperty = NULL;
}

- (IBAction) redo:(id)sender
{
    if (!self.currentDocument) return;
    [self.currentDocument.undoManager redo];
    self.currentDocument.lastEditedProperty = NULL;
}

- (PCCanvasSize)orientedDeviceTypeForSize:(CGSize)size {
    PCDeviceTargetType deviceTarget = self.currentProjectSettings.deviceResolutionSettings.deviceTarget;
    PCDeviceTargetOrientation orientationTarget = self.currentProjectSettings.deviceResolutionSettings.deviceOrientation;
    if (deviceTarget == PCDeviceTargetTypePhone) {
        return (orientationTarget == PCDeviceTargetOrientationPortrait ? PCCanvasSizeIPhonePortrait : PCCanvasSizeIPhoneLandscape);
    } else {
        return (orientationTarget == PCDeviceTargetOrientationPortrait ? PCCanvasSizeIPadPortrait : PCCanvasSizeIPadLandscape);
    }
}

- (void) updatePositionScaleFactor
{
    [[PCStageScene scene].rulerLayer setup];
}

- (void) setResolution:(int)r
{
    self.currentDocument.currentResolution = r;
    
    [self updatePositionScaleFactor];
    
    
    [self updateResolutionMenu];
    [self reloadResources];
    
    // Update size of root node
    //[PositionPropertySetter refreshAllPositions];
}

- (IBAction) menuEditResolutionSettings:(id)sender
{
    if (!self.currentDocument) return;
    
    PCDeviceResolutionSettings* setting = self.currentDocument.resolutions.firstObject;
    
    StageSizeWindow* wc = [[StageSizeWindow alloc] initWithWindowNibName:@"StageSizeWindow"];
    wc.wStage = setting.width;
    wc.hStage = setting.height;
    
    int success = [wc runModalSheetForWindow:self.window];
    if (success)
    {
        setting.width = wc.wStage;
        setting.height = wc.hStage;
        
        self.currentDocument.resolutions = [self updateResolutions:self.currentDocument.resolutions forDocDimensionType:kCCBDocDimensionsTypeLayer];
        [self updateResolutionMenu];
        [self setResolution:0];
        
        [self saveUndoStateDidChangeProperty:@"*stageSize"];
    }
}

- (IBAction)menuResolution:(id)sender
{
    if (!self.currentDocument) return;
    
    [self setResolution:(int)[sender tag]];
    [self updateCanvasBorderMenu];
}

- (IBAction)menuEditCustomPropSettings:(id)sender
{
    if (!self.currentDocument) return;
    if (!self.selectedSpriteKitNode) return;
    
    NSString* customClass = [self.selectedSpriteKitNode extraPropForKey:@"customClass"];
    if (!customClass || [customClass isEqualToString:@""])
    {
        [self modalDialogTitle:@"Custom Class Needed" message:@"To add custom properties to a node you need to use a custom class."];
        return;
    }
    
    CustomPropSettingsWindow* wc = [[CustomPropSettingsWindow alloc] initWithWindowNibName:@"CustomPropSettingsWindow"];
    [wc copySettingsForNode:self.selectedSpriteKitNode];
    
    int success = [wc runModalSheetForWindow:self.window];
    if (success)
    {
        self.selectedSpriteKitNode.customProperties = wc.settings;
        [self updateInspectorFromSelection];
        
        [self saveUndoStateDidChangeProperty:@"*customPropSettings"];
    }
}

- (IBAction)menuSetStateOriginCentered:(id)sender {
    
    PCStageScene *stageScene = [PCStageScene scene];
    BOOL centered = ![stageScene centeredOrigin];
    [stageScene setStageSize:[stageScene stageSize] centeredOrigin:centered];
    
    [self saveUndoStateDidChangeProperty:@"*stageOriginCentered"];
    //[self updateStateOriginCenteredMenu];
}

- (void) updateCanvasBorderMenu
{
    int tag = self.currentProjectSettings.stageBorderType;
    [CCBUtil setSelectedSubmenuItemForMenu:self.menuCanvasBorder tag:tag];
}

- (void) updateWarningsButton
{
    [self updateWarningsOutline];
}

- (void) updateWarningsOutline
{
    self.warningHandler.warnings = self.currentProjectSettings.lastWarnings;
}

- (IBAction)physicsPanelAction:(id)sender {
    [self.physicsHandler togglePhysicsProperty:sender];
}

- (IBAction) menuSetCanvasBorder:(id)sender
{
    int tag = (int)[sender tag];
    self.currentProjectSettings.stageBorderType = tag;
    [[PCStageScene scene] setStageBorder:tag];
}

- (IBAction)menuZoomIn:(id)sender {
    PCStageScene *stageScene = [PCStageScene scene];
    stageScene.stageZoom = stageScene.stageZoom * 1.2;
}

- (IBAction)menuZoomOut:(id)sender {
    PCStageScene *stageScene = [PCStageScene scene];
    stageScene.stageZoom = stageScene.stageZoom / 1.2;
}

- (IBAction)menuResetView:(id)sender {
    PCStageScene *scene = [PCStageScene scene];
    scene.scrollOffset = CGPointZero;
    scene.stageZoom = 1;
}

- (IBAction)menuZoomToFit:(id)sender {
    PCStageScene *stageScene = [PCStageScene scene];
    stageScene.scrollOffset = CGPointZero;
    [stageScene zoomToFit];
}

- (IBAction)showHideTimelineView:(id)sender {
    [self.splitHorizontalView toggleBottomView];
}

- (IBAction)pressedToolSelection:(id)sender {
    NSSegmentedControl *segmentedControl = sender;

    PCStageScene *stageScene = [PCStageScene scene];
    stageScene.currentTool = (CCBTool)[segmentedControl selectedSegment];
}

- (IBAction) pressedPanelVisibility:(id)sender
{
    NSSegmentedControl* segmentedControl = sender;
    [self.window disableUpdatesUntilFlush];
    
    switch ([segmentedControl selectedSegment]) {
        case 0:
            [self.mainVerticalSplitView showLeftView:[segmentedControl isSelectedForSegment:0]];
            break;
        case 1:
            [self.splitHorizontalView toggleBottomView:[segmentedControl isSelectedForSegment:1]];
            break;
        case 2:
            [self.mainVerticalSplitView showRightView:[segmentedControl isSelectedForSegment:2]];
            break;
        default:
            break;
    }
}

- (IBAction)toggleAppSettingsView:(NSSegmentedControl *)sender {
    if (sender.selectedSegment == 0) {
        if (self.window.contentView == self.appSettingsView) return;

        [PCStageScene scene].paused = YES;

        self.appSettingsView.frame = self.window.frame;
        self.window.contentView = self.appSettingsView;

        NSUInteger index = [self.toolbar.items indexOfObject:self.panelVisibilityToolbarItem];
        if (index != NSNotFound) {
            [self.toolbar removeItemAtIndex:index];
        }
    }
    else if (sender.selectedSegment == 1) {
        if (self.window.contentView == self.drawingView) return;

        self.appSettingsView.frame = self.window.frame;
        self.window.contentView = self.drawingView;
        [self.toolbar insertItemWithItemIdentifier:self.panelVisibilityToolbarItem.itemIdentifier atIndex:self.toolbar.items.count];
        self.panelVisibilityToolbarItem.enabled = YES;

        [PCStageScene scene].paused = NO;
        [self.behaviourListViewController validate];
    }
}

- (IBAction)menuTimelineSettings:(id)sender {
    if (!self.currentDocument) return;

    SequencerSettingsWindowController *sequencerSettingsWindowController = [[SequencerSettingsWindowController alloc] initWithWindowNibName:@"SequencerSettingsWindow"];
    [sequencerSettingsWindowController copySequences:self.currentDocument.sequences];

    int success = [sequencerSettingsWindowController runModalSheetForWindow:self.window];
    if (!success) {
        return;
    }

    // Remove any deleted timelines
    for (SequencerSequence *sequence in self.currentDocument.sequences) {
        BOOL sequenceStillExists = NO;
        for (SequencerSequence *updatesSequence in sequencerSettingsWindowController.sequences) {
            if (sequence.sequenceId == updatesSequence.sequenceId) {
                sequenceStillExists = YES;
                break;
            }
        }
        if (!sequenceStillExists) {
            [self.sequenceHandler deleteSequenceId:sequence.sequenceId];
        }
    }

    // Assign unique IDs to newly created sequences
    for (SequencerSequence *sequence in sequencerSettingsWindowController.sequences) {
        if (sequence.sequenceId == -1) {
            sequence.sequenceId = [SequencerSequence uniqueSequenceIdFromSequencers:sequencerSettingsWindowController.sequences];
        }
    }

    // Update the timelines
    self.currentDocument.sequences = sequencerSettingsWindowController.sequences;
    self.sequenceHandler.currentSequence = self.currentDocument.sequences.firstObject;
    self.currentDocument.isDirty = YES;

    [self.behaviourListViewController validate];
    [self saveUndoStateDidChangeProperty:@"*timelinesEdited"];
}

- (IBAction)menuTimelineNew:(id)sender {
    if (!self.currentDocument) return;
    self.sequenceHandler.currentSequence = [self.currentDocument addNewSequencer];
    [self saveUndoStateDidChangeProperty:@"*newTimeline"];
}

- (IBAction)menuTimelineDuplicate:(id)sender
{
    if (!self.currentDocument) return;
    
    // Duplicate current timeline
    int newSeqId = [SequencerSequence uniqueSequenceIdFromSequencers:self.currentDocument.sequences];
    SequencerSequence* newSeq = [self.sequenceHandler.currentSequence duplicateWithNewId:newSeqId];
    
    // Add it to list
    [self.currentDocument.sequences addObject:newSeq];
    
    // and set it to current
    self.sequenceHandler.currentSequence = newSeq;
    [self saveUndoStateDidChangeProperty:@"*duplicateTimeline"];
}

- (IBAction)menuTimelineDuration:(id)sender
{
    if (!self.currentDocument) return;
    
    SequencerDurationWindow* wc = [[SequencerDurationWindow alloc] initWithWindowNibName:@"SequencerDurationWindow"];
    wc.duration = self.sequenceHandler.currentSequence.timelineLength;
    
    int success = [wc runModalSheetForWindow:self.window];
    if (success)
    {
        [self.sequenceHandler deleteKeyframesForCurrentSequenceAfterTime:wc.duration];
        self.sequenceHandler.currentSequence.timelineLength = wc.duration;
        [self updateInspectorFromSelection];
        [self saveUndoStateDidChangeProperty:@"*timelineDuration"];
    }
}

- (IBAction) menuOpenResourceManager:(id)sender
{
    //[resManagerPanel.window setIsVisible:![resManagerPanel.window isVisible]];
}

- (void) reloadResources
{
    if (!self.currentDocument) return;
    [self.sequenceHandler updatePropertiesToTimelinePosition];
}

- (CGFloat)contentScaleFactor {
    PCDeviceResolutionSettings *resolution = self.currentDocument.resolutions[self.currentDocument.currentResolution];
    return resolution.scale ?: 1;
}

- (IBAction)menuAlignToPixels:(id)sender {
    if (!self.currentDocument) return;
    if (self.selectedSpriteKitNodes.count == 0) return;

    [SKNode pc_alignNodesToPixels:self.selectedSpriteKitNodes];

    // Update keyframes after the position has been updated
    for (SKNode *node in self.selectedSpriteKitNodes) {
        if (![node allowsUserPositioning]) continue;
        [PositionPropertySetter addPositionKeyframeForSpriteKitNode:node];
    }

    [self refreshProperty:@"position"];
    
    [self saveUndoStateDidChangeProperty:@"*align"];
}

- (IBAction) menuAlignObjects:(id)sender
{
    [SKNode pc_alignNodes:self.selectedSpriteKitNodes withAlignment:[sender tag]];
}

- (IBAction)menuArrange:(id)sender {
    int type = [sender tag];

    SKNode *node = self.selectedSpriteKitNodes.firstObject;
    SKNode *parent = node.parent;

    NSArray *siblings = [node.parent children];

    // Check bounds
    if ((type == kCCBArrangeSendToBack || type == kCCBArrangeSendBackward) && [parent.children.firstObject isEqualTo:node]) {
        NSBeep();
        return;
    }

    if ((type == kCCBArrangeBringToFront || type == kCCBArrangeBringForward) && [parent.children.lastObject isEqualTo:node]) {
        NSBeep();
        return;
    }

    if (siblings.count < 2) {
        NSBeep();
        return;
    }

    int newIndex = 0;

    // Bring forward / send backward
    if (type == kCCBArrangeSendToBack) {
        newIndex = 0;
    }
    else if (type == kCCBArrangeBringToFront) {
        newIndex = siblings.count - 1;
    }
    else if (type == kCCBArrangeSendBackward) {
        newIndex = [parent.children indexOfObject:node] - 1;
    }
    else if (type == kCCBArrangeBringForward) {
        newIndex = [parent.children indexOfObject:node] + 1;
    }

    [self deleteNode:node];
    [self addSpriteKitNode:node toParent:parent atIndex:newIndex followInsertionNode:YES];
}

- (IBAction)menuSetEasing:(id)sender
{
    int easingType = [sender tag];
    [self.sequenceHandler setContextKeyframeEasingType:easingType];
    [self.sequenceHandler updatePropertiesToTimelinePosition];
}

- (IBAction)menuSetEasingOption:(id)sender
{
    if (!self.currentDocument) return;
    
    float opt = [self.sequenceHandler.contextKeyframe.easing.options floatValue];
    
    
    SequencerKeyframeEasingWindow* wc = [[SequencerKeyframeEasingWindow alloc] initWithWindowNibName:@"SequencerKeyframeEasingWindow"];
    wc.option = opt;
    
    int type = self.sequenceHandler.contextKeyframe.easing.type;
    if (type == kCCBKeyframeEasingCubicIn
        || type == kCCBKeyframeEasingCubicOut
        || type == kCCBKeyframeEasingCubicInOut)
    {
        wc.optionName = @"Rate:";
    }
    else if (type == kCCBKeyframeEasingElasticIn
             || type == kCCBKeyframeEasingElasticOut
             || type == kCCBKeyframeEasingElasticInOut)
    {
        wc.optionName = @"Period:";
    }
    
    int success = [wc runModalSheetForWindow:self.window];
    if (success)
    {
        float newOpt = wc.option;
        
        if (newOpt != opt)
        {
            self.sequenceHandler.contextKeyframe.easing.options = [NSNumber numberWithFloat:wc.option];
            [self.sequenceHandler updatePropertiesToTimelinePosition];
            [self saveUndoStateDidChangeProperty:@"*keyframeeasingoption"];
        }
    }
}

- (IBAction)menuCreateKeyframesFromSelection:(id)sender
{
    [SequencerUtil createFramesFromSelectedResources];
}

- (IBAction)menuActionDelete:(id)sender
{
    int selectedRow = [sender tag];
    
    if (selectedRow > 0 && self.currentProjectSettings)
    {
        ResourceManagerOutlineView * resManagerOutlineView = (ResourceManagerOutlineView*)self.resourceOutlineView;
        
        [resManagerOutlineView deleteSelectedResource];
    }
}

- (IBAction)menuActionNewFolder:(NSMenuItem*)sender
{
    //forward to normal handler.
    [self newFolder:sender];
}

- (IBAction)menuNewFolder:(NSMenuItem*)sender
{
    ResourceManagerOutlineView * resManagerOutlineView = (ResourceManagerOutlineView*)self.resourceOutlineView;
    sender.tag = resManagerOutlineView.selectedRow;
    
    [self newFolder:sender];
}

- (IBAction)menuAlignKeyframeToMarker:(id)sender
{
    [SequencerUtil alignKeyframesToMarker];
}

- (IBAction)menuStretchSelectedKeyframes:(id)sender
{
    SequencerStretchWindow* wc = [[SequencerStretchWindow alloc] initWithWindowNibName:@"SequencerStretchWindow"];
    wc.factor = 1;
    
    int success = [wc runModalSheetForWindow:self.window];
    if (success)
    {
        [SequencerUtil stretchSelectedKeyframes:wc.factor];
    }
}

- (IBAction)menuReverseSelectedKeyframes:(id)sender
{
    [SequencerUtil reverseSelectedKeyframes];
}

- (NSString*) keyframePropNameFromTag:(PCInsertKeyframeMenuTag)tag
{
    switch (tag) {
        case PCInsertKeyframeMenuTagVisible: return @"visible";
        case PCInsertKeyframeMenuTagPosition: return @"position";
        case PCInsertKeyframeMenuTagScale: return @"scale";
        case PCInsertKeyframeMenuTagRotation: return @"rotation";
        case PCInsertKeyframeMenuTagSpriteFrame: return @"spriteFrame";
        case PCInsertKeyframeMenuTagOpacity: return @"opacity";
        case PCInsertKeyframeMenuTagColor: return @"color";
        case PCInsertKeyframeMenuTagXRotation3D: return @"xRotation3D";
        case PCInsertKeyframeMenuTagYRotation3D: return @"yRotation3D";
        case PCInsertKeyframeMenuTagZRotation3D: return @"zRotation3D";
        default: return nil;
    } 
}

- (IBAction)menuAddKeyframe:(id)sender
{
    PCInsertKeyframeMenuTag tag = (PCInsertKeyframeMenuTag) [sender tag];
    [self.sequenceHandler menuAddKeyframeNamed:[self keyframePropNameFromTag:tag]];
}

- (IBAction)menuAddEventKeyframe:(id)sender {
    SequencerSequence* seq = [SequencerHandler sharedHandler].currentSequence;
    [self.scrubberSelectionView addKeyframeAtRow:sequencerCallBackTimelineRow sub:sequencerCallBackTimelineRow time:seq.timelinePosition];
}

- (IBAction)menuCutKeyframe:(id)sender
{
    [self cut:sender];
}

- (IBAction)menuCopyKeyframe:(id)sender
{
    [self copy:sender];
}

- (IBAction)menuPasteKeyframes:(id)sender
{
    [self paste:sender];
}

- (IBAction)menuDeleteKeyframe:(id)sender
{
    [self cut:sender];
}

- (IBAction)menuJavaScriptControlled:(id)sender
{
    self.jsControlled = !self.jsControlled;
    //[self updateJSControlledMenu];
    [self updateInspectorFromSelection];
    [self saveUndoStateDidChangeProperty:@"*javascriptcontrolled"];    
}

- (BOOL) validateMenuItem:(NSMenuItem *)menuItem
{
    if (menuItem.action == @selector(saveDocument:)) return self.hasOpenedDocument;
    else if (menuItem.action == @selector(saveProjectAs:)) return self.hasOpenedDocument;
    else if (menuItem.action == @selector(saveAllDocuments:)) return self.hasOpenedDocument;
    else if (menuItem.action == @selector(performClose:)) return self.hasOpenedDocument;
    else if (menuItem.action == @selector(menuCreateKeyframesFromSelection:))
    {
        return NO;
//        return (hasOpenedDocument && [SequencerUtil canCreateFramesFromSelectedResources]);
    }
    else if (menuItem.action == @selector(menuAlignKeyframeToMarker:))
    {
        return (self.hasOpenedDocument && [SequencerUtil canAlignKeyframesToMarker]);
    }
    else if (menuItem.action == @selector(menuStretchSelectedKeyframes:))
    {
        return (self.hasOpenedDocument && [SequencerUtil canStretchSelectedKeyframes]);
    }
    else if (menuItem.action == @selector(menuReverseSelectedKeyframes:))
    {
        return (self.hasOpenedDocument && [SequencerUtil canReverseSelectedKeyframes]);
    }
    else if (menuItem.action == @selector(menuAddKeyframe:))
    {
        if (!self.hasOpenedDocument) return NO;
        if (!self.selectedSpriteKitNode) return NO;

        PCInsertKeyframeMenuTag tag = (PCInsertKeyframeMenuTag) menuItem.tag;
        return [self.sequenceHandler canInsertKeyframeNamed:[self keyframePropNameFromTag:tag]];
    }
    else if (menuItem.action == @selector(menuSetCanvasBorder:))
    {
        if (!self.hasOpenedDocument) return NO;
        int tag = [menuItem tag];
        if (tag == PCStageBorderTypeNone) return YES;
        CGSize canvasSize = [[PCStageScene scene] stageSize];
        if (canvasSize.width == 0 || canvasSize.height == 0) return NO;
        return YES;
    }
    else if (menuItem.action == @selector(menuArrange:))
    {
        if (!self.hasOpenedDocument) return NO;
        return (self.selectedSpriteKitNode != NULL);
    }
    else if (menuItem.action == @selector(menuRun:)) {
        return self.hasOpenedDocument;
    } else if (menuItem.action == @selector(menuActionDelete:)) {
		if (self.resourceOutlineView.selectedRow == 0) {
			return NO;
		}
	}
    
    return YES;
}

- (IBAction)menuAbout:(id)sender
{
    if(!self.aboutWindow)
    {
        self.aboutWindow = [[AboutWindow alloc] initWithWindowNibName:@"AboutWindow"];
    }
    
    [self.aboutWindow show];
}

- (NSUndoManager*) windowWillReturnUndoManager:(NSWindow *)window {
    return [PCUndoManager sharedPCUndoManager];
}


#pragma mark - Adding Child Nodes

- (BOOL)addSpriteKitNode:(SKNode *)node toParent:(SKNode *)parent atIndex:(NSInteger)index followInsertionNode:(BOOL)followInsertion {
    if (!node || !parent) return NO;
    
    if (followInsertion) {
        while ([parent conformsToProtocol:@protocol(PCNodeChildInsertion)]) {
            SKNode *newParent = [(id<PCNodeChildInsertion>)parent insertionNode];
            if (!newParent) break;
            if (newParent == parent) break;
            parent = newParent;
        }
    }
    
    PlugInNode *parentPlugin = [self pluginNodeForNode:parent];
    PlugInNode *nodePlugin = [self pluginNodeForNode:node];
    
    // Check that the parent supports children
    if (parentPlugin && !parentPlugin.canHaveChildren) {
        //[self modalDialogTitle:@"Failed to add item" message:[NSString stringWithFormat: @"You cannot add children to a %@",nodeInfoParent.plugIn.nodeClassName]];
        self.errorDescription = [NSString stringWithFormat: @"You cannot add children to a %@", parentPlugin.nodeClassName];
        return NO;
    }
    
    // Check if the added node requires a specific type of parent
    NSString *requireParent = nodePlugin.requireParentClass;
    if (requireParent && ![requireParent isEqualToString: parentPlugin.nodeClassName]) {
    //[self modalDialogTitle:@"Failed to add item" message:[NSString stringWithFormat: @"A %@ must be added to a %@",nodeInfo.plugIn.nodeClassName, requireParent]];
        self.errorDescription = [NSString stringWithFormat: @"A %@ must be added to a %@", nodePlugin.nodeClassName, requireParent];
        return NO;
    }
    
    // Check if the parent require a specific type of children
    NSArray *requireChild = parentPlugin.requireChildClass;
    if (requireChild && [requireChild indexOfObject:nodePlugin.nodeClassName] == NSNotFound) {
        //[self modalDialogTitle:@"Failed to add item" message:[NSString stringWithFormat: @"You cannot add a %@ to a %@",nodeInfo.plugIn.nodeClassName, nodeInfoParent.plugIn.nodeClassName]];
        self.errorDescription = [NSString stringWithFormat: @"You cannot add a %@ to a %@", nodePlugin.nodeClassName, parentPlugin.nodeClassName];
        return NO;
    }
    
    if (index == -1 || index >= [parent.children count]) {
        [parent addChild:node];
    }
    else if (index < [parent.children count]) {
        [parent insertChild:node atIndex:index];
    }
    
    if (parent.hidden) {
        node.hidden = YES;
    }

    [self reloadObjectHierarchy];

    [self saveUndoStateDidChangePropertySkipSameCheck:@"*objectHiearchyChange"];
    
    self.selectedSpriteKitNodes = @[ node ];

    [[PCStageScene scene] selectNodeForMouseInput:node];
    
    return YES;
}
        
- (BOOL)addSpriteKitNode:(SKNode *)node toParent:(SKNode *)parent {
    return [self addSpriteKitNode:node toParent:parent atIndex:-1 followInsertionNode:YES];
}
        
- (BOOL)addSpriteKitNode:(SKNode*)node asChild:(BOOL)asChild {
    SKNode *parent = [PCStageScene scene].rootNode;

    if (asChild) {
        parent = self.selectedSpriteKitNodes.firstObject;

        if (!parent && ![PCStageScene scene].rootNode) return NO;
        
        if (!parent) {
            self.selectedSpriteKitNodes = @[ [PCStageScene scene].rootNode ];
        }
    } else {
        SKNode *firstSelectedNode = self.selectedSpriteKitNodes.firstObject;
        if (firstSelectedNode && firstSelectedNode != parent) {
            parent = [self nodeWithPluginForNode:firstSelectedNode.parent];
        }
    }

    BOOL success = [self addSpriteKitNode:node toParent:parent];
    if (!success && !asChild) {
        // If failed to add the node, attempt to add it as a child instead
        return [self addSpriteKitNode:node asChild:YES];
    }
    return success;
}
        
#pragma mark Plugins

// Called when double clicking a node on plugin list
// Called when clicking shape|text out from shortcut alley
- (void)dropAddPlugInNodeNamed:(NSString *)nodeName parent:(SKNode *)parent index:(int)idx {
    if (![parent isKindOfClass:[SKNode class]]) return;
    [self addSpriteKitPlugInNodeNamed:nodeName asChild:YES toParent:parent atIndex:idx followInsertionNode:YES];
}

// Called when dragging a node out from plugin list
// Called when dragging shape|text out from shortcut alley
- (void) dropAddPlugInNodeNamed:(NSString*)nodeName at:(CGPoint)pt userInfo:(NSDictionary *)userInfo
{
    // New node was dropped in working canvas
    SKNode* addedNode = [self addPlugInSpriteKitNodeNamed:nodeName asChild:NO];
    if (!addedNode) return;
    // special case for dragging from the Text/font popover
    if ([addedNode isKindOfClass:NSClassFromString(@"PCSKTextView")]) {
        PCSKTextView *textView = (PCSKTextView *)addedNode;
        if (userInfo) {
            NSFont *font = userInfo[@"defaultFont"];
            if (font) {
                [textView setFont:font];
            }
        }
    }
    else if ([nodeName isEqualToString:@"PCShapeNode"]) {
        PCSKShapeNode *shapeNode = (PCSKShapeNode *)addedNode;
        if (userInfo) {
            NSInteger shapeType = [userInfo[@"shapeType"] integerValue];
            [shapeNode setShapeType:shapeType];
        }
    } else if ([addedNode isKindOfClass:NSClassFromString(@"PCParticleSystem")]) {
        PCTemplate *template = userInfo[@"particleTemplate"];
        if (template) {
            [self.propertyInspectorHandler applyTemplate:template];
            [self refreshAllProperties];
        }
    }
    
    // Set position
    [self setNodePositionAfterDrop:addedNode point:pt];
    
    [self saveUndoStateToCacheForComparison];
}

- (SKNode *)addSpriteKitPlugInNodeNamed:(NSString *)name asChild:(BOOL)asChild toParent:(SKNode *)parent atIndex:(int)index followInsertionNode:(BOOL)followInsertion {
    return [self addSpriteKitPlugInNodeNamed:name asChild:asChild toParent:parent atIndex:index followInsertionNode:followInsertion andConfigureWithBlock:nil];
}

- (SKNode *)addSpriteKitPlugInNodeNamed:(NSString *)name asChild:(BOOL)asChild toParent:(SKNode *)parent atIndex:(int)index followInsertionNode:(BOOL)followInsertion andConfigureWithBlock:(void (^)(SKNode *))configurationBlock {
    self.errorDescription = NULL;
    __block BOOL success;

    SKNode *node = [[PlugInManager sharedManager] createDefaultSpriteKitNodeOfType:name andConfigureWithBlock:^(SKNode *node) {
        [self assignUniqueNameToNode:node];

        if (configurationBlock) {
            configurationBlock(node);
        }

        if (parent) {
            success = [self addSpriteKitNode:node toParent:parent atIndex:index followInsertionNode:followInsertion];
        }
        else {
            success = [self addSpriteKitNode:node asChild:asChild];
        }

        [node pc_firstTimeSetup];
    }];

    if (!node) return nil;
    
    if (!success && self.errorDescription)
    {
        node = NULL;
        [self modalDialogTitle:@"Failed to Add Object" message:self.errorDescription];
    }
    
    [self reloadObjectHierarchy];
    [self setSelectedNode:node];
    [self.behaviourListViewController validate];

    return node;
}

#pragma mark Sprites

// Called when dragging out sprite from shortcut alley
// Called when dragging out from media library (left panel)
- (void)dropAddSpriteWithUUID:(NSString *)uuid at:(CGPoint)point parent:(SKNode *)parent {
    SKNode *firstNode = self.selectedSpriteKitNodes.firstObject;
    if (!parent && firstNode && firstNode != [[PCStageScene scene] rootNode]) {
        parent = firstNode.parent;
    }
    if (!parent) {
        parent = [[PCStageScene scene] rootNode];
    }
    
    PlugInNode *plugIn = [self pluginNodeForNode:parent];
    
    if (!uuid) uuid = @"";
    
    NSString *class = plugIn.dropTargetSpriteFrameClass;
    NSString *property = plugIn.dropTargetSpriteFrameProperty;
    
    if (!class || !property) return;

    // Create the node
    SKNode* node = [[PlugInManager sharedManager] createDefaultSpriteKitNodeOfType:class andConfigureWithBlock:^(SKNode *node) {
        [self assignUniqueNameToNode:node];

        [CCBReaderInternal setProp:property ofType:@"SpriteFrame" toValue:uuid forSpriteKitNode:node parentSize:CGSizeZero];
        // Set it's displayName to the name of the spriteFile
        PCResource *resource = [[PCResourceManager sharedManager] resourceWithUUID:uuid];
        if (resource) {
            node.displayName = [[resource.filePath lastPathComponent] stringByDeletingPathExtension];
        }
    }];

    [self addSpriteKitNode:node asChild:NO];
    
    [self setNodePositionAfterDrop:node point:point];
}

- (void)dropAddSpriteWithUUID:(NSString *)uuid at:(CGPoint)point {
    SKNode *node = self.selectedSpriteKitNodes.firstObject;
    if (!node) node = [PCStageScene scene].rootNode;
    
    SKNode *parent = node.parent;
    NodeInfo *info = parent.userObject;
    
    if (info.plugIn.acceptsDroppedSpriteFrameChildren) {
        [self dropAddSpriteWithUUID:uuid at:point parent:parent];
        return;
    }
    
    info = node.userObject;
    if (info.plugIn.acceptsDroppedSpriteFrameChildren) {
        [self dropAddSpriteWithUUID:uuid at:point parent:node];
    }
}

- (void)dropAddSpriteWithUUID:(NSString *)uuid {
    [self dropAddSpriteWithUUID:uuid at:PCPointNil parent:nil];
}

#pragma mark Videos

// Called when double clicking a video in media library
- (void)dropAddVideoWithFile:(NSString *)videoFile {
    [self dropAddVideoWithFile:videoFile at:PCPointNil];
}

- (void) dropAddVideoWithFile:(NSString *)videoFilePath at:(CGPoint)pt {
    // New node was dropped in working canvas
    PCSKVideoPlayer *addedNode = (PCSKVideoPlayer *)[self addSpriteKitPlugInNodeNamed:@"PCVideoPlayer" asChild:NO toParent:nil atIndex:0 followInsertionNode:YES andConfigureWithBlock:^(SKNode *createdNode) {
        PCSKVideoPlayer *videoPlayer = (PCSKVideoPlayer *)createdNode;
        videoPlayer.fileUUID = [ResourceManagerUtil uuidForResourceWithRelativePath:videoFilePath];
    }];

    if (!addedNode) return;
    [self setNodePositionAfterDrop:addedNode point:pt];
    [self updateInspectorFromSelection];
}

#pragma mark 3D

// Called when double clicking a video in media library
- (void)dropAdd3DModelWithFile:(NSString *)modelFile {
    [self dropAdd3DModelWithFile:modelFile at:PCPointNil];
}

- (void)dropAdd3DModelWithFile:(NSString *)modelFile at:(CGPoint)pt {
    // New node was dropped in working canvas
    PC3DNode *addedNode = (PC3DNode *)[self addPlugInSpriteKitNodeNamed:@"PC3DNode" asChild:NO];
    
    // Set position
    if (!addedNode) {
        return;
    }
    addedNode.filePath = [ResourceManagerUtil uuidForResourceWithRelativePath:modelFile];
    [self assignUniqueNameToNode:addedNode];
    [self updateInspectorFromSelection];
    [self setNodePositionAfterDrop:addedNode point:pt];
}

#pragma mark Other

// called when any resource is dropped into the canvas area
- (void)dropAddResource {
	if (self.selectedPopover.isShown) {
		[self.selectedPopover performClose:nil];
	}
}

#pragma mark Utility

- (void)setNodePositionAfterDrop:(SKNode *)droppedNode point:(CGPoint)point {
    if (!droppedNode) { return; }
    
    // Get parent we are being added to
    SKNode *parent = droppedNode.parent;
    if (!parent) parent = [PCStageScene scene].rootNode;
    
    // If nil point add to center of parent
    if (PCPointIsNil(point)) {
        CGRect frame = parent.frame;
                                                                                                                   
        if ((frame.size.width == 0 || frame.size.height == 0) && parent.parent) {
            // Crop nodes have no size and this is basically a nasty hack but I can't think of anything better.
            frame = parent.parent.frame;
        }
        
        point = CGPointMake(frame.size.width * 0.5 - (parent.anchorPoint.x * frame.size.width), frame.size.height * 0.5 - (parent.anchorPoint.y * frame.size.height));
        
        point = [parent pc_convertToWorldSpace:point];
    }
    
    point = [parent pc_convertToNodeSpace:point];
    
    // Round position
    point.x = roundf(point.x);
    point.y = roundf(point.y);
    [PositionPropertySetter setPosition:NSPointFromCGPoint(point) forSpriteKitNode:droppedNode prop:@"position"];
    
    [self.nodeManager updateNodeManagerInspectorForProperty:@"position"];
    
    [self updateInspectorFromSelection];
    
    // save the document state after we have set the node position
    [self saveUndoStateToCacheForComparison];
}

- (void)assignUniqueNameToNode:(SKNode *)addedNode {
    NodeInfo *info = (NodeInfo *)addedNode.userObject;
    NSString *className = [info.plugIn.displayName stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSArray *allNodes = [[PCStageScene scene].rootNode allNodes];
    addedNode.name = [addedNode uniqueDisplayNameFromName:className withinNodes:allNodes];
}

- (void)assignUuidToNode:(SKNode *)addedNode {
    NodeInfo *info = (NodeInfo *)addedNode.userObject;
    [info generateUuid];
}

#pragma mark - Playback countrols

- (void) updatePlayback
{
    
    if (!self.currentDocument)
    {
        [self playbackStop:NULL];
    }
    
    if (self.playingBack)
    {
        // Step forward
        
        double thisTime = [NSDate timeIntervalSinceReferenceDate];
        double deltaTime = thisTime - self.playbackLastFrameTime;
        double frameDelta = 1.0/self.sequenceHandler.currentSequence.timelineResolution;
        float targetNewTime =  self.sequenceHandler.currentSequence.timelinePosition + deltaTime;
        
        int steps = (int)(deltaTime/frameDelta);
        
        //determine new time in to the future.
        
        [self.sequenceHandler.currentSequence stepForward:steps];
        
        if (self.sequenceHandler.currentSequence.timelinePosition >= self.sequenceHandler.currentSequence.timelineLength)
        {
            [[OALSimpleAudio sharedInstance] stopAllEffects];
            //If we loop, calulate the overhang
            if(targetNewTime >= self.sequenceHandler.currentSequence.timelinePosition && self.sequenceHandler.loopPlayback)
            {
                [self playbackJumpToStart:nil];
                steps = (int)((targetNewTime - self.sequenceHandler.currentSequence.timelineLength)/frameDelta);
                [self.sequenceHandler.currentSequence stepForward:steps];
            }
            else
            {
                [self playbackStop:NULL];
                return;
            }
        }
    
        self.playbackLastFrameTime += steps * frameDelta;
        
        // Call this method again in a little while
        [self performSelector:@selector(updatePlayback) withObject:nil afterDelay:frameDelta];
        
    } else {
        [[OALSimpleAudio sharedInstance] stopAllEffects];
    }
}

- (IBAction)togglePlayback:(id)sender {
    if(!self.playingBack)
    {
        [self playbackPlay:sender];
    }
    else
    {
        [self playbackStop:sender];
    }
}

- (IBAction)toggleLoopingPlayback:(id)sender
{
    self.sequenceHandler.loopPlayback = [(NSButton*)sender state] == 1 ? YES : NO;
}

- (IBAction)playbackPlay:(id)sender
{
    if (!self.hasOpenedDocument) return;
    if (self.playingBack) return;
    
    // Jump to start of sequence if the end is reached
    if (self.sequenceHandler.currentSequence.timelinePosition >= self.sequenceHandler.currentSequence.timelineLength)
    {
        self.sequenceHandler.currentSequence.timelinePosition = 0;
    }
    
    // Deselect all objects to improve performance
    self.selectedSpriteKitNodes = nil;
    
    // Start playback
    self.playbackLastFrameTime = [NSDate timeIntervalSinceReferenceDate];
    self.playingBack = YES;
    [self updatePlayback];
}

- (IBAction)playbackStop:(id)sender
{
    self.playingBack = NO;
}

- (IBAction)playbackJumpToStart:(id)sender
{
    if (!self.hasOpenedDocument) return;
    self.playbackLastFrameTime = [NSDate timeIntervalSinceReferenceDate];
    self.sequenceHandler.currentSequence.timelinePosition = 0;
    [[SequencerHandler sharedHandler] updateScrollerToShowCurrentTime];
    [[OALSimpleAudio sharedInstance] stopAllEffects];
}

- (IBAction)playbackStepBack:(id)sender
{
    if (!self.hasOpenedDocument) return;
    [self.sequenceHandler.currentSequence stepBack:1];
}

- (IBAction)playbackStepForward:(id)sender
{
    if (!self.hasOpenedDocument) return;
    [self.sequenceHandler.currentSequence stepForward:1];
}

- (IBAction)pressedPlaybackControl:(id)sender
{
    NSSegmentedControl* sc = sender;
    
    int tag = [sc selectedSegment];
    if (tag == 0) [self playbackJumpToStart:sender];
    else if (tag == 1) [self playbackStepBack:sender];
    else if (tag == 2) [self playbackStepForward:sender];
    else if (tag == 3) [self playbackStop:sender];
    else if (tag == 4) [self playbackPlay:sender];
    else if (tag == -1)
    {
        NSLog(@"No selected index!!");
    }
}

#pragma mark - Delegate methods

- (BOOL) windowShouldClose:(id)sender
{
    if ([self hasDirtyDocument])
    {
        NSAlert* alert = [NSAlert alertWithMessageText:@"Quit PencilCase" defaultButton:@"Save" alternateButton:@"Cancel" otherButton:@"Discard Changes" informativeTextWithFormat:@"There are unsaved documents. If you quit now you will lose any changes you have made."];
        [alert setAlertStyle:NSWarningAlertStyle];
        NSInteger result = [alert runModal];
        switch (result) {
            case NSAlertDefaultReturn: // save
                [self saveAllDocuments:nil];
                return YES;
            case NSAlertAlternateReturn: // cancel
                return NO;
            case NSAlertOtherReturn: // discard
            default:
                return YES;
        }
    }
    return YES;
}

- (void) windowWillClose:(NSNotification *)notification
{
    [[NSApplication sharedApplication] terminate:self];
}

- (IBAction) menuQuit:(id)sender
{
    if ([self windowShouldClose:self.window])
    {
        [[NSApplication sharedApplication] terminate:self];
    }
}

- (IBAction)playButtonPressed:(id)sender {
    NSInteger deploymentTarget = [self.deploymentPopupButton selectedTag];
    switch(deploymentTarget) {
        case PCRunTargetSimulator:
            [self menuRun:nil];
            return;
        case PCRunTargetExportToXCode:
            [self menuPublishToXcode:nil];
            return;
        }
}

- (IBAction)menuRun:(id)sender {
    [self publishAndRun];
}

- (IBAction)showRecentsWindow:(id)sender {
    [self.splashController showRecents];
}

- (IBAction)createNewProject:(id)sender {
    [self.splashController showNewProject];
}

#pragma mark - BITCrashManagerDelegate

- (void)showMainApplicationWindowForCrashManager:(id)crashManager {
    // launch the main app window
    [self.window makeFirstResponder:nil];
    [self.window makeKeyAndOrderFront:nil];
}

#pragma mark - SUUpdaterDelegate

- (NSArray *)feedParametersForUpdater:(SUUpdater *)updater sendingSystemProfile:(BOOL)sendingProfile {
    return [[BITSystemProfile sharedSystemProfile] systemUsageData];
}

#pragma mark - PCResourceManager resource observer

- (void)resourceListUpdated {
    [self.behaviourListViewController validate];
    [self updateInspectorFromSelection];
}

- (IBAction)openTrainingGuide:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://github.com/robotsandpencils/pencilcase/wiki"]];
}

@end
