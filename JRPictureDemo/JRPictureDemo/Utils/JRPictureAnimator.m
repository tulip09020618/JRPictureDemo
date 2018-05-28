//
//  JRPictureAnimator.m
//  JRPictureDemo
//
//  Created by hqtech on 2018/5/28.
//  Copyright © 2018年 tulip. All rights reserved.
//

#import "JRPictureAnimator.h"

@interface JRPictureAnimator ()

/**
 记录当前动画是弹出还是消失
 */
@property (nonatomic, assign) BOOL presented;

@end

@implementation JRPictureAnimator

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    self.presented = YES;
    return self;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    self.presented = NO;
    return self;
}

#pragma mark 设置转场动画时间
- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.5;
}

#pragma mark 转场动画
- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    if (self.presented) {
        [self animateTransitionForPresent:transitionContext];
    }else {
        [self animateTransitionForDismiss:transitionContext];
    }
}

#pragma mark 自定义弹出转场动画
- (void)animateTransitionForPresent:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIView *presentView = [transitionContext viewForKey:UITransitionContextToViewKey];
    // 将执行的View添加到containerView上
    [transitionContext.containerView addSubview:presentView];
    
    // 获取动画开始位置
    CGRect startRect = [self.presentDelegate presentStartRect:self.indexPath];
    // 获取动画结束位置
    CGRect endRect = [self.presentDelegate presentEndRect:self.indexPath];
    // 获取要查看的图片
    UIImageView *imageView = [self.presentDelegate presentImgView:self.indexPath];
    // 将要查看的图片添加到containerView上
    [transitionContext.containerView addSubview:imageView];
    imageView.frame = startRect;
    
    // 查看动画
    presentView.alpha = 0;
    transitionContext.containerView.backgroundColor = [UIColor blackColor];
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        imageView.frame = endRect;
    }completion:^(BOOL finished) {
        presentView.alpha = 1.0;
        [imageView removeFromSuperview];
        transitionContext.containerView.backgroundColor = [UIColor clearColor];
        [transitionContext completeTransition:YES];
    }];
}

#pragma mark 自定义消失动画
- (void)animateTransitionForDismiss:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIView *dismissView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    [dismissView removeFromSuperview];
    
    // 要取消查看的图片
    UIImageView *imageView = [self.dismissDelegate dismissImgView];
    // 将要取消查看的图片添加到containerView上
    [transitionContext.containerView addSubview:imageView];
    
    // 取消动画
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        imageView.frame = [self.presentDelegate presentStartRect:self.indexPath];
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
    }];
}

@end
