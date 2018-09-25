Pod::Spec.new do |s|
    s.name         = 'PencilCaseLauncher'
    s.version      = '1.0.0'
    s.platform     = :ios, '8.0'
    s.summary      = 'A player that can launch and play PencilCase apps.'
    s.homepage     = 'https://robotsandpencils.com'
    s.author = {
        'Cody Rayment' => 'cody.rayment@robotsandpencils.com'
    }
    s.source = {
        :git => 'git@github.com:RobotsAndPencils/PencilCase.git'
    }
    s.requires_arc = true
    s.frameworks = 'WebKit','CoreBluetooth','SystemConfiguration', 'CFNetwork', 'Security', 'OpenAL'
    s.library = 'c++', 'icucore'

    s.prefix_header_contents = <<-PREFIX
        // Platform defines. TARGET_OS_MAC is defined on iOS so this makes it easier to detect iOS.
        #if TARGET_IPHONE_SIMULATOR
        #define PC_PLATFORM_IOS
        #elif TARGET_OS_IPHONE
        #define PC_PLATFORM_IOS
        #elif TARGET_OS_MAC
        #define PC_PLATFORM_MAC
        #endif

        #ifdef __OBJC__
        #import <UIKit/UIKit.h>
        #import <SpriteKit/SpriteKit.h>
        #import <PSAlertView/PSPDFAlertView.h>
        #import <PencilCaseLauncher/CommonUtils.h>

        #import <PencilCaseLauncher/CCBAnimationManager.h>
        #import <PencilCaseLauncher/CGPointUtilities.h>
        #import <PencilCaseLauncher/CCBuilderReader.h>
        #endif
    PREFIX
    s.ios.vendored_frameworks = 'PencilCaseLauncher/Frameworks/MyoKit.framework', 'PencilCaseLauncher/Frameworks/Firebase.framework'
    s.source_files = "Shared Source/**/*.{h,m,c}", "PencilCaseLauncher/Source/**/*.{h,m,c}"
    s.resources = ['PencilCaseLauncher/Assets/**/*.{png,js}', 'PencilCaseLauncher/Source/**/*.{xib}']
    s.dependency 'PSAlertView', '2.0.3'
    s.dependency 'RXCollections', '1.0'
    s.dependency 'SVProgressHUD', '1.1.2'
    s.dependency 'SSZipArchive', '0.3.2'
    s.dependency 'YapDatabase', '2.5.4'
    s.dependency 'BlocksKit/Core', '2.2.5'
    s.dependency 'ACEDrawingView', '1.3.5'
    s.dependency 'RPJSContext', '2.2.1'
    s.dependency 'JRSwizzle', '1.0'
    s.dependency 'GHMarkdownParser'
end
