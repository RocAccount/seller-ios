//
//  ViewController.m
//  SellerPad
//
//  Created by zhuyuming-MAC on 2018/5/3.
//  Copyright © 2018年 zhuyuming-MAC. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (strong, nonatomic) IBOutlet WKWebView *VM;
@property (strong, nonatomic) IBOutlet UIView *BaseVM;

@property (strong,nonatomic) IBOutlet NSDictionary *Urls;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    self.VM = [self createWebView];
    [self addWebView:self.BaseVM];
    [self changeUrlAndLoadHtml:1];

}

-(NSDictionary *)Urls{
    if(_Urls==nil){
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"PageUrl.plist" ofType:nil];
        _Urls = [[NSDictionary alloc] initWithContentsOfFile:filePath];
    }
    return _Urls;
}

- (IBAction)changeView:(UIButton *)sender {
    [self changeUrlAndLoadHtml:sender.tag];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)addWebView:(UIView *)view
{
    self.VM.scrollView.scrollEnabled = NO;
    [view addSubview:self.VM];
    [self.VM setTranslatesAutoresizingMaskIntoConstraints:false];
    self.VM.frame = CGRectMake(0, 96, 1024, 576);
}

-(WKWebView *)createWebView
{
    WKWebViewConfiguration *configuration =
    [[WKWebViewConfiguration alloc] init];    
    return [[WKWebView alloc] initWithFrame:CGRectZero configuration:configuration];
}

-(void)changeUrlAndLoadHtml:(NSInteger)tag{
    
    NSString *url =@"http://sellertest.aggior.com/pre/#!/";
    NSLog(@"%@",url);
    NSLog(@"%@",[NSString stringWithFormat:@"%ld",(long)tag]);
    NSLog(@"%@",self.Urls);
    NSLog(@"%@",[self.Urls objectForKey:[NSString stringWithFormat:@"%ld",(long)tag]]);
    url = [url stringByAppendingString:[self.Urls objectForKey:[NSString stringWithFormat:@"%ld",(long)tag]]];
    NSLog(@"%@",url);
    NSURL *thisUrl = [NSURL URLWithString:url];
    NSURLRequest *request = [NSURLRequest requestWithURL:thisUrl];
    
    [self.VM loadRequest:request];
}




@end
