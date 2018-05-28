//
//  JRPictureAnimator.h
//  JRPictureDemo
//
//  Created by hqtech on 2018/5/28.
//  Copyright © 2018年 tulip. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 查看图片的转场动画代理
 */
@protocol JRPictureAnimatorPresentDelegate <NSObject>

/**
 获取要查看图片相对于windows的位置

 @param indexPath 要查看图片所在cell的indexPath
 @return 要查看图片相对windows的位置
 */
- (CGRect)presentStartRect:(NSIndexPath *)indexPath;

/**
 获取要查看图片动画结束后的位置

 @param indexPath 要查看图片所在cell的indexPath
 @return 要查看图片动画结束后的位置
 */
- (CGRect)presentEndRect:(NSIndexPath *)indexPath;

/**
 获取要查看的图片

 @param indexPath 要查看图片所在cell的indexPath
 @return 要查看的图片
 */
- (UIImageView *)presentImgView:(NSIndexPath *)indexPath;

@end

/**
 取消查看的转场动画代理
 */
@protocol JRPictureAnimatorDismissDelegate <NSObject>

/**
 获取要取消查看的图片

 @return 要取消查看的图片
 */
- (UIImageView *)dismissImgView;

@end

@interface JRPictureAnimator : NSObject <UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) id<JRPictureAnimatorPresentDelegate> presentDelegate;
@property (nonatomic, assign) id<JRPictureAnimatorDismissDelegate> dismissDelegate;

/**
 要查看图片所在cell的indexPath
 */
@property (nonatomic, strong) NSIndexPath *indexPath;

@end
