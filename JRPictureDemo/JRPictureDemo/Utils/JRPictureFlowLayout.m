//
//  JRPictureFlowLayout.m
//  JRPictureDemo
//
//  Created by hqtech on 2018/5/27.
//  Copyright © 2018年 tulip. All rights reserved.
//

#import "JRPictureFlowLayout.h"

#define collectionW self.collectionView.frame.size.width
// 每行间距
static const CGFloat rowMargin = 10;
// 每列间距
static const CGFloat colMargin = 10;
// 内边距：左上右下
static const UIEdgeInsets defaultInsets = {10, 10, 10, 10};
// 默认列数
static const NSInteger colsCount = 2;

@interface JRPictureFlowLayout ()

// 每一列的最大Y值
@property (nonatomic, strong) NSMutableArray<NSNumber *> *colMaxYs;
// 存放所有cell的布局属性
@property (nonatomic, strong) NSMutableArray<UICollectionViewLayoutAttributes *> *attrsArray;

@end

@implementation JRPictureFlowLayout

- (NSMutableArray<NSNumber *> *)colMaxYs {
    if (_colMaxYs == nil) {
        _colMaxYs = [NSMutableArray array];
    }
    return _colMaxYs;
}

- (NSMutableArray<UICollectionViewLayoutAttributes *> *)attrsArray {
    if (_attrsArray == nil) {
        _attrsArray = [NSMutableArray array];
    }
    return _attrsArray;
}

- (CGSize)collectionViewContentSize {
    // 找出最长一列的最大Y值
    CGFloat maxY = [self.colMaxYs[0] floatValue];
    for (NSInteger i = 0; i < self.colMaxYs.count; i ++) {
        CGFloat colY = [self.colMaxYs[i] floatValue];
        if (maxY < colY) {
            maxY = colY;
        }
    }
    return CGSizeMake(0, maxY + defaultInsets.bottom);
}

- (void)prepareLayout {
    [super prepareLayout];
    
    // 重置每一列的最大Y值
    [self.colMaxYs removeAllObjects];
    for (NSInteger i = 0; i < colsCount; i ++) {
        [self.colMaxYs addObject:[NSNumber numberWithFloat:defaultInsets.top]];
    }
    
    // 重置所有布局属性
    [self.attrsArray removeAllObjects];
    // cell的总个数
    NSInteger count = [self.collectionView numberOfItemsInSection:0];
    for (NSInteger i = 0; i < count; i ++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        UICollectionViewLayoutAttributes *attrs = [self layoutAttributesForItemAtIndexPath:indexPath];
        [self.attrsArray addObject:attrs];
    }
    
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    return self.attrsArray;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attrs = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    // 设置cell的布局属性
    
    // 计算cell的宽度和高度
    // 水平方向间距总和
    CGFloat xTotalMargin = defaultInsets.left + defaultInsets.right + (colsCount - 1) * colMargin;
    // cell宽度
    CGFloat cellW = (collectionW - xTotalMargin) / colsCount;
    // cell高度
    CGFloat cellH = 100;
    if (self.itemHeightBlock) {
        cellH = self.itemHeightBlock(cellW, indexPath);
    }
    
    // 找出最短的一列和该列的最大Y值(将新的cell添加到最短一列)
    CGFloat maxY = [self.colMaxYs[0] floatValue];
    NSInteger minCol = 0;
    for (NSInteger i = 1; i < self.colMaxYs.count; i ++) {
        CGFloat colY = [self.colMaxYs[i] floatValue];
        if (maxY > colY) {
            maxY = colY;
            minCol = i;
        }
    }
    
    CGFloat cellX = defaultInsets.left + minCol * (cellW + colMargin);
    CGFloat cellY = maxY + rowMargin;
    // 设置新的cellframe
    attrs.frame = CGRectMake(cellX, cellY, cellW, cellH);
    
    // 更新该列的最大Y值
    self.colMaxYs[minCol] = [NSNumber numberWithFloat:CGRectGetMaxY(attrs.frame)];
    
    return attrs;
}

@end
