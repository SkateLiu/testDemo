//
//  SettingButton.m
//  BodyScale
//
//  Created by cxx on 14-11-21.
//  Copyright (c) 2014年 August. All rights reserved.
//

#import "SettingButton.h"

@implementation SettingButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)setImage:(UIImage *)image WithText:(NSString *)text
{
    CGSize titleSize = [text sizeWithFont: [UIFont systemFontOfSize:14]];
      CGSize imgSize = self.imageView.frame.size;
    [self.imageView setContentMode:UIViewContentModeLeft];
    [self setImageEdgeInsets:UIEdgeInsetsMake(0, imgSize.height, 0, 0)];
    [self setImage:image forState:UIControlStateNormal];
    
    [self.titleLabel setContentMode:UIViewContentModeCenter];
    [self.titleLabel setBackgroundColor:[UIColor clearColor]];
    [self.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [self.titleLabel setTextColor:[UIColor whiteColor]];
    CGSize size = self.titleLabel.frame.size;
    size.width = titleSize.width;
  
    [self setTitleEdgeInsets:UIEdgeInsetsMake(0, size.width/2, 0.0, 0)];
    [self setTitle:text forState:UIControlStateNormal];
}
@end