//
//  WebImageManager.m
//  异步加载图像
//
//  Created by fengjun on 16/5/30.
//  Copyright © 2016年 fengjun. All rights reserved.
//

#import "WebImageManager.h"
#import "CZAdditions.h"
#import "WebImageDownloadOperation.h"


@interface WebImageManager ()
//操作缓存
@property (nonatomic, strong) NSMutableDictionary *operationCache;
//图像缓存
@property (nonatomic, strong) NSMutableDictionary *imageCache;

//下载队列

@property (nonatomic, strong) NSOperationQueue *downloadQueue;
@end


@implementation WebImageManager
+ (instancetype)shareWebImageManager{
    static id  instance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        instance = [[super alloc] init];
        
    });
    
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        // 初始化队列和缓存
        _operationCache = [NSMutableDictionary dictionary];
        _imageCache = [NSMutableDictionary dictionary];
        
        _downloadQueue = [[NSOperationQueue alloc] init];
        
        // 注册内存警告通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(memoryWarning) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    return self;
}

#pragma mark - 内存警告方法
- (void)memoryWarning {
    
    // 1. 清理图像缓存
    [_imageCache removeAllObjects];
    
    // 2. 取消没有完成的下载操作
    [_downloadQueue cancelAllOperations];
    
    // 3. 清空操作缓冲池
    [_operationCache removeAllObjects];
}

#pragma mark - 取消操作
- (void)cancelDownloadWithURLString:(NSString *)urlString {
    
    // 1. 从操作缓冲池去处操作
    WebImageDownloadOperation *op = _operationCache[urlString];
    
    // 2. 给操作发送 cancel 消息，如果没有拿到 op 会怎样？什么也不会发生
    [op cancel];
}

//异步加载图像
///异步方法的执行，不能通过方法的返回值返回结果，最常用的方式就是通过 block 的参数执行回调！

- (void)loadImageWithurlString:(NSString *)urlString completion:(void(^)( UIImage  *))completion{
    
    //断言
    NSAssert(completion != nil, @"必须传入完成回调！");
    
    //先看看内存缓存中是否有图片
    UIImage *cacheImage = _imageCache[urlString];
    
    if (cacheImage != nil) {
        NSLog(@"返回内存缓存");
        
        completion(cacheImage);
        
        return;
    }
    
    //再看看沙盒张是否有
    NSString * path = [self imagePathInCacheDirectoryWithURLString:urlString];
    
    cacheImage = [UIImage imageWithContentsOfFile:path];
    
    if ([UIImage imageWithContentsOfFile:path]) {
        NSLog(@"返回沙盒缓存");
        
        [_imageCache setObject:cacheImage forKey:urlString];
        
        completion(cacheImage);
        
        return;
    }
    
    
    // 3. 下载操作过长，需要通过操作缓存避免重复下载
    if (_operationCache[urlString] != nil) {
        NSLog(@"%@ 正在下载中，稍安勿躁...", urlString);
        
        return;
    }
    
    
    
    //单个图像下载用自定义NSBlockOperation
    
    WebImageDownloadOperation * operation = [WebImageDownloadOperation downloadOperationWithURLString:urlString cachePath:[self imagePathInCacheDirectoryWithURLString:urlString] ];
    
    __weak WebImageDownloadOperation * weakOperation = operation;
    
      [operation setCompletionBlock:^{
        
        UIImage *image = weakOperation.downloadImage;
        NSLog(@"图像:%@",image);
          
          
        if (image != nil) {
            //存入图像缓存池
           [_imageCache setObject:image forKey:urlString];
        }
        
        
        //从操作队列中移除
        [_operationCache removeObjectForKey:urlString];
        
         //更新主线程UI
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            NSLog(@"更新主线程UI%@",[NSThread currentThread]);
            completion(image);
            
        }];
        
        
        
    }];
    
    //添加到队列中
    [_downloadQueue addOperation:operation];
    
    
    //添加到操作缓冲！
    [_operationCache setObject:operation forKey:urlString];
    
}
//根据URL字符串获得图像的全路径
- (NSString * )imagePathInCacheDirectoryWithURLString:(NSString *)urlString{
    
    NSString * cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject;
    
    //对url进行MD5算法
    NSString * fileName = [urlString cz_md5String];
    
    
    //返回图像的绝对路径
    return [cachePath stringByAppendingPathComponent:fileName];
    
}
@end
