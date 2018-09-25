//
//  Constants.m
//  SpriteBuilder
//
//  Created by Brendan Duddridge on 2014-03-13.
//
//

// Pasteboard Types

#import "Constants.h"

NSString *const PCPasteboardTypeFont = @"com.robotsandpencils.pencilcase.font";
NSString *const PCPasteboardTypeShape = @"com.robotsandpencils.pencilcase.shape";
NSString *const PCPasteboardTypeParticleTemplate = @"com.robotsandpencils.pencilcase.particleTemplate";
NSString *const PCPasteboardTypeNode = @"com.cocosbuilder.node";
NSString *const PCPasteboardTypeTexture = @"com.cocosbuilder.texture";
NSString *const PCPasteboardTypeTemplate = @"com.cocosbuilder.template";
NSString *const PCPasteboardTypeCCB = @"com.cocosbuilder.ccb";
NSString *const PCPasteboardTypePluginNode = @"com.cocosbuilder.PlugInNode";
NSString *const PCPasteboardTypeWAV = @"com.cocosbuilder.wav";
NSString *const PCPasteboardTypeMOV = @"com.cocosbuilder.mov";
NSString *const PCPasteboardType3DModel = @"com.cocosbuilder.dae";
NSString *const PCPasteboardTypeResource = @"com.cocosbuilder.PCResource";
NSString *const PCPasteboardTypeBehavioursWhen = @"com.cocosbuilder.BehavioursWhen";
NSString *const PCPasteboardTypeBehavioursThen = @"com.cocosbuilder.BehavioursThen";

NSString *const PCDroppedFileNotification = @"PCDroppedFileNotification";

CGFloat const PCMinimumContentSize = 1;

NSInteger const PCJavaScriptNumberMax = 9007199254740992;

NSString * const MixedStateDidChangeNotification = @"MixedStateDidChangeNotification";
NSString * const UpdateNodeManagerPropertiesNotification = @"UpdateNodeManagerPropertiesNotification";
NSString * const ReloadObjectHierarchyNotification = @"ReloadObjectHierarchyNotification";

// Version numbers: See header for notes
NSInteger const PCPublishedFileFormatVersion = 15;
NSInteger const PCMakerFileFormatVersion = 19;
NSInteger const PCMakerFileFormatVersionRequiringJSRepublish = 17;

NSString * const PCCreationExtension = @"creation";

#pragma mark - Notifications

NSString *const PCCreateNewProjectNotification = @"PCCreateNewProjectNotification";
NSString *const PCCancelCreatingNewProjectNotification = @"PCCancelCreatingNewProjectNotification";
NSString *const PCCloseSplashWindowNotification = @"PCCloseSplashWindowNotification";
NSString *const PCProjectFailedToOpenNotification = @"PCProjectFailedToOpenNotification";
NSString *const PCProjectOpenedNotification = @"PCProjectOpenedNotification;";
NSString *const PCNodeDeletedNotification = @"PCNodeDeletedNotification";
NSString *const PCTableCellsChangedNotification = @"PCTableCellsChangedNotification";
NSString *const PCKeyValueStoreKeyConfigChangedNotification = @"PCKeyValueStoreKeyConfigChangedNotification";

NSString *const PCSaveNewProjectNotification = @"PCSaveNewProjectNotification";
// userInfo keys:
NSString *const PCProjectDeviceTargetTypeKey = @"deviceTargetType";
NSString *const PCProjectDeviceTargetOrientationKey = @"deviceTargetOrientation";

NSString *const PCOpenProjectNotification = @"PCOpenProjectNotification";
// userInfo keys:
NSString *const PCOpenProjectURLKey = @"url";

NSString *const PCShowOpenFilePanelNotification = @"PCShowOpenFilePanelNotification";

// Behaviours
const CGFloat PCBehaviourListAnimationInterval = .2;

NSString * const PCTokenHighlightSourceChangeNotification = @"PCTokenHighlightSourceChangeNotification";
NSString * const PCTokenHighlightSourceUUIDKey = @"PCTokenHighlightSourceUUIDKey";
NSString * const PCTokenHighlightSourceStateKey = @"PCTokenHighlightSourceStateKey";
NSString * const PCExposedTokenReplacedNotification = @"PCExposedTokenReplacedNotification";

