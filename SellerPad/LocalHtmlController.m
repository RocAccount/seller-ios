//
//  UIViewController+LocalHtml.m
//  SellerPad
//
//  Created by zhuyuming-MAC on 2018/5/5.
//  Copyright © 2018年 zhuyuming-MAC. All rights reserved.
//

#import "LocalHtmlController.h"
#import "AFHTTPSessionManager.h"
#import "JSONModel.h"
#import "ResultModel.h"
#import "ResourceLoader.h"
#import "CustomerProtocol.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

@class CustomerModel;
@class UserModel;
@interface LocalHtmlController ()

#define UIColorFromHEXWithAlpha(rgbValue,a) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:a]

//@interface LocalHtmlController ()
@property (strong,nonatomic) UIWebView *webView;
@property (strong,nonatomic) WebViewJavascriptBridge* bridge;
@property (strong,nonatomic) ResourceLoader *rs;
//@property (weak, nonatomic) IBOutlet UIImageView *im;
@property (strong,nonatomic) UIProgressView *progress;
@property (strong,nonatomic) UILabel *downInfo;
@property (strong,nonatomic) UIView *bkView;
@property (nonatomic, strong) AFNetworkReachabilityManager *manager;
@property (assign,nonatomic) BOOL hasNetWork;
//音视频
@property (nonatomic,strong)AVPlayer *player;
//音视频控制器
@property (nonatomic,strong)AVPlayerViewController *playerVC;
@end

@implementation LocalHtmlController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self judgeNet];
    
    self.navigationController.navigationBarHidden=YES;
    
    self.view.backgroundColor = [UIColor blackColor];
    //wkwebview绑定
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"index.html" withExtension:nil];

    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    dispatch_semaphore_t s = dispatch_semaphore_create(1);
    [self.webView loadRequest:request];
    [self.view addSubview:self.webView];
    [self registerJsHandler:self.bridge];
    //数据加载
     self.rs = [[ResourceLoader alloc] init];

    ResultProgressModel *downStat = [[ResultProgressModel alloc] init];
    downStat.Progress = @"0";
    [self initProgressView];
    
    self.rs.cbResourceDownState = ^(ResultProgressModel *downState) {
        downStat.Count = downState.Count;
        downStat.State = downState.State;
        downStat.Type = downState.Type;
        if([NSThread isMainThread]){
            if(downStat.Count ==0 && downStat.Type==1 )
            {
                return;
            }

            //下载
            if(downStat.Type == 0){
                downStat.Progress = [NSString stringWithFormat:@"%d",[downStat.Progress intValue]+1];
                [self.downInfo setText:[NSString stringWithFormat:@"正在缓存页面资源:%@%%",[NSString stringWithFormat:@"%.2f",[downStat.Progress floatValue]/downStat.Count*100]]];
            }
            else if(downStat.Type == 1){
                downStat.Progress = [NSString stringWithFormat:@"%d",[downStat.Progress intValue]+1];
                [self.downInfo setText:[NSString stringWithFormat:@"正在缓存图片资源:%@%%",[NSString stringWithFormat:@"%.2f",[downStat.Progress floatValue]/downStat.Count*100]]];
            }
            else if(downStat.Type == 3){
                
                self.downInfo.text = @"下载出错请重新打开APP!";
                dispatch_wait(s, DISPATCH_TIME_FOREVER);
                return ;
            }
            
            
            if(self.bkView.isHidden){
                [self.bkView setHidden:false];
            }
        
            [self.progress setProgress:[downStat.Progress floatValue]/downStat.Count];
        
            if([downStat.Progress intValue]==downStat.Count&&downStat.Type==0)
            {
                self.progress.progress = 0.01;
                self.downInfo.text = @"正在缓存图片资源:0.01%";
                downStat.Progress = @"0";
                [self.rs updateAllPageResources2];
            }
            else if([downStat.Progress intValue]==downStat.Count&&downStat.Type==1){
                downStat.Progress = @"0";
                [self.bkView setHidden:true];
                [self.rs.DownloadList removeAllObjects];
                self.rs.DownloadCount = 0;
                [self.rs changeResourceUpdateTime];
                id obj = [self.rs getDataInfo:@"page0"];
                [self callJsHandler:self.bridge action:@"InitPage" data:[obj toJSONString]];
            }
            else if(downStat.Type==2){
                downStat.Progress = @"0";
                [self.bkView setHidden:true];
                id obj = [self.rs getDataInfo:@"page0"];
                [self callJsHandler:self.bridge action:@"InitPage" data:[obj toJSONString]];
            }
       
        }
        else
        {
            dispatch_sync(dispatch_get_main_queue(), ^{
                if(downStat.Type == 3){
                    self.downInfo.text = @"下载出错请重新打开APP!";
                }
            });
        }
        //NSLog(@"执行回掉：%.2f,%@",self.progress.progress,downStat);
    };
   [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(photoBack) name:@"back" object:nil];
}

-(void)photoBack{
    [NSURLProtocol registerClass:[CustomerProtocol class]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    /** 取消注册网路请求拦截 */
    [NSURLProtocol unregisterClass:[CustomerProtocol class]];
}

-(UIWebView *)webView
{
    if(_webView==nil){
//        WKWebViewConfiguration *configuration =
//        [[WKWebViewConfiguration alloc] init];
//        [configuration.preferences setValue:@YES forKey:@"allowFileAccessFromFileURLs"];
//        _webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:configuration];
        _webView = [[UIWebView alloc] initWithFrame:CGRectZero];
        _webView.scrollView.scrollEnabled = NO;
        _webView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
        [_webView setTranslatesAutoresizingMaskIntoConstraints:false];
        CGRect myRect=[UIScreen mainScreen].bounds;
        NSLog(@"screen:width:%f,height:%f",myRect.size.width,myRect.size.height);
        _webView.frame = CGRectMake(0, (myRect.size.height-myRect.size.width*9/16)/2, myRect.size.width, myRect.size.width*9/16);
        NSLog(@"screen:width:%f,height:%f",_webView.frame.size.width,_webView.frame.size.height);
        _webView.delegate = self;
        //_bridge = [WKWebViewJavascriptBridge bridgeForWebView:_webView];
        _bridge = [WebViewJavascriptBridge bridgeForWebView:_webView];
        [_bridge setWebViewDelegate:self];
        _webView.backgroundColor = [UIColor redColor];
    }
    return _webView;
}

-(void)initVideo:(NSString *)filePath {
    if(_playerVC==nil){
        _playerVC = [[AVPlayerViewController alloc] init];
        NSURL *fileurl = nil;
        if([filePath containsString:@"filelocal://"]){
            filePath = [filePath stringByReplacingOccurrencesOfString:@"filelocal://" withString:@""];
            NSArray *array =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *homePath = array.firstObject;
            NSString *path = [homePath stringByAppendingPathComponent:filePath];
            fileurl = [NSURL fileURLWithPath:path];
        }
        else{
            fileurl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:filePath ofType:nil]];
        }
        _player = [AVPlayer playerWithURL:fileurl];
        
        _playerVC.player = _player;
        CGRect myRect=[UIScreen mainScreen].bounds;
        _playerVC.view.frame = CGRectMake(0, (myRect.size.height-myRect.size.width*9/16)/2, myRect.size.width, myRect.size.width*9/16);
        _playerVC.videoGravity = AVLayerVideoGravityResizeAspect;
        _playerVC.showsPlaybackControls = YES;
      
        _playerVC.view.translatesAutoresizingMaskIntoConstraints = YES;
        
        UIButton *clearBtn = [[UIButton alloc] initWithFrame:CGRectMake(myRect.size.width-80,myRect.size.height-45,80,45)];
        clearBtn.backgroundColor = [UIColor blackColor];
        clearBtn.alpha = 0.02;
        [clearBtn addTarget:self action:@selector(clearPage:) forControlEvents:UIControlEventTouchUpInside];
       
        
       
        [self addChildViewController:_playerVC];
        [self.view addSubview:_playerVC.view];
        [self.view addSubview:clearBtn];
        [_playerVC.player play];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playbackFinished:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:self.player.currentItem];
    }
}


