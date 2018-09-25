//
//  PCFirebaseDataSourceExport+JSExport.h
//  PencilCaseLauncherDemo
//
//  Created by Stephen Gazzard on 2015-05-01.
//  Copyright (c) 2015 Robots & Pencils. All rights reserved.
//

@import JavaScriptCore;

#import "PCFirebaseDataSource.h"

@protocol PCFirebaseDataSourceExport <JSExport>

JSExportAs(monitorValue,
- (void)jsMonitorValueAtPath:(NSString *)path newValueCallback:(JSValue *)newValueCallback
);

JSExportAs(stopMonitoringValue,
- (void)stopMonitoringValueAtPath:(NSString *)path
);

JSExportAs(fetchValue,
- (void)jsFetchValueAtPath:(NSString *)path success:(JSValue *)success failure:(JSValue *)failure
);

JSExportAs(saveValue,
- (void)jsSaveValue:(id)value toPath:(NSString *)path success:(JSValue *)success failure:(JSValue *)failure
);

JSExportAs(appendValue,
- (void)jsAppendValue:(id)value toPath:(NSString *)path success:(JSValue *)success failure:(JSValue *)failure
);

@end

@interface PCFirebaseDataSource (JSExport) <PCFirebaseDataSourceExport>


@end