// Properties Names
NSString *const PCPropertyNameGravity = @"Gravity";

NSString *const PCTernTypeNameBool = @"bool";
NSString *const PCTernTypeNameString = @"string";
NSString *const PCTernTypeNameColor = @"Color";
NSString *const PCTernTypeNamePoint = @"Point";
NSString *const PCTernTypeNameScale = @"Scale";
NSString *const PCTernTypeNameSize = @"Size";
NSString *const PCTernTypeNameTexture = @"Texture";
NSString *const PCTernTypeNameVector = @"Vector";
NSString *const PCTernTypeNameTimeline = @"Timeline";
NSString *const PCTernTypeNameTemplate = @"Template";
NSString *const PCTernTypeNameTableCell = @"Cell";
NSString *const PCTernTypeNameNode = @"BaseObject";
NSString *const PCTernTypeNameCard = @"Card";
NSString *const PCTernTypeNameBeacon = @"Beacon";
NSString *const PCTernTypeNameNumber = @"number";
NSString *const PCTernTypeNameUnknown = @"Object";
NSString *const PCTernTypeNameRectangle = @"Rectangle";
NSString *const PCTernTypeNameUndefined = @"undefined";
NSString *const PCTernTypeNameNull = @"null";
NSString *const PCTernTypeNameArray = @"Array";
NSString *const PCTernTypeNameDate = @"Date";

const NSOperatingSystemVersion pc_SierraOperatingSystemVersion = { 10, 12, 0 };
const NSOperatingSystemVersion pc_ElCapitanOperatingSystemVersion = { 10, 11, 0 };
const NSOperatingSystemVersion pc_YosemiteOperatingSystemVersion = { 10, 10, 0 };

// Corners
CCBCornerId CCBOppositeHorizontalCorner(CCBCornerId cornerIndex) {
    switch (cornerIndex) {
        case kCCBEdgeLeft:
            return kCCBEdgeRight;
        case kCCBEdgeRight:
            return kCCBEdgeLeft;
        case kCCBCornerIdBottomLeft:
            return kCCBCornerIdBottomRight;
        case kCCBCornerIdBottomRight:
            return kCCBCornerIdBottomLeft;
        case kCCBCornerIdTopLeft:
            return kCCBCornerIdTopRight;
        case kCCBCornerIdTopRight:
            return kCCBCornerIdTopLeft;
        default:
            return cornerIndex;
    }
}

CCBCornerId CCBOppositeVerticalCorner(CCBCornerId cornerIndex) {
    switch (cornerIndex) {
        case kCCBEdgeTop:
            return kCCBEdgeBottom;
        case kCCBEdgeBottom:
            return kCCBEdgeTop;
        case kCCBCornerIdBottomLeft:
            return kCCBCornerIdTopLeft;
        case kCCBCornerIdTopLeft:
            return kCCBCornerIdBottomLeft;
        case kCCBCornerIdTopRight:
            return kCCBCornerIdBottomRight;
        case kCCBCornerIdBottomRight:
            return kCCBCornerIdTopRight;
        default:
            return cornerIndex;
    }
}

@implementation Constants

#pragma mark - Node Types

+ (NSArray *)allNodeTypes {
    return @[
             @(PCNodeTypeNode),
             @(PCNodeTypeLabel),
             @(PCNodeTypeTextView),
             @(PCNodeTypeTextField),
             @(PCNodeTypeTextInput),
             @(PCNodeTypeButton),
             @(PCNodeTypeShareButton),
             @(PCNodeTypeColor),
             @(PCNodeTypeImage),
             @(PCNodeTypeMultiView),
             @(PCNodeTypeMultiViewCell),
             @(PCNodeTypeFingerPaint),
             @(PCNodeTypeWebView),
             @(PCNodeTypeCameraNode),
             @(PCNodeTypeSlider),
             @(PCNodeTypeSwitch),
             @(PCNodeTypeTable),
             @(PCNodeTypeParticle),
             @(PCNodeTypeShape),
             @(PCNodeTypeScrollView),
             @(PCNodeTypeVideo),
             @(PCNodeType3D),
             @(PCNodeTypeForce),
             @(PCNodeTypeGradient),
             @(PCNodeTypeCard),
             @(PCNodeTypeScrollContent),
             ];
}

