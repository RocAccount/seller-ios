//
//  ResultModel.h
//  SellerPad
//
//  Created by zhuyuming-MAC on 2018/5/16.
//  Copyright © 2018年 zhuyuming-MAC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"
#import "UserModel.h"
#import "ContentModel.h"
#import "MonthDayCalendarInfoModel.h"
#import "CategoryModel.h"
#import "MerchantConfigModel.h"
#import "CustomerModel.h"





@interface ResultUserModel : JSONModel
@property(nonatomic,assign) int State;
@property(nonatomic,strong) NSString<Optional>* Message;
@property(nonatomic,strong) LoginUserModel<Optional> *Value;
@end


@interface ResourceList : JSONModel
@property(nonatomic,copy)  NSArray<UserModel,Optional> *UserList;
@property (strong, nonatomic) NSArray<ContentModel,Optional> *ContentList;
@property(nonatomic,strong)  NSArray<MonthDayCalendarInfoModel,Optional> *CalendarList;
@property(nonatomic,strong)  NSArray<CategoryModel,Optional> *CategoryList;
@property(nonatomic,strong)  NSArray<MerchantConfigModel,Optional> *MerchantConfigList;
@end


@interface ResultContentsModel : JSONModel
@property(nonatomic,assign) int State;
@property(nonatomic,strong) NSString<Optional> *Message;
@property(nonatomic,strong)  ResourceList<Optional> *Value;
@end


@interface ResultCustomerModel : JSONModel
@property(nonatomic,assign) int State;
@property(nonatomic,strong) NSString<Optional> *Message;
@property(nonatomic,strong)  CustomerModel<Optional> *Value;
@end


@interface ResultResourceUpdateTime : JSONModel
@property(nonatomic,assign) int State;
@property(nonatomic,strong) NSString<Optional> *Message;
@property(nonatomic,strong) NSString<Optional> *Value;
@end


@interface ResultProgressModel : JSONModel
@property(nonatomic,assign) int State;
//0为json（数据）,1为资源,2为不需要加载情况
@property(nonatomic,assign) int Type;
@property(nonatomic,strong) NSString<Optional> *Message;
@property(nonatomic,strong) NSString<Optional> *Progress;
@property(nonatomic,assign) int Count;
@end


@interface CustomerModels : JSONModel
@property(nonatomic,strong)  NSArray<CustomerModel,Optional> *customers;
@end




