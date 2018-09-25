//
//  PCUndoManager.m
//  SpriteBuilder
//
//  Created by Reuben Lee on 2014-08-20.
//
//

#import "PCUndoManager.h"
#import "SKNode+NodeInfo.h"
#import "SKNode+Sequencer.h"
#import "PlugInNode.h"
#import "CCBDocument.h"
#import "SequencerHandler.h"
#import "SequencerSequence.h"
#import "SequencerKeyframe.h"
#import "PCSlidesViewController.h"
#import "NSObject+DebugPrinting.h"

@interface PCUndoManager()

@property (assign, nonatomic) BOOL batchingChanges;
@property (strong, nonatomic) NSString *batchedProperty;

@end

@implementation PCUndoManager

+ (PCUndoManager *)sharedPCUndoManager {
    static PCUndoManager *sharedPCUndoManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedPCUndoManager = [[self alloc] init];
        sharedPCUndoManager.levelsOfUndo = 4000; // Rough math of 200 MB for undo, and avg of about 50 KB (No keyed frames) per undo
    });
    return sharedPCUndoManager;
}

- (void) registerUndoWithTarget:(id)target selector:(SEL)selector object:(id)anObject {
    [super registerUndoWithTarget:target selector:selector object:anObject];
    //[self printDebugInfo];
    UndoDebugLog(@"Register Undo for %@", target);
}

- (id)prepareWithInvocationTarget:(id)target {
    id result = [super prepareWithInvocationTarget:target];
    //[self printDebugInfo];
    UndoDebugLog(@"Register Undo for %@", target);
    return result;
}

- (void)undo {
    UndoDebugLog(@" **---------------------------** ");
    UndoDebugLog(@" ************ Undo ************* ");
    UndoDebugLog(@" **---------------------------** ");
    [super undo];
}

- (void)redo {
    UndoDebugLog(@" **---------------------------** ");
    UndoDebugLog(@" ************ Redo ************* ");
    UndoDebugLog(@" **---------------------------** ");
    [super redo];
}

- (void)printDebugInfo {
    UndoDebugLog(@"UndoManager Status -> isUndoing: %@ isRedoing: %@", self.isUndoing?@"YES":@"NO", self.isRedoing?@"YES":@"NO");
}

#pragma mark - Undo methods

- (void)saveUndoStateDidChangeProperty:(NSString *)property inDocument:(CCBDocument *)document selectedNodes:(NSArray *)selectedNodes slideController:(PCSlidesViewController *)slidesViewController {
    if (!document) return;

    property = [self convertLocalProperty:property toGlobalScopeForNode:selectedNodes.firstObject];
    if ([self shouldSkipDocumentCopyForProperty:property]) return;

    NSDictionary *currentDocumentData = [NSDictionary dictionaryWithDictionary:document.docData];
    [document updateWithCurrentDocumentState];

    if ([self shouldSkipUndoForProperty:property inDocument:document documentData:currentDocumentData]) return;

    if (document.undoManager.isUndoing == YES) property = @"*Undo Action";
    if (document.undoManager.isRedoing == YES) property = @"*Redo Action";

    [self saveUndoForProperty:property inDocument:document documentData:currentDocumentData selectedNodes:selectedNodes slideController:slidesViewController];
}

- (void)beginBatchChanges {
    self.batchedProperty = nil;
    self.batchingChanges = YES;
}

- (void)endBatchChanges {
    self.batchedProperty = nil;
    self.batchingChanges = NO;
}

#pragma mark - private

- (BOOL)shouldSkipDocumentCopyForProperty:(NSString *)property {
    if (!self.batchingChanges) return NO;
    if (self.batchedProperty) {
        if ([self.batchedProperty isEqualToString:property]) return YES;

        //Property has changed - consider this a new batch
        [self endBatchChanges];
        [self beginBatchChanges];
    }
    self.batchedProperty = property;
    return NO;
}

