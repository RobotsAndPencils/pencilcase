//
//  NSString+FilePath.m
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2014-10-09.
//
//

#import "NSString+DAE.h"

@implementation NSString (DAE)

- (BOOL)pc_isFilePathToXmlFile {
    // try to load url into a xml doc
    NSError *error = nil;
    NSXMLDocument *modelXMLDoc = [[NSXMLDocument alloc] initWithContentsOfURL:[NSURL fileURLWithPath:self] options:NSXMLNodeOptionsNone error:&error];

    // if we can't parse it, return NO
    if (error != nil) return NO;
    if (modelXMLDoc == nil) return NO;

    return YES;
}

+ (NSArray *)pc_fetchTextureImagePathsFor3DModelAt:(NSString *)modelPath {

    // we assume this is passing in a dae file which is in xml format
    NSError *error = nil;
    NSXMLDocument *modelXMLDoc = [[NSXMLDocument alloc] initWithContentsOfURL:[NSURL fileURLWithPath:modelPath] options:NSXMLNodeOptionsNone error:&error];

    // if we can't parse it, just return an empty array
    if (error != nil) return [NSArray array];
    if (modelXMLDoc == nil) return [NSArray array];

    // look for image element
    NSArray *imageNodes = [modelXMLDoc nodesForXPath:@"//image" error:&error];

    if (error != nil) return [NSArray array];

    NSMutableArray *results = [NSMutableArray array];

    for (NSXMLElement *imageElement in imageNodes){
        NSArray *froms = [imageElement elementsForName:@"init_from"];
        if (froms.count > 0){
            // find the path and add to result
            NSXMLElement *path = froms.firstObject;
            [results addObject:path.stringValue];
        }
    }

    // search for the files in the same dir as the modelPath
    for (NSInteger i = 0; i < [results count]; i++){
        NSString *currentResult = results[i];
        NSString *testPath = [modelPath stringByDeletingLastPathComponent];
        testPath = [testPath stringByAppendingString:@"/"];
        testPath = [testPath stringByAppendingString:[currentResult lastPathComponent]];

        // if they are in the same dir, we just need to return the file name, not the entire path
        if ([[NSFileManager defaultManager] fileExistsAtPath:testPath]){
            results[i] = [currentResult lastPathComponent];
        }
    }

    return results;
}

@end