-(void)clearPage:(UIButton*)sender{
    [sender setHidden:true];
    [self destoryVideo];
}

- (void)playbackFinished:(NSNotification *)noti{
    NSLog(@"播完了!");
    [self destoryVideo];
}

-(void)destoryVideo{
    if (_playerVC) {
        [_playerVC removeFromParentViewController];
        [_playerVC.view removeFromSuperview];
        _playerVC = nil;
        if(_player){
            _player = nil;
        }
        
    }
}

-(void)registerJsHandler:(WebViewJavascriptBridge *)bridge{
    [bridge registerHandler:@"Log" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"JSLog:%@",data);
    }];
    
    [bridge registerHandler:@"GetLocalUserInfo" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"GetLocalUserInfo:%@",data);
        LoginUserModel * user = [[LoginUserModel alloc] init];;
        user.UserName = [[NSUserDefaults standardUserDefaults] objectForKey:@"UName"];
        user.StoreName = [[NSUserDefaults standardUserDefaults] objectForKey:@"UPwd"];
        
        NSLog(@"data:%@",user);
        responseCallback([user toJSONString]);
    }];
    
    [bridge registerHandler:@"Login" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"data:%@",data);
        //NSDictionary * info = [self dictionaryWithJsonString:data];
        [self login:[data objectForKey:@"username"] password: [data objectForKey:@"password"]];
    }];
    
    [bridge registerHandler:@"CustomerAdd" handler:^(id data, WVJBResponseCallback responseCallback) {
        [self customerAdd:[[CustomerModel alloc] initWithDictionary:data error:nil]];
    }];
    
    [bridge registerHandler:@"WorkOver" handler:^(id data, WVJBResponseCallback responseCallback) {
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        [self workOver:[[CustomerModel alloc] initWithDictionary:data error:nil]];
    }];
    
    [bridge registerHandler:@"GetContents" handler:^(id data, WVJBResponseCallback responseCallback) {
        //[self getContents:0 stepId:(long)[data objectForKey:@"stepId"]];
        NSLog(@"%@",data[@"stepId"]);
         id obj = [self.rs getDataInfo:[NSString stringWithFormat:@"page%@",data[@"stepId"]]];
         [self callJsHandler:self.bridge action:@"InitPage" data:[obj toJSONString]];

    }];
    
    [bridge registerHandler:@"PlayVideo" handler:^(id data, WVJBResponseCallback responseCallback) {
        [self initVideo:data[@"url"]];
    }];
    
    [bridge registerHandler:@"EnterPhotos" handler:^(id data, WVJBResponseCallback responseCallback) {
        
        PhotosVC* vc = [[PhotosVC alloc] init];
        vc.delegate = self;
        vc.contentItem = [[ContentModel alloc] initWithDictionary:[data[@"item"] mutableCopy] error:nil];
        [vc.view setBackgroundColor:UIColorFromHEXWithAlpha(0x3c3a3e,0.8)];
        //[self.navigationController pushViewController:vc animated:NO];
        [self presentViewController:vc animated:NO completion:nil];
        
    }];
}

-(void)callJsHandler:(WebViewJavascriptBridge *)bridge action:(NSString *)action data:(id)data{
    [bridge callHandler:action data:data];
}




