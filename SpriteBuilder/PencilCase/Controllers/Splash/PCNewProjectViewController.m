//
//  PCNewProjectViewController.m
//  SpriteBuilder
//
//  Created by Orest Nazarewycz on 2014-11-14.
//
//

#import "PCNewProjectViewController.h"
#import "NSButton+DeviceTypeSettings.h"
#import "NSColor+HexColors.h"

@interface PCNewProjectViewController ()

@property (weak, nonatomic) IBOutlet NSButton *iPhoneLandscapeButton;
@property (weak, nonatomic) IBOutlet NSButton *iPhonePortraitButton;
@property (weak, nonatomic) IBOutlet NSButton *iPadPortraitButton;
@property (weak, nonatomic) IBOutlet NSButton *iPadLandscapeButton;

@property (weak, nonatomic) IBOutlet NSTextField *titleLabel;
@property (weak, nonatomic) IBOutlet NSTextField *selectCanvaslabel;
@property (weak, nonatomic) IBOutlet NSTextField *templateLabel;
@property (weak, nonatomic) IBOutlet NSTextField *ipadLabel1;
@property (weak, nonatomic) IBOutlet NSTextField *ipadLabel2;
@property (weak, nonatomic) IBOutlet NSTextField *iphoneLabel1;
@property (weak, nonatomic) IBOutlet NSTextField *iphoneLabel2;
@property (weak, nonatomic) IBOutlet NSTextField *portraitLabel1;
@property (weak, nonatomic) IBOutlet NSTextField *portraitLabel2;
@property (weak, nonatomic) IBOutlet NSTextField *landscapeLabel1;
@property (weak, nonatomic) IBOutlet NSTextField *landscapeLabel2;
@property (weak, nonatomic) IBOutlet NSTextField *templateLabel1;
@property (weak, nonatomic) IBOutlet NSTextField *templateLabel2;
@property (weak, nonatomic) IBOutlet NSTextField *templateLabel3;
@property (weak, nonatomic) IBOutlet NSTextField *templateLabel4;
@property (weak, nonatomic) IBOutlet NSTextField *templateLabel5;
@property (weak, nonatomic) IBOutlet NSTextField *templateLabel6;
@property (weak, nonatomic) IBOutlet NSTextField *templateLabel7;
@property (weak, nonatomic) IBOutlet NSTextField *basicLabel;
@property (weak, nonatomic) IBOutlet NSTextField *comingSoonLabel;

@property (strong, nonatomic) NSArray *gothamBookLabels;

@end

@implementation PCNewProjectViewController

- (void)viewDidLoad {
    self.deviceTarget = PCDeviceTargetTypePhone;
    self.deviceOrientation = PCDeviceTargetOrientationPortrait;
    self.iPhonePortraitButton.state = NSOnState;
    [self setupDeviceConfigurationButtons];
    [self setupUIFonts];
}

- (void)setupUIFonts {
    self.titleLabel.font = [NSFont fontWithName:@"Montserrat-Light" size:self.titleLabel.font.pointSize];
    self.selectCanvaslabel.textColor = [NSColor pc_darkLabelColor];
    self.templateLabel.textColor = [NSColor pc_darkLabelColor];
}

- (void)setupDeviceConfigurationButtons {
    self.iPhoneLandscapeButton.pc_deviceTarget = PCDeviceTargetTypePhone;
    self.iPhonePortraitButton.pc_deviceTarget = PCDeviceTargetTypePhone;
    self.iPhoneLandscapeButton.pc_deviceOrientation = PCDeviceTargetOrientationLandscape;
    self.iPhonePortraitButton.pc_deviceOrientation = PCDeviceTargetOrientationPortrait;

    self.iPadLandscapeButton.pc_deviceTarget = PCDeviceTargetTypeTablet;
    self.iPadPortraitButton.pc_deviceTarget = PCDeviceTargetTypeTablet;
    self.iPadLandscapeButton.pc_deviceOrientation = PCDeviceTargetOrientationLandscape;
    self.iPadPortraitButton.pc_deviceOrientation = PCDeviceTargetOrientationPortrait;
}

- (IBAction)setSelectedDeviceAndOrientationSetting:(id)sender {
    NSButton *settingButton = (NSButton *)sender;
    self.iPadLandscapeButton.state = NSOffState;
    self.iPadPortraitButton.state = NSOffState;
    self.iPhoneLandscapeButton.state = NSOffState;
    self.iPhonePortraitButton.state = NSOffState;
    settingButton.state = NSOnState;

    self.deviceTarget = settingButton.pc_deviceTarget;
    self.deviceOrientation = settingButton.pc_deviceOrientation;
}

- (IBAction)cancelNewCreation:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:PCCancelCreatingNewProjectNotification object:self];
}

- (IBAction)buildCreation:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:PCSaveNewProjectNotification object:self userInfo:@{ PCProjectDeviceTargetTypeKey : @(self.deviceTarget), PCProjectDeviceTargetOrientationKey : @(self.deviceOrientation) }];
}

- (IBAction)closeWindow:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:PCCloseSplashWindowNotification object:nil];
}

@end
