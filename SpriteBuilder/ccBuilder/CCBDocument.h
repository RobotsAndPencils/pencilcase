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

#import <Foundation/Foundation.h>

@class SequencerSequence;
@class SKNode;
@class PCProjectSettings;

@interface CCBDocument : NSObject

@property (nonatomic, strong) NSString* fileName;
@property (nonatomic, strong) NSString* exportPath;
@property (nonatomic, strong) NSString* exportPlugIn;
@property (nonatomic, assign) BOOL exportFlattenPaths;
@property (nonatomic, strong) NSMutableDictionary* docData;
@property (nonatomic, weak) NSUndoManager* undoManager; // weak as we are using a shared undo manager
@property (nonatomic, strong) NSString* lastEditedProperty;
@property (nonatomic, assign) BOOL isDirty;
@property (nonatomic, assign) CGPoint stageScrollOffset;
@property (nonatomic, assign) CGFloat stageZoom;
@property (nonatomic, strong) NSMutableArray* resolutions;
@property (nonatomic, assign) NSInteger currentResolution;
@property (nonatomic, strong) NSMutableArray* sequences;
@property (nonatomic, assign) NSInteger currentSequenceId;
@property (nonatomic, assign) NSInteger docDimensionsType;

- (id)initWithFile:(NSString *)filePath;
- (void)writeToFile:(NSString *)fileName;

+ (NSString*)absolutePathForSubcontentDocumentWithFilename:(NSString *)fileName;
- (NSString *)formattedName;
- (void)updateWithCurrentDocumentState;

/**
 Translates the keyframes from the sequencers in the nodes destination slide to the sequencers in this slide. Will create sequencers if the node references more sequencers than we have.
 @param node The node with the keyframes to translate
 @param sequencerOrder The order that the sequencer were in the original card.
 @param sequencerNames The name of the sequencers in the original card, in case new sequencers need to be created.
 */
- (void)updateKeyframesForNode:(SKNode *)node givenSequencerOrder:(NSArray *)sequencerOrder sequencerNames:(NSArray *)sequencerNames;

/**
 Creates a new sequencer with a unique id and adds it to the sequencer array
 @returns The created sequencer
 */
- (SequencerSequence *)addNewSequencer;

/**
 * @returns The current sequence or the first one if none is marked current
 */
- (SequencerSequence *)currentSequence;

- (void)loadResolutionDataFromDocumentData:(NSDictionary *)documentData forProject:(PCProjectSettings *)project documentDimensionsType:(NSInteger)documentDimensionsType;
- (void)loadSequencesFromDocumentData:(NSDictionary *)documentData;

@end
