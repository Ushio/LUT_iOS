//
//  CIFilter+LUT.h
//  LUTFilter
//
//  Created by ushiostarfish on 2014/12/06.
//  Copyright (c) 2014年 Ushio. All rights reserved.
//

#import <CoreImage/CoreImage.h>

typedef void (^FunctionSetParameter)(CIFilter *filter);

FunctionSetParameter functionSetParameterWithLutImageData(NSData *lutImageData);

@interface CIFilter(LUT)
+ (CIFilter *)lut_filter;
- (void)lut_setLut:(NSData *)lut;
@end
