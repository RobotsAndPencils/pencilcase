//
//  PCKeyValueStore(JSExport)
//  PCPlayer
//
//  Created by brandon on 2014-03-13.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

@import JavaScriptCore;
#import "PCKeyValueStore.h"
#import "NSObject+JSDataBinding.h"

@protocol PCKeyValueStoreExport <JSExport, NSObjectJSDataBindingExport>

// var userInfo = {
//   id: '0',
//   name: 'K1LL4H',
//   score: 24
// };
// KeyValueStore.setValue(userInfo, userInfo.id, 'Users', function(obj) {
//   log('Saved object: ' + obj);
// }, function(errorString) {
//   log('Error saving object: ' + errorString);
// });
JSExportAs(setValue,
- (void)setObject:(id)object forKey:(NSString *)key inCollection:(NSString *)collectionName success:(JSValue *)successCallback failure:(JSValue *)failureCallback
);

// var userInfo = KeyValueStore.getValue('0', 'Users');
// log('Fetched a user named: ' + user.name);
JSExportAs(getValue,
- (id)objectForKey:(NSString *)key inCollection:(NSString *)collectionName
);

// var keys = KeyValueStore.allKeysInCollection('Users');
// var user;
// _.each(keys, function(key) {
//   user = KeyValueStore.getValue(key, 'Users');
//   log('Fetched user named: ' + user.name);
// });
JSExportAs(allKeysInCollection,
- (NSArray *)allKeysInCollection:(NSString *)collectionName
);

@end

@interface PCKeyValueStore (JSExport) <PCKeyValueStoreExport>
@end
