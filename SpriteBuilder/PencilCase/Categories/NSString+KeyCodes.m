//
//  NSString+KeyCodes.m
//  
//
//  Created by Orest Nazarewycz on 2014-09-26.
//
//

#import "NSString+KeyCodes.h"

@implementation NSString (KeyCodes)

+ (NSString *)pc_stringForKeyCode:(NSInteger)keyCode {
    switch (keyCode) {
        case 0: return(@"a");
        case 1: return(@"s");
        case 2: return(@"d");
        case 3: return(@"f");
        case 4: return(@"h");
        case 5: return(@"g");
        case 6: return(@"z");
        case 7: return(@"x");
        case 8: return(@"c");
        case 9: return(@"v");
        case 11: return(@"b");
        case 12: return(@"q");
        case 13: return(@"w");
        case 14: return(@"e");
        case 15: return(@"r");
        case 16: return(@"y");
        case 17: return(@"t");
        case 18: return(@"1");
        case 19: return(@"2");
        case 20: return(@"3");
        case 21: return(@"4");
        case 22: return(@"6");
        case 23: return(@"5");
        case 24: return(@"=");
        case 25: return(@"9");
        case 26: return(@"7");
        case 27: return(@"-");
        case 28: return(@"8");
        case 29: return(@"0");
        case 30: return(@"]");
        case 31: return(@"o");
        case 32: return(@"u");
        case 33: return(@"[");
        case 34: return(@"i");
        case 35: return(@"p");
        case 36: return(@"RETURN");
        case 37: return(@"l");
        case 38: return(@"j");
        case 39: return(@"'");
        case 40: return(@"k");
        case 41: return(@";");
        case 42: return(@"\\");
        case 43: return(@",");
        case 44: return(@"/");
        case 45: return(@"n");
        case 46: return(@"m");
        case 47: return(@".");
        case 48: return(@"TAB");
        case 49: return(@"SPACE");
        case 50: return(@"`");
        case 51: return(@"DELETE");
        case 52: return(@"ENTER");
        case 53: return(@"ESCAPE");
        case 65: return(@".");
        case 67: return(@"*");
        case 69: return(@"+");
        case 71: return(@"CLEAR");
        case 75: return(@"/");
        case 76: return(@"ENTER");   // numberpad on full kbd
        case 78: return(@"-");
        case 81: return(@"=");
        case 82: return(@"0");
        case 83: return(@"1");
        case 84: return(@"2");
        case 85: return(@"3");
        case 86: return(@"4");
        case 87: return(@"5");
        case 88: return(@"6");
        case 89: return(@"7");
        case 91: return(@"8");
        case 92: return(@"9");
        case 96: return(@"F5");
        case 97: return(@"F6");
        case 98: return(@"F7");
        case 99: return(@"F3");
        case 100: return(@"F8");
        case 101: return(@"F9");
        case 103: return(@"F11");
        case 105: return(@"F13");
        case 107: return(@"F14");
        case 109: return(@"F10");
        case 111: return(@"F12");
        case 113: return(@"F15");
        case 114: return(@"HELP");
        case 115: return(@"HOME");
        case 116: return(@"PGUP");
        case 117: return(@"DELETE");  // full keyboard right side numberpad
        case 118: return(@"F4");
        case 119: return(@"END");
        case 120: return(@"F2");
        case 121: return(@"PGDN");
        case 122: return(@"F1");
        case 123: return(@"UIKeyInputLeftArrow");
        case 124: return(@"UIKeyInputRightArrow");
        case 125: return(@"UIKeyInputDownArrow");
        case 126: return(@"UIKeyInputUpArrow");
        default:
            return @"";
    }
}

@end