-(void)customerAdd:(CustomerModel *)model
{
    if(self.hasNetWork){
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        params[@"customer"]=[model toDictionary];
        // 设置请求格式
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        // 设置返回格式
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        
        NSString *requestUrl = [NSString stringWithFormat:@"%@api/v1/customer",self.rs.HostName];

        [manager POST:requestUrl parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
            NSDictionary *dict = (NSDictionary *)responseObject;
            ResultCustomerModel *customer = [[ResultCustomerModel alloc] initWithDictionary:dict error:nil];
            
            //NSLog(@"%@", customer);
            
            [self callJsHandler:self.bridge action:@"GoPage" data:[customer toJSONString]];
            
        } failure:^(NSURLSessionDataTask *operation, NSError *error) {
            //NSLog(@"%@",error);
            //return nil;
        }];
    }
    else{
        ResultCustomerModel *customer = [ResultCustomerModel alloc];
        customer.State = 0;
        customer.Value = [CustomerModel alloc];
        customer.Value = model;
        customer.Value.CreatedDate = [ResourceLoader getCurrentTimes];
        [self.rs saveOFFLineCustomerInfo:customer.Value isAdd:true];
        [self callJsHandler:self.bridge action:@"GoPage" data:[customer toJSONString]];
    }
}

-(void)workOver:(CustomerModel *)model
{
    if(self.hasNetWork&&model.Id>0){
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        params[@"customer"]=[model toDictionary];
        // 设置请求格式
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        // 设置返回格式
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        NSString *requestUrl = [NSString stringWithFormat:@"%@api/v1/workover",self.rs.HostName];
        
        [manager POST:requestUrl parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
            NSDictionary *dict = (NSDictionary *)responseObject;
            ResultCustomerModel *customer = [[ResultCustomerModel alloc] initWithDictionary:dict error:nil];
            [self callJsHandler:self.bridge action:@"GoPage" data:[customer toJSONString]];
            [self.rs getLastResourceUpdateTime];
        } failure:^(NSURLSessionDataTask *operation, NSError *error) {
            //NSLog(@"%@",error);
            //return nil;
        }];
    }else{
        ResultCustomerModel *customer = [ResultCustomerModel alloc];
        customer.State = 0;
        customer.Value = [CustomerModel alloc];
        customer.Value = model;
        customer.Value.EndDate = [ResourceLoader getCurrentTimes];
        [self.rs saveOFFLineCustomerInfo:customer.Value isAdd:false];
        [self callJsHandler:self.bridge action:@"GoPage" data:[customer toJSONString]];
    }
}


- (void)login:(NSString *)username password:(NSString *)password
{
    if(self.hasNetWork||(!self.hasNetWork&&!self.rs.ResourceUpdateTime)){
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        params[@"username"]=username;
        params[@"password"]=password;
        // 设置请求格式
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        // 设置返回格式
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        
        NSString *requestUrl = [NSString stringWithFormat:@"%@api/v1/login",self.rs.HostName];

        [manager POST:requestUrl parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
            NSDictionary *dict = (NSDictionary *)responseObject;
            ResultUserModel *user = [[ResultUserModel alloc] initWithDictionary:dict error:nil];
            if(user.State==0)
            {
                //NSLog(@"%@", user);
                [self saveUserInfo:username passWord:password token:dict[@"Value"][@"Token"] uId:dict[@"Value"][@"UserId"]];
                [self callJsHandler:self.bridge action:@"GoPage" data:[user toJSONString]];
                [self.rs getLastResourceUpdateTime];
                [self uploadOFFLineCustomerInfo];
            }else
            {
                [self callJsHandler:self.bridge action:@"GoPage" data:[user toJSONString]];
            }
        } failure:^(NSURLSessionDataTask *operation, NSError *error) {
            NSLog(@"%@",error);
        }];
    }
    else{
        ResultUserModel *user = [ResultUserModel alloc];
        user.Value.UserName = [[NSUserDefaults standardUserDefaults] objectForKey:@"UName"];
        user.Value.UserId = (long)[[NSUserDefaults standardUserDefaults] objectForKey:@"UId"];
        user.State = 0;
        [self callJsHandler:self.bridge action:@"GoPage" data:[user toJSONString]];
    }
    
}



