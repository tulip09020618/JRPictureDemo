//
//  JRPictureFlowLayout.h
//  JRPictureDemo
//
//  Created by hqtech on 2018/5/27.
//  Copyright © 2018年 tulip. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JRPictureFlowLayout : UICollectionViewFlowLayout

/**
 获取cell高度
 */
@property (nonatomic, copy) CGFloat (^ itemHeightBlock) (CGFloat itemWidth, NSIndexPath *indexPath, CGFloat width);

@end
