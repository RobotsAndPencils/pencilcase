//
//  PCRecentsViewController.m
//  SpriteBuilder
//
//  Created by Orest Nazarewycz on 2014-11-14.
//
//

#import "PCRecentsViewController.h"
#import "NSButton+CosmeticUtilities.h"
#import "PCSplashNavigationViewController.h"
#import "NSColor+HexColors.h"
#import "PCUserProjectDocuments.h"
#import "PCUserProjectTableRowView.h"
#import "TTTTimeIntervalFormatter.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "PCView.h"
#import "NSColor+PCColors.h"

static NSString * const PCLabelKey = @"label";
static NSString * const PCBackgroundKey = @"background";

typedef NS_ENUM(NSInteger, PCRecentsFilter) {
    PCRecentsFilterNone = 0,
    PCRecentsFilterPhone,
    PCRecentsFilterTablet,
    PCRecentsFilterFavorites
};

@interface PCRecentsViewController () <NSTableViewDelegate>

@property (strong, nonatomic) NSMutableArray *allRecentProjects;
@property (strong, nonatomic) NSMutableArray *filteredRecentProjects;
@property (weak, nonatomic) IBOutlet NSButton *filterRecentButton;
@property (weak, nonatomic) IBOutlet NSButton *filterPhoneButton;
@property (weak, nonatomic) IBOutlet NSButton *filterTabletButton;
@property (weak, nonatomic) IBOutlet NSButton *filterFavoritesButton;

@property (weak) IBOutlet NSTextField *versionNumberLabel;

@property (weak, nonatomic) IBOutlet NSTableView *projectList;
@property (strong, nonatomic) NSTableView *projectListTableView;

@property (weak, nonatomic) IBOutlet NSTextField *titleLabel;
@property (weak, nonatomic) IBOutlet NSTextField *seeWhatsPossibleLabel;
@property (weak, nonatomic) IBOutlet NSTextField *pcVersionTextLabel;
@property (weak, nonatomic) IBOutlet NSTextField *registeredToTextLabel;
@property (weak, nonatomic) IBOutlet NSView *videoArea;
@property (strong, nonatomic) AVPlayerView *promoVideoPlayerView;

@property (strong, nonatomic) NSMutableArray *gothamBookViews;

@end

@implementation PCRecentsViewController

- (void)loadView {
    [super loadView];
    [[PCUserProjectDocuments userDocuments] readProjectReferenceURLs];

    [self setupInterfaceFonts];

    self.projectListTableView = self.projectList;
    self.projectList.delegate = self;
    self.allRecentProjects = [[NSMutableArray alloc] init];
    self.projectListTableView.target = self;
    
    NSURL* promoVideoPath = [[NSBundle mainBundle] URLForResource:@"PencilCasePromoVideo" withExtension:@"mov"];
    AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:promoVideoPath];
    self.promoVideoPlayerView = [[AVPlayerView alloc] initWithFrame:self.videoArea.bounds];
    self.promoVideoPlayerView.player = [[AVPlayer alloc] initWithPlayerItem:playerItem];
    [self.videoArea addSubview:self.promoVideoPlayerView];
    
    [self.filterFavoritesButton sendActionOn:NSLeftMouseDownMask];
    [self.filterPhoneButton sendActionOn:NSLeftMouseDownMask];
    [self.filterTabletButton sendActionOn:NSLeftMouseDownMask];
    [self.filterRecentButton sendActionOn:NSLeftMouseDownMask];

    self.projectListTableView.action = @selector(openClickedRow:);

    self.versionNumberLabel.stringValue = [[NSBundle mainBundle] infoDictionary][(NSString *)kCFBundleVersionKey];

    [self loadRecentsList];
    self.projectList.hidden = self.allRecentProjects.count == 0;
}

- (void)loadRecentsList {
    [self.allRecentProjects removeAllObjects];
    NSMutableArray *allProjects = [[PCUserProjectDocuments userDocuments] userProjectDocuments];
    for (PCUserProjectDocument *document in allProjects) {
        [self.allRecentProjects addObject:document];
    }
    [self filterRecentProjectsList:self.filterRecentButton];
}

- (void)viewDidDisappear {
    [self.promoVideoPlayerView.player pause];
}

- (void)setupInterfaceFonts {
    self.titleLabel.font = [NSFont fontWithName:@"Montserrat-Light" size:self.titleLabel.font.pointSize];
    self.seeWhatsPossibleLabel.textColor = [NSColor pc_darkLabelColor];
}

- (NSArray *)recentURLs {
    return [[NSDocumentController sharedDocumentController] recentDocumentURLs];
}

- (void)openClickedRow:(id)sender {
    NSInteger index = [self.projectListTableView clickedRow];
    /**
     Should fix hockey crash https://rink.hockeyapp.net/manage/apps/59357/app_versions/129/crash_reasons/49726874
     From Apple docs:
     This property contains the index of the row that the user clicked. The value is -1 when the user clicks in an area of the table view that is not occupied by table rows.
     */
    if (index == -1) return;

    PCUserProjectDocument *projectInfo = self.filteredRecentProjects[index];
    NSURL *url = projectInfo.userProjectReferenceUrl;
    [[NSNotificationCenter defaultCenter] postNotificationName:PCOpenProjectNotification object:nil userInfo:@{ PCOpenProjectURLKey: url }];
}

#pragma mark - Public

- (void)reload {
    [[PCUserProjectDocuments userDocuments] readProjectReferenceURLs];
    [self loadRecentsList];
    [self.projectListTableView reloadData];
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.filteredRecentProjects.count;
}

- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row {
    PCUserProjectTableRowView *tableRow = [[PCUserProjectTableRowView alloc] initWithFrame:CGRectMake(0, 0, 360, 61)];
    return tableRow;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSTableCellView *result = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    PCUserProjectDocument *projectInfo = self.filteredRecentProjects[row];
    NSTextField *projectTitleLabel = [result viewWithTag:0];
    NSTextField *deviceTargetTextField = [result viewWithTag:1];
    NSImageView *appIconImageView = [result viewWithTag:2];
    NSButton *favoriteButton = [result viewWithTag:3];
    PCView *backgroundView = [result viewWithTag:4];

    projectTitleLabel.stringValue = projectInfo.projectName;
    projectTitleLabel.textColor = [NSColor pc_darkLabelColor];
    deviceTargetTextField.font = [NSFont fontWithName:@"Gotham-Light" size:deviceTargetTextField.font.pointSize];
    deviceTargetTextField.stringValue = [PCDeviceResolutionSettings stringForPCDeviceTargetType:projectInfo.deviceTarget];
    TTTTimeIntervalFormatter *timeIntervalFormatter = [[TTTTimeIntervalFormatter alloc] init];
    NSString *modificationDate = [timeIntervalFormatter stringForTimeIntervalFromDate:[NSDate date] toDate:projectInfo.modificationDate];

    deviceTargetTextField.stringValue = [NSString stringWithFormat:@"%@ - %@", [PCDeviceResolutionSettings stringForPCDeviceTargetType:projectInfo.deviceTarget], modificationDate];
    appIconImageView.image = projectInfo.projectAppIcon;
    favoriteButton.state = projectInfo.isFavorite;

    NSTrackingArea *trackingArea = [[NSTrackingArea alloc] initWithRect:result.bounds options:(NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved | NSTrackingActiveInKeyWindow) owner:self userInfo:@{ PCLabelKey : projectTitleLabel, PCBackgroundKey : backgroundView }];
    [result addTrackingArea:trackingArea];
    return result;
}

- (IBAction)filterRecentProjectsList:(id)sender {
    NSButton *filterButton = (NSButton *)sender;
    self.filterRecentButton.state = NSOffState;
    self.filterPhoneButton.state = NSOffState;
    self.filterTabletButton.state = NSOffState;
    self.filterFavoritesButton.state = NSOffState;
    filterButton.state = NSOnState;
    [self resignFirstResponder];

    switch (filterButton.tag) {
        case PCRecentsFilterPhone:
            self.filteredRecentProjects = [Underscore.array(self.allRecentProjects).filter(^BOOL(PCUserProjectDocument *projectinfo) {
                return projectinfo.deviceTarget == PCDeviceTargetTypePhone;
            }).unwrap mutableCopy];
            break;
        case PCRecentsFilterTablet:
            self.filteredRecentProjects = [Underscore.array(self.allRecentProjects).filter(^BOOL(PCUserProjectDocument *projectinfo) {
                return projectinfo.deviceTarget == PCDeviceTargetTypeTablet;
            }).unwrap mutableCopy];
            break;
        case PCRecentsFilterFavorites:
            self.filteredRecentProjects = [Underscore.array(self.allRecentProjects).filter(^BOOL(PCUserProjectDocument *projectinfo) {
                return projectinfo.isFavorite;
            }).unwrap mutableCopy];
            break;
        case PCRecentsFilterNone:
        default:
            self.filteredRecentProjects = [self.allRecentProjects mutableCopy];
            break;
    }

    [self.projectListTableView reloadData];
}

- (IBAction)newCreation:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:PCCreateNewProjectNotification object:self];
}

- (IBAction)openOtherFile:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:PCShowOpenFilePanelNotification object:self];
}

- (IBAction)closeWindow:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:PCCloseSplashWindowNotification object:nil];
}

- (IBAction)favoriteCreation:(id)sender {
    NSButton *favoriteButton = (NSButton *)sender;
    NSInteger cellRow = [self.projectListTableView rowForView:favoriteButton];
    PCUserProjectDocument *projectInfo = self.filteredRecentProjects[cellRow];
    NSURL *url = projectInfo.userProjectReferenceUrl;
    [[PCUserProjectDocuments userDocuments] favoriteUserProject:url favorite:(favoriteButton.state == NSOnState)];
}

- (IBAction)playPromoVideo:(id)sender {
    NSButton *videoThumbnailButton = (NSButton *)sender;
    videoThumbnailButton.hidden = YES;
    [self.promoVideoPlayerView.player play];
}

#pragma mark - Mouse input 

- (void)setCellFromEvent:(NSEvent *)event toHighlighted:(BOOL)highlighted {
    NSDictionary *params = (NSDictionary *)event.userData;
    NSTextField *textField = params[PCLabelKey];
    PCView *background = params[PCBackgroundKey];
    if (highlighted) {
        textField.textColor = [NSColor pc_highlightedRecentsTitleColor];
        background.pc_backgroundColor = [NSColor pc_highlightedCellBackgroundColor];
        [[NSCursor pointingHandCursor] push];
    } else {
        textField.textColor = [NSColor pc_regularRecentsTitleColor];
        background.pc_backgroundColor = [NSColor whiteColor];
        [NSCursor pop];
    }
    [background setNeedsDisplay:YES];
}

- (void)mouseEntered:(NSEvent *)theEvent {
    [self setCellFromEvent:theEvent toHighlighted:YES];
}

- (void)mouseExited:(NSEvent *)theEvent {
    [self setCellFromEvent:theEvent toHighlighted:NO];
}

@end
