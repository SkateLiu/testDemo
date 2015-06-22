//
//  LeftSideTableViewCell.m
//  BodyScaleProduction
//
//  Created by Go Salo on 14-5-15.
//  Copyright (c) 2014年 Go Salo. All rights reserved.
//

#import "LeftSideTableViewCell.h"
#import "ThemeManager.h"

@implementation LeftSideTableViewCell

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ThemeDidChangeNotification object:nil];
}

- (void)awakeFromNib {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themeChange:) name:ThemeDidChangeNotification object:nil];
    
    self.textLabel.textColor = [UIColor whiteColor];
    self.textLabel.font = [UIFont systemFontOfSize:15.0f];
    
    UIView *selectedView = [UIView new];
    selectedView.backgroundColor = [ThemeManager sharedManager].themeColor;
    self.selectedBackgroundView = selectedView;
}

- (void)themeChange:(NSNotification *)notification {
    self.selectedBackgroundView.backgroundColor = [ThemeManager sharedManager].themeColor;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    
    if (self.accessoryView && [self.accessoryView isKindOfClass:[UILabel class]]) {
        [(UILabel *)self.accessoryView setBackgroundColor:[UIColor colorWithRed:230/255.0 green:47/255.0 blue:52/255.0 alpha:1]];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    if (self.accessoryView && [self.accessoryView isKindOfClass:[UILabel class]]) {
        [(UILabel *)self.accessoryView setBackgroundColor:[UIColor colorWithRed:230/255.0 green:47/255.0 blue:52/255.0 alpha:1]];
    }
}

@end