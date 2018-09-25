//
//  Constants.h
//  SpriteBuilder
//
//  Created by Brendan Duddridge on 2014-03-13.
//
//

#import <Foundation/Foundation.h>

#define BUNDLE_VERSION [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]
#define VERSION_STRING [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]

// Pasteboard Types
extern NSString *const PCPasteboardTypeFont;
extern NSString *const PCPasteboardTypeParticleTemplate;
extern NSString *const PCPasteboardTypeShape;
extern NSString *const PCPasteboardTypeNode;
extern NSString *const PCPasteboardTypeTexture;
extern NSString *const PCPasteboardTypeTemplate;
extern NSString *const PCPasteboardTypeCCB;
extern NSString *const PCPasteboardTypePluginNode;
extern NSString *const PCPasteboardTypeWAV;
extern NSString *const PCPasteboardTypeMOV;
extern NSString *const PCPasteboardType3DModel;
extern NSString *const PCPasteboardTypeResource;
extern NSString *const PCPasteboardTypeBehavioursWhen;
extern NSString *const PCPasteboardTypeBehavioursThen;

extern NSString *const PCDroppedFileNotification;

extern CGFloat const PCMinimumContentSize;

extern NSInteger const PCJavaScriptNumberMax;

extern NSString *const MixedStateDidChangeNotification;
extern NSString *const UpdateNodeManagerPropertiesNotification;
extern NSString *const ReloadObjectHierarchyNotification;

extern NSString *const PCPropertyNameGravity;

/**
 * The version of the serialization format of a .creation (laucher file). Increment when changing the .creation export in a way which will break old versions of the launcher.

 * This is the version that the launcher will read/compare to see if it is capable of running this .creation

 * When changing this value, make sure to also change matching values `PCVersion` and (if applicable) `PCMinimumVersion` in `CCBReader.h` in the launcher pod. This is very important or the launcher will refuse to open newly exported files.
 */
extern NSInteger const PCPublishedFileFormatVersion;

/**
 * The version of the serialization format of a .pcase (author file). Increment when changing the .pcase format in a way which will break old versions of PencilCase.

 * If this version is incremented then older versions of PencilCase will no longer try to open files created by the new PencilCase.

 * Incrementing this also prompts the user to update to the new format when they open a file with an older version.
 */
extern NSInteger const PCMakerFileFormatVersion;

/**
 * The earliest known version of the file format that is known to have backwards compatible JavaScript. If we goof up and make breaking changes that prevent this backwards compatibility, we have to regenerate every JS in the users project file if they open a project older than this version - can be very expensive so avoid if at all possible!
 */
extern NSInteger const PCMakerFileFormatVersionRequiringJSRepublish;

extern NSString * const PCCreationExtension;

#pragma mark - NSNotifications

extern NSString *const PCCreateNewProjectNotification;
extern NSString *const PCCancelCreatingNewProjectNotification;
extern NSString *const PCCloseSplashWindowNotification;
extern NSString *const PCProjectFailedToOpenNotification;
extern NSString *const PCProjectOpenedNotification;
extern NSString *const PCNodeDeletedNotification;
extern NSString *const PCTableCellsChangedNotification;
extern NSString *const PCKeyValueStoreKeyConfigChangedNotification;

extern NSString *const PCSaveNewProjectNotification;
// userInfo keys:
extern NSString *const PCProjectDeviceTargetTypeKey;
extern NSString *const PCProjectDeviceTargetOrientationKey;

extern NSString *const PCOpenProjectNotification;
// userInfo keys:
extern NSString *const PCOpenProjectURLKey;

extern NSString *const PCShowOpenFilePanelNotification;

#pragma mark - NSUserDefault Keys

extern NSString *const PCTernTypeNameBool;
extern NSString *const PCTernTypeNameString;
extern NSString *const PCTernTypeNameColor;
extern NSString *const PCTernTypeNamePoint;
extern NSString *const PCTernTypeNameScale;
extern NSString *const PCTernTypeNameSize;
extern NSString *const PCTernTypeNameTexture;
extern NSString *const PCTernTypeNameVector;
extern NSString *const PCTernTypeNameTimeline;
extern NSString *const PCTernTypeNameTemplate;
extern NSString *const PCTernTypeNameTableCell;
extern NSString *const PCTernTypeNameNode;
extern NSString *const PCTernTypeNameCard;
extern NSString *const PCTernTypeNameBeacon;
extern NSString *const PCTernTypeNameNumber;
extern NSString *const PCTernTypeNameUnknown;
extern NSString *const PCTernTypeNameRectangle;
extern NSString *const PCTernTypeNameUndefined;
extern NSString *const PCTernTypeNameNull;
extern NSString *const PCTernTypeNameArray;
extern NSString *const PCTernTypeNameDate;

