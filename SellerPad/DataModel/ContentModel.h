//
//  ContentModel.h
//  SellerPad
//
//  Created by zhuyuming-MAC on 2018/5/7.
//  Copyright © 2018年 zhuyuming-MAC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"


@interface ContentImageItem : JSONModel
@property(nonatomic,assign) int State;
@property(nonatomic,strong) NSString<Optional> *ImageUrl;
@property(nonatomic,strong) NSString<Optional> *TmpImageUrl;
@end

@interface ContentImage :JSONModel
@property (nonatomic,assign) long Id;
@property(nonatomic,strong) NSString<Optional> *ContentId;
@property(nonatomic,strong) NSString<Optional> *ImageUrl;
@property(nonatomic,strong) NSString<Optional> *Type;
@property(nonatomic,strong) NSString<Optional> *OrderNum;
@property(nonatomic,strong) NSString<Optional> *PreviewImageUrl;
@property(nonatomic,strong) NSString<Optional> *Width;
@property(nonatomic,strong) NSString<Optional> *Height;
@end

@protocol ContentImage <NSObject>
@end

@interface ContentModel : JSONModel

@property (nonatomic,assign) long Id;

@property(nonatomic,strong) NSString<Optional> *Name;

@property(nonatomic,strong) NSString<Optional> *EName;

@property(nonatomic,strong) NSDate<Optional> *PublishTime;

@property(nonatomic,strong) NSDate<Optional> *UpdateTime;

@property(nonatomic,strong) NSString<Optional> *Text;

@property(nonatomic,strong) NSString<Optional> *Summary;

@property(nonatomic,strong) NSString<Optional> *Link;

@property(nonatomic,strong) NSString<Optional> *Type;

@property(nonatomic,strong) NSString<Optional> *State;

@property(nonatomic,strong) NSString<Optional> *KeyWords;

@property(nonatomic,strong) NSString<Optional> *ImageUrl;

@property(nonatomic,strong) NSString<Optional> *FilePath;

@property(nonatomic,strong) NSString<Optional> *Source;

@property(nonatomic,strong) NSString<Optional> *ResourcePath;

@property(nonatomic,strong) NSString<Optional> *OrderNum;

@property(nonatomic,strong) NSString<Optional> *VideoPath;

@property(nonatomic,strong) NSString<Optional> *StoreId;

@property(nonatomic,strong) NSString<Optional> *UserId;

@property(nonatomic,strong) NSString<Optional> *MerchantId;

@property(nonatomic,strong) NSString<Optional> *StepId;

@property(nonatomic,strong) NSString<Optional> *ItemId;

@property(nonatomic,strong) NSString<Optional> *CategoryId;

@property(nonatomic,strong) NSString<Optional> *IsHide;

@property(nonatomic,strong) NSString<Optional> *PreviewImageUrl;

@property(nonatomic,strong) NSString<Optional> *CategoryName;

@property(nonatomic,strong) NSArray<ContentImage,Optional> *Images;

@end

@protocol ContentModel <NSObject>
@end



