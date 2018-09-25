//
//  NSOpenPanel+PCImport.h
//  SpriteBuilder
//
//  Created by Michael Beauregard on 15-03-09.
//
//

@class PCResourceDirectory;

@interface NSOpenPanel (PCImport)

+ (void)showImportResourcesDialog:(void (^)(BOOL success))completion toResourceDirectory:(PCResourceDirectory *)resourceDirectory;

@end
