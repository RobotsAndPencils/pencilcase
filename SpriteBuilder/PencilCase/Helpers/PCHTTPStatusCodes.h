#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, PCHTTPStatus) {
    // Informational - 1xx codes
    PCHTTPStatus100Continue = 100,
    PCHTTPStatus101SwitchingProtocols = 101,
    
    // Successful - 2xx codes
    PCHTTPStatus200OK = 200,
    PCHTTPStatus201Created = 201,
    PCHTTPStatus202Accepted = 202,
    PCHTTPStatus203NonAuthoritative = 203,
    PCHTTPStatus204NoContent = 204,
    PCHTTPStatus205ResetContent = 205,
    PCHTTPStatus206PartialContent = 206,
    
    // Redirection - 3xx codes
    PCHTTPStatus300MultipleChoices = 300,
    PCHTTPStatus301MovedPermanently = 301,
    PCHTTPStatus302Found = 302,
    PCHTTPStatus303SeeOther = 303,
    PCHTTPStatus304NotModified = 304,
    PCHTTPStatus305UseProxy = 305,
    PCHTTPStatus307TemporaryRedirect = 307,
    
    // Client errors - 4xx codes
    PCHTTPStatus400BadRequest = 400,
    PCHTTPStatus401Unauthorized = 401,
    PCHTTPStatus402PaymentRequired = 402,
    PCHTTPStatus403Forbidden = 403,
    PCHTTPStatus404NotFound = 404,
    PCHTTPStatus405MethodNotAllowed = 405,
    PCHTTPStatus406NotAcceptable = 406,
    PCHTTPStatus407ProxyAuthenticationRequired = 407,
    PCHTTPStatus408RequestTimeout = 408,
    PCHTTPStatus409Conflict = 409,
    PCHTTPStatus410Gone = 410,
    PCHTTPStatus411LengthRequired = 411,
    PCHTTPStatus412PreconditionFailed = 412,
    PCHTTPStatus413RequestEntityTooLarge = 413,
    PCHTTPStatus414RequestURITooLong = 414,
    PCHTTPStatus415UnsupportedMediaType = 415,
    PCHTTPStatus416RequestedRangeNotSatisfiable = 416,
    PCHTTPStatus417ExpectationFailed = 417,
    
    // Server errors - 5xx codes
    PCHTTPStatus500InternalServerError = 500,
    PCHTTPStatus501NotImplemented = 501,
    PCHTTPStatus502BadGateway = 502,
    PCHTTPStatus503ServiceUnavailable = 503,
    PCHTTPStatus504GatewayTimeout = 504,
    PCHTTPStatus505HTTPVersionNotSupported = 505,
};

extern NSString *PCHTTPStatusString(PCHTTPStatus status);
extern BOOL PCHTTPStatusIsInformational(PCHTTPStatus status);
extern BOOL PCHTTPStatusIsSuccessful(PCHTTPStatus status);
extern BOOL PCHTTPStatusIsRedirection(PCHTTPStatus status);
extern BOOL PCHTTPStatusIsClientError(PCHTTPStatus status);
extern BOOL PCHTTPStatusIsServerError(PCHTTPStatus status);
