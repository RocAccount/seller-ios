//
//  ResourceLoader.h
//  SellerPad
//
//  Created by zhuyuming-MAC on 2018/5/24.
//  Copyright © 2018年 zhuyuming-MAC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPSessionManager.h"
#import "JSONModel.h"
#import "ResultModel.h"
#import "ContentModel.h"

//0 152,1 sellertest,2 seller
#define MODEL 2
#define PAGECOUNT 18

typedef void(^resourceDownState)(ResultProgressModel *downState);

@interface ResourceLoader : NSObject
@property(strong,nonatomic) NSString *HostName;
@property(strong,nonatomic) NSString *ResourceUpdateTime;
@property(assign,nonatomic) int PageCount;
@property(strong,nonatomic) NSDictionary *DownPropDict;
@property(strong,nonatomic) NSMutableArray *DownloadList;
@property(assign,nonatomic) int DownloadCount;
@property(strong,nonatomic) dispatch_semaphore_t sema;
//@property(assign,nonatomic) int ResourceType;
@property (strong,nonatomic) resourceDownState cbResourceDownState;
-(void)cbResourceDownState:(resourceDownState)cbResourceDownStateBlock;
-(void)getContents:(int)type stepId:(long)stepId;
-(void)updateAllPageJson;
-(void)updateAllPageResources;
-(void)updateAllPageResources2;
-(ResultContentsModel *)getDataInfo:(NSString *)jsonName;
-(void)changeResourceUpdateTime;
-(void)getLastResourceUpdateTime;
+ (NSString *)getTmpDirectory;
+ (BOOL)clearCachesFromDirectoryPath:(NSString *)dirPath;
-(NSArray<CustomerModel>*)getOFFLineCustomerInfo;
-(void)saveOFFLineCustomerInfo:(CustomerModel*) model isAdd:(BOOL)isAdd;
+(NSString *)getCurrentTimes;
@end
