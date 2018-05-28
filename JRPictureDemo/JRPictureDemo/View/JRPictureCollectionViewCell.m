//
//  JRPictureCollectionViewCell.m
//  JRPictureDemo
//
//  Created by hqtech on 2018/5/27.
//  Copyright © 2018年 tulip. All rights reserved.
//

#import "JRPictureCollectionViewCell.h"

@interface JRPictureCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

@end

@implementation JRPictureCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setTitle:(NSString *)title {
    _title = title;
    
    self.titleLabel.text = title;
    CGFloat titleHeight = [JRUtils getHeight:title fontSize:17 width:self.bounds.size.width];
    self.titleLabel.frame = CGRectMake(0, 0, self.bounds.size.width, titleHeight);
}

- (void)setContent:(NSString *)content {
    _content = content;
    
    self.contentLabel.text = content;
    CGFloat contentHeight = [JRUtils getHeight:content fontSize:12 width:self.bounds.size.width];
    self.contentLabel.frame = CGRectMake(0, CGRectGetMaxY(self.titleLabel.frame), self.bounds.size.width, contentHeight);
    
    self.imgView.frame = CGRectMake(0, CGRectGetMaxY(self.contentLabel.frame), self.bounds.size.width, self.bounds.size.height - CGRectGetMaxY(self.contentLabel.frame));
}

- (void)dealloc {
    NSLog(@"cell dealloc");
    self.imgView = nil;
}

@end
