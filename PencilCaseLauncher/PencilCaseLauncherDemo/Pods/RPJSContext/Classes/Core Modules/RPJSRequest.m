//
//  RPJSRequest.m
//  RPJSContext
//
//  Created by Brandon Evans on 2014-04-24.
//  Copyright (c) 2014 Robots and Pencils. All rights reserved.
//

#import "RPJSRequest.h"
#import "AFHTTPRequestOperationManager.h"

@implementation RPJSRequest

+ (void)setupInContext:(JSContext *)context {
    context[@"__request_get"] = ^(JSValue *urlValue, JSValue *successCallback, JSValue *errorCallback) {
        NSString *urlString = [self urlStringFromURLValue:urlValue];
        NSDictionary *headers = [self headersFromURLValue:urlValue];

        AFHTTPRequestOperation *operation = [self operationWithURLString:urlString httpMethod:@"GET" headers:headers parameters:@{} successCallback:successCallback errorCallback:errorCallback];
        if (operation) {
            [[self sharedQueue] addOperation:operation];
        }
    };
    context[@"__request_post"] = ^(JSValue *urlValue, NSDictionary *parameters, JSValue *successCallback, JSValue *errorCallback) {
        NSString *urlString = [self urlStringFromURLValue:urlValue];
        NSDictionary *headers = [self headersFromURLValue:urlValue];

        AFHTTPRequestOperation *operation = [self operationWithURLString:urlString httpMethod:@"POST" headers:headers parameters:parameters successCallback:successCallback errorCallback:errorCallback];
        if (operation) {
            [[self sharedQueue] addOperation:operation];
        }
    };
}

#pragma mark - Private

+ (NSOperationQueue *)sharedQueue {
    static dispatch_once_t once;
    static NSOperationQueue *queue;
    dispatch_once(&once, ^{
        queue = [[NSOperationQueue alloc] init];
        queue.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount;
        queue.qualityOfService = NSQualityOfServiceUserInitiated;
    });
    return queue;
}

+ (AFHTTPRequestOperation *)operationWithURLString:(NSString *)urlString httpMethod:(NSString *)httpMethod headers:(NSDictionary *)headers parameters:(NSDictionary *)parameters successCallback:(JSValue *)successCallback errorCallback:(JSValue *)errorCallback {
    if (!urlString || urlString.length == 0 || !httpMethod || httpMethod.length == 0) {
        return nil;
    }

    AFJSONRequestSerializer *requestSerializer = [[AFJSONRequestSerializer alloc] init];
    NSError *requestConstructionError;
    NSMutableURLRequest *request = [requestSerializer requestWithMethod:httpMethod URLString:urlString parameters:parameters error:&requestConstructionError];
    if (requestConstructionError) {
        return nil;
    }

    NSMutableDictionary *mutableHeaders = [[self defaultHeaders] mutableCopy];
    [mutableHeaders addEntriesFromDictionary:headers];
    for (NSString *headerName in mutableHeaders) {
        NSString *header = mutableHeaders[headerName];
        [request setValue:header forHTTPHeaderField:headerName];
    }

    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFCompoundResponseSerializer compoundSerializerWithResponseSerializers:@[ [[AFHTTPResponseSerializer alloc] init], [[AFJSONResponseSerializer alloc] init] ]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *completedOperation, id responseObject) {
        NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        if (responseString) {
            [successCallback callWithArguments:@[ responseString ]];
        }
    } failure:^(AFHTTPRequestOperation *failedOperation, NSError *error) {
        [errorCallback callWithArguments:@[ [[error userInfo] description] ?: @"" ]];
    }];

    return operation;
}

/**
 *  Extracts the URL from the first argument (optionally a JS Object)
 *
 *  @param urlValue The first argument
 *
 *  @return A URL string or nil
 */
+ (NSString *)urlStringFromURLValue:(JSValue *)urlValue {
    NSString *urlString;

    if ([urlValue isString]) {
        urlString = [urlValue toString];
    }
    else if ([urlValue isObject]) {
        NSDictionary *options = [urlValue toDictionary];
        urlString = options[@"url"];
    }

    return urlString;
}

/**
 *  Extracts the headers from the first argument (optionally a JS Object)
 *
 *  @param urlValue The first argument
 *
 *  @return A dictionary of headers, at worst empty and non-nil
 */
+ (NSDictionary *)headersFromURLValue:(JSValue *)urlValue {
    NSDictionary *headers = @{};

    if ([urlValue isObject]) {
        NSDictionary *options = [urlValue toDictionary];
        headers = options[@"headers"];
        if (!headers || [headers isEqual:[NSNull null]]) {
            headers = @{};
        }
    }

    return headers;
}

+ (NSDictionary *)defaultHeaders {
    return @{
        @"Accept": @"application/json"
    };
}

@end
