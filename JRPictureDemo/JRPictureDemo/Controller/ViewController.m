//
//  ViewController.m
//  JRPictureDemo
//
//  Created by hqtech on 2018/5/27.
//  Copyright © 2018年 tulip. All rights reserved.
//

#import "ViewController.h"
#import "JRPictureFlowLayout.h"
#import "JRXMLDataParser.h"
#import "JRPictureCollectionViewCell.h"
#import "JRBigPictureViewController.h"
#import "JRPictureAnimator.h"

static NSString *cellID = @"cellID";

@interface ViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, JRPictureAnimatorPresentDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) NSMutableArray *dataSource;

/**
 查看图片动画
 */
@property (nonatomic, strong) JRPictureAnimator *animator;

@end

@implementation ViewController

- (JRPictureAnimator *)animator {
    if (_animator == nil) {
        _animator = [[JRPictureAnimator alloc] init];
    }
    return _animator;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    JRPictureFlowLayout *layout = [[JRPictureFlowLayout alloc] init];
    layout.itemHeightBlock = ^CGFloat(CGFloat itemWidth, NSIndexPath *indexPath) {
        JRPictureModel *model = self.dataSource[indexPath.item];
        if (model.thumbImg == nil) {
            return 100;
        }else {
            return itemWidth * model.thumbSize.height / model.thumbSize.width;
        }
    };
    self.collectionView.collectionViewLayout = layout;
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"JRPictureCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:cellID];
    
    // 加载数据
    [self loadData];
    
}

#pragma mark 加载数据
- (void)loadData {
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = @"正在加载数据";
    
    JRXMLDataParser *parser = [[JRXMLDataParser alloc] init];
    parser.parseComplete = ^(NSArray *pictureModels) {
        // 解析完成
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            NSLog(@"解析完成：%@", pictureModels);
            self.dataSource = [NSMutableArray arrayWithArray:pictureModels];
            [self.collectionView reloadData];
            
            // 下载图片
            [self downloadImg];
        });
    };
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(globalQueue, ^{
        //子线程异步执行任务，防止主线程卡顿
        [parser startParse];
    });
}

- (NSMutableArray *)dataSource {
    if (_dataSource == nil) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    JRPictureCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    cell.backgroundColor = [UIColor purpleColor];
    
    JRPictureModel *model = self.dataSource[indexPath.item];
    cell.titleLabel.text = model.title;
    
    if (model.thumbImg != nil) {
        cell.imgView.image = model.thumbImg;
        
        // 绘制圆角
        CGRect rect = CGRectMake(0, 0, model.thumbImg.size.width, model.thumbImg.size.height);
        UIGraphicsBeginImageContextWithOptions(rect.size, NO, [UIScreen mainScreen].scale);
        [[UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:10.0] addClip];
        [cell.imgView.image drawInRect:rect];
        cell.imgView.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
    }else {
        cell.imgView.image = nil;
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    JRPictureModel *model = self.dataSource[indexPath.item];
    if (model.originalImg == nil) {
        return;
    }
    
    // 查看大图
    JRBigPictureViewController *bigPictureVC = [[JRBigPictureViewController alloc] init];
    bigPictureVC.image = model.originalImg;
    // 自定义转场动画
    bigPictureVC.modalPresentationStyle = UIModalPresentationCustom;
    bigPictureVC.transitioningDelegate = self.animator;
    
    self.animator.indexPath = indexPath;
    // 查看图片动画代理
    self.animator.presentDelegate = self;
    // 取消查看动画代理
    self.animator.dismissDelegate = bigPictureVC;
    
    [self presentViewController:bigPictureVC animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark 下载图片
- (void)downloadImg {
    
    for (NSInteger i = 0; i < self.dataSource.count; i ++) {
        JRPictureModel *model = self.dataSource[i];
        
        dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(globalQueue, ^{
            //子线程异步执行任务，防止主线程卡顿
            NSLog(@"异步下载：%ld", (long)i);
            
            NSURL *url = [NSURL URLWithString:model.imgUrl];
            // 下载图片
            NSError *error;
            [NSData dataWithContentsOfURL:url options:0 error:&error];
            while (error != nil) {
                NSLog(@"下载图片错误：%@", error);
                [NSData dataWithContentsOfURL:url options:0 error:&error];
            }
            NSData *imgData = [NSData dataWithContentsOfURL:url];
            UIImage *image = [UIImage imageWithData:imgData];
            model.originalImg = image;
            model.originalSize = image.size;
            UIImage *thumbImg = [self compressImageWith:image];
            model.thumbImg = thumbImg;
            model.thumbSize = thumbImg.size;
            
            dispatch_queue_t mainQueue = dispatch_get_main_queue();
            //异步返回主线程，更新UI
            dispatch_async(mainQueue, ^{
                [self.collectionView reloadData];
            });
        });
    }
    
}

#pragma mark 压缩图片
- (UIImage *)compressImageWith:(UIImage *)image
{
    float imageWidth = image.size.width;
    float imageHeight = image.size.height;
    float width = ([UIScreen mainScreen].bounds.size.width - 30) / 2;
    float height = image.size.height/(image.size.width/width);
    
    float widthScale = imageWidth /width;
    float heightScale = imageHeight /height;
    
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    
    if (widthScale > heightScale) {
        [image drawInRect:CGRectMake(0, 0, imageWidth /heightScale , height)];
    }
    else {
        [image drawInRect:CGRectMake(0, 0, width , imageHeight /widthScale)];
    }
    
    // 从当前context中创建一个改变大小后的图片
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    
    return newImage;
}

#pragma mark - JRPictureAnimatorPresentDelegate
// 动画开始位置
- (CGRect)presentStartRect:(NSIndexPath *)indexPath {
    JRPictureCollectionViewCell *cell = (JRPictureCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    
    CGRect rect = [self.collectionView convertRect:cell.frame toView:[UIApplication sharedApplication].keyWindow];
    return rect;
}

// 动画结束位置
- (CGRect)presentEndRect:(NSIndexPath *)indexPath {
    // 获取img
    JRPictureModel *model = self.dataSource[indexPath.item];
    UIImage *img = model.originalImg;
    // 计算imgView动画结束时的位置
    CGFloat x = 0;
    CGFloat y = 0;
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = width * img.size.height / img.size.width;
    y = ([UIScreen mainScreen].bounds.size.height - height) / 2;
    return CGRectMake(x, y, width, height);
}

// 要查看图片
- (UIImageView *)presentImgView:(NSIndexPath *)indexPath {
    JRPictureModel *model = self.dataSource[indexPath.item];
    
    UIImageView *imgView = [[UIImageView alloc] init];
    imgView.image = model.thumbImg;
    
    return imgView;
}

@end
