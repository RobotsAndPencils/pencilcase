//
//  PCUndoManager.h
//  SpriteBuilder
//
//  Created by Reuben Lee on 2014-08-20.
//
//

#import <Foundation/Foundation.h>

@class CCBDocument;
@class PCSlidesViewController;

//#define UndoDebugLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#define UndoDebugLog(...)

typedef void (^PCRevertSelectionBlock)(NSArray *);
typedef void (^PCRevertToStateBlock)(NSDictionary *);

@interface PCUndoManager : NSUndoManager

@property (copy, nonatomic) dispatch_block_t undoCommittedBlock;
@property (copy, nonatomic) PCRevertSelectionBlock revertSelectionBlock;
@property (copy, nonatomic) PCRevertToStateBlock revertStateBlock;

+ (PCUndoManager *)sharedPCUndoManager;

- (void)saveUndoStateDidChangeProperty:(NSString*)prop inDocument:(CCBDocument *)document selectedNodes:(NSArray *)selectedNodes slideController:(PCSlidesViewController *)slidesViewController;

- (void)beginBatchChanges;
- (void)endBatchChanges;

@end
