//
//  UIImageView+CZWebCache.h
//  异步加载图像
//
//  Created by fengjun on 16/5/30.
//  Copyright © 2016年 fengjun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (CZWebCache)
/**
 * 使用 URLString 设置 imageView 的图像
 */
- (void)cz_setImageWithURLString:(NSString *)urlString;

/**
 * 
 * 一个属性：分类中不能同时有 ivar(成员变量) / getter / setter
 */

//下载图像的 URL 字符串
@property (nonatomic, copy) NSString *cz_urlString;
@end
