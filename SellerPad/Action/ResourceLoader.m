//
//  ResourceLoader.m
//  SellerPad
//
//  Created by zhuyuming-MAC on 2018/5/24.
//  Copyright © 2018年 zhuyuming-MAC. All rights reserved.
//

#import "ResourceLoader.h"

@implementation ResourceLoader
-(id)init{
    if(self = [super init]){
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"config.plist" ofType:nil];
        NSDictionary *config = [[NSDictionary alloc] initWithContentsOfFile:filePath];
        self.PageCount = PAGECOUNT;
        self.DownPropDict = config[@"downPropDict"];
        self.DownloadList = [NSMutableArray array];
        switch (MODEL) {
            case 0:
                self.HostName =config[@"LocalUrl"];
                break;
            case 1:
                self.HostName = config[@"DevUrl"];
                break;
            case 2:
                self.HostName = config[@"ProductUrl"];
                break;
            default:
                self.HostName = config[@"ProductUrl"];
                break;
        }
        self.sema = dispatch_semaphore_create(1);
        self.ResourceUpdateTime = [self getResourceUpdateTime:@"ResourceUpdateTime"];
        self.DownloadCount = 0;
    }
    return  self;
}



-(void)cbResourceDownState:(resourceDownState)cbResourceDownStateBlock{
    self.cbResourceDownState = cbResourceDownStateBlock;
}


-(void)getContents:(int)type stepId:(long)stepId pageKey:(int)pageKey
{

    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"type"]=[NSNumber numberWithInt:type];
    params[@"stepId"]=[NSNumber numberWithLong:stepId];
    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:@"UToken"];
    [manager.requestSerializer setValue:token forHTTPHeaderField:@"token"];
    NSString *url =[NSString stringWithFormat:@"%@api/v1/contents?stepId=%ld&type=%d",self.HostName,stepId,type];
    [manager GET:url parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        ResultProgressModel *info = [[ResultProgressModel alloc] init];
        info.Progress = [NSString stringWithFormat:@"%d",pageKey/self.PageCount];
        info.State = 0;
        info.Count = self.PageCount;

        self.cbResourceDownState(info);
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        
    }];
}

-(void)getLastResourceUpdateTime
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:@"UToken"];
    [manager.requestSerializer setValue:token forHTTPHeaderField:@"token"];
    NSString *url =[NSString stringWithFormat:@"%@api/v1/resourcetime",self.HostName];
    [manager GET:url parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        ResultResourceUpdateTime *result = [[ResultResourceUpdateTime alloc] initWithDictionary:responseObject error:nil];
        if(result!=NULL&&result!=nil){
            if([result.Value isEqualToString:self.ResourceUpdateTime])
            {
                ResultProgressModel *info = [[ResultProgressModel alloc] init];
                info.Progress =0;
                info.Type = 2;
                info.Count = 1;
                self.cbResourceDownState(info);
            }
            else{
                [self saveDataInfo:@"LastResourceTimeTmp" value:result.Value];
                [self updateAllPageJson];
            }
        }
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        
    }];
}

-(void)updateAllPageJson
{
    [self.DownloadList removeAllObjects];
    for(int i=0;i<self.PageCount;i++){
            AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            params[@"type"]=[NSNumber numberWithInt:0];
            params[@"stepId"]=[NSNumber numberWithLong:i];
            NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:@"UToken"];
            [manager.requestSerializer setValue:token forHTTPHeaderField:@"token"];
            NSString *url =[NSString stringWithFormat:@"%@api/v1/contents?stepId=%d&type=%d",self.HostName,i,0];
            [manager GET:url parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
                ResultContentsModel *result = [[ResultContentsModel alloc] initWithDictionary:responseObject error:nil];
                ResultProgressModel *info = [[ResultProgressModel alloc] init];
                [self findAllResources:result.Value.ContentList];
                [self saveDataInfo:[NSString stringWithFormat:@"page%d",i] value:result];
                
                info.Progress = [NSString stringWithFormat:@"%d",i];
                info.Type = 0;
                info.Count = self.PageCount;
                self.cbResourceDownState(info);

            } failure:^(NSURLSessionDataTask *operation, NSError *error) {
                
            }];
    }
}

