//
//  ViewController.m
//  异步加载图像
//
//  Created by fengjun on 16/5/28.
//  Copyright © 2016年 fengjun. All rights reserved.
//

#import "ViewController.h"
#import "AFNetworking.h"
#import "AppInfo.h"
#import "AppInfoCell.h"

#import "CZAdditions.h"
#import "WebImageManager.h"
#import "WebImageDownloadOperation.h"

#import "UIImageView+CZWebCache.h"
//实现一共简单的WebImageMangager

/*
 沙盒
 每次打开应用都要从网络下载图片，造成流量浪费，可以把图片放在本地
 
 
 
 内存缓存
 在模型中定义一个属性，有缺陷！内存警告的时候，不好释放在内存中缓存的图像！
 */


static NSString * cellId = @"cellId";
@interface ViewController ()<UITableViewDataSource>

@end

@implementation ViewController{
    
    UITableView * _tableView;
    
    NSArray <AppInfo * >* _appInfoList;
    
}

-(void)loadView{
    UITableView * tv = [[UITableView alloc] init];
    
    
    self.view = tv;
    
    _tableView = tv;
    
}

-(void)viewDidLoad{
    [super viewDidLoad];
 
    
    [self setupUI];
    
    NSLog(@"%@",NSHomeDirectory());
}

- (void)didReceiveMemoryWarning{
    
    
    
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return _appInfoList.count ;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    AppInfoCell * cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    
    
    AppInfo * model = _appInfoList[indexPath.row];
    
    
    cell.nameLabel.text = model.name;
    cell.downloadLabel.text = model.download;
    
    [cell.iconImageView cz_setImageWithURLString:model.icon];
    
    

    return cell;
    
}



- (void)setupUI {
    
    
    [self loaddata];
    
    _tableView.dataSource =self;
    
    
    //[_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellId];
    
    [_tableView registerNib:[UINib nibWithNibName:@"AppInfoCell"  bundle:nil ] forCellReuseIdentifier:cellId];
    
    _tableView.rowHeight = 100;
}

- (void)loaddata{
    //从网络加载数据
    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager ];
    
    [manager  GET:@"https://raw.githubusercontent.com/fengjun1234/SimpleDemo/master/apps.json"
       parameters:nil
         progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              
              NSLog(@"%@ %@",responseObject,[responseObject class]);
              
              //字典转模型
              
              NSMutableArray * arrayM = [NSMutableArray array];
              
              for (NSDictionary * dict in responseObject) {
                  
                  AppInfo * model = [[AppInfo alloc] init];
                  
                  [model setValuesForKeysWithDictionary:dict];
                  
                  [arrayM addObject:model];
              }
              
              _appInfoList = arrayM.copy;
              
              //
              [_tableView reloadData];
              
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              NSLog(@"请求失败 %@",error);
          }];
    
}

@end