- (void)saveUndoForProperty:(NSString *)property inDocument:(CCBDocument *)document documentData:(NSDictionary *)currentDocumentData selectedNodes:(NSArray *)selectedNodes slideController:(PCSlidesViewController *)slidesViewController {

    UndoDebugLog(@">>>>>>> prop: %@ lastEdit: %@ <<<<<<<", property, document.lastEditedProperty);

    // use a group to both undo the document change and the selection of the slide
    [document.undoManager beginUndoGrouping];

#if DEBUG
    UndoDebugLog(@"%@", [NSObject pc_debugDifferentDescriptionBetween:currentDocumentData and:document.docData]);
    UndoDebugLog(@"Undo Data Size: %lu", (unsigned long)[[NSPropertyListSerialization dataFromPropertyList:currentDocumentData
                                                                                                    format:NSPropertyListBinaryFormat_v1_0 errorDescription:NULL] length]);
#endif

    // save the current selction using uuid to undo stack
    NSMutableArray *currentSelectedSKNodes = [NSMutableArray array];
    for (SKNode *selectedNode in selectedNodes) {
        [currentSelectedSKNodes addObject:selectedNode.uuid];
    }
    [[document.undoManager prepareWithInvocationTarget:self] reselectSKNodesAfterDocumentReload:currentSelectedSKNodes];

    // save document changes to undo stack
    [[document.undoManager prepareWithInvocationTarget:self] revertToState:currentDocumentData];

    // make sure the slide selection is entered on the stack after document change so it is pop first
    NSInteger selectedIdx = [slidesViewController selectedSlideIndex];
    [[document.undoManager prepareWithInvocationTarget:slidesViewController] selectSlideAtIndexNumber:@(selectedIdx)];
    [document.undoManager endUndoGrouping];
    document.lastEditedProperty = property;

    [self updateDirtyMark];
}

/**
 Converts a property from a 'local' scope to a 'global' scope, if necessary. If the property starts with a *, it is a global property (not specifc to a node) and no conversion is necessary. Otherwise, some logic is applied to get the property name into a global scope.
 @param property The property to convert.
 @param selectedNode The node that the property belongs to (if applicable)
 @returns The property in a global scope; that is, a property name that is globally unique for this property. This is typically in the form [nodeUUID]-propertyName-[sequenceId]-[timelinePosition], with nodeUUID, sequenceId, and timelinePosition only being added if the data exists for the property in question.
 */

- (NSString *)convertLocalProperty:(NSString *)property toGlobalScopeForNode:(SKNode *)selectedNode {
    // check if we are already global scope property (starts with a *)
    if ([property rangeOfString:@"*"].location == 0) return property;

    // Check to see if the current editing prop has a keyframe
    CCBKeyframeType type = [SequencerKeyframe keyframeTypeFromPropertyType:[selectedNode.plugIn propertyTypeForProperty:property]];
    if (type != kCCBKeyframeTypeUndefined) {
        SequencerSequence * sequence = [SequencerHandler sharedHandler].currentSequence;
        SequencerNodeProperty *sequencerNodeProperty = [selectedNode sequenceNodeProperty:property sequenceId:sequence.sequenceId];
        if (sequencerNodeProperty) {
            // if it does, make sure to add the id and time position to the current property name
            property = [NSString stringWithFormat:@"%@-%d-%f", property, sequence.sequenceId, sequence.timelinePosition];
        }
    }

    // add the selected sprite uuid to the property name
    if (selectedNode) {
         property = [NSString stringWithFormat:@"%@-%@", selectedNode.uuid, property];
    }

    return property;
}

- (BOOL)shouldSkipUndoForProperty:(NSString *)property inDocument:(CCBDocument *)document documentData:(NSDictionary *)currentDocumentData {
    if (!document.undoManager.isUndoing && !document.undoManager.isRedoing){
        // check to see if the document data has actually changed
        if ([currentDocumentData isEqualToDictionary:document.docData]) {
            UndoDebugLog(@"same doc, skipping - %@", property);
            return YES;
        }

        // check if we are changing the same property, but skip it if we are not undoing or redoing.
        if (property && [document.lastEditedProperty isEqualToString:property]) {
            UndoDebugLog(@"prop skip %@", property);
            [document updateWithCurrentDocumentState];
            return YES;
        }

        // document just being initialized, no need to add to undo stack
        if (property == nil && document.lastEditedProperty == nil) {
            UndoDebugLog(@"both null prop skip %@", property);
            [document updateWithCurrentDocumentState];
            return YES;
        }
    } else {
        // if we know that we are undoing or redoing, make sure to add to the stack if it is the
        // saved action (prop == nil), for anything else (prop != nil) skip it because it is loading initial properties
        if (property != nil) {
            UndoDebugLog(@"prop not nil during undo/redo skip %@", property);
            [document updateWithCurrentDocumentState];
            return YES;
        }
    }
    return NO;
}

- (void)reselectSKNodesAfterDocumentReload:(NSArray *)selectedNodes {
    if (self.revertSelectionBlock) {
        self.revertSelectionBlock(selectedNodes);
    }
}

- (void)revertToState:(NSDictionary *)previousState {
    if (self.revertStateBlock) {
        self.revertStateBlock(previousState);
    }
}

- (void)updateDirtyMark {
    if (self.undoCommittedBlock) {
        self.undoCommittedBlock();
    }
}


@end
