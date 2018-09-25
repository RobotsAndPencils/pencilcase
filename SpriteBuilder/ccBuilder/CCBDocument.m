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

#import "SequencerSequence.h"
#import "SequencerHandler.h"
#import "PCGuidesNode.h"
#import "CCBReaderInternal.h"
#import "CCBWriterInternal.h"
#import "AppDelegate.h"
#import "PCDeviceResolutionSettings.h"
#import "PCResourceManager.h"
#import "PCStageScene.h"
#import "SKNode+Sequencer.h"
#import "PCUndoManager.h"

@implementation CCBDocument

#pragma mark - Static

+ (NSString*)absolutePathForSubcontentDocumentWithFilename:(NSString *)fileName {
    return [[PCResourceManager sharedManager].rootDirectory.directoryPath stringByAppendingPathComponent:fileName];
}

#pragma mark - Implementation

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        self.undoManager = [PCUndoManager sharedPCUndoManager];

        self.stageZoom = 1;
        self.stageScrollOffset = CGPointMake(0,0);
    }

    return self;
}

- (id)initWithFile:(NSString *)filePath {
    self = [self init];

    NSMutableDictionary* doc = [NSMutableDictionary dictionaryWithContentsOfFile:filePath];

    self.fileName = [filePath lastPathComponent];
    self.docData = doc;
    self.exportPath = [doc objectForKey:@"exportPath"];
    self.exportPlugIn = [doc objectForKey:@"exportPlugIn"];
    self.exportFlattenPaths = [[doc objectForKey:@"exportFlattenPaths"] boolValue];

    if ([doc[@"fileVersion"] integerValue] < kCCBFileFormatVersion) {
        self.isDirty = YES;
    }

    return self;
}

- (NSString*) formattedName
{
    return [self.fileName stringByDeletingPathExtension];
}

#pragma mark - Properties

- (void) setFileName:(NSString *)fn
{
    // Set new filename
    if (fn != _fileName)
    {
        _fileName = fn;
    }
}

- (void)updateWithCurrentDocumentState {
    AppDelegate *appDelegate = [AppDelegate appDelegate];
    PCStageScene *stageScene = [PCStageScene scene];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    // Add node graph
    NSMutableDictionary *nodeGraph = [CCBWriterInternal dictionaryFromSKNode:[PCStageScene scene].rootNode];
    dict[@"nodeGraph"] = nodeGraph;

    // Add meta data
    dict[@"fileType"] = @"CocosBuilder";
    dict[@"fileVersion"] = @(kCCBFileFormatVersion);
    dict[@"jsControlled"] = @(appDelegate.jsControlled);
    dict[@"centeredOrigin"] = @([stageScene centeredOrigin]);
    dict[@"stageBorder"] = @(appDelegate.currentProjectSettings.stageBorderType);

    // Guides & notes
    if (stageScene.guideLayer) {
        dict[@"guides"] = [stageScene.guideLayer serializeGuides];
    }
    dict[@"docDimensionsType"] = @(self.docDimensionsType);

    // Resolutions
    if (self.resolutions) {
        NSMutableArray *serializedResolutions = [NSMutableArray array];
        for (PCDeviceResolutionSettings *resolution in self.resolutions) {
            [serializedResolutions addObject:[resolution serialize]];
        }
        dict[@"resolutions"] = serializedResolutions;
        dict[@"currentResolution"] = @(self.currentResolution);
    }

    // Sequencer timelines
    if (self.sequences) {
        NSMutableArray *serializedSequences = [NSMutableArray array];
        for (SequencerSequence *sequence in self.sequences) {
            [serializedSequences addObject:[sequence serialize]];
        }
        dict[@"sequences"] = serializedSequences;
        dict[@"currentSequenceId"] = @(appDelegate.sequenceHandler.currentSequence.sequenceId);
    }

    if (self.exportPath && self.exportPlugIn) {
        dict[@"exportPlugIn"] = self.exportPlugIn;
        dict[@"exportPath"] = self.exportPath;
        dict[@"exportFlattenPaths"] = @(self.exportFlattenPaths);
    }

    self.docData = dict;
}

- (void)writeToFile:(NSString *)fileName {
    [self.docData writeToFile:fileName atomically:YES];
}

#pragma mark - Loading

- (void)migrateResolutionFrom:(NSDictionary *)documentData centered:(BOOL)centered {
    // Support old files where the current width and height was stored
    int stageWidth = [documentData[@"stageWidth"] intValue];
    int stageHeight = [documentData[@"stageHeight"] intValue];

    [[PCStageScene scene] setStageSize:CGSizeMake(stageWidth, stageHeight) centeredOrigin:centered];

    // Setup a basic resolution and attach it to the current document
    PCDeviceResolutionSettings *resolution = [[PCDeviceResolutionSettings alloc] init];
    resolution.width = stageWidth;
    resolution.height = stageHeight;
    resolution.centeredOrigin = centered;

    self.resolutions = [@[resolution] mutableCopy];
    self.currentResolution = 0;
}

