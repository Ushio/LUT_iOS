//
//  CIFilter+LUT.m
//  LUTFilter
//
//  Created by ushiostarfish on 2014/12/06.
//  Copyright (c) 2014年 Ushio. All rights reserved.
//

#import "CIFilter+LUT.h"
#import <ImageIO/ImageIO.h>

static void loadCGImage(CGImageRef *imageoutput, NSData *data) {
    CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)data, nil);
    if(imageSource == nil)
    {
        return;
    }
    if(CGImageSourceGetCount(imageSource) == 0)
    {
        CFRelease(imageSource);
        return;
    }
    CGImageRef image = CGImageSourceCreateImageAtIndex(imageSource, 0, nil);
    if(image == nil)
    {
        CFRelease(imageSource);
        return;
    }
    CFRelease(imageSource);
    imageSource = NULL;
    
    *imageoutput = image;
}
static BOOL isPowerOfTwo(size_t x)
{
    return ((x != 0) && ((x & (~x + 1)) == x));
}

@implementation CIFilter (LUT)
+ (CIFilter *)lut_filter
{
    return [CIFilter filterWithName:@"CIColorCube"];
}
- (void)lut_setLut:(NSData *)lut
{
    CGImageRef image = NULL;
    loadCGImage(&image, lut);
    NSAssert(image, @"");
    
    size_t width = CGImageGetWidth(image);
    size_t height = CGImageGetHeight(image);
    
    NSAssert(isPowerOfTwo(width), @"");
    NSAssert(isPowerOfTwo(height), @"");
    NSAssert(height * height == width, @"");
    
    size_t bitsPerComponent = 8;
    size_t bytesPerRow = 4 * width;
    size_t bytesSize = bytesPerRow * height;
    uint8_t *bytes = malloc(bytesSize);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big;
    CGContextRef context = CGBitmapContextCreate(bytes, width, height, bitsPerComponent, bytesPerRow, colorSpace, bitmapInfo);
    NSAssert(context, @"");
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    CGContextSetInterpolationQuality(context, kCGInterpolationNone);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), image);
    CGColorSpaceRelease(colorSpace);
    colorSpace = NULL;
    CGContextRelease(context);
    context = NULL;
    CGImageRelease(image);
    image = NULL;
    
    size_t size = height;

    NSMutableData *lutCube = [NSMutableData data];
    [lutCube setLength:size * size * size * sizeof(float) * 4];
    
    float *dstHead = (float *)[lutCube mutableBytes];
    
    double div_255 = 1.0 / 255.0;
    for(int k = 0 ; k < size ; ++k)
    {
        // b
        for(int j = 0 ; j < size ; ++j)
        {
            // g
            int inputY = j;
            for(int i = 0 ; i < size ; ++i)
            {
                // r
                size_t inputX = size * k + i;
                uint8_t *pixel = bytes + bytesPerRow * inputY + inputX * 4;
                double r = (double)(pixel[0]) * div_255;
                double g = (double)(pixel[1]) * div_255;
                double b = (double)(pixel[2]) * div_255;
                
                float *dst = dstHead + (k * size * size + j * size + i) * 4;
                
                dst[0] = r;
                dst[1] = g;
                dst[2] = b;
                dst[3] = 1.0f;
            }
        }
    }
    
    free(bytes);
    bytes = NULL;
    
    [self setValue:lutCube forKey:@"inputCubeData"];
    [self setValue:@(size) forKey:@"inputCubeDimension"];
}
@end
