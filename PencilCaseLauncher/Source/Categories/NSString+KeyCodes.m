//
//  NSString+KeyCodes.m
//  
//
//  Created by Orest Nazarewycz on 2014-09-26.
//
//

#import "NSString+KeyCodes.h"

@implementation NSString (KeyCodes)

+ (NSDictionary *)keyCodeToStringMap {
    static NSDictionary *keyCodeToStringMap;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // From HIToolbox/Events.h
        keyCodeToStringMap = @{
            @0: @"a",
            @1: @"s",
            @2: @"d",
            @3: @"f",
            @4: @"h",
            @5: @"g",
            @6: @"z",
            @7: @"x",
            @8: @"c",
            @9: @"v",
            @11: @"b",
            @12: @"q",
            @13: @"w",
            @14: @"e",
            @15: @"r",
            @16: @"y",
            @17: @"t",
            @18: @"1",
            @19: @"2",
            @20: @"3",
            @21: @"4",
            @22: @"6",
            @23: @"5",
            @24: @"=",
            @25: @"9",
            @26: @"7",
            @27: @"-",
            @28: @"8",
            @29: @"0",
            @30: @"]",
            @31: @"o",
            @32: @"u",
            @33: @"[",
            @34: @"i",
            @35: @"p",
            @36: @"RETURN",
            @37: @"l",
            @38: @"j",
            @39: @"'",
            @40: @"k",
            @41: @";",
            @42: @"\\",
            @43: @",",
            @44: @"/",
            @45: @"n",
            @46: @"m",
            @47: @".",
            @48: @"TAB",
            @49: @"SPACE",
            @50: @"`",
            @51: @"DELETE",
            @52: @"ENTER",
            @53: @"ESCAPE",
            @65: @".",
            @67: @"*",
            @69: @"+",
            @71: @"CLEAR",
            @75: @"/",
            @76: @"ENTER",   // numberpad on full keyboard
            @78: @"-",
            @81: @"=",
            @82: @"0",
            @83: @"1",
            @84: @"2",
            @85: @"3",
            @86: @"4",
            @87: @"5",
            @88: @"6",
            @89: @"7",
            @91: @"8",
            @92: @"9",
            @96: @"F5",
            @97: @"F6",
            @98: @"F7",
            @99: @"F3",
            @100: @"F8",
            @101: @"F9",
            @103: @"F11",
            @105: @"F13",
            @107: @"F14",
            @109: @"F10",
            @111: @"F12",
            @113: @"F15",
            @114: @"HELP",
            @115: @"HOME",
            @116: @"PGUP",
            @117: @"DELETE",  // full keyboard right side numberpad
            @118: @"F4",
            @119: @"END",
            @120: @"F2",
            @121: @"PGDN",
            @122: @"F1",
            @123: @"UIKeyInputLeftArrow",
            @124: @"UIKeyInputRightArrow",
            @125: @"UIKeyInputDownArrow",
            @126: @"UIKeyInputUpArrow"
        };
    });
    return keyCodeToStringMap;
}

+ (NSString *)pc_stringForKeyCode:(NSInteger)keyCode {
    return [self keyCodeToStringMap][@(keyCode)] ?: @"";
}

+ (NSInteger)pc_keyCodeForString:(NSString *)keyString {
    return [[[self keyCodeToStringMap] allKeysForObject:keyString].firstObject integerValue] ?: 0;
}

@end
