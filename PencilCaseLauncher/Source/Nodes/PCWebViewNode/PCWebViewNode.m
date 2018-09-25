//
//  PCWebViewNode.m
//  PCPlayer
//
//  Created by Cody Rayment on 2014-03-25.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

@import JavaScriptCore;
@import WebKit;

#import "PCWebViewNode.h"
#import "PCOverlayView.h"

#import "SKNode+JavaScript.h"
#import "SKNode+LifeCycle.h"
#import "PCJSContext.h"

typedef NS_ENUM(NSInteger, EventInspectorWebViewLoadingContentState) {
    EventInspectorWebViewContentStartLoading = 0,
    EventInspectorWebViewContentFinishLoading,
    EventInspectorWebViewContentFailToLoad
};


@interface PCWebViewNode () <WKNavigationDelegate>

@property (strong, nonatomic) UIView *container;
@property (strong, nonatomic) WKWebView *webView;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;

// This is really dumb, but the request property was removed from WKNavigation, and it doesn't conform to NSCopying, so it's basically useless.
// Also, the WKNavigation argument is sometimes nil in the WKWebView delegate methods so we can't actually use it to track navigation progress in all scenarios.
// We put the navigations in an array so they stick around outside the method scope and keep the JS callbacks alive
@property (strong, nonatomic) NSMutableArray *navigations;
@property (strong, nonatomic) NSMutableArray *jsCompletionHandlers;

@end

@implementation PCWebViewNode

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }

    self.navigations = [NSMutableArray array];
    self.jsCompletionHandlers = [NSMutableArray array];

    return self;
}

- (void)pc_didEnterScene {
    [super pc_didEnterScene];
    [self setup];
}

- (void)pc_presentationDidStart {
    [super pc_presentationDidStart];
    [[PCOverlayView overlayView] addTrackingNode:self];
    self.webView.frame = CGRectMake(0, 0, self.container.frame.size.width, self.container.frame.size.height);
}

- (void)pc_presentationCompleted {
    [super pc_presentationCompleted];
    self.webView.navigationDelegate = self;
}

- (void)pc_dismissTransitionWillStart {
    [super pc_dismissTransitionWillStart];
    [[PCOverlayView overlayView] removeTrackingNode:self];
}

- (void)back:(JSValue *)completionHandler {
    if ([self.webView canGoBack]) {
        [self.webView goBack];

        // Because of the WebKit bug mentioned in the header file, this callback is called immediately.
        if (completionHandler) {
            [completionHandler callWithArguments:@[]];
        }
    }
}

- (void)forward:(JSValue *)completionHandler {
    if ([self.webView canGoForward]) {
        [self.webView goForward];

        // Because of the WebKit bug mentioned in the header file, this callback is called immediately.
        if (completionHandler) {
            [completionHandler callWithArguments:@[]];
        }
    }
}

- (void)refresh:(JSValue *)completionHandler {
    [self.webView stopLoading];
    WKNavigation *navigation = [self.webView reload];

    if (completionHandler) {
        [self.navigations addObject:navigation];
        JSManagedValue *managedHandler = [JSManagedValue managedValueWithValue:completionHandler andOwner:navigation];
        [self.jsCompletionHandlers addObject:managedHandler];
    }
}

- (void)stop:(JSValue *)completionHandler {
    [self.webView stopLoading];

    // Stopping occurs instantaneously
    if (completionHandler) {
        [completionHandler callWithArguments:@[]];
    }
}

- (void)home:(JSValue *)completionHandler {
    [self setPath:self.homeURL completionHandler:completionHandler];
}

#pragma mark - Private

- (void)setup {
    self.container = [[UIView alloc] initWithFrame:CGRectZero];
    self.container.backgroundColor = [UIColor clearColor];

    self.webView = [[WKWebView alloc] initWithFrame:self.container.bounds];
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self loadURL:self.path completionHandler:nil];
    [self.container addSubview:self.webView];

    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.spinner.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    self.spinner.center = CGPointMake(CGRectGetMidX(self.container.bounds), CGRectGetMidY(self.container.bounds));
    self.spinner.hidesWhenStopped = YES;
    [self.spinner startAnimating];
    [self.container addSubview:self.spinner];
    [self updateUIUserInteractionEnabled:self.userInteractionEnabled];
}

