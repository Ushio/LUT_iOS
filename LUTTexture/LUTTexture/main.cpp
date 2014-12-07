//
//  main.cpp
//  LUTTexture
//
//  Created by ushiostarfish on 2014/12/06.
//  Copyright (c) 2014年 Ushio. All rights reserved.
//

#include <iostream>
#include <fstream>
#include <vector>
#include <math.h>

double remap(double value, double inputMin, double inputMax, double outputMin, double outputMax)
{
    return (value - inputMin) * ((outputMax - outputMin) / (inputMax - inputMin)) + outputMin;
}

std::vector<uint8_t> lut(size_t pot = 5 /* 32 */)
{
    size_t size = 1 << pot;

    size_t height = size;
    size_t width = size * size;
    
    std::vector<uint8_t> data(height * width * 4);
    uint8_t *base = data.data();
    for(int y = 0 ; y < height ; ++y)
    {
        uint8_t *head = base + y * width * 4;
        for(int x = 0 ; x < width ; ++x)
        {
            int rIndex = x % size;
            int gIndex = y;
            int bIndex = x / size;
            
            uint8_t *pixel = head + x * 4;
            pixel[0] = static_cast<uint8_t>(round(remap(rIndex, 0, size - 1, 0, 255)));
            pixel[1] = static_cast<uint8_t>(round(remap(gIndex, 0, size - 1, 0, 255)));
            pixel[2] = static_cast<uint8_t>(round(remap(bIndex, 0, size - 1, 0, 255)));
            pixel[3] = 255;
        }
    }
    return data;
}

int main(int argc, const char * argv[]) {
    auto image = lut();
    std::ofstream ofs("", std::ios::out | std::ios::binary);
    ofs.write(reinterpret_cast<const char *>(image.data()), image.size());
    return 0;
}
