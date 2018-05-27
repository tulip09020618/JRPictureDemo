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

static NSString *cellID = @"cellID";

@interface ViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.collectionViewLayout = [[JRPictureFlowLayout alloc] init];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"JRPictureCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:cellID];
    
    
    JRXMLDataParser *parser = [[JRXMLDataParser alloc] init];
    parser.parseComplete = ^(NSArray *pictureModels) {
        // 解析完成
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"解析完成：%@", pictureModels);
            self.dataSource = [NSMutableArray arrayWithArray:pictureModels];
            [self.collectionView reloadData];
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
    
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
