//
//  PCUserProjectDocuments.m
//  SpriteBuilder
//
//  Created by Orest Nazarewycz on 2015-01-16.
//
//

#import "PCUserProjectDocuments.h"
#import "PCApplicationSupport.h"
#import "NSFileManager+FileUtilities.h"

NSString *const PCUserProjectDocumentsFileName = @"PCUserProjectDocuments.plist";

@interface PCUserProjectDocuments ()

@property (strong, nonatomic) NSMutableArray *userProjectsInTrash;

@end

@implementation PCUserProjectDocuments

+ (PCUserProjectDocuments *)userDocuments {
    static dispatch_once_t onceToken;
    static PCUserProjectDocuments *userProjectDocuments = nil;
    dispatch_once(&onceToken, ^{
        userProjectDocuments = [[PCUserProjectDocuments alloc] init];
    });

    return userProjectDocuments;
}

- (id)init {
    self = [super init];
    if (self) {
        _userProjectDocuments = [[NSMutableArray alloc] init];
        _userProjectsInTrash = [[NSMutableArray alloc] init];
        [self readProjectReferenceURLs];
    }
    return self;
}

- (void)readProjectReferenceURLs {
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSString *applicationSupportDirectory = [PCApplicationSupport pencilCaseApplicationSupportDirectoryPath];
    NSString *userProjectDocumentsFilePath = [applicationSupportDirectory stringByAppendingPathComponent:PCUserProjectDocumentsFileName];
    if (![fileManager fileExistsAtPath:userProjectDocumentsFilePath isDirectory:NO]) {
        [fileManager createFileAtPath:userProjectDocumentsFilePath contents:nil attributes:nil];
        return;
    }

    [self.userProjectDocuments removeAllObjects];
    [self.userProjectsInTrash removeAllObjects];
    NSMutableArray *documents = [NSKeyedUnarchiver unarchiveObjectWithFile:userProjectDocumentsFilePath];
    for (PCUserProjectDocument *document in documents) {
        if (document.userProjectReferenceUrl == nil) continue;

        NSMutableArray *documentDestinationArray = ([NSFileManager pc_isFileInTrash:document.userProjectReferenceUrl] ? self.userProjectsInTrash : self.userProjectDocuments);
        [documentDestinationArray addObject:document];
    }

    // sort the documents
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"modificationDate" ascending:NO];
    [self.userProjectDocuments sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
}

- (void)writeProjectReferenceUrls {
    NSString *applicationSupportDirectory = [PCApplicationSupport pencilCaseApplicationSupportDirectoryPath];
    NSString *userProjectDocumentsFilePath = [applicationSupportDirectory stringByAppendingPathComponent:PCUserProjectDocumentsFileName];

    //We want to persist the user projects in the trash in case the user pulls them back out so that it's still in the recent list, so create a temporary array to store both live and trashed projects
    NSArray *allDocuments = [self.userProjectDocuments arrayByAddingObjectsFromArray:self.userProjectsInTrash];
    [NSKeyedArchiver archiveRootObject:allDocuments toFile:userProjectDocumentsFilePath];
}

- (void)addProjectToUserDocumentsList:(NSString *)projectPath isFavorite:(BOOL)isFavorite {
    NSURL *fileURL = [NSURL fileURLWithPath:projectPath];
    for (PCUserProjectDocument *document in self.userProjectDocuments) {
        if ([document.userProjectReferenceUrl isEqual:fileURL]) return;
    }

    NSURL *url = [NSURL fileURLWithPath:projectPath];
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    if (![fileManager fileExistsAtPath:projectPath]) {
        PCLog(@"Error project does not exist at path: %@", projectPath);
        return;
    }

    PCUserProjectDocument *projectDoc = [[PCUserProjectDocument alloc] initWithProjectURL:url isFavorite:isFavorite];
    [self.userProjectDocuments addObject:projectDoc];
    [self writeProjectReferenceUrls];
}

- (void)favoriteUserProject:(NSURL *)projectDocumentUrl favorite:(BOOL)favorite {
    if (!projectDocumentUrl) return;
    for (PCUserProjectDocument *document in self.userProjectDocuments) {
        if ([document.userProjectReferenceUrl isEqual:projectDocumentUrl]) {
            document.isFavorite = favorite;
        }
    }
    [self writeProjectReferenceUrls];
}

- (NSMutableArray *)getUserProjectFavorites {
    NSMutableArray *favoriteProjects = [[NSMutableArray alloc] init];
    for (PCUserProjectDocument *document in self.userProjectDocuments) {
        if (document.isFavorite) {
            [favoriteProjects addObject:document.userProjectReferenceUrl];
        }
    }
    return favoriteProjects;
}

- (NSMutableArray *)getAllUserProjectPaths {
    NSMutableArray *projectPaths = [[NSMutableArray alloc] init];
    for (PCUserProjectDocument *document in self.userProjectDocuments) {
        [projectPaths addObject:document.userProjectReferenceUrl];
    }
    return projectPaths;
}

@end
