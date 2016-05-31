//
//  UIImageView+CZWebCache.m
//  异步加载图像
//
//  Created by fengjun on 16/5/30.
//  Copyright © 2016年 fengjun. All rights reserved.
//

#import "UIImageView+CZWebCache.h"
#import "WebImageManager.h"
#import <objc/runtime.h>
/**
 * urlString KEY
 */
const char *cz_URLStringKey = "cz_URLStringKey";

@implementation UIImageView (CZWebCache)
/**
 1. **记录**要下载的 urlString
 2. 当设置 urlString 的时候，根之前记录的 urlString 进行比较，
 3. 如果不相同，意味着下载新的图像，将之前的下载操作取消！
 */
- (void)cz_setImageWithURLString:(NSString *)urlString {
    
    // 判读地址是否变化
    if (![urlString isEqualToString:self.cz_urlString] && self.cz_urlString != nil) {
        
        NSLog(@"取消之前的下载操作 %@", self.cz_urlString);
        
        // 取消之前的下载操作
        [[WebImageManager  shareWebImageManager] cancelDownloadWithURLString:self.cz_urlString];
    }
    
    // 记录新的地址
    self.cz_urlString = urlString;
    
    // 在下载之前，将图像设置为 nil
    self.image = nil;
    
    [[WebImageManager shareWebImageManager] loadImageWithurlString: urlString completion:^(UIImage * image) {
        // 下载完成之后，清空之前保存的 urlString
        // 避免再一次进入之后，提示取消之前的下载操作
        
        //表示已经当前要下载的图像已经下载完成
        self.cz_urlString = nil;
        
        // 下载完成之后，设置图像
        self.image = image;
    }
    ];
}

#pragma mark - 属性的 getter & setter 方法
/**
 * 如果在开发中，重写了 getter & setter 方法，系统不再提供 `_成员变量`
 *
 * `alloc` 方法会根据类的属性，来分配合理的空间！
 *
 * 在分类中，如何能够记录住内容? -> `运行时`的关联对象！
 *
 * - objc_getAssociatedObject
 * - objc_setAssociatedObject
 *
 * 可以实现在分类中定义属性，并且保存属性的内容！最大应用场景：在开发第三方框架，或者包装分类方法时，`简化操作`！
 */
- (NSString *)cz_urlString {
    /**
     参数
     1. 属性值绑定的对象
     2. 属性值的 KEY
     */
    return objc_getAssociatedObject(self, cz_URLStringKey);
}

- (void)setCz_urlString:(NSString *)cz_urlString {
    
    // 记录 传入的值
    /**
     参数
     1. 属性值绑定的对象
     2. 属性值的 KEY
     3. 要存储的属性值
     4. 属性的管理策略 - MRC 支持的类型，weak 是 ARC 特有的
     OBJC_ASSOCIATION_ASSIGN = 0,          // assign
     OBJC_ASSOCIATION_RETAIN_NONATOMIC = 1, // nonatomic strong
     OBJC_ASSOCIATION_COPY_NONATOMIC = 3,   // nonatomic copy
     OBJC_ASSOCIATION_RETAIN = 01401,       // atomic strong
     OBJC_ASSOCIATION_COPY = 01403          // atomic copy
     */
    objc_setAssociatedObject(self, cz_URLStringKey, cz_urlString, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
@end
