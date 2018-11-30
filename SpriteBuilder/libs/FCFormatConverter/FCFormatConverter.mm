//
//  FCFormatConverter.m
//  CocosBuilder
//
//  Created by Viktor on 6/27/13.
//
//

#import "FCFormatConverter.h"
#import "PVRTexture.h"
#import "PVRTextureUtilities.h"

static FCFormatConverter* gDefaultConverter = NULL;

static NSString * kErrorDomain = @"com.robotsandpencils.PencilCase";

@implementation FCFormatConverter

+ (FCFormatConverter*) defaultConverter
{
    if (!gDefaultConverter)
    {
        gDefaultConverter = [[FCFormatConverter alloc] init];
    }
    return gDefaultConverter;
}

- (NSString*) proposedNameForConvertedImageAtPath:(NSString*)srcPath format:(int)format compress:(BOOL)compress isSpriteSheet:(BOOL)isSpriteSheet
{
    if ( isSpriteSheet )
		{
		    // The name of a sprite in a spritesheet never changes.
		    return [srcPath copy];
		}
    if (format == kFCImageFormatPNG ||
        format == kFCImageFormatPNG_8BIT)
    {
        // File might be loaded from a .psd file.
        return [[srcPath stringByDeletingPathExtension] stringByAppendingPathExtension:@"png"];
    }
    else if (format == kFCImageFormatPVR_RGBA8888 ||
             format == kFCImageFormatPVR_RGBA4444 ||
             format == kFCImageFormatPVR_RGB565 ||
             format == kFCImageFormatPVRTC_4BPP ||
             format == kFCImageFormatPVRTC_2BPP)
    {
        NSString* dstPath = [[srcPath stringByDeletingPathExtension] stringByAppendingPathExtension:@"pvr"];
        if (compress) dstPath = [dstPath stringByAppendingPathExtension:@"ccz"];
        return dstPath;
    }
    else if (format == kFCImageFormatJPG_Low ||
             format == kFCImageFormatJPG_Medium ||
             format == kFCImageFormatJPG_High)
    {
        NSString* dstPath = [[srcPath stringByDeletingPathExtension] stringByAppendingPathExtension:@"png"];
        return dstPath;
    }
    return NULL;
}
-(BOOL)convertImageAtPath:(NSString*)srcPath
                   format:(int)format
                   dither:(BOOL)dither
                 compress:(BOOL)compress
            isSpriteSheet:(BOOL)isSpriteSheet
           outputFilename:(NSString**)outputFilename
                    error:(NSError**)error;
{	
    NSFileManager* fm = [NSFileManager defaultManager];
    NSString* dstDir = [srcPath stringByDeletingLastPathComponent];
    
    // Convert PSD to PNG as a pre-step.
    // Unless the .psd is part of a spritesheet, then the original name has to be preserved.
    if ( [[srcPath pathExtension] isEqualToString:@"psd"] && !isSpriteSheet)
    {
            CGImageSourceRef image_source = CGImageSourceCreateWithURL((__bridge CFURLRef)[NSURL fileURLWithPath:srcPath], NULL);
            CGImageRef image = CGImageSourceCreateImageAtIndex(image_source, 0, NULL);
            
            NSString *out_path = [[srcPath stringByDeletingPathExtension] stringByAppendingPathExtension:@"png"];
            CFURLRef out_url = (__bridge CFURLRef)[NSURL fileURLWithPath:out_path];
            CGImageDestinationRef image_destination = CGImageDestinationCreateWithURL(out_url, kUTTypePNG, 1, NULL);
            CGImageDestinationAddImage(image_destination, image, NULL);
            bool success = CGImageDestinationFinalize(image_destination);
            
            CFRelease(image_source);
            CGImageRelease(image);
            CFRelease(image_destination);

            if (!success) {
                return NO;
            }
            
            [fm removeItemAtPath:srcPath error:nil];
            srcPath = out_path;
    }
		
    if (format == kFCImageFormatPNG)
    {
        // PNG image - no conversion required
        if (outputFilename) *outputFilename = [srcPath copy];
        return YES;
    }
    if (format == kFCImageFormatPNG_8BIT)
    {
        /* Cody turned off: Seems to not be needed. Maybe was used for psd support?
        // 8 bit PNG image
        NSTask* pngTask = [[NSTask alloc] init];
        [pngTask setLaunchPath:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"pngquant"]];
        NSMutableArray* args = [NSMutableArray arrayWithObjects:
                                @"--force", @"--ext", @".png", srcPath, nil];
        if (dither) [args addObject:@"-dither"];
        [pngTask setArguments:args];
        [pngTask launch];
        [pngTask waitUntilExit];
        
        if ([fm fileExistsAtPath:srcPath])
        {
            if (outputFilename) *outputFilename = [srcPath copy];
            return YES;
        }
         */
    }
    else if (format == kFCImageFormatPVR_RGBA8888 ||
             format == kFCImageFormatPVR_RGBA4444 ||
             format == kFCImageFormatPVR_RGB565 ||
             format == kFCImageFormatPVRTC_4BPP ||
             format == kFCImageFormatPVRTC_2BPP)
    {
        
        // PVR(TC) image
        NSString *dstPath = [[srcPath stringByDeletingPathExtension] stringByAppendingPathExtension:@"pvr"];
        
        pvrtexture::PixelType pixelType;
        EPVRTVariableType variableType = ePVRTVarTypeUnsignedByteNorm;
        
        if (format == kFCImageFormatPVR_RGBA8888)
        {
            pixelType = pvrtexture::PixelType('r','g','b','a',8,8,8,8);
        }
        else if (format == kFCImageFormatPVR_RGBA4444)
        {
            pixelType = pvrtexture::PixelType('r','g','b','a',4,4,4,4);
            variableType = ePVRTVarTypeUnsignedShortNorm;
        }
        else if (format == kFCImageFormatPVR_RGB565)
        {
            pixelType = pvrtexture::PixelType('r','g','b',0,5,6,5,0);
            variableType = ePVRTVarTypeUnsignedShortNorm;
        }
        else if (format == kFCImageFormatPVRTC_4BPP)
        {
            pixelType = pvrtexture::PixelType(ePVRTPF_PVRTCI_4bpp_RGB);
        }
        else if (format == kFCImageFormatPVRTC_2BPP)
        {
            pixelType = pvrtexture::PixelType(ePVRTPF_PVRTCI_2bpp_RGB);
        }

        NSImage * image = [[NSImage alloc] initWithContentsOfFile:srcPath];
        NSBitmapImageRep* rawImg = [NSBitmapImageRep imageRepWithData:[image TIFFRepresentation]];
        
        pvrtexture::CPVRTextureHeader header(pvrtexture::PVRStandard8PixelType.PixelTypeID, image.size.height , image.size.width);
        pvrtexture::CPVRTexture     * pvrTexture = new pvrtexture::CPVRTexture(header , rawImg.bitmapData);
        
        bool hasError = NO;
        
        if(!Transcode(*pvrTexture, pixelType, variableType, ePVRTCSpacelRGB, pvrtexture::ePVRTCBest, dither))
        {
            NSString * errorMessage = [NSString stringWithFormat:@"Failure to transcode image: %@", srcPath];
            NSDictionary * userInfo __attribute__((unused)) =@{NSLocalizedDescriptionKey:errorMessage};
            if (error) {
                *error = [NSError errorWithDomain:kErrorDomain code:EPERM userInfo:userInfo];
            }
            hasError = YES;
        }
        
        if(!hasError)
        {
            CPVRTString filePath([dstPath UTF8String], dstPath.length);
            
            if(!pvrTexture->saveFileLegacyPVR(filePath,  pvrtexture::eOGLES2))
            {
                NSString * errorMessage = [NSString stringWithFormat:@"Failure to save image: %@", dstPath];
                NSDictionary * userInfo __attribute__((unused)) =@{NSLocalizedDescriptionKey:errorMessage};
                if (error) {
                    *error = [NSError errorWithDomain:kErrorDomain code:EPERM userInfo:userInfo];
                }
                hasError = YES;
            }
        }
        
        
        // Remove PNG file
        [[NSFileManager defaultManager] removeItemAtPath:srcPath error:NULL];
        //Clean up memory.
        delete pvrTexture;
        
        if(hasError)
        {
            return NO;//return failure;
        }
        
        if (compress)
        {
            // Create compressed file (ccz)
            NSTask* zipTask = [[NSTask alloc] init];
            [zipTask setCurrentDirectoryPath:dstDir];
            [zipTask setLaunchPath:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"ccz"]];
            NSMutableArray* args = [NSMutableArray arrayWithObjects:dstPath, nil];
            [zipTask setArguments:args];
            [zipTask launch];
            [zipTask waitUntilExit];

            if (zipTask.terminationStatus != 0) {
                return NO;
            }
            
            // Remove uncompressed file
            [[NSFileManager defaultManager] removeItemAtPath:dstPath error:NULL];
            
            // Update name of texture file
            dstPath = [dstPath stringByAppendingPathExtension:@"ccz"];
        }
        
        if ([fm fileExistsAtPath:dstPath])
        {
            if (outputFilename) *outputFilename = [dstPath copy];
            return YES;
        }
    }
    else if (format == kFCImageFormatJPG_Low ||
             format == kFCImageFormatJPG_Medium ||
             format == kFCImageFormatJPG_High)
    {
        // JPG image format
        NSString* dstPath = [[srcPath stringByDeletingPathExtension] stringByAppendingPathExtension:@"png"];
        
        // Set the compression factor
        float compressionFactor = 1;
        if (format == kFCImageFormatJPG_High) compressionFactor = 0.9;
        else if (format == kFCImageFormatJPG_Medium) compressionFactor = 0.6;
        else if (format == kFCImageFormatJPG_Low) compressionFactor = 0.3;
        
        NSDictionary* props = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:compressionFactor] forKey:NSImageCompressionFactor];
        
        // Convert the file
        NSBitmapImageRep *imageRep = (NSBitmapImageRep *)[NSBitmapImageRep imageRepWithContentsOfFile:srcPath];
        NSData *imgData = [imageRep representationUsingType:NSJPEGFileType properties:props];
        
        if (![imgData writeToFile:dstPath atomically:YES]) return NO;
        
        // Remove old file
        if (![srcPath isEqualToString:dstPath])
        {
            [fm removeItemAtPath:srcPath error:NULL];
        }
        
        if (outputFilename) *outputFilename = [dstPath copy];
        return YES;
        
    }
    else
    {
        // Conversion failed
        if(error != nil)
        {
            *error = [NSError errorWithDomain:kErrorDomain code:EPERM userInfo:@{NSLocalizedDescriptionKey:@"Unhandled format"}];
        }
        
        return NO;
    }
    return NO;
}

