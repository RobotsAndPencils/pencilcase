//
//  PCUserProjectDocuments.h
//  SpriteBuilder
//
//  Created by Orest Nazarewycz on 2015-01-16.
//
//

#import <Foundation/Foundation.h>
#import "PCUserProjectDocument.h"

@interface PCUserProjectDocuments : NSObject

@property (strong, nonatomic) NSMutableArray *userProjectDocuments;

+ (PCUserProjectDocuments *)userDocuments;

- (void)readProjectReferenceURLs;
- (void)writeProjectReferenceUrls;
- (void)addProjectToUserDocumentsList:(NSString *)projectPath isFavorite:(BOOL)isFavorite;
- (void)favoriteUserProject:(NSURL *)projectDocumentUrl favorite:(BOOL)favorite;
- (NSMutableArray *)getUserProjectFavorites;
- (NSMutableArray *)getAllUserProjectPaths;

@end
