//
//  PCSlide.m
//  SpriteBuilder
//
//  Created by Orest Nazarewycz on 1/23/2014.
//
//

#import "PCSlide.h"
#import "PCResourceManager.h"
#import "AppDelegate.h"
#import "NSImage+ProportionalScaling.h"
#import "SKNode+NodeInfo.h"
#import "SKNode+JavaScript.h"
#import "PCStageScene.h"
#import "PCBehaviourList.h"
#import "PCBehavioursDataSource.h"
#import "CCBReaderInternal.h"
#import "PCFontConsuming.h"

NSString *const PCSlideThumbnailSuffix = @"-Thumb";
NSString *const PCSlideThumbnailExtension = @"-Thumb.ppng";

@interface PCSlide ()

@end

@implementation PCSlide

+ (NSString *)fileNameForUuid:(NSString *)uuid {
    return [uuid stringByAppendingPathExtension:@"ccb"];
}

- (id)init {
    return [self initWithUuid:nil];
}

- (id)initWithUuid:(NSString *)uuid {
    self = [super init];
    if (self) {
        _uuid = [uuid length] ? uuid : [[NSUUID UUID] UUIDString];
        _slideThumbnail = [[NSImage alloc] init];
        _fileName = [PCSlide fileNameForUuid:_uuid];
        _behaviourList = [[PCBehaviourList alloc] init];
        _labelFontInfo = [NSMutableDictionary dictionary];
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary *)dict {
    self = [self init];
    if (self) {
        _uuid = dict[@"uuid"];
        _fileName = [_uuid stringByAppendingPathExtension:@"ccb"];

        // The document needs to be set before we can load the behaviour list because it will need to look up nodes by their UUID to validate tokens
        _document = [[CCBDocument alloc] initWithFile:[self absoluteFilePath]];

        _behaviourList = [NSKeyedUnarchiver unarchiveObjectWithData:dict[@"behaviourList"]];
        if (!_behaviourList) _behaviourList = [[PCBehaviourList alloc] init];

        _labelFontInfo = [dict[@"labelFontInfo"] mutableCopy];
        if (!_labelFontInfo) {
            _labelFontInfo = [NSMutableDictionary dictionary];
        }
    }
    return self;
}

+ (instancetype)duplicateFromDictionary:(NSDictionary *)dictionary {
    PCSlide *slideToDuplicate = [[PCSlide alloc] initWithDictionary:dictionary];
    NSString *filePath = [slideToDuplicate absoluteFilePath];
    NSString *imagePath = [slideToDuplicate absoluteImageFilePath];
    NSString *javaScriptPath = [slideToDuplicate absoluteJavaScriptFilePath];
    NSString *thumbnailPath = [slideToDuplicate absoluteThumbnailImageFilePath];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (!filePath || ![fileManager fileExistsAtPath:filePath]) return nil;
    if (!imagePath || ![fileManager fileExistsAtPath:imagePath]) return nil;
    if (!javaScriptPath || ![fileManager fileExistsAtPath:javaScriptPath]) return nil;
    if (!thumbnailPath || ![fileManager fileExistsAtPath:thumbnailPath]) return nil;

    PCSlide *slide = [[PCSlide alloc] init];
    [fileManager copyItemAtPath:filePath toPath:[slide absoluteFilePath] error:nil];
    [fileManager copyItemAtPath:imagePath toPath:[slide absoluteImageFilePath] error:nil];
    [fileManager copyItemAtPath:javaScriptPath toPath:[slide absoluteJavaScriptFilePath] error:nil];
    [fileManager copyItemAtPath:thumbnailPath toPath:[slide absoluteThumbnailImageFilePath] error:nil];
    slide.document = [[CCBDocument alloc] initWithFile:[slide absoluteFilePath]];

    if (slideToDuplicate.behaviourList) {
        slide.behaviourList = [slideToDuplicate.behaviourList copy];
    }
    if (slideToDuplicate.labelFontInfo) {
        slide.labelFontInfo = [slideToDuplicate.labelFontInfo mutableCopy];
    }

    [slide regenerateAllUUIDs];
    return slide;
}

- (NSDictionary *)dictionaryRepresentation {
    NSDictionary *slideInfo = @{
        @"fileName": self.fileName,
        @"uuid": self.uuid,
        @"imageFileName": [self imageFileName],
        @"behaviourList": [NSKeyedArchiver archivedDataWithRootObject:self.behaviourList],
        @"labelFontInfo": self.labelFontInfo
    };
    return slideInfo;
}

- (void)updateThumbnail {
    NSString *thumbnailPath = [[[self absoluteFilePath] stringByAppendingString:PCSlideThumbnailSuffix] stringByAppendingPathExtension:@"ppng"];
    NSImage *image = [[NSImage alloc] initWithContentsOfFile:thumbnailPath];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:thumbnailPath]) {
        thumbnailPath = [[self absoluteFilePath] stringByAppendingPathExtension:@"ppng"];
        image = [[[NSImage alloc] initWithContentsOfFile:thumbnailPath] imageByScalingProportionallyToSize:NSMakeSize(400, 300)];
    }

    if (image) {
        self.slideThumbnail = image;
    }
}