- (void)loadResolutionDataFromDocumentData:(NSDictionary *)documentData forProject:(PCProjectSettings *)project documentDimensionsType:(NSInteger)documentDimensionsType {
    BOOL centered = (documentDimensionsType == kCCBDocDimensionsTypeNode);
    NSMutableArray *serializedResolutions = documentData[@"resolutions"];
    if (!serializedResolutions) {
        [self migrateResolutionFrom:documentData centered:centered];
        return;
    }

    // Load resolutions
    NSMutableArray *resolutions = [NSMutableArray array];
    for (id serializedResolution in serializedResolutions) {
        PCDeviceResolutionSettings *resolution = [[PCDeviceResolutionSettings alloc] initWithSerialization:serializedResolution];
        [resolutions addObject:resolution];
    }

    // Save in current document
    self.docDimensionsType = documentDimensionsType;
    self.resolutions = [project updateResolutions:resolutions forDocDimensionType:documentDimensionsType];;
    self.currentResolution = project.deviceResolutionSettings.deviceTarget;;

    // Update CocosScene
    PCDeviceResolutionSettings *resolution = [resolutions objectAtIndex:self.currentResolution];
    CGSize stageSize = CGSizeMake(resolution.width, resolution.height);
    [[PCStageScene scene] setStageSize:stageSize centeredOrigin:centered];
}

- (void)loadDefaultTimeline {
    // Setup a default timeline
    NSMutableArray *sequences = [NSMutableArray array];

    SequencerSequence *sequence = [[SequencerSequence alloc] init];
    sequence.name = @"Default Timeline";
    sequence.sequenceId = CardDefaultSequenceId;
    sequence.autoPlay = YES;
    [sequences addObject:sequence];

    self.sequences = sequences;
}

- (void)loadSequencesFromDocumentData:(NSDictionary *)documentData {
    NSMutableArray *serializedSequences = documentData[@"sequences"];
    if (!serializedSequences) {
        [self loadDefaultTimeline];
        return;
    }
    if (serializedSequences) {
        // Load from the file
        self.currentSequenceId = [documentData[@"currentSequenceId"] intValue];

        self.sequences = [NSMutableArray array];
        for (id serializedSequence in serializedSequences) {
            SequencerSequence *sequence = [[SequencerSequence alloc] initWithSerialization:serializedSequence];
            [self.sequences addObject:sequence];
        }
    }
}

#pragma mark - Sequencer

- (void)updateKeyframesForNode:(SKNode *)node givenSequencerOrder:(NSArray *)sequencerOrder sequencerNames:(NSArray *)sequencerNames {
    NSInteger maxNodeTimelineIndex = -1;
    NSArray *allSequencerIds = [node allSequencerIds];
    for (NSNumber *sequencerId in allSequencerIds) {
        NSInteger order = [sequencerOrder indexOfObject:sequencerId];
        maxNodeTimelineIndex = MAX(order, maxNodeTimelineIndex);
    }
    [self increaseTimelineCountTo:maxNodeTimelineIndex + 1 originalNames:sequencerNames];

    NSMutableDictionary *newIdMapping = [NSMutableDictionary dictionary];
    for (NSNumber *originalSequencerId in allSequencerIds) {
        SequencerSequence *matchingSequence = self.sequences[[sequencerOrder indexOfObject:originalSequencerId]];
        newIdMapping[originalSequencerId] = @(matchingSequence.sequenceId);
    }

    [node remapSequencersWithMapping:newIdMapping];
}

- (void)increaseTimelineCountTo:(NSUInteger)newCount originalNames:(NSArray *)originalNames {
    while ([self.sequences count] < newCount) {
        SequencerSequence *newSequencer = [self addNewSequencer];
        NSInteger newSequencerIndex = [self.sequences indexOfObject:newSequencer];
        if ([originalNames count] > newSequencerIndex) {
            newSequencer.name = originalNames[newSequencerIndex];
        }
    }
}

- (SequencerSequence *)addNewSequencer {
    SequencerSequence *newSequence = [[SequencerSequence alloc] init];
    newSequence.name = @"Untitled Timeline";
    newSequence.sequenceId = [SequencerSequence uniqueSequenceIdFromSequencers:self.sequences];

    // Add it to list
    [self.sequences addObject:newSequence];
    return newSequence;
}

- (SequencerSequence *)currentSequence {
    for (SequencerSequence *sequence in self.sequences) {
        if (sequence.sequenceId == self.currentSequenceId) {
            return sequence;
        }
    }
    return self.sequences.firstObject;
}

@end