+ (NSArray *)userFacingNodeTypes {
    return @[
             @(PCNodeTypeLabel),
             @(PCNodeTypeTextView),
             @(PCNodeTypeTextField),
             @(PCNodeTypeTextInput),
             @(PCNodeTypeButton),
             @(PCNodeTypeShareButton),
             @(PCNodeTypeColor),
             @(PCNodeTypeImage),
             @(PCNodeTypeMultiView),
             @(PCNodeTypeFingerPaint),
             @(PCNodeTypeWebView),
             @(PCNodeTypeCameraNode),
             @(PCNodeTypeSlider),
             @(PCNodeTypeSwitch),
             @(PCNodeTypeTable),
             @(PCNodeTypeParticle),
             @(PCNodeTypeShape),
             @(PCNodeTypeScrollView),
             @(PCNodeTypeVideo),
             @(PCNodeType3D),
             @(PCNodeTypeForce),
             @(PCNodeTypeGradient),
             @(PCNodeTypeCard),
             @(PCNodeTypeScrollContent)
             ];
}

+ (NSArray *)userCreatableNodeTypes {
    return @[
             @(PCNodeTypeLabel),
             @(PCNodeTypeColor),
             @(PCNodeTypeFingerPaint),
             @(PCNodeTypeCameraNode),
             @(PCNodeTypeSlider),
             @(PCNodeTypeSwitch),
             @(PCNodeTypeGradient)
             ];
}

#pragma mark - Token transforms

+ (PCPropertyType)propertyTypeFromEvaluationType:(PCTokenEvaluationType)evaluationType {
    switch (evaluationType) {
        case PCTokenEvaluationTypeBOOL:
            return PCPropertyTypeBool;
        case PCTokenEvaluationTypeString:
            return PCPropertyTypeString;
        case PCTokenEvaluationTypeColor:
            return PCPropertyTypeColor;
        case PCTokenEvaluationTypeImage:
            return PCPropertyTypeImage;
        case PCTokenEvaluationTypeJavaScript:
            return PCPropertyTypeJavaScript;
        case PCTokenEvaluationTypeKeyboardInput:
            return PCPropertyTypeKeyboardInput;
        case PCTokenEvaluationTypePoint:
            return PCPropertyTypePoint;
        case PCTokenEvaluationTypeScale:
            return PCPropertyTypeScale;
        case PCTokenEvaluationTypeSize:
            return PCPropertyTypeSize;
        case PCTokenEvaluationTypeTexture:
            return PCPropertyTypeTexture;
        case PCTokenEvaluationTypeVector:
            return PCPropertyTypeVector;

        case PCTokenEvaluationTypeTimeline:
        case PCTokenEvaluationTypeTemplate:
        case PCTokenEvaluationTypeTableCell:
        case PCTokenEvaluationTypeProperty:
        case PCTokenEvaluationTypeNodeType:
        case PCTokenEvaluationTypeNode:
        case PCTokenEvaluationTypeCard:
        case PCTokenEvaluationTypeBeacon:
        case PCTokenEvaluationTypeNumber:
        case PCTokenEvaluationTypeUnknown:
        default:
            return PCPropertyTypeNotSupported;
    }
}