- (NSString *)imageFileName {
    return [self.fileName stringByAppendingPathExtension:@"ppng"];
}

- (NSString *)absoluteFilePath {
    NSString *directoryPath = [PCResourceManager sharedManager].rootDirectory.directoryPath;
    return [directoryPath stringByAppendingPathComponent:self.fileName];
}

- (NSString *)absoluteImageFilePath {
    return [[self absoluteFilePath] stringByAppendingPathExtension:@"ppng"];
}

- (NSString *)absoluteThumbnailImageFilePath {
    return [[self absoluteFilePath] stringByAppendingString:PCSlideThumbnailExtension];
}

- (NSString *)javaScriptFileName {
    return [[self.fileName stringByDeletingPathExtension] stringByAppendingPathExtension:@"js"];
}

- (NSString *)absoluteJavaScriptFilePath {
    return [[self.absoluteFilePath stringByDeletingPathExtension] stringByAppendingPathExtension:@"js"];
}

#pragma mark - Saving

- (void)saveDocument {
    NSInteger slideIndex = [AppDelegate appDelegate].currentSlideIndex;
    [self saveBehavioursJSFileWithIndex:slideIndex];

    NSArray *allChildren = [[[PCStageScene scene] rootNode] recursiveChildrenOfClass:[SKNode class]];
    
    [self saveFontNamesForNodes:[allChildren filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return [evaluatedObject conformsToProtocol:@protocol(PCFontConsuming)];
    }]]];
}