- (void)loadURL:(NSString *)urlString completionHandler:(JSValue *)completionHandler {
    if (!self.webView) {
        [completionHandler callWithArguments:@[]];
        return;
    }

    [self.webView stopLoading];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    WKNavigation *navigation = [self.webView loadRequest:request];

    if (completionHandler) {
        [self.navigations addObject:navigation];
        JSManagedValue *managedHandler = [JSManagedValue managedValueWithValue:completionHandler andOwner:navigation];
        [self.jsCompletionHandlers addObject:managedHandler];
    }
}

- (void)setPath:(NSString *)path completionHandler:(JSValue *)completionHandler {
    _path = path;
    NSURL *url = [NSURL URLWithString:self.path];
    if (url.scheme.length == 0) {
        _path = [NSString stringWithFormat:@"http://%@", path];
    }
    [self loadURL:self.path completionHandler:completionHandler];
}

- (NSString *)currentURL {
    return self.webView.URL.absoluteString;
}

- (void)setCurrentURL:(NSString *)currentURL {
    NSURL *url = [NSURL URLWithString:currentURL];
    if (url.scheme.length == 0) {
       currentURL = [NSString stringWithFormat:@"http://%@", currentURL];
    }
    [self loadURL:currentURL completionHandler:nil];
}

- (void)postNotificationForChangeToState:(EventInspectorWebViewLoadingContentState)loadingState {
    NSDictionary *userInfo = @{
        PCJSContextEventNotificationEventNameKey: @"stateChanged",
        PCJSContextEventNotificationArgumentsKey: @[ [self stringForLoadingState:loadingState] ]
    };
    [[NSNotificationCenter defaultCenter] postNotificationName:PCJSContextEventNotificationName object:self userInfo:userInfo];
}

- (void)callJSCompletionHandlerForNavigation:(WKNavigation *)navigation {
    NSUInteger navigationIndex = [self.navigations indexOfObject:navigation];
    if (navigationIndex == NSNotFound) return;

    JSManagedValue *managedHandler = self.jsCompletionHandlers[navigationIndex];
    if (!managedHandler) return;

    JSValue *completionHandler = managedHandler.value;
    if (completionHandler) {
        [completionHandler callWithArguments:@[]];
    }

    [self.jsCompletionHandlers removeObjectAtIndex:navigationIndex];
    [self.navigations removeObjectAtIndex:navigationIndex];
}

- (NSString *)stringForLoadingState:(EventInspectorWebViewLoadingContentState)state {
    switch (state) {
        case EventInspectorWebViewContentStartLoading: return @"started";
        case EventInspectorWebViewContentFinishLoading: return @"finished";
        case EventInspectorWebViewContentFailToLoad: return @"failed";
    }
    return @"undefined";
}

#pragma mark - PCOverlayNode

- (UIView *)trackingView {
    return self.container;
}

- (void)viewUpdated:(BOOL)frameChanged {
    if (frameChanged) {
        self.webView.frame = CGRectMake(0, 0, self.container.bounds.size.width, self.container.bounds.size.height);
        self.spinner.center = CGPointMake(CGRectGetMidX(self.container.bounds), CGRectGetMidY(self.container.bounds));
    }
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    [self.spinner startAnimating];
    EventInspectorWebViewLoadingContentState loadingState = EventInspectorWebViewContentStartLoading;
    [self postNotificationForChangeToState:loadingState];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [self.spinner stopAnimating];
    EventInspectorWebViewLoadingContentState loadingState = EventInspectorWebViewContentFinishLoading;
    [self postNotificationForChangeToState:loadingState];
    [self callJSCompletionHandlerForNavigation:navigation];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [self.spinner stopAnimating];
    EventInspectorWebViewLoadingContentState loadingState = EventInspectorWebViewContentFailToLoad;
    [self postNotificationForChangeToState:loadingState];
    [self callJSCompletionHandlerForNavigation:navigation];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [self.spinner stopAnimating];
    EventInspectorWebViewLoadingContentState loadingState = EventInspectorWebViewContentFailToLoad;
    [self postNotificationForChangeToState:loadingState];
    [self callJSCompletionHandlerForNavigation:navigation];
}

#pragma mark - Properties

- (void)setUserInteractionEnabled:(BOOL)userInteractionEnabled {
    [super setUserInteractionEnabled:userInteractionEnabled];
    [self updateUIUserInteractionEnabled:userInteractionEnabled];
}

- (void)updateUIUserInteractionEnabled:(BOOL)userInteractionEnabled {
    self.webView.userInteractionEnabled = userInteractionEnabled;
}

@end
