//
//  JRRootViewController.m
//  JRPictureDemo
//
//  Created by hqtech on 2018/5/28.
//  Copyright © 2018年 tulip. All rights reserved.
//

#import "JRRootViewController.h"
#import "JRPictureFlowLayout.h"
#import "JRXMLDataParser.h"
#import "JRPictureCollectionViewCell.h"
#import "JRBigPictureViewController.h"
#import "JRPictureAnimator.h"

static NSString *cellID = @"cellID";

@interface JRRootViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, JRPictureAnimatorPresentDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) NSMutableArray *dataSource;

/**
 查看图片动画
 */
@property (nonatomic, strong) JRPictureAnimator *animator;

@end

@implementation JRRootViewController

- (JRPictureAnimator *)animator {
    if (_animator == nil) {
        _animator = [[JRPictureAnimator alloc] init];
    }
    return _animator;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    // 自定义瀑布流布局
    JRPictureFlowLayout *layout = [[JRPictureFlowLayout alloc] init];
    // 动态获取cell高度
    layout.itemHeightBlock = ^CGFloat(CGFloat itemWidth, NSIndexPath *indexPath, CGFloat width) {
        JRPictureModel *model = self.dataSource[indexPath.item];
        CGFloat titleH = [JRUtils getHeight:model.title fontSize:17 width:width];
        CGFloat contentH = [JRUtils getHeight:model.content fontSize:12 width:width];
        
        if (model.thumbImg == nil) {
            // 默认图片的高度
            CGFloat defaultH = width;
            return (titleH + contentH + defaultH);
        }else {
            return (itemWidth * model.thumbImg.size.height / model.thumbImg.size.width + titleH + contentH);
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
    
    // 获取并解析xml数据
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
    
    JRPictureModel *model = self.dataSource[indexPath.item];
    // 设置标题
    cell.title = model.title;
    // 设置内容
    cell.content = model.content;
    
    UIImage *image = [UIImage imageNamed:@"default_img"];
    if (model.thumbImg != nil) {
        image = model.thumbImg;
    }
    cell.imgView.image = image;
    // 绘制圆角
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, [UIScreen mainScreen].scale);
    [[UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:10.0] addClip];
    [image drawInRect:rect];
    cell.imgView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    JRPictureModel *model = self.dataSource[indexPath.item];
    UIImage *image = [UIImage imageNamed:@"default_img"];
    if (model.originalImg != nil) {
        image = model.originalImg;
    }
    
    // 查看大图
    JRBigPictureViewController *bigPictureVC = [[JRBigPictureViewController alloc] init];
    bigPictureVC.image = image;
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
            if (error != nil) {
                NSLog(@"下载图片错误：%@", error);
                [NSData dataWithContentsOfURL:url options:0 error:&error];
            }
            NSData *imgData = [NSData dataWithContentsOfURL:url];
            UIImage *image = [UIImage imageWithData:imgData];
            model.originalImg = image;
            UIImage *thumbImg = [self compressImageWith:image];
            model.thumbImg = thumbImg;
            
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
    
    CGRect rect = [cell convertRect:cell.imgView.frame toView:[UIApplication sharedApplication].keyWindow];
    return rect;
}

// 动画结束位置
- (CGRect)presentEndRect:(NSIndexPath *)indexPath {
    // 获取img
    JRPictureModel *model = self.dataSource[indexPath.item];
    
    UIImage *img = [UIImage imageNamed:@"default_img"];
    if (model.originalImg != nil) {
        img = model.originalImg;
    }
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
    
    if (model.thumbImg != nil) {
        imgView.image = model.thumbImg;
    }else {
        imgView.image = [UIImage imageNamed:@"default_img"];
    }
    
    return imgView;
}

@end