- (NSString*) proposedNameForConvertedSoundAtPath:(NSString*)srcPath format:(int)format
{
    NSString* ext = NULL;
    if (format == kFCSoundFormatCAF) ext = @"caf";
    else if (format == kFCSoundFormatMP4) ext = @"m4a";
    else if (format == kFCSoundFormatOGG) ext = @"ogg";
    
    if (ext)
    {
        return [[srcPath stringByDeletingPathExtension] stringByAppendingPathExtension:ext];
    }
    return NULL;
}

- (NSString*) convertSoundAtPath:(NSString*)srcPath format:(int)format quality:(int)quality
{
    NSString* dstPath = [self proposedNameForConvertedSoundAtPath:srcPath format:format];
    NSFileManager* fm = [NSFileManager defaultManager];
    
    if (format == kFCSoundFormatCAF)
    {
        // Convert to CAF
        NSTask* sndTask = [[NSTask alloc] init];
        
        [sndTask setLaunchPath:@"/usr/bin/afconvert"];
        NSMutableArray* args = [NSMutableArray arrayWithObjects:
                                @"-f", @"caff",
                                @"-d", @"LEI16@44100",
                                @"-c", @"1",
                                srcPath, dstPath, nil];
        [sndTask setArguments:args];
        [sndTask launch];
        [sndTask waitUntilExit];

        if (sndTask.terminationStatus != 0) {
            return NULL;
        }
        
        // Remove old file
        if (![srcPath isEqualToString:dstPath])
        {
            [fm removeItemAtPath:srcPath error:NULL];
        }
        
        return dstPath;
    }
    else if (format == kFCSoundFormatMP4)
    {
        // Convert to AAC
        
        int qualityScaled = ((quality -1) * 127) / 7;//Quality [1,8]
        
        // Do the conversion
        NSTask* sndTask = [[NSTask alloc] init];
        
        [sndTask setLaunchPath:@"/usr/bin/afconvert"];
        NSMutableArray* args = [NSMutableArray arrayWithObjects:
                                @"-f", @"m4af",
                                @"-d", @"aac",
                                @"-u", @"pgcm", @"2",
                                @"-u", @"vbrq", [NSString stringWithFormat:@"%i",qualityScaled],
                                @"-q", @"127",
                                @"-s", @"3",
                                srcPath, dstPath, nil];
        [sndTask setArguments:args];
        [sndTask launch];
        [sndTask waitUntilExit];

        if (sndTask.terminationStatus != 0) {
            return NULL;
        }

        // Remove old file
        if (![srcPath isEqualToString:dstPath])
        {
            [fm removeItemAtPath:srcPath error:NULL];
        }
        
        return dstPath;
    }
    else if (format == kFCSoundFormatOGG)
    {
        // Convert to OGG
        NSTask* sndTask = [[NSTask alloc] init];
        [sndTask setCurrentDirectoryPath:[srcPath stringByDeletingLastPathComponent]];
        [sndTask setLaunchPath:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"oggenc"]];
        NSMutableArray* args = [NSMutableArray arrayWithObjects:
                                [NSString stringWithFormat:@"-q%d", quality],
                                @"-o", dstPath, srcPath,
                                nil];
        [sndTask setArguments:args];
        [sndTask launch];
        [sndTask waitUntilExit];

        if (sndTask.terminationStatus != 0) {
            return NULL;
        }

        // Remove old file
        if (![srcPath isEqualToString:dstPath])
        {
            [fm removeItemAtPath:srcPath error:NULL];
        }
        
        return dstPath;
    }
    
    return NULL;
}

@end