-(void)findAllResources:(NSArray *)contentList
{
    
    for(id obj in contentList)
    {
        id dictObject = obj;
        if(![obj isKindOfClass:[NSDictionary class]]){
            dictObject = [obj toDictionary];
        }
        
        for(NSString *key in dictObject){
            id value = dictObject[key];
            if([value isKindOfClass:[NSArray class]]&&[[NSArray alloc] initWithArray:value].count>0){
                [self findAllResources:value];
            }else{
                if(self.DownPropDict[key]&&value!=nil){
                    [self.DownloadList removeObject:value];
                    [self.DownloadList addObject:value];
                    if([[dictObject allKeys] containsObject:@"ContentId"]&&(!dictObject[@"PreviewImageUrl"]))
                    {
                        NSArray *array = [value componentsSeparatedByString:@"."];
                        NSString *name=[array[0] stringByAppendingFormat:@"%@%@",@"_x_150_94.",array[1]];
                        [self.DownloadList removeObject:name];
                        [self.DownloadList addObject:name];
                    }
                }
            }
        }
    }
    self.DownloadCount = [self.DownloadList count];
}
    
    

//-(void)updateAllPageResources
//{
//    NSArray *array =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *homePath = array.firstObject;
//     NSFileManager *fileManager = [NSFileManager defaultManager];
//
////        dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
//    dispatch_queue_t queue = dispatch_queue_create("com.gcd.dispatchApply.serialQueue", NULL);
//    dispatch_apply([self.DownloadList count],queue, ^(size_t index) {
//        NSString *url =[NSString stringWithFormat:@"%@%@",self.HostName,[self.DownloadList objectAtIndex:index]];
//        ResultProgressModel *info = [[ResultProgressModel alloc] init];
//        NSString *fileName = url.lastPathComponent;
//        NSString *path = [[self.DownloadList objectAtIndex:index] stringByReplacingOccurrencesOfString:url.lastPathComponent withString:@""];
//        NSString *sPath = [homePath stringByAppendingPathComponent:path];
//        NSString *savePath = [sPath stringByAppendingPathComponent:fileName];
//        if(![fileManager fileExistsAtPath:sPath])
//        {
//            [fileManager createDirectoryAtPath:sPath withIntermediateDirectories:YES attributes:nil error:nil];
//        }
//        if(![fileManager fileExistsAtPath:savePath]){
//            [self downloadFileWithURL:url parameters:nil savedPath:savePath downloadSuccess:^(NSURLResponse *response, NSURL *filePath) {
//                //                    NSLog(@"downloaded:%@,%@",filePath,savePath);
//                info.Type = 1;
//                info.Count = self.DownloadCount;
//                self.cbResourceDownState(info);
//
//            } downloadFailure:^(NSError *error) {
//                NSLog(@"downloadfileure:%@",error);
//                if([fileManager fileExistsAtPath:savePath]){
//                    [fileManager removeItemAtPath:savePath error:nil];
//                }
//                info.Type = 3;
//                self.cbResourceDownState(info);
//            } downloadProgress:^(NSProgress *downloadProgress) {
//
//            }];
//        }
//        else{
//            NSLog(@"hasfile:");
//            info.Type = 1;
//            info.Count = self.DownloadCount;
//            self.cbResourceDownState(info);
//        }
//    });
//
//}


-(void)updateAllPageResources2{
    [self clearCachesFromDirectoryPath:NSTemporaryDirectory()];
    [self downResourceInfo:[self.DownloadList objectAtIndex:0]];
}