extern const NSOperatingSystemVersion pc_ElCapitanOperatingSystemVersion;
extern const NSOperatingSystemVersion pc_YosemiteOperatingSystemVersion;
extern const NSOperatingSystemVersion pc_SierraOperatingSystemVersion;

typedef NS_ENUM(NSInteger, CCBParticleType) {
    kCCBParticleTypeExplosion = 0,
    kCCBParticleTypeFire,
    kCCBParticleTypeFireworks,
    kCCBParticleTypeFlower,
    kCCBParticleTypeGalaxy,
    kCCBParticleTypeMeteor,
    kCCBParticleTypeRain,
    kCCBParticleTypeSmoke,
    kCCBParticleTypeSnow,
    kCCBParticleTypeSpiral,
    kCCBParticleTypeSun
};

typedef NS_ENUM(NSInteger, CCBTransformHandle) {
    kCCBTransformHandleNone = 0,
    kCCBTransformHandleDownInside,
    kCCBTransformHandleMove,
    kCCBTransformHandleScale,
    kCCBTransformHandleRotate,
    kCCBTransformHandleAnchorPoint,
    kCCBTransformHandleContentSize,
    kCCBTransformHandleContentSizeX,
    kCCBTransformHandleContentSizeY,
    kCCBTransformHandleScaleX,
    kCCBTransformHandleScaleY
};

typedef NS_ENUM(NSInteger, CCBTool) {
    kCCBToolAnchor      =(1 << 0),
    kCCBToolScale       =(1 << 1),
    kCCBToolGrab        =(1 << 2),
    kCCBToolRotate      =(1 << 3),
    kCCBToolTranslate   =(1 << 4),
    kCCBToolSelection   =(1 << 5),
    kCCBToolMax         =(1 << 6)
};

typedef NS_ENUM(NSUInteger, CCBCornerId) {
    kCCBCornerIdBottomLeft = 0,
    kCCBCornerIdBottomRight = 1,
    kCCBCornerIdTopRight = 2,
    kCCBCornerIdTopLeft = 3,
    kCCBEdgeBottom = 4,
    kCCBEdgeRight = 5,
    kCCBEdgeTop = 6,
    kCCBEdgeLeft = 7
};

typedef NS_ENUM(NSInteger, PCCanvasSize) {
    PCCanvasSizeCustom = 0,
    PCCanvasSizeIPhoneLandscape,
    PCCanvasSizeIPhonePortrait,
    PCCanvasSizeIPhone5Landscape,
    PCCanvasSizeIPhone5Portrait,
    PCCanvasSizeIPadLandscape,
    PCCanvasSizeIPadPortrait,
    PCCanvasSizeFixedLandscape,
    PCCanvasSizeFixedPortrait,
    PCCanvasSizeAndroidXSmallLandscape,
    PCCanvasSizeAndroidXSmallPortrait,
    PCCanvasSizeAndroidSmallLandscape,
    PCCanvasSizeAndroidSmallPortrait,
    PCCanvasSizeAndroidMediumLandscape,
    PCCanvasSizeAndroidMediumPortrait,
    PCCanvasSizeCount
};



enum {
    kCCBArrangeBringToFront,
    kCCBArrangeBringForward,
    kCCBArrangeSendBackward,
    kCCBArrangeSendToBack,
};

enum {
    kCCBDocDimensionsTypeFullScreen,
    kCCBDocDimensionsTypeNode,
    kCCBDocDimensionsTypeLayer,
};

typedef NS_ENUM(NSUInteger, PCProjectTabTag) {
    PCProjectTabTagSlides = 0,
    PCProjectTabTagMedia,
    PCProjectTabTagSupplies,
    PCProjectTabTagWarnings,
};

