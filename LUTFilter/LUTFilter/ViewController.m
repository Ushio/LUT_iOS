//
//  ViewController.m
//  LUTFilter
//
//  Created by ushiostarfish on 2014/12/06.
//  Copyright (c) 2014年 Ushio. All rights reserved.
//

#import "ViewController.h"

#import <CoreImage/CoreImage.h>
#import "CIFilter+LUT.h"
#import "TableViewCell.h"

@implementation ViewController
{
    IBOutlet UITableView *_tableView;
    CIContext *_context;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _context = [CIContext contextWithOptions:nil];
    _tableView.dataSource = self;
}
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    _tableView.rowHeight = _tableView.bounds.size.width * 0.5 + 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    UIImage *inputImage = [UIImage imageNamed:@"Parrots.png"];
    cell.imageViewL.image = inputImage;
    
    CIFilter *filter = [CIFilter lut_filter];
    NSString *lutPath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"lut%@.png", @(indexPath.row + 1)] ofType:@""];
    NSData *lut = [NSData dataWithContentsOfFile:lutPath];
    [filter lut_setLut:lut];
    [filter setValue:[CIImage imageWithCGImage:inputImage.CGImage] forKey:@"inputImage"];
    
    CIImage *outputImage = filter.outputImage;
    
    CGImageRef result = [_context createCGImage:outputImage fromRect:outputImage.extent];
    UIImage *resultImage = [UIImage imageWithCGImage:result];
    CGImageRelease(result);
    result = NULL;
    
    cell.imageViewR.image = resultImage;
    
    return cell;
}

@end
