//
//  PCFontConsuming.h
//  SpriteBuilder
//
//  Created by Reuben Lee on 2015-04-17.
//
//

#import <Foundation/Foundation.h>

@protocol PCFontConsuming <NSObject>

/**
 Get all the font name and size used in the rich text data
 */
- (NSDictionary *)fontNamesAndSizes;

@end
