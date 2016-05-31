//
//  WebImageDownloadOperation.h
//  异步加载图像
//
//  Created by fengjun on 16/5/30.
//  Copyright © 2016年 fengjun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebImageDownloadOperation : NSOperation

@property (nonatomic, strong) UIImage * downloadImage;

+ (instancetype)downloadOperationWithURLString:(NSString *)urlString cachePath:(NSString *)cachePath;
@end
