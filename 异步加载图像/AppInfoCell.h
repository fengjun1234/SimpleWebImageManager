//
//  AppInfoCell.h
//  异步加载图像
//
//  Created by fengjun on 16/5/29.
//  Copyright © 2016年 fengjun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppInfoCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *downloadLabel;

@end
