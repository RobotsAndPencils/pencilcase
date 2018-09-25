//
//  PCKeyValueStoreKeyConfig.h
//  SpriteBuilder
//
//  Created by Brandon Evans on 2015-04-02.
//
//

#import "Constants.h"

@interface PCKeyValueStoreKeyConfig : NSObject <NSCoding, NSCopying>

@property (nonatomic, copy) NSString *key;
@property (nonatomic, copy) NSString *collectionName;
@property (nonatomic, assign) PCKeyValueStoreKeyType type;

- (instancetype)initWithKey:(NSString *)key keyUniquenessTest:(BOOL (^)(PCKeyValueStoreKeyConfig *))uniquenessTest;

@end