-(void)downResourceInfo:(NSString*)item{
    NSArray *array =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *homePath = array.firstObject;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *url =[NSString stringWithFormat:@"%@%@",self.HostName,item];
    ResultProgressModel *info = [[ResultProgressModel alloc] init];
    NSString *fileName = url.lastPathComponent;
    NSString *path = [item stringByReplacingOccurrencesOfString:url.lastPathComponent withString:@""];
    NSString *sPath = [homePath stringByAppendingPathComponent:path];
    NSString *savePath = [sPath stringByAppendingPathComponent:fileName];
    
    if(![fileManager fileExistsAtPath:sPath])
    {
        [fileManager createDirectoryAtPath:sPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    if(![fileManager fileExistsAtPath:savePath]){
        [self downloadFileWithURL:url hpath:homePath parameters:nil savedPath:savePath downloadSuccess:^(NSURLResponse *response, NSURL *filePath) {
            //                    NSLog(@"downloaded:%@,%@",filePath,savePath);
            info.Type = 1;
            info.Count = self.DownloadCount;
            self.cbResourceDownState(info);
            [self.DownloadList removeObject:item];
            if([self.DownloadList count]>0){
                [self downResourceInfo:[self.DownloadList objectAtIndex:0]];
            }
        } downloadFailure:^(NSError *error) {
            NSLog(@"downloadfileure:%@",error);
            if([fileManager fileExistsAtPath:savePath]){
                [fileManager removeItemAtPath:savePath error:nil];
            }
            info.Type = 3;
            self.cbResourceDownState(info);
//            [self.DownloadList removeObject:item];
//            if([self.DownloadList count]>0){
//                [self downResourceInfo:[self.DownloadList objectAtIndex:0]];
//            }
        } downloadProgress:^(NSProgress *downloadProgress) {
        }];
    }
    else{
        NSLog(@"hasfile:");
        info.Type = 1;
        info.Count = self.DownloadCount;
        self.cbResourceDownState(info);
//        int pre1 =[self.DownloadList count];
        
        [self.DownloadList removeObject:item];
//        int pre2 = [self.DownloadList count];
//        NSLog(@"pre:%d-preafter:%d,allcount:%d",pre1,pre2,self.DownloadCount);
//        if(pre1-pre2>1){
//            NSLog(@"haha");
//        }
        if([self.DownloadList count]>0){
            [self downResourceInfo:[self.DownloadList objectAtIndex:0]];
        }

    }
    
}

- (void)downloadFileWithURL:(NSString*)requestURLString
                      hpath:(NSString*)hpath
                 parameters:(NSDictionary *)parameters
                  savedPath:(NSString*)savedPath
            downloadSuccess:(void (^)(NSURLResponse *response, NSURL *filePath))success
            downloadFailure:(void (^)(NSError *error))failure
           downloadProgress:(void (^)(NSProgress *downloadProgress))progress

{

    AFHTTPRequestSerializer *serializer = [AFHTTPRequestSerializer serializer];
    NSMutableURLRequest *request =[serializer requestWithMethod:@"GET" URLString:requestURLString parameters:parameters error:nil];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSURLSessionDownloadTask *task = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        progress(downloadProgress);
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {        
        return [NSURL fileURLWithPath:savedPath];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if(error){
            failure(error);
        }else{
            success(response,filePath);
        }

    }];
    [task resume];
}


-(void)saveDataInfo:(NSString *)jsonName value:(ResultContentsModel *)value
{
    //归档
    NSMutableData *data = [[NSMutableData alloc] init];
    //创建归档辅助类
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    //编码
    [archiver encodeObject:value forKey:jsonName];
    //结束编码
    [archiver finishEncoding];
    //写入到沙盒
    NSArray *array =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *fileName = [array.firstObject stringByAppendingPathComponent:jsonName];
    if([data writeToFile:fileName atomically:YES]){
        NSLog(@"归档成功:%@",fileName);
    }
}

-(void)saveResourceUpdateTime:(NSString *)jsonName value:(NSString *)value
{
    //    NSArray *array = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //    NSString *documents = [array lastObject];
    //    NSString *documentPath = [documents stringByAppendingPathComponent:jsonName];
    //    [NSKeyedArchiver archiveRootObject:value toFile:documentPath];
    
    //归档
    NSMutableData *data = [[NSMutableData alloc] init];
    //创建归档辅助类
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    //编码
    [archiver encodeObject:value forKey:jsonName];
    //结束编码
    [archiver finishEncoding];
    //写入到沙盒
    NSArray *array =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *fileName = [array.firstObject stringByAppendingPathComponent:jsonName];
    if([data writeToFile:fileName atomically:YES]){
        //NSLog(@"归档成功:%@",fileName);
    }
}


-(NSString *)getResourceUpdateTime:(NSString *)jsonName
{
    //解档
    NSArray *array =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *fileName = [array.firstObject stringByAppendingPathComponent:jsonName];
    NSData *undata = [[NSData alloc] initWithContentsOfFile:fileName];
    //解档辅助类
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:undata];
    //解码并解档出model
    NSString *unModel = [unarchiver decodeObjectForKey:jsonName];
    //NSLog(@"%@",unModel);
    //关闭解档
    [unarchiver finishDecoding];
    
    return unModel;
}

-(void)changeResourceUpdateTime
{
    NSString *time = [self getResourceUpdateTime:@"LastResourceTimeTmp"];
    [self saveResourceUpdateTime:@"ResourceUpdateTime" value:time];
}

-(ResultContentsModel *)getDataInfo:(NSString *)jsonName
{
    //解档
    NSArray *array =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *fileName = [array.firstObject stringByAppendingPathComponent:jsonName];
    NSData *undata = [[NSData alloc] initWithContentsOfFile:fileName];
    //解档辅助类
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:undata];
    //解码并解档出model
    ResultContentsModel *unModel = [unarchiver decodeObjectForKey:jsonName];
    //NSLog(@"%@",unModel);
    unModel.Message = array.firstObject;
    //关闭解档
    [unarchiver finishDecoding];
    return unModel;
}

