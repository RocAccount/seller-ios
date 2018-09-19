//
//  MonthDayCalendarInfoModel.h
//  SellerPad
//
//  Created by zhuyuming-MAC on 2018/5/7.
//  Copyright © 2018年 zhuyuming-MAC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"
@interface MonthDayCalendarInfoModel : JSONModel
@property(nonatomic,strong) NSString<Optional> *Day;
@property(nonatomic,strong) NSString<Optional> *DayNum;
@property(nonatomic,strong) NSString<Optional> *Value;
@property(nonatomic,strong) NSString<Optional> *SeatValue;
@property(nonatomic,strong) NSString<Optional> *DayOfWeek;
@property(nonatomic,strong) NSString<Optional> *CalendarId;
@property(nonatomic,assign) int IsNeedShow;
@end

@protocol MonthDayCalendarInfoModel <NSObject>
@end
