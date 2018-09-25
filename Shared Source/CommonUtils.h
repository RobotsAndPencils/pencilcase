#ifdef DEBUG
#    define PCLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#    define PCLogCall PCLog(@"[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd))
#else
#    define PCLog(...)
#endif

/*
* Check if something is nil, null, zero length, or zero count
* Thanks Wil http://wilshipley.com/blog/2005/10/pimp-my-code-interlude-free-code.html
*/
static inline BOOL PCIsEmpty(id thing) {
    return thing == nil
    || ([thing isEqual:[NSNull null]])
    || ([thing respondsToSelector:@selector(length)]
        && [(id)thing length] == 0)
    || ([thing respondsToSelector:@selector(count)]
        && [(id)thing count] == 0);
}

/*
* Radian <-> Degree conversion
*/
#define RADIANS_TO_DEGREES(__ANGLE__) ((__ANGLE__) / (CGFloat)M_PI * 180.0f)
#define DEGREES_TO_RADIANS(__ANGLE__) ((CGFloat)M_PI * (__ANGLE__) / 180.0f)

/*
* Detect if we're currently running as a test target or not (for Test scheme set Environment Varible IS_TARGET_TEST to 1 )
*/
#define IS_TEST_TARGET [[[NSProcessInfo processInfo] environment] objectForKey:@"IS_TARGET_TEST"]


#if TARGET_OS_IPHONE

/*
 *  System Versioning Preprocessor Macros from http://stackoverflow.com/a/5337804/1751969
 *
 * if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"3.1.1")) {
 * ...
 * }
 *
 */
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

/*
 * Quick check if device is an iPad for iPhone vs iPad handling in the same code
 */
#define IS_IPAD() (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

/*
 * Check if a device has iPhone 5 screen height
 */
#define IS_WIDESCREEN() ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

/*
 * Check if device is retina or retina HD
 */
#define IS_RETINA() ([[UIScreen mainScreen] scale] == 2.0)
#define IS_RETINA_HD() ([[UIScreen mainScreen] scale] == 3.0)
#define SINGLE_PIXEL_LINE_WIDTH() (1.0 / [[UIScreen mainScreen] scale])

#endif