-(void)saveUserInfo:(NSString *)userName passWord:(NSString *)passWord token:(NSString *)token uId:(NSString *)uId
{
    [[NSUserDefaults standardUserDefaults] setObject:userName forKey:@"UName"];
    [[NSUserDefaults standardUserDefaults] setObject:passWord forKey:@"UPwd"];
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"UToken"];
    [[NSUserDefaults standardUserDefaults] setObject:uId forKey:@"UId"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
//{
//    NSURL *URL = request.URL;
//    NSString *scheme = [URL scheme];
//    NSLog(@"load url:%@,%@",URL,scheme);
////    if ([scheme isEqualToString:@"haleyaction"]) {
////        [self handleCustomAction:URL];
////        return NO;
////    }
//    return YES;
//}

-(void)initProgressView
{
    if(_progress==nil){
        CGRect myRect=[UIScreen mainScreen].bounds;
        _progress = [[UIProgressView alloc] initWithFrame:CGRectMake(0, (myRect.size.height-30)/2, myRect.size.width, 100)];
        _progress.transform = CGAffineTransformMakeScale(1.0f, 5.0f);
        _progress.backgroundColor = [UIColor lightGrayColor];
        _progress.tintColor = [UIColor blueColor];
        [_progress setHidden:false];
        _downInfo = [[UILabel alloc] initWithFrame:CGRectMake(0, (myRect.size.height-30)/2, myRect.size.width, 50)];
        _downInfo.backgroundColor = [UIColor clearColor];
        _downInfo.textColor = [UIColor whiteColor];
        _downInfo.textAlignment = UITextAlignmentCenter;
        _bkView = [[UIView alloc] initWithFrame:myRect];
        _bkView.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.7];
        [_bkView setHidden:true];
        [_bkView addSubview:_progress];
        [_bkView addSubview:_downInfo];
        [self.view addSubview:_bkView];
    }
}

-(void)uploadOFFLineCustomerInfo{
    if(!self.hasNetWork){
        return;
    }
    NSArray<CustomerModel>* info = [self.rs getOFFLineCustomerInfo];
    if(info!=NULL){
        if(info.count>0){
            AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
            
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            CustomerModels *pinfo = [[CustomerModels alloc] init];
            pinfo.customers = info;
            params = [pinfo toDictionary];
            // 设置请求格式
            manager.requestSerializer = [AFJSONRequestSerializer serializer];
            // 设置返回格式
            manager.responseSerializer = [AFJSONResponseSerializer serializer];
            NSString *requestUrl = [NSString stringWithFormat:@"%@api/v1/offlinecustomer",self.rs.HostName];
            
            [manager POST:requestUrl parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
                NSDictionary *dict = (NSDictionary *)responseObject;
                ResultCustomerModel *customer = [[ResultCustomerModel alloc] initWithDictionary:dict error:nil];
                NSLog(@"%@",customer);
                [self.rs saveOFFLineCustomerInfo:NULL isAdd:false];
            } failure:^(NSURLSessionDataTask *operation, NSError *error) {
                NSLog(@"%@",error);
            }];
        }
    }
}
    
    
    // 判断网络
- (void)judgeNet
    {
        self.manager = [AFNetworkReachabilityManager manager];
        __weak typeof(self) weakSelf = self;
        [self.manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            switch (status) {
                case AFNetworkReachabilityStatusNotReachable: {
                    //                [weakSelf loadMessage:@"网络不可用"];
                    self.hasNetWork = false;
                    NSLog(@"网络不可用");
                    break;
                }
                
                case AFNetworkReachabilityStatusReachableViaWiFi: {
                    //                [weakSelf loadMessage:@"Wifi已开启"];
                    self.hasNetWork = true;
                    NSLog(@"Wifi已开启");
                    break;
                }
                
                case AFNetworkReachabilityStatusReachableViaWWAN: {
                    //                [weakSelf loadMessage:@"你现在使用的流量"];
                    self.hasNetWork = true;
                    NSLog(@"你现在使用的流量");
                    break;
                }
                
                case AFNetworkReachabilityStatusUnknown: {
                    //                [weakSelf loadMessage:@"你现在使用的未知网络"];
                    self.hasNetWork = false;
                    NSLog(@"你现在使用的未知网络");
                    break;
                }
                
                default:
                break;
            }
        }];
        [self.manager startMonitoring];
    }




@end
