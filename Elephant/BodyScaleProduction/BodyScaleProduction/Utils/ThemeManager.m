//
//  ThemeManager.m
//
//  Created by Zhanghao on 6/6/14.
//  Copyright (c) 2014 Zhanghao. All rights reserved.
//

#import "ThemeManager.h"

#define Current_Theme           @"Current_Theme"
#define Theme_Document_Name     @"Theme"            // 对应主题文件目录名

#define Theme_Classic_Color     [UIColor colorWithRed:35/255.0 green:122/255.0 blue:219/255.0 alpha:1]
#define Theme_Red_Color         [UIColor colorWithRed:229/255.0 green:58/255.0 blue:118/255.0 alpha:1]
#define Theme_Blue_Color        [UIColor colorWithRed:35/255.0 green:122/255.0 blue:219/255.0 alpha:1]
#define Theme_Purple_Color      [UIColor colorWithRed:177/255.0 green:109/255.0 blue:213/255.0 alpha:1]
#define Theme_Green_Color       [UIColor colorWithRed:130/255.0 green:192/255.0 blue:66/255.0 alpha:1]
#define Theme_Yellow_Color      [UIColor colorWithRed:238/255.0 green:178/255.0 blue:38/255.0 alpha:1]

NSString *const ThemeDidChangeNotification = @"ThemeDidChangeNotification";

@interface ThemeManager ()

@property (nonatomic, copy) NSString *themePath;
@property (nonatomic, assign, readwrite) ThemeStyle style;

@end

@implementation ThemeManager

#pragma mark - Init Methods

+ (instancetype)sharedManager {
    static ThemeManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[ThemeManager alloc] init];
    });
    return manager;
}

+ (void)initialize {
    NSString *defaultTheme = [[NSUserDefaults standardUserDefaults] objectForKey:Current_Theme];
    if (!defaultTheme) {
        [[NSUserDefaults standardUserDefaults] setObject:@(ThemeStyleClassic) forKey:Current_Theme];
    }
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _style = ThemeStyleClassic;
    }
    return self;
}

#pragma mark - Getter

- (ThemeStyle)style {
    return [(NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:Current_Theme] intValue];
}

- (NSString *)themePath {
    NSString *themeName = [NSString stringWithUTF8String:style_to_name[self.style].themeName];
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    NSString *themeBasePath = [resourcePath stringByAppendingPathComponent:Theme_Document_Name];
    return [themeBasePath stringByAppendingPathComponent:themeName];
}

- (UIColor *)themeColor {
    UIColor *color = nil;
    switch (self.style) {
        case ThemeStyleClassic:
            color = Theme_Classic_Color;
            break;
        case ThemeStyleRed:
            color = Theme_Red_Color;
            break;
        case ThemeStyleBlue:
            color = Theme_Blue_Color;
            break;
        case ThemeStylePurple:
            color = Theme_Purple_Color;
            break;
        case ThemeStyleGreen:
            color = Theme_Green_Color;
            break;
        case ThemeStyleYellow:
            color = Theme_Yellow_Color;
            break;
        default:
            break;
    }
    return color;
}

#pragma mark - Public Methods

- (UIImage *)themeImageNamed:(NSString *)imageName {
    if (!imageName || imageName.length == 0) {
        return nil;
    }
    
    NSString *imagePath = [self.themePath stringByAppendingPathComponent:imageName];
    
    CGFloat scale = [UIScreen mainScreen].scale;
    
    if ([imagePath hasSuffix:@".png"]) {
        // image.png -> image@2x.png
        if ((int)scale == 2) {
            // 如果是Retina屏幕，需要插入@2x
            imagePath = [[imagePath substringToIndex:imagePath.length - 4] stringByAppendingString:@"@2x.png"];
        }
    } else {
        if ((int)scale == 2) {
            imagePath = [imagePath stringByAppendingString:@"@2x"];
        }
        // 添加.png后缀
        imagePath = [imagePath stringByAppendingString:@".png"];
    }
    
    // 使用imageWithData函数的缓存测略来解决tableView滑动顿卡问题，
    // imageWithContentsOfFile这个函数无缓存，造成tableView滑动时加载image顿卡现象
    NSData *imageData = [NSData dataWithContentsOfFile:imagePath options:NSDataReadingMappedAlways error:nil];
    
    // 需要使用scale参数来调整Retina屏幕生成的图片
    UIImage *image = [UIImage imageWithData:imageData scale:scale];
    
    return image;
}

- (void)changeToTheme:(ThemeStyle)themeStyle {
    _style = themeStyle;

    [[NSUserDefaults standardUserDefaults] setObject:@(themeStyle) forKey:Current_Theme];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (kIsiOS_7) {
        UIImage *image = ThemeImage(@"navigation_bar_background_image_iOS7");
        [[UINavigationBar appearance] setBackgroundImage:image
                                           forBarMetrics:UIBarMetricsDefault];
    } else {
        UIImage *image = ThemeImage(@"navigation_bar_background_image_iOS6");
        [[UINavigationBar appearance] setBackgroundImage:image
                                           forBarMetrics:UIBarMetricsDefault];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ThemeDidChangeNotification object:nil];
}

@end
