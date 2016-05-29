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

/*
 沙盒
 每次打开应用都要从网络下载图片，造成流量浪费，可以把图片放在本地
 
 
 
 内存缓存
 在模型中定义一个属性，有缺陷！内存警告的时候，不好释放在内存中缓存的图像！
 */


static NSString * cellId = @"cellId";
@interface ViewController ()<UITableViewDataSource>

//图像缓存池
@property (nonatomic, strong) NSMutableDictionary * imageCache;

//操作缓存池
@property (nonatomic, strong) NSMutableDictionary * operationCache;

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
    // 实例化图像缓冲池
    _imageCache = [NSMutableDictionary dictionary];
    
    
    [self setupUI];
    
    NSLog(@"%@",NSHomeDirectory());
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return _appInfoList.count ;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    AppInfoCell * cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    
    
    AppInfo * model = _appInfoList[indexPath.row];
    
    
    cell.nameLabel.text = model.name;
    cell.downloadLabel.text = model.download;
    
    UIImage * cacheImage = [_imageCache valueForKey:model.icon];
    
    //如果图像缓存池中有，则从图像缓存池中取
    if (cacheImage!=nil) {
        NSLog(@"从缓存中取图像");
        cell.iconImageView.image = cacheImage;
        return cell;
    }
    
    //看沙盒中是否有该图像
    NSString * imagePath = [self imagePathInCacheDirectoryWithURLString:model.icon];
    
    cacheImage = [UIImage imageWithContentsOfFile:imagePath];
    if (cacheImage!=nil) {
        NSLog(@"从沙盒中取图像");
        
        cell.iconImageView.image = cacheImage;
        
        //把沙盒中图像添加到缓存中，以后可以直接从缓存中取了
        [_imageCache setValue:cacheImage forKey:model.icon];
    }
    
    //判断是否在操作队列中
    if (_operationCache[model.icon] !=nil) {
        return cell;
    }
    
    
    
    //先设置下站位图像
    UIImage *placeholder = [UIImage imageNamed:@"user_default"];
    cell.iconImageView.image = placeholder;
    
    
    //异步加载网络图片
    NSOperationQueue * queue = [[ NSOperationQueue alloc] init];
    
    //由于在每次滚动的过程中，每次滚出的cell都要重新执行当前数据源方法，所以每次都会从网络下载图像，造成流量浪费，因此可以把下载好的图片保存在每个model中，如果模型中有image，则直接用model中的image图像设置
    
    //定义操作block
    NSBlockOperation * op = [ NSBlockOperation blockOperationWithBlock:^{
        
        NSLog(@"%@",[NSThread currentThread]);
        
        NSString * urlString = model.icon;
        
        NSURL * url  = [NSURL URLWithString:urlString];
        
        //模拟某个图像延时
        //这样在下载的过程中，不停的对该图像滚进屏幕和滚出屏幕，造成一直向队列中添加任务，造成重复的添加任务
        if ([model.name isEqualToString:@"保卫萝卜"]) {
            [NSThread sleepForTimeInterval:10];
        }
        
        
        NSData * data = [NSData dataWithContentsOfURL:url];
        NSLog(@"下载%@中.....",model.name);
        
        //从url下载完成后，立即从操作队列中删除
        [_operationCache removeObjectForKey:model.icon];
        
        
        
        UIImage * image = [UIImage imageWithData:data];
        
        
        //取图像的保存路径
        NSString * imagePath = [self imagePathInCacheDirectoryWithURLString:urlString];
        
        
        //把图像二进制数据保存到沙盒中
        [data writeToFile:imagePath atomically:YES];
        

        //把图像保存在图像缓存池imageCache
        [_imageCache setValue:image forKey:urlString];
        
        
        
        //下载完成后主线程更新UI
        
        [[NSOperationQueue mainQueue]  addOperationWithBlock:^{
            cell.iconImageView.image = image;
           // NSLog(@"更新主线程UI");
        }];
        
        
        
    }];
    
    
    //添加到队列中
    [queue addOperation:op];
    NSLog(@"%@下载被添加到队列中",model.name);
    
    
    //添加到操作缓冲池中
    [_operationCache setValue:op forKey:model.icon];
    
    
    //cell.textLabel.text = model.name;;
    return cell;
    
}

//根据URL字符串获得图像的全路径
- (NSString * )imagePathInCacheDirectoryWithURLString:(NSString *)urlString{
    
    NSString * cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject;
    
    //对url进行MD5算法
    NSString * fileName = [urlString cz_md5String];
    
    
    //返回图像的绝对路径
    return [cachePath stringByAppendingPathComponent:fileName];
    
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
