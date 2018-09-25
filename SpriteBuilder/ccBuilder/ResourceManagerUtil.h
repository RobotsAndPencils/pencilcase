/*
 * CocosBuilder: http://www.cocosbuilder.com
 *
 * Copyright (c) 2012 Zynga Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import <Foundation/Foundation.h>

#import "PCResourceManager.h"
#include "PCResource.h"

@class PCResource;


@interface ResourceManagerUtil : NSObject

+ (void)populateResourcePopup:(NSPopUpButton *)popup resourceType:(enum PCResourceType)resType allowSpriteFrames:(BOOL)allowSpriteFrames selectedFile:(NSString *)file target:(id)target;

/**
 *  Populates a popup button's menu with a list of supported fonts.
 *
 *  @param popupButton The popup button to populate. Any existing menu items will be removed.
 *  @param file        The name of the currently selected font
 *  @param target      The target for the menu item
 *  @param action      The action for the menu item. If NULL, the default value of selectedResource: will be used.
 */
+ (void)populatePopupButtonWithFonts:(NSPopUpButton *)popupButton selectedFontName:(NSString *)file target:(id)target action:(SEL)action;

+ (void)setTitle:(NSString *)str forPopup:(NSPopUpButton *)popup;

+ (void)setTitle:(NSString *)str forPopup:(NSPopUpButton *)popup forceMarker:(BOOL)forceMarker;

+ (NSImage *)iconForResource:(PCResource *)res;

/**
 Convenience method - given either a UUID string, finds the matching resource
 @param resourceIdentifier - desired resource's UUID string
 @returns The relative path of the resource if it exists or null if it does not.
 */
+ (NSString *)relativePathForResourceWithUUID:(NSString *)desiredResourceUUID;

/**
 @param relativePath A path in the form resources/filename.extension
 @returns The UUID of the resource that matches the path.
 */
+ (NSString *)uuidForResourceWithRelativePath:(NSString *)relativePath;

#pragma mark - Path Conversions (Absolute / Relative / Project)

/**
 Given an absolute (on file system) path, converts it to a path relative to the project
 @param path The absolute path that should be converted
 @returns This is a little confusing as the path it returns will be relative to _any_ active directory. If it is the same as an active directory, will return an empty string. If the path is not relative to the project at all, it will return nil.
 */
+ (NSString *)relativePathFromAbsolutePath:(NSString *)path;

/**
 Takes an absolute path and converts it to a string that should be safe to show to the user.
 @param the path to convert, as an absolute file path
 @returns the converted path
 */
+ (NSString *)userFacingPathFromAbsolutePath:(NSString *)path;

/**
 Given a path relative to the project directory, gets the absolute path to the original path inside the project.
 @param relativePath The path relative to the project.
 @returns The absolute path in the file system to the path inside the project. For example, if the project is at /File1.pcase, and the relativePath is /resources/image1.png, will return /File1.pcase/resources/image1.png
 */
+ (NSString *)projectPathFromRelativePath:(NSString *)relativePath;

/**
 Given an absolute path to a resource or directory contained inside the project bundle, returns the path to the resource relative to the project bundle.
 @param projectFilePath An absolute path to a directory or resource contained inside the project bundle
 @returns the path to the resource relative to the project bundle.
 */
+ (NSString *)relativePathFromPathInProject:(NSString *)projectPath;

/**
 Converts all keys in a dictionary from an absolute path contianed within the project to the relative version of that path in the project
 @param dictionary The dictionary to base the newly created dictionary off of
 @returns A dictionary with all keys replaced
 */
+ (NSDictionary *)convertDictionaryKeysFromProjectPathToRelativePath:(NSDictionary *)dictionary;

/**
 Converts all keys in a dictionary from a path relative to the project to the absolute version of that path in the project
 @param dictionary The dictionary to base the newly created dictionary off fo
 @returns A dictionary with all keys replaced
 */
+ (NSDictionary *)convertDictionaryKeysFromRelativePathToProjectPath:(NSDictionary *)dictionary;

+ (NSArray *)allImageResources;

@end
