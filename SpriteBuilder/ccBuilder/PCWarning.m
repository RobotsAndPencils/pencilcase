//
//  PCWarning.m
//  SpriteBuilder
//
//  Created by Stephen Gazzard on 2014-08-20.
//
//

#import "PCWarning.h"

@implementation PCWarning

- (NSString *)description {
    NSString *resolution = self.resolution ? [NSString stringWithFormat:@" (%@)", self.resolution] : @"";
    NSString * relevantFile = self.relatedFile ? [NSString stringWithFormat:@" (%@)", self.relatedFile] : @"";
    
    return [NSString stringWithFormat:@"PencilCase Player%@%@: %@", resolution, relevantFile, self.message];
}

@end
