//
//  PCSlide.h
//  SpriteBuilder
//
//  Created by Orest Nazarewycz on 1/23/2014.
//
//

#import "CCBDocument.h"

@class PCBehaviourList;


extern NSString *const PCSlideThumbnailSuffix;


@interface PCSlide : NSObject

@property (strong, nonatomic) CCBDocument* document;
@property (strong, nonatomic) NSString *uuid;
@property (strong, nonatomic) NSString *fileName;
@property (strong, nonatomic) NSImage *slideThumbnail;
@property (strong, nonatomic) PCBehaviourList *behaviourList;
@property (strong, nonatomic) NSMutableDictionary *labelFontInfo;

@property (copy, nonatomic, readonly) NSString *javaScriptFileName;
@property (copy, nonatomic, readonly) NSString *absoluteJavaScriptFilePath;

- (id)initWithDictionary:(NSDictionary *)dict;
- (id)initWithUuid:(NSString *)uuid;
- (NSDictionary *)dictionaryRepresentation;
- (void)updateThumbnail;
- (NSString *)imageFileName;
- (NSString *)absoluteFilePath;
- (NSString *)absoluteImageFilePath;

- (void)saveDocument;
- (void)saveBehavioursJSFileWithIndex:(NSInteger)slideIndex;
- (void)deleteDocument;

// Copy/Pasta
- (PCSlide *)duplicate;
- (NSData *)pasteboardData;
+ (PCSlide *)createFromPasteboardData:(NSData *)data;

/**
 Creates a copy of the slide represented by the raw data passed in.
 @param data Literally the data representing the contents of a slide file
 */
+ (PCSlide *)createFromRawData:(NSData *)data;

+ (NSString *)fileNameForUuid:(NSString *)uuid;

@end