- (void)saveFontNamesForNodes:(NSArray *)nodes {
    NSString *fontDir = [[self.absoluteFilePath stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"Fonts"];
    [[NSFileManager defaultManager] createDirectoryAtPath:fontDir withIntermediateDirectories:YES attributes:NULL error:NULL];

    for (SKNode<PCFontConsuming> *node in nodes) {
        [self saveFontNamesForTextView:node fontDir:fontDir];
    }
}

- (void)saveFontNamesForTextView:(SKNode<PCFontConsuming> *)skTextView fontDir:(NSString *)fontDir {
    NSDictionary *fonts = [skTextView fontNamesAndSizes];
    for (NSString *fontName in fonts) {
        for (NSNumber *fontSize in fonts[fontName]) {
            NSString *newFontName = [self fontFromName:fontName fontSize:[fontSize floatValue] fontDirectory:fontDir];
            if (newFontName) self.labelFontInfo[fontName] = newFontName;
        }
    }
}

- (void)saveBehavioursJSFileWithIndex:(NSInteger)slideIndex {
    // Putting the slide index in a comment helps with debugging since the only other information about this JS is the card UUID
    NSString *cardActionScripts = [NSString stringWithFormat:@"// Card %lu\n\n", (slideIndex + 1)];

    cardActionScripts = [cardActionScripts stringByAppendingString:[self.behaviourList javaScriptRepresentation]];

    NSString *scriptFileName = [[self.absoluteFilePath stringByDeletingPathExtension] stringByAppendingPathExtension:@"js"];
    NSError *jsFileWriteError;
    BOOL jsFileWriteSuccess = [cardActionScripts writeToFile:scriptFileName atomically:YES encoding:NSUTF8StringEncoding error:&jsFileWriteError];
    if (!jsFileWriteSuccess) {
        PCLog(@"Error writing JS file for slide %@: %@", self, jsFileWriteError.localizedDescription);
    }
}

- (NSString *)fontFromName:(NSString *)fontName fontSize:(CGFloat)fontSize fontDirectory:(NSString *)fontDir {
    // find the path to the font file on the system
    CTFontDescriptorRef fontRef = CTFontDescriptorCreateWithNameAndSize((__bridge CFStringRef)fontName, fontSize);
    if (!fontRef) {
        return nil;
    }

    CFURLRef url = (CFURLRef)CTFontDescriptorCopyAttribute(fontRef, kCTFontURLAttribute);
    if (!url)  {
        CFRelease(fontRef);
        return nil; // We don't have this font installed
    }

    NSString *fontPath = [NSString stringWithString:[(__bridge NSURL *)url path]];
    CFRelease(fontRef);

    NSString *fontFilename = [fontPath lastPathComponent];

    // Skip this label font if it is not using transferable font type
    if (![[fontFilename pathExtension] isEqualToString:@"ttf"] &&
        ![[fontFilename pathExtension] isEqualToString:@"otf"] &&
        ![[fontFilename pathExtension] isEqualToString:@"ttc"]) {
        CFRelease(url);
        return nil;
    }

    // Copy it into the font directory
    NSString *newFontPath = [fontDir stringByAppendingPathComponent:fontFilename];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:newFontPath]) {
        NSError *fontCopyError;
        [fileManager copyItemAtPath:fontPath toPath:newFontPath error:&fontCopyError];
        if (fontCopyError) {
            PCLog(@"Error copying font file: %@", fontCopyError.localizedDescription);
        }
    }

    // Load the actual CGFont and get the full name
    CGDataProviderRef fontDataProvider = CGDataProviderCreateWithURL(url);
    CGFontRef newFont = CGFontCreateWithDataProvider(fontDataProvider);
    CFStringRef newFontName = CGFontCopyPostScriptName(newFont);

    if (fontDataProvider) CGDataProviderRelease(fontDataProvider);
    if (newFont) CGFontRelease(newFont);

    CFRelease(url);

    if (!newFontName) {
        return nil;
    }

    NSString *result = [(__bridge NSString *)newFontName copy];
    CFRelease(newFontName);
    return result;
}

- (void)deleteDocument {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:[self absoluteThumbnailImageFilePath] error:nil];
    [fileManager removeItemAtPath:[self absoluteFilePath] error:nil];
    [fileManager removeItemAtPath:[self absoluteImageFilePath] error:nil];
    [fileManager removeItemAtPath:[self absoluteJavaScriptFilePath] error:nil];
}

#pragma mark - Copy/Paste

- (PCSlide *)duplicate {
    return [PCSlide createFromPasteboardData:[self pasteboardData]];
}

- (NSData *)pasteboardData {
    return [NSKeyedArchiver archivedDataWithRootObject:[self dictionaryRepresentation]];
}

+ (PCSlide *)createFromPasteboardData:(NSData *)data {
    NSDictionary *info = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    if (!info || ![info isKindOfClass:[NSDictionary class]]) return nil;
    return [self duplicateFromDictionary:info];
}

+ (PCSlide *)createFromRawData:(NSData *)rawData {
    PCSlide *slide = [[PCSlide alloc] init];
    [rawData writeToFile:[slide absoluteFilePath] atomically:YES];
    
    slide.document = [[CCBDocument alloc] initWithFile:[slide absoluteFilePath]];
    [slide updateThumbnail];
    [slide regenerateAllUUIDs];
    return slide;
}

- (void)regenerateAllUUIDs {
    [[AppDelegate appDelegate] openDocument:self.document parentDocument:nil];
    
    [self regenerateUUIDForNodeGraph:[PCStageScene scene].rootNode rootNode:[PCStageScene scene].rootNode];
    [self.behaviourList regenerateUUIDs];
    [self.behaviourList validate];

    [[AppDelegate appDelegate] saveFile:[self absoluteFilePath] withPreview:NO];
}

- (void)regenerateUUIDForNodeGraph:(SKNode *)node rootNode:(SKNode *)rootNode {
    NSUUID *oldUUID = node.UUID;;
    NSUUID *newUUID = [NSUUID UUID];
    node.UUID = newUUID;
    [self.behaviourList updateReferencesToNodeUUID:oldUUID toNewUUID:newUUID];
    for (SKNode *child in node.children) {
        [self regenerateUUIDForNodeGraph:child rootNode:rootNode];
    }
}

@end