-(ResultCustomerModel *)getCustomerInfo:(NSString *)jsonName{
    NSArray *array =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *fileName = [array.firstObject stringByAppendingPathComponent:jsonName];
    NSData *undata = [[NSData alloc] initWithContentsOfFile:fileName];
    //解档辅助类
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:undata];
    //解码并解档出model
    ResultCustomerModel *unModel = [unarchiver decodeObjectForKey:jsonName];
    
    //关闭解档
    [unarchiver finishDecoding];
    return unModel;
}

-(void)saveCusomerInfo:(NSString *)jsonName value:(ResultCustomerModel *)value{
    //归档
    NSMutableData *data = [[NSMutableData alloc] init];
    //创建归档辅助类
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    //编码
    [archiver encodeObject:value forKey:jsonName];
    //结束编码
    [archiver finishEncoding];
    //写入到沙盒
    NSArray *array =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *fileName = [array.firstObject stringByAppendingPathComponent:jsonName];
    if([data writeToFile:fileName atomically:YES]){
        NSLog(@"归档成功:%@",fileName);
    }
}

- (NSArray *)getAllFileNames:(NSString *)dirPath{
    NSArray *files = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:dirPath error:nil];
    return files;
}
- (BOOL)clearCachesWithFilePath:(NSString *)path{
    NSFileManager *mgr = [NSFileManager defaultManager];
    return [mgr removeItemAtPath:path error:nil];
}


- (BOOL)clearCachesFromDirectoryPath:(NSString *)dirPath{
    
    //获得全部文件数组
    NSArray *fileAry =  [self getAllFileNames:dirPath];
    //遍历数组
    BOOL flag = NO;
    for (NSString *fileName in fileAry) {
        NSString *filePath = [dirPath stringByAppendingPathComponent:fileName];
        flag = [self clearCachesWithFilePath:filePath];
        
        if (!flag)
            break;
    }
    
    return flag;
}
    
-(void)saveOFFLineCustomerInfo:(CustomerModel*) model isAdd:(BOOL)isAdd{
    //解档
    NSArray *array =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *fileName = [array.firstObject stringByAppendingPathComponent:@"OffLineCustomerInfo"];
    NSData *undata = [[NSData alloc] initWithContentsOfFile:fileName];
    //解档辅助类
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:undata];
    //解码并解档出model
    NSMutableArray<CustomerModel> *customerList = [unarchiver decodeObjectForKey:@"OffLineCustomerInfo"];
    //关闭解档
    [unarchiver finishDecoding];
    
    if(customerList!=NULL&&customerList.count>0)
    {
        if(isAdd){
            [customerList addObject:model];
        }else{
            if(model!=NULL){
                [customerList removeLastObject];
                [customerList addObject:model];
            }
            else{
                [customerList removeAllObjects];
            }
        }
    }
    else{
        if(model!=NULL){
            customerList = [[NSMutableArray<CustomerModel> alloc]initWithObjects:model,nil];
        }
    }
    
    //归档
    NSMutableData *data = [[NSMutableData alloc] init];
    //创建归档辅助类
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    //编码
    [archiver encodeObject:customerList forKey:@"OffLineCustomerInfo"];
    //结束编码
    [archiver finishEncoding];
    //写入到沙盒
    if([data writeToFile:fileName atomically:YES]){
        NSLog(@"归档成功:%@",fileName);
    }
}
    
    
-(NSArray<CustomerModel>*)getOFFLineCustomerInfo{
    //解档
    NSArray *array =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *fileName = [array.firstObject stringByAppendingPathComponent:@"OffLineCustomerInfo"];
    NSData *undata = [[NSData alloc] initWithContentsOfFile:fileName];
    //解档辅助类
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:undata];
    //解码并解档出model
    NSMutableArray<CustomerModel> *customerList = [unarchiver decodeObjectForKey:@"OffLineCustomerInfo"];
    //关闭解档
    [unarchiver finishDecoding];
    return customerList;
}

+(NSString*)getCurrentTimes{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    
    //现在时间,你可以输出来看下是什么格式
    
    NSDate *datenow = [NSDate date];
    
    //----------将nsdate按formatter格式转成nsstring
    
    NSString *currentTimeString = [formatter stringFromDate:datenow];

    return currentTimeString;
    
}
    
@end
