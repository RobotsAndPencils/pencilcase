#import "PCHTTPStatusCodes.h"

NSString *PCHTTPStatusString(PCHTTPStatus status) {
    switch (status) {
        case PCHTTPStatus100Continue: return @"Continue";
        case PCHTTPStatus101SwitchingProtocols: return @"Switching Protocols";
        case PCHTTPStatus200OK: return @"OK";
        case PCHTTPStatus201Created: return @"Created";
        case PCHTTPStatus202Accepted: return @"Accepted";
        case PCHTTPStatus203NonAuthoritative: return @"Non Authoritative";
        case PCHTTPStatus204NoContent: return @"No Content";
        case PCHTTPStatus205ResetContent: return @"Reset Content";
        case PCHTTPStatus206PartialContent: return @"Partial Content";
        case PCHTTPStatus300MultipleChoices: return @"Multiple Choices";
        case PCHTTPStatus301MovedPermanently: return @"Moved Permanently";
        case PCHTTPStatus302Found: return @"Found";
        case PCHTTPStatus303SeeOther: return @"See Other";
        case PCHTTPStatus304NotModified: return @"Not Modified";
        case PCHTTPStatus305UseProxy: return @"Use Proxy";
        case PCHTTPStatus307TemporaryRedirect: return @"Temporary Redirect";
        case PCHTTPStatus400BadRequest: return @"Bad Request";
        case PCHTTPStatus401Unauthorized: return @"Unauthorized";
        case PCHTTPStatus402PaymentRequired: return @"PaymentRequired";
        case PCHTTPStatus403Forbidden: return @"Forbidden";
        case PCHTTPStatus404NotFound: return @"Not Found";
        case PCHTTPStatus405MethodNotAllowed: return @"Method Not Allowed";
        case PCHTTPStatus406NotAcceptable: return @"Not Acceptable";
        case PCHTTPStatus407ProxyAuthenticationRequired: return @"Proxy Authentication Required";
        case PCHTTPStatus408RequestTimeout: return @"Request Timeout";
        case PCHTTPStatus409Conflict: return @"Conflict";
        case PCHTTPStatus410Gone: return @"Gone";
        case PCHTTPStatus411LengthRequired: return @"Length Required";
        case PCHTTPStatus412PreconditionFailed: return @"Precondition Failed";
        case PCHTTPStatus413RequestEntityTooLarge: return @"Request Entity Too Large";
        case PCHTTPStatus414RequestURITooLong: return @"Request URI Too Long";
        case PCHTTPStatus415UnsupportedMediaType: return @"Unsupported Media Type";
        case PCHTTPStatus416RequestedRangeNotSatisfiable: return @"Requested Range Not Satisfiable";
        case PCHTTPStatus417ExpectationFailed: return @"Expectation Failed";
        case PCHTTPStatus500InternalServerError: return @"Internal Server Error";
        case PCHTTPStatus501NotImplemented: return @"Not Implemented";
        case PCHTTPStatus502BadGateway: return @"Bad Gateway";
        case PCHTTPStatus503ServiceUnavailable: return @"Service Unavailable";
        case PCHTTPStatus504GatewayTimeout: return @"Gateway Timeout";
        case PCHTTPStatus505HTTPVersionNotSupported: return @"HTTP Version Not Supported";
    }
    return @"Invalid Status Code";
}

BOOL PCHTTPStatusIsInformational(PCHTTPStatus status) {
    return status >= 100 && status < 200;
}

BOOL PCHTTPStatusIsSuccessful(PCHTTPStatus status) {
    return status >= 200 && status < 300;
}

BOOL PCHTTPStatusIsRedirection(PCHTTPStatus status) {
    return status >= 300 && status < 400;
}

BOOL PCHTTPStatusIsClientError(PCHTTPStatus status) {
    return status >= 400 && status < 500;
}

BOOL PCHTTPStatusIsServerError(PCHTTPStatus status) {
    return status >= 500;
}