+ (PCTokenEvaluationType)evaluationTypeFromPropertyType:(PCPropertyType)propertyType {
    switch (propertyType) {
        case PCPropertyTypeBool:
            return PCTokenEvaluationTypeBOOL;
        case PCPropertyTypeColor:
            return PCTokenEvaluationTypeColor;
        case PCPropertyTypeFloat:
        case PCPropertyTypeInteger:
            return PCTokenEvaluationTypeNumber; //A little ugly because it does not translate back unfortunately
        case PCPropertyTypeImage:
            return PCTokenEvaluationTypeImage;
        case PCPropertyTypeJavaScript:
            return PCTokenEvaluationTypeJavaScript;
        case PCPropertyTypeKeyboardInput:
            return PCTokenEvaluationTypeKeyboardInput;
        case PCPropertyTypePoint:
            return PCTokenEvaluationTypePoint;
        case PCPropertyTypeScale:
            return PCTokenEvaluationTypeScale;
        case PCPropertyTypeSize:
            return PCTokenEvaluationTypeSize;
        case PCPropertyTypeString:
            return PCTokenEvaluationTypeString;
        case PCPropertyTypeTexture:
            return PCTokenEvaluationTypeTexture;
        case PCPropertyTypeVector:
            return PCTokenEvaluationTypeVector;
        case PCPropertyTypeNode:
            return PCTokenEvaluationTypeNode;
        case PCPropertyTypeNotSupported:
            return PCTokenEvaluationTypeUnknown;
    }
    return PCTokenEvaluationTypeUnknown;
}

+ (NSString *)stringFromEvaluationType:(PCTokenEvaluationType)evaluationType {
    switch (evaluationType) {
        case PCTokenEvaluationTypeBOOL:
            return @"Boolean";
        case PCTokenEvaluationTypeString:
            return @"String";
        case PCTokenEvaluationTypeColor:
            return @"Color";
        case PCTokenEvaluationTypeImage:
            return @"Image";
        case PCTokenEvaluationTypeJavaScript:
            return @"JavaScript";
        case PCTokenEvaluationTypeKeyboardInput:
            return @"Keyboard Input";
        case PCTokenEvaluationTypePoint:
            return @"Point";
        case PCTokenEvaluationTypeScale:
            return @"Scale";
        case PCTokenEvaluationTypeSize:
            return @"Size";
        case PCTokenEvaluationTypeTexture:
            return @"Texture";
        case PCTokenEvaluationTypeVector:
            return @"Vector";
        case PCTokenEvaluationTypeTimeline:
            return @"Timeline";
        case PCTokenEvaluationTypeTemplate:
            return @"Template";
        case PCTokenEvaluationTypeTableCell:
            return @"Cell";
        case PCTokenEvaluationTypeProperty:
            return @"Property";
        case PCTokenEvaluationTypeNodeType:
            return @"Node Type";
        case PCTokenEvaluationTypeNode:
            return @"Node";
        case PCTokenEvaluationTypeCard:
            return @"Card";
        case PCTokenEvaluationTypeBeacon:
            return @"Beacon";
        case PCTokenEvaluationTypeNumber:
            return @"Number";
        case PCTokenEvaluationTypeUnknown:
            return @"Unknown";
        default:
            return @"Not Supported";
    }
}

+ (NSString *)ternTypeNameFromEvaluationType:(PCTokenEvaluationType)evaluationType {
    switch (evaluationType) {
        case PCTokenEvaluationTypeBOOL:
            return PCTernTypeNameBool;
        case PCTokenEvaluationTypeString:
            return PCTernTypeNameString;
        case PCTokenEvaluationTypeColor:
            return PCTernTypeNameColor;
        case PCTokenEvaluationTypePoint:
            return PCTernTypeNamePoint;
        case PCTokenEvaluationTypeScale:
            return PCTernTypeNameScale;
        case PCTokenEvaluationTypeSize:
            return PCTernTypeNameSize;
        case PCTokenEvaluationTypeTexture:
            return PCTernTypeNameTexture;
        case PCTokenEvaluationTypeVector:
            return PCTernTypeNameVector;
        case PCTokenEvaluationTypeTimeline:
            return PCTernTypeNameTimeline;
        case PCTokenEvaluationTypeTemplate:
            return PCTernTypeNameTemplate;
        case PCTokenEvaluationTypeTableCell:
            return PCTernTypeNameTableCell;
        case PCTokenEvaluationTypeNode:
            return PCTernTypeNameNode;
        case PCTokenEvaluationTypeCard:
            return PCTernTypeNameCard;
        case PCTokenEvaluationTypeBeacon:
            return PCTernTypeNameBeacon;
        case PCTokenEvaluationTypeNumber:
            return PCTernTypeNameNumber;
        case PCTokenEvaluationTypeUnknown:
            return PCTernTypeNameUnknown;
        case PCTokenEvaluationTypeRect:
            return PCTernTypeNameRectangle;
        default:
            return PCTernTypeNameUndefined;
    }
}