typedef NS_ENUM(NSUInteger, PCInspectorTabTag) {
    PCInspectorTabTagItemProperties = 0,
    PCInspectorTabTagBehaviours,
    PCInspectorTabTagPhysics,
    PCInspectorTabTagTemplates,
};

/** Behaviours **/
FOUNDATION_EXPORT const CGFloat PCBehaviourListAnimationInterval;

FOUNDATION_EXPORT NSString * const PCTokenHighlightSourceChangeNotification;
FOUNDATION_EXPORT NSString * const PCTokenHighlightSourceUUIDKey;
FOUNDATION_EXPORT NSString * const PCTokenHighlightSourceStateKey;

FOUNDATION_EXPORT NSString * const PCExposedTokenReplacedNotification;

typedef NS_ENUM(NSInteger, PCTokenType) {
    PCTokenTypeValue,
    PCTokenTypeVariable,
    PCTokenTypePredicate,
};

typedef NS_ENUM(NSInteger, PCTokenEvaluationType) {
    PCTokenEvaluationTypeUnknown = -1,
    PCTokenEvaluationTypeNumber = 0,
    PCTokenEvaluationTypeBOOL,
    PCTokenEvaluationTypeString,
    PCTokenEvaluationTypePoint,
    PCTokenEvaluationTypeSize,
    PCTokenEvaluationTypeVector,
    PCTokenEvaluationTypeColor,

    PCTokenEvaluationTypeCard,
    PCTokenEvaluationTypeNode,
    PCTokenEvaluationTypeProperty,
    PCTokenEvaluationTypeNodeType,
    PCTokenEvaluationTypeTexture,
    PCTokenEvaluationTypeTimeline,
    PCTokenEvaluationTypeBeacon,
    PCTokenEvaluationTypeTableCell,

    PCTokenEvaluationTypeKeyboardInput,

    PCTokenEvaluationTypeJavaScript,
    PCTokenEvaluationTypeScale,
    PCTokenEvaluationTypeTemplate,

    PCTokenEvaluationTypeImage,

    PCTokenEvaluationTypeRect,
    PCTokenEvaluationTypeCount // Always keep this at the end, it's for enumeration purposes
};

typedef NS_ENUM(NSInteger, PCNodeType) {
    PCNodeTypeUnknown = -1,
    PCNodeTypeNode = 0,
    PCNodeTypeLabel,
    PCNodeTypeTextView,
    PCNodeTypeTextField,
    PCNodeTypeTextInput,
    PCNodeTypeButton,
    PCNodeTypeShareButton,
    PCNodeTypeColor,
    PCNodeTypeImage,
    PCNodeTypeMultiView,
    PCNodeTypeMultiViewCell,
    PCNodeTypeFingerPaint,
    PCNodeTypeWebView,
    PCNodeTypeCameraNode,
    PCNodeTypeSlider,
    PCNodeTypeSwitch,
    PCNodeTypeTable,
    PCNodeTypeParticle,
    PCNodeTypeShape,
    PCNodeTypeScrollView,
    PCNodeTypeVideo,
    PCNodeType3D,
    PCNodeTypeForce,
    PCNodeTypeGradient,
    PCNodeTypeCard,
    PCNodeTypeScrollContent,
};

typedef NS_ENUM(NSInteger, PCPropertyType) {
    PCPropertyTypeNotSupported = -1,
    PCPropertyTypeInteger = 0,
    PCPropertyTypeFloat,
    PCPropertyTypeString,
    PCPropertyTypePoint,
    PCPropertyTypeVector,
    PCPropertyTypeSize,
    PCPropertyTypeTexture,
    PCPropertyTypeColor,
    PCPropertyTypeBool,
    PCPropertyTypeKeyboardInput,
    PCPropertyTypeJavaScript,
    PCPropertyTypeScale,
    PCPropertyTypeImage,
    PCPropertyTypeNode
};

typedef NS_ENUM(NSUInteger, PCKeyValueStoreKeyType) {
    PCKeyValueStoreKeyTypeNone = 0,
    PCKeyValueStoreKeyTypeNumber,
    PCKeyValueStoreKeyTypeBool,
    PCKeyValueStoreKeyTypeString,
    PCKeyValueStoreKeyTypePoint,
    PCKeyValueStoreKeyTypeSize,
    PCKeyValueStoreKeyTypeVector,
    PCKeyValueStoreKeyTypeColor,
    PCKeyValueStoreKeyTypeTexture,
    PCKeyValueStoreKeyTypeScale
};

