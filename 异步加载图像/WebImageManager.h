//
//  WebImageManager.h
//  异步加载图像
//
//  Created by fengjun on 16/5/30.
//  Copyright © 2016年 fengjun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebImageManager : NSObject
+ (instancetype)shareWebImageManager;
- (void)loadImageWithurlString:(NSString *)urlString completion:(void(^)( UIImage  *))completion;
- (void)cancelDownloadWithURLString:(NSString *)urlString;
@end