+ (PCTokenEvaluationType)evaluationTypeFromTernTypeName:(NSString *)typeName {
    if ([typeName isEqualToString:PCTernTypeNameBool]) {
        return PCTokenEvaluationTypeBOOL;
    }
    else if ([typeName isEqualToString:PCTernTypeNameString]) {
        return PCTokenEvaluationTypeString;
    }
    else if ([typeName isEqualToString:PCTernTypeNameColor]) {
        return PCTokenEvaluationTypeColor;
    }
    else if ([typeName isEqualToString:PCTernTypeNamePoint]) {
        return PCTokenEvaluationTypePoint;
    }
    else if ([typeName isEqualToString:PCTernTypeNameScale]) {
        return PCTokenEvaluationTypeScale;
    }
    else if ([typeName isEqualToString:PCTernTypeNameSize]) {
        return PCTokenEvaluationTypeSize;
    }
    else if ([typeName isEqualToString:PCTernTypeNameTexture]) {
        return PCTokenEvaluationTypeTexture;
    }
    else if ([typeName isEqualToString:PCTernTypeNameVector]) {
        return PCTokenEvaluationTypeVector;
    }
    else if ([typeName isEqualToString:PCTernTypeNameTimeline]) {
        return PCTokenEvaluationTypeTimeline;
    }
    else if ([typeName isEqualToString:PCTernTypeNameTemplate]) {
        return PCTokenEvaluationTypeTemplate;
    }
    else if ([typeName isEqualToString:PCTernTypeNameTableCell]) {
        return PCTokenEvaluationTypeTableCell;
    }
    else if ([typeName isEqualToString:PCTernTypeNameNode]) {
        return PCTokenEvaluationTypeNode;
    }
    else if ([typeName isEqualToString:PCTernTypeNameCard]) {
        return PCTokenEvaluationTypeCard;
    }
    else if ([typeName isEqualToString:PCTernTypeNameBeacon]) {
        return PCTokenEvaluationTypeBeacon;
    }
    else if ([typeName isEqualToString:PCTernTypeNameNumber]) {
        return PCTokenEvaluationTypeNumber;
    }
    else if ([typeName isEqualToString:PCTernTypeNameUnknown]) {
        return PCTokenEvaluationTypeUnknown;
    }
    else if ([typeName isEqualToString:PCTernTypeNameRectangle]) {
        return PCTokenEvaluationTypeRect;
    }
    return PCTokenEvaluationTypeUnknown;
}

+ (PCTokenEvaluationType)tokenEvaluationTypeForKeyType:(PCKeyValueStoreKeyType)keyType {
    switch (keyType) {
        case PCKeyValueStoreKeyTypeNone: return PCTokenEvaluationTypeUnknown;
        case PCKeyValueStoreKeyTypeNumber: return PCTokenEvaluationTypeNumber;
        case PCKeyValueStoreKeyTypeBool: return PCTokenEvaluationTypeBOOL;
        case PCKeyValueStoreKeyTypeString: return PCTokenEvaluationTypeString;
        case PCKeyValueStoreKeyTypePoint: return PCTokenEvaluationTypePoint;
        case PCKeyValueStoreKeyTypeSize: return PCTokenEvaluationTypeSize;
        case PCKeyValueStoreKeyTypeVector: return PCTokenEvaluationTypeVector;
        case PCKeyValueStoreKeyTypeColor: return PCTokenEvaluationTypeColor;
        case PCKeyValueStoreKeyTypeTexture: return PCTokenEvaluationTypeTexture;
        case PCKeyValueStoreKeyTypeScale: return PCTokenEvaluationTypeScale;
    }
    return PCTokenEvaluationTypeUnknown;
}

