//
//  PCSKWebViewNode.m
//  SpriteBuilder
//
//  Created by Cody Rayment on 2014-07-17.
//
//

#import "PCSKWebViewNode.h"
#import "SKNode+CocosCompatibility.h"
#import "SKNode+LifeCycle.h"
#import "PCWebView.h"
#import "PCOverlayView.h"

@interface PCSKWebViewNode () <WebPolicyDelegate>

@property (copy, nonatomic) NSString *path;
@property (strong, nonatomic) PCView *containerView;
@property (strong, nonatomic) PCWebView *webView;

@end

@implementation PCSKWebViewNode

- (PCEditorResizeBehaviour)editorResizeBehaviour {
    return PCEditorResizeBehaviourContentSize;
}

#pragma mark Life Cycle

- (void)pc_didEnterScene {
    [super pc_didEnterScene];
    [self setup];
    [[PCOverlayView overlayView] addTrackingNode:self];
}

- (void)pc_willExitScene {
    [super pc_willExitScene];

    // WebView will crash while dealloc'ing while it is still loading. This is reported in the
    // following bug report:
    // https://bugs.webkit.org/show_bug.cgi?id=138443
    //
    // The author of the bug report also wrote about it here:
    // http://indiestack.com/2014/11/burn-after-releasing/
    //
    // The suggested workaround is to close the web view so that the complex teardown happens
    // prior to dealloc thus avoiding the crash
    [self.webView close];

    [[PCOverlayView overlayView] removeTrackingNode:self];
}

#pragma mark - Private

- (void)setup {
    self.containerView = [[PCView alloc] initWithFrame:self.frame];
    self.webView = [[PCWebView alloc] initWithFrame:self.containerView.bounds];
    self.webView.wantsLayer = YES;
    self.webView.policyDelegate = self;
    self.webView.autoresizingMask = NSViewWidthSizable|NSViewHeightSizable;
    [self.containerView addSubview:self.webView];
    [self startRequest];
}

- (void)startRequest {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.path]];
    [[self.webView mainFrame] loadRequest:request];
}

- (NSSet *)schemeBlacklist {
    static NSSet *blacklist = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        // List of schemes that we want to prevent the web view from opening
        NSArray *schemes = @[
            @"itms",
            @"itmss",
        ];

        blacklist = [NSSet setWithArray:schemes];
    });
    return blacklist;
}

#pragma mark - Properties

- (void)setPath:(NSString *)path {
    NSURL *url = [NSURL URLWithString:path];
    if (url.scheme.length == 0) {
        path = [NSString stringWithFormat:@"http://%@", path];
    }
    _path = path;
    [self startRequest];
}

- (void)setHomeURL:(NSString *)homeURL {
    [self setPath:homeURL];
    _homeURL = self.path;
}

#pragma mark - PCOverlayView

- (NSView<PCOverlayTrackingView> *)trackingView; {
    return self.containerView;
}

#pragma mark - WebPolicyDelegate

- (void)webView:(WebView *)webView decidePolicyForNavigationAction:(NSDictionary *)actionInformation
         request:(NSURLRequest *)request
           frame:(WebFrame *)frame
decisionListener:(id<WebPolicyDecisionListener>)listener {
    if ([self.schemeBlacklist containsObject:request.URL.scheme]) {
        [listener ignore];
        return;
    }

    [listener use];
}

@end
