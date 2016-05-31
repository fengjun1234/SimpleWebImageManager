//
//  WebImageDownloadOperation.m
//  异步加载图像
//
//  Created by fengjun on 16/5/30.
//  Copyright © 2016年 fengjun. All rights reserved.
//

#import "WebImageDownloadOperation.h"

@interface WebImageDownloadOperation  ();
@property (nonatomic, strong) NSString *urlString;
@property (nonatomic, strong) NSString *cachePath;

@end


@implementation WebImageDownloadOperation


+ (instancetype)downloadOperationWithURLString:(NSString *)urlString cachePath:(NSString *)cachePath{
    
    WebImageDownloadOperation *operation = [[self alloc] init];
    
    // 保存属性
    operation.urlString = urlString;
    operation.cachePath = cachePath;
    return operation;
}

/**
 * 自定义操作的入口方法，如果自定义操作，直接重写这个方法
 *
 * 方法中的代码，在操作被添加到队列后，会自动执行！
 */
- (void)main {
    
    @autoreleasepool {
        NSLog(@"准备下载图像 %@ %@", [NSThread currentThread], _urlString);
        
        // 0. 模拟休眠
        [NSThread sleepForTimeInterval:1.0];
        

        NSURL *url = [NSURL URLWithString:_urlString];
        
        // 在下载之前判断操作是否被取消
        
        //当前做法就是当接收到cancel消息时的自定义做法
        if (self.isCancelled) {
            NSLog(@"下载前被取消");
            return;
        }
        
        NSData *data = [NSData dataWithContentsOfURL:url];
        
        NSLog(@"下载完成");
        
        // 在下载之后判断操作是否被取消
        if (self.isCancelled) {
            NSLog(@"下载后被取消，直接返回，不回调！");
            return;
        }
        
        if (data != nil) {
            //返回图像
            self.downloadImage = [UIImage imageWithData:data];
            
            //二进制保存沙盒
            [data writeToFile:_cachePath atomically:YES];
            
        }
    }
}

@end
