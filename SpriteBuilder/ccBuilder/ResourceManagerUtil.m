/*
 * CocosBuilder: http://www.cocosbuilder.com
 *
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

#import "ResourceManagerUtil.h"
#import "SequencerPopoverSound.h"
#import "PCResource.h"
#import "PCResourceManager.h"
#import "AppDelegate.h"
#import "PCProjectSettings.h"

@implementation ResourceManagerUtil

+ (void)setTitle:(NSString *)title forPopup:(NSPopUpButton *)popup forceMarker:(BOOL)forceMarker {
    NSMenu *menu = [popup menu];
    title = title ? : @"";
    
    // Remove items that contains a slash (/ or •)
    NSArray *items = [[menu itemArray] copy];
    for (NSMenuItem *item in items) {
        NSRange rangeOfForwardSlash = [item.title rangeOfString:@"/"];
        NSRange rangeOfDot = [item.title rangeOfString:@"•"];
        if (rangeOfForwardSlash.location == NSNotFound && rangeOfDot.location == NSNotFound) continue;
        [menu removeItem:item];
    }
    
    // Add a • in front of the name if multiple active directories are used
    if (forceMarker) {
        title = [NSString stringWithFormat:@"• %@", title];
    }
    
    // Set the title
    [popup setTitle:title];
}

+ (void)setTitle:(NSString *)title forPopup:(NSPopUpButton *)popup {
    [self setTitle:title forPopup:popup forceMarker:NO];
}

+ (void)addDirectory:(PCResourceDirectory *)directory toMenu:(NSMenu *)menu target:(id)target resType:(int)resourceType allowSpriteFrames:(BOOL) allowSpriteFrames {
    NSArray *filteredResources = Underscore.filter([directory any], ^BOOL(PCResource *resource){
        return resource.type == resourceType || resource.type == PCResourceTypeDirectory;
    });
    
    for (id item in filteredResources)
    {
        if (![item isKindOfClass:[PCResource class]]) continue;
        PCResource *resource = item;
            
        if (resource.type == PCResourceTypeImage
            || resource.type == PCResourceTypeBMFont
            || resource.type == PCResourceTypeCCBFile
            || resource.type == PCResourceTypeTTF
            || resource.type == PCResourceTypeAudio
            || resource.type == PCResourceTypeVideo)
        {
            NSString *itemName = [resource.relativePath lastPathComponent];
            NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:itemName action:@selector(selectedResource:) keyEquivalent:@""];
            [menuItem setTarget:target];
            [menu addItem:menuItem];
            menuItem.representedObject = resource;
        } else if (resource.type == PCResourceTypeDirectory) {
            PCResourceDirectory * subDirectory = resource.data;
            NSString *itemName = [subDirectory.directoryPath lastPathComponent];
            NSMenu *subMenu = [[NSMenu alloc] initWithTitle:itemName ?: @""];
            
            [ResourceManagerUtil addDirectory:subDirectory toMenu:subMenu target:target resType:resourceType allowSpriteFrames:allowSpriteFrames];
            
            NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:itemName action:NULL keyEquivalent:@""];
            [menu addItem:menuItem];
            [menu setSubmenu:subMenu forItem:menuItem];
        }
    }
}

+ (void)populateResourceMenu:(NSMenu *)menu resType:(int)resType allowSpriteFrames:(BOOL)allowSpriteFrames selectedFile:(NSString *)file target:(id)target {
    // Clear the menu and add items to it!
    [menu removeAllItems];
    
    PCResourceManager *resourceManager = [PCResourceManager sharedManager];
    if (!resourceManager.rootResourceDirectory) return;

    PCResourceDirectory *activeDirectory = resourceManager.rootResourceDirectory;
    [ResourceManagerUtil addDirectory:activeDirectory toMenu:menu target:target resType: resType allowSpriteFrames:allowSpriteFrames];
}

+ (void)populateResourcePopup:(NSPopUpButton *)popup resourceType:(PCResourceType)resourceType allowSpriteFrames:(BOOL)allowSpriteFrames selectedFile:(NSString *)file target:(id)target {
    NSMenu *menu = [popup menu];
    
    [self populateResourceMenu:menu resType:resourceType allowSpriteFrames:allowSpriteFrames selectedFile:file target:target];
    
    // Set the selected item
    NSString *selectedTitle = file;
    if (!file || [file isEqualToString:@""]) {
        selectedTitle = [ResourceManagerUtil noResourceStringForResourceType:resourceType];
    }
    [self setTitle:selectedTitle forPopup:popup];
}

+ (NSString *)noResourceStringForResourceType:(PCResourceType)resourceType {
    //Only return for resources the user should actually be able to select. Ignore ones user cannot add to project for now.
    switch (resourceType) {
        case PCResourceType3DModel:
            return NSLocalizedString(@"PCNo3DModel", nil);
        case PCResourceTypeAudio:
            return NSLocalizedString(@"PCNoAudio", nil);
        case PCResourceTypeImage:
            return NSLocalizedString(@"PCNoImage", nil);
        case PCResourceTypeTTF:
            return NSLocalizedString(@"PCNoFont", nil);
        case PCResourceTypeVideo:
            return NSLocalizedString(@"PCNoVideo", nil);
        default:
            PCLog(@"WARNING: Trying to find no resource string for unsupported resource type %ld", resourceType);
            return @"";
    }
}

+ (NSFont *)fontWithName:(NSString *)name size:(CGFloat)size {
    static NSMutableDictionary *preloadedFonts;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        preloadedFonts = [NSMutableDictionary dictionary];
    });

    NSString *key = [NSString stringWithFormat:@"%@_%.1f", name, size];
    NSFont *font = preloadedFonts[key];
    if (!font) {
        font = [NSFont fontWithName:name size:size];
        preloadedFonts[key] = font;
    }
    return font;
}

+ (void)populatePopupButtonWithFonts:(NSPopUpButton *)popupButton selectedFontName:(NSString *)file target:(id)target action:(SEL)action {
    NSMenu* menu = [popupButton menu];
    [menu removeAllItems];

    if (!action) {
        action = @selector(selectedResource:);
    }

    NSArray *systemFonts = [[PCResourceManager sharedManager] supportedFonts];
    for (NSFont *fontName in systemFonts) {
        NSMenuItem* fontItem = [[NSMenuItem alloc] initWithTitle:fontName.familyName action:action keyEquivalent:@""];
        [fontItem setTarget:target];
        fontItem.representedObject = fontName.familyName;
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        [style setMinimumLineHeight:16];
        [style setMaximumLineHeight:16];
        NSDictionary *fontAttributes = @{ NSFontAttributeName : [self fontWithName:fontName.familyName size:12],
                                          NSParagraphStyleAttributeName : style };
        fontItem.attributedTitle = [[NSAttributedString alloc] initWithString:fontName.familyName attributes:fontAttributes];

        [menu addItem:fontItem];
    }
    if (file) {
        [popupButton selectItemWithTitle:file];
    }
}

#pragma mark File icons

+ (NSImage *)smallIconForFile:(NSString *)file {
    NSImage* icon = [[NSWorkspace sharedWorkspace] iconForFile:file];
    icon.size = NSMakeSize(16, 16);
    return icon;
}

+ (NSImage *)smallIconForFileType:(NSString *)type {
    NSImage* icon = [[NSWorkspace sharedWorkspace] iconForFileType:type];
    icon.size = NSMakeSize(16, 16);
    return icon;
}

+ (NSImage *)iconForResource:(PCResource *)resource {
    switch (resource.type) {
        case PCResourceTypeImage:
            return [ResourceManagerUtil smallIconForFileType:@"png"];
        default:
            return [ResourceManagerUtil smallIconForFile:resource.filePath];
    }
}

#pragma warning - Resource Path helpers

+ (NSString *)relativePathForResourceWithUUID:(NSString *)desiredResourceUUID {
    PCResource *resource = [[PCResourceManager sharedManager] resourceWithUUID:desiredResourceUUID];
    return resource ? [ResourceManagerUtil relativePathFromAbsolutePath:resource.filePath] : @"";
}

+ (NSString *)uuidForResourceWithRelativePath:(NSString *)relativePath {
    NSString *filePath = [[[AppDelegate appDelegate].currentProjectSettings rootPencilCaseResourcesPath] stringByAppendingPathComponent:relativePath];
    PCResource *resource = [[PCResourceManager sharedManager] resourceForPath:filePath];
    return resource.uuid;
}

#pragma mark - Absolute / Relative / Project path conversions

+ (NSString * _Nullable)relativePathFromPathInProject:(NSString * _Nullable)projectPath {
    NSString *rootProjectPath = [AppDelegate appDelegate].currentProjectSettings.projectDirectory;
    if (!rootProjectPath) {
        return projectPath;
    }

    NSRange rangeOfProjectPath = [projectPath rangeOfString:rootProjectPath];
    BOOL leadingSlash = [projectPath rangeOfString:@"/"].location == 0;
    if (rangeOfProjectPath.location == 0 || (leadingSlash && rangeOfProjectPath.location == 1)) {
        return [projectPath substringFromIndex:rangeOfProjectPath.length];
    }
    return projectPath;
}

+ (NSString *)projectPathFromRelativePath:(NSString *)relativePath {
    NSString *projectPath = [AppDelegate appDelegate].currentProjectSettings.projectDirectory;
    if (projectPath && [relativePath rangeOfString:projectPath].location == 0) {
        // Already have the absolute project path, return it
        return relativePath;
    }
    return [projectPath stringByAppendingPathComponent:relativePath];
}

+ (NSString *)relativePathFromAbsolutePath:(NSString *)path {

    NSString *base = [PCResourceManager sharedManager].rootDirectory.directoryPath;
    if ([path isEqualToString:base]) {
        return @"";
    }
    if ([path hasPrefix:base]) {
        return [path substringFromIndex:[base length] + 1];
    }

    PCLog(@"WARNING! ResourceManagerUtil: No relative path for %@",path);
    PCLog(@"  base: %@", base);
    return nil;
}

+ (NSString *)userFacingPathFromAbsolutePath:(NSString *)path {
    //First, check if the path exists in the resources directory, and clear that portion of the path if it exists
    NSString *resourcesFolderPath = [PCResourceManager sharedManager].rootResourceDirectory.directoryPath;
    if ([path hasPrefix:resourcesFolderPath]) {
        return [path substringFromIndex:resourcesFolderPath.length + 1];
    }
    //It was not in the resources directory, fall back to the relative path
    return [self relativePathFromAbsolutePath:path];
}

+ (NSDictionary *)convertDictionaryKeysFromProjectPathToRelativePath:(NSDictionary *)dictionary {
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    for (NSString *projectFilePath in dictionary.allKeys) {
        NSString *relativeFilePath = [ResourceManagerUtil relativePathFromPathInProject:projectFilePath];
        result[relativeFilePath] = dictionary[projectFilePath];
    }
    return [result copy];
}

+ (NSDictionary *)convertDictionaryKeysFromRelativePathToProjectPath:(NSDictionary *)dictionary {
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    for (NSString *relativeFilePath in dictionary.allKeys) {
        NSString *projectFilePath = [ResourceManagerUtil projectPathFromRelativePath:relativeFilePath];
        result[projectFilePath] = dictionary[relativeFilePath];
    }
    return [result copy];
}

+ (NSArray *)allImageResources {
    PCResourceManager *resourceManager = [PCResourceManager sharedManager];
    if (!resourceManager.rootResourceDirectory) return @[];

    PCResourceDirectory *directory = resourceManager.rootResourceDirectory;
    return [self allImageResourcesInDirectory:directory];
}

+ (NSArray *)allImageResourcesInDirectory:(PCResourceDirectory *)directory {
    NSMutableArray *resources = [[NSMutableArray alloc] init];

    for (PCResource *resource in [directory any]) {
        if (resource.type == PCResourceTypeImage) {
            [resources addObject:resource];
        }
        else if (resource.type == PCResourceTypeDirectory) {
            PCResourceDirectory *subDirectory = resource.data;
            [resources addObjectsFromArray:[self allImageResourcesInDirectory:subDirectory]];
        }
    }
    
    return [resources copy];
}

@end