+ (PCPropertyType)propertyTypeForKeyType:(PCKeyValueStoreKeyType)keyType {
    switch (keyType) {
        case PCKeyValueStoreKeyTypeNone: return PCPropertyTypeNotSupported;
        case PCKeyValueStoreKeyTypeNumber: return PCPropertyTypeFloat;
        case PCKeyValueStoreKeyTypeBool: return PCPropertyTypeBool;
        case PCKeyValueStoreKeyTypeString: return PCPropertyTypeString;
        case PCKeyValueStoreKeyTypePoint: return PCPropertyTypePoint;
        case PCKeyValueStoreKeyTypeSize: return PCPropertyTypeSize;
        case PCKeyValueStoreKeyTypeVector: return PCPropertyTypeVector;
        case PCKeyValueStoreKeyTypeColor: return PCPropertyTypeColor;
        case PCKeyValueStoreKeyTypeTexture: return PCPropertyTypeTexture;
        case PCKeyValueStoreKeyTypeScale: return PCPropertyTypeScale;
    }
    return PCPropertyTypeNotSupported;
}

+ (NSArray *)userSelectableKeyTypes {
    return @[
        @(PCKeyValueStoreKeyTypeNumber),
        @(PCKeyValueStoreKeyTypeBool),
        @(PCKeyValueStoreKeyTypeString),
        @(PCKeyValueStoreKeyTypePoint),
        @(PCKeyValueStoreKeyTypeSize),
        @(PCKeyValueStoreKeyTypeVector),
        @(PCKeyValueStoreKeyTypeColor),
        @(PCKeyValueStoreKeyTypeTexture),
        @(PCKeyValueStoreKeyTypeScale)
    ];
}

+ (NSString *)stringForKeyType:(PCKeyValueStoreKeyType)keyType {
    switch (keyType) {
        case PCKeyValueStoreKeyTypeNone: return @"None";
        case PCKeyValueStoreKeyTypeNumber: return @"Number";
        case PCKeyValueStoreKeyTypeBool: return @"Boolean";
        case PCKeyValueStoreKeyTypeString: return @"Text";
        case PCKeyValueStoreKeyTypePoint: return @"Point";
        case PCKeyValueStoreKeyTypeSize: return @"Size";
        case PCKeyValueStoreKeyTypeVector: return @"Vector";
        case PCKeyValueStoreKeyTypeColor: return @"Color";
        case PCKeyValueStoreKeyTypeTexture: return @"Image";
        case PCKeyValueStoreKeyTypeScale: return @"Scale";
    }
    return @"None";
}

+ (NSArray *)javaScriptObjectEvaluationTypes {
    return @[
        @(PCTokenEvaluationTypeSize),
        @(PCTokenEvaluationTypeVector),
        @(PCTokenEvaluationTypePoint),
        @(PCTokenEvaluationTypeRect),
        @(PCTokenEvaluationTypeScale)
    ];
}

+ (NSSet *)propertiesForJavaScriptObjectEvaluationType:(PCTokenEvaluationType)type {
    switch (type) {
        case PCTokenEvaluationTypePoint:
            return [NSSet setWithArray:@[ @"x", @"y" ]];
        case PCTokenEvaluationTypeSize:
            return [NSSet setWithArray:@[ @"width", @"height" ]];
        case PCTokenEvaluationTypeVector:
            return [NSSet setWithArray:@[ @"dx", @"dy" ]];
        case PCTokenEvaluationTypeScale:
            return [NSSet setWithArray:@[ @"x", @"y" ]];
        case PCTokenEvaluationTypeRect:
            return [NSSet setWithArray:@[ @"x", @"y", @"width", @"height" ]];
        default:
            return [NSSet set];
    }
}

+ (NSArray *)unsupportedExpressionTernTypes {
    return @[
        PCTernTypeNameUndefined,
        PCTernTypeNameNull,
        PCTernTypeNameArray,
        PCTernTypeNameDate
    ];
}

+ (NSArray *)supportedExpressionTernTypes {
    return @[
        PCTernTypeNameNumber,
        PCTernTypeNameBool,
        PCTernTypeNameString,
        PCTernTypeNamePoint,
        PCTernTypeNameSize,
        PCTernTypeNameVector,
        PCTernTypeNameColor,
        PCTernTypeNameNode,
        PCTernTypeNameTexture,
        PCTernTypeNameScale
    ];
}

+ (NSArray *)ternTypeNamesRequiringPrototype {
    return @[
        PCTernTypeNameNode,
        PCTernTypeNameCard
    ];
}

@end