typedef NS_ENUM(NSUInteger, PCPublisherTargetType) {
    PCPublisherTargetTypeHTML5,
    PCPublisherTargetTypeIPhone,
    PCPublisherTargetTypeAndroid,
};

static inline BOOL CCBCornerIdIsOnRightSide(CCBCornerId cornerIndex) {
    return cornerIndex == kCCBCornerIdBottomRight || cornerIndex == kCCBCornerIdTopRight || cornerIndex == kCCBEdgeRight;
}

static inline BOOL CCBCornerIdIsOnLeftSide(CCBCornerId cornerIndex) {
    return cornerIndex == kCCBCornerIdBottomLeft || cornerIndex == kCCBCornerIdTopLeft || cornerIndex == kCCBEdgeLeft;
}

static inline BOOL CCBCornerIdIsOnBottomSide(CCBCornerId cornerIndex) {
    return cornerIndex == kCCBCornerIdBottomLeft || cornerIndex == kCCBCornerIdBottomRight || cornerIndex == kCCBEdgeBottom;
}

static inline BOOL CCBCornerIdIsOnTopSide(CCBCornerId cornerIndex) {
    return cornerIndex == kCCBCornerIdTopLeft || cornerIndex == kCCBCornerIdTopRight || cornerIndex == kCCBEdgeTop;
}

static inline BOOL CCBCornerIdIsOnCorner(CCBCornerId cornerIndex) {
    return cornerIndex >= kCCBCornerIdBottomLeft && cornerIndex <= kCCBCornerIdTopLeft;
}

static inline BOOL CCBCornerIdIsHorizontalEdge(CCBCornerId cornerIndex) {
    return cornerIndex == kCCBEdgeLeft || cornerIndex == kCCBEdgeRight;
}

static inline BOOL CCBCornerIdIsVerticalEdge(CCBCornerId cornerIndex) {
    return cornerIndex == kCCBEdgeBottom || cornerIndex == kCCBEdgeTop;
}

CCBCornerId CCBOppositeHorizontalCorner(CCBCornerId cornerIndex);

CCBCornerId CCBOppositeVerticalCorner(CCBCornerId cornerIndex);

@interface Constants : NSObject

+ (NSArray *)allNodeTypes;

+ (NSArray *)userFacingNodeTypes;

/*
 * Nodes that a user should be able to create with a behaviour. Content nodes (images, video, etc.) shouldn't be in this list, but anything that can be created without initial content should be okay.
 */
+ (NSArray *)userCreatableNodeTypes;

+ (PCPropertyType)propertyTypeFromEvaluationType:(PCTokenEvaluationType)evaluationType;
+ (PCTokenEvaluationType)evaluationTypeFromPropertyType:(PCPropertyType)propertyType;
+ (NSString *)stringFromEvaluationType:(PCTokenEvaluationType)evaluationType;
+ (NSString *)ternTypeNameFromEvaluationType:(PCTokenEvaluationType)evaluationType;
+ (PCTokenEvaluationType)evaluationTypeFromTernTypeName:(NSString *)typeName;

+ (PCTokenEvaluationType)tokenEvaluationTypeForKeyType:(PCKeyValueStoreKeyType)keyType;
+ (PCPropertyType)propertyTypeForKeyType:(PCKeyValueStoreKeyType)keyType;
+ (NSArray *)userSelectableKeyTypes;
+ (NSString *)stringForKeyType:(PCKeyValueStoreKeyType)keyType;

/**
 * Evaluation types that correspond to JavaScript Object types representing structs of numbers
 */
+ (NSArray *)javaScriptObjectEvaluationTypes;
+ (NSSet *)propertiesForJavaScriptObjectEvaluationType:(PCTokenEvaluationType)type;

+ (NSArray *)unsupportedExpressionTernTypes;
+ (NSArray *)supportedExpressionTernTypes;

/**
 * Sometimes Tern needs the type of an object specified as its prototype (i.e. "BaseObject.prototype" instead of "BaseObject") in order to properly lookup properties.
 */
+ (NSArray *)ternTypeNamesRequiringPrototype;

@end
