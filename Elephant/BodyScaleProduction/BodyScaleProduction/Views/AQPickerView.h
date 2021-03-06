//
//  AQPickerView.h
//  AQPickerView
//
//  Created by Zhanghao on 6/5/14.
//  Copyright (c) 2014 Zhanghao. All rights reserved.
//

#import <UIKit/UIKit.h>

// 预留接口，以便扩展其他类型
typedef NS_ENUM(NSUInteger, AQPickerMode) {
    AQPickerModeYearMonthDay = 0    // 显示年月日
};

@class AQPickerView;

@protocol AQPickerViewDelegate <NSObject>

@optional
- (void)cancelButtonTapped:(AQPickerView *)pickerView;
- (void)savedWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day;
- (void)pickerViewWillDismiss:(AQPickerView *)pickerView;
- (void)pickerViewDidDismiss:(AQPickerView *)pickerView;
- (void)pickerViewDidStopWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day;

@end


#define Picker_View_Default_Height      224

@interface AQPickerView : UIView

@property (nonatomic, copy) NSString *title;
@property (nonatomic, weak) IBOutlet id<AQPickerViewDelegate> delegate;

@property (nonatomic, assign, readonly) BOOL didShow;

@property (nonatomic, readonly)NSInteger cYear;
@property (nonatomic, readonly)NSInteger cMonth;
@property (nonatomic, readonly)NSInteger cDay;

/**
 *  初始年龄在10-100之间
 */
- (id)initWithFrame:(CGRect)frame initialAge:(NSInteger)initialAge initialMonth:(NSInteger)initialMonth initialDay:(NSInteger)initialDay;
- (void)show;
- (void)dismiss;

@end
