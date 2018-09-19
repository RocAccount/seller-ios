//
//  PhotosVC.m
//  SellerPad
//
//  Created by zhuyuming-MAC on 2018/9/3.
//  Copyright © 2018年 zhuyuming-MAC. All rights reserved.
//

#import "PhotosVC.h"
#import "CustomerProtocol.h"
#import "ImageCell.h"

@interface PhotosVC ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (strong,nonatomic) UIButton * btnBack;
@property (strong,nonatomic) NSMutableArray<ContentImageItem*> *images;
@property (strong,nonatomic) UICollectionView *collectionView;
@property (strong,nonatomic) UIImageView * bigImage;

@property(assign,nonatomic) int selectedIndex;

#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

#define IS_PAD (UI_USER_INTERFACE_IDIOM()== UIUserInterfaceIdiomPad)



#define WIDTHPX(x) ([UIScreen mainScreen].bounds.size.width*x/1920.0)

#define HEIGHTPX(y) ([UIScreen mainScreen].bounds.size.height*y/1080.0)

#define UIColorFromHEXWithAlpha(rgbValue,a) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:a]

#define BTN_BACK_W (IS_PAD ? 100 : 100)

#define BTN_FONTSIZE (IS_PAD ? 16 : 10)

#define COL_HEIGHT (IS_PAD ? 95 : ([UIScreen mainScreen].bounds.size.height/5+18))

#define COL_WIDTH (IS_PAD ? 150: COL_HEIGHT*150/95)

#define PANWIDTH (IS_PAD ? ([[UIScreen mainScreen] bounds].size.width-WIDTHPX(BTN_BACK_W)*2)/6 : ([[UIScreen mainScreen] bounds].size.width-WIDTHPX(BTN_BACK_W)*2)/4)

@end

@implementation PhotosVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.images = [[NSMutableArray alloc] init];
    self.view.backgroundColor = UIColorFromHEXWithAlpha(0x3c3a3e,0.8);
    [self initView:_contentItem];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)initView:(ContentModel *) item{
    [self initImages];
    //NSLog(@"%@",_images);
    CGRect myRect=[UIScreen mainScreen].bounds;
    if(_btnBack==nil){
        //返回按钮
        float width = WIDTHPX(BTN_BACK_W);
        NSLog(@"%d",BTN_BACK_W);
        CGRect rect = CGRectMake((myRect.size.width-width), 0, width, width);
        _btnBack = [[UIButton alloc] initWithFrame:rect];
        //_btnBack.layer.cornerRadius = 50.0;
        //_btnBack.layer.borderWidth = 1.0;
        
        //_btnBack.layer.borderColor= baseColor.CGColor;
        _btnBack.backgroundColor =  UIColorFromHEXWithAlpha(0xb79d82,0.3);
        
//        _btnBack.layer.masksToBounds = 30;
        
         UIBezierPath *maskPath =  [UIBezierPath bezierPathWithArcCenter:CGPointMake(_btnBack.bounds.origin.x+width, _btnBack.bounds.origin.y) radius:width startAngle:180 endAngle:270 clockwise:YES];
        //[maskPath stroke];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.path = maskPath.CGPath;
        maskLayer.lineWidth = 1.0;
        maskLayer.strokeColor = UIColorFromHEXWithAlpha(0xb79d82,1).CGColor;
        _btnBack.layer.mask = maskLayer;
        //_btnBack.layer.cornerRadius = 30;
        

        
        [_btnBack setTitle:@"返回" forState:UIControlStateNormal];
        
        _btnBack.titleLabel.font = [UIFont systemFontOfSize:BTN_FONTSIZE];
        _btnBack.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        _btnBack.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
        [_btnBack setTitleEdgeInsets: UIEdgeInsetsMake(10,0, 0, 5)];
        [_btnBack setTitleColor:UIColorFromHEXWithAlpha(0xb79d82,1) forState:UIControlStateNormal];
        [_btnBack addTarget:self action:@selector(backLocalHtmlVC) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_btnBack];
    }
    [self initImageCollectionView];
    
}

-(void)initImages{
    NSArray *array =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *homePath = array.firstObject;
    if(_contentItem&&_contentItem.Images){
        for (ContentImage *o in _contentItem.Images) {
            if(o.ImageUrl){
                ContentImageItem *s = [ContentImageItem alloc];
                s.State = 0;
                s.ImageUrl = [homePath stringByAppendingPathComponent:o.ImageUrl];
                NSArray *array = [o.ImageUrl componentsSeparatedByString:@"."];
                s.TmpImageUrl = [homePath stringByAppendingPathComponent:[array[0] stringByAppendingFormat:@"%@%@",@"_x_150_94.",array[1]]];
                [_images addObject:s];
            }
        }
    }
}

-(void)initImageCollectionView{
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    

    CGRect rct = self.view.bounds;
    rct.size.height = COL_HEIGHT;
    rct.origin.y = [[UIScreen mainScreen] bounds].size.height - rct.size.height-10;
     _collectionView = [[UICollectionView alloc]initWithFrame:rct collectionViewLayout:layout];
    _collectionView.allowsSelection = YES;
    _collectionView.allowsMultipleSelection = NO;
    _collectionView.dataSource = self;
    _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    //_collectionView.autoresizingMask = UIViewAutoresizingNone;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.decelerationRate = UIScrollViewDecelerationRateNormal;
    _collectionView.backgroundColor = [UIColor clearColor];
    [_collectionView setDelegate:self];
    [_collectionView setDataSource:self];
    
    [self.collectionView registerClass:[ImageCell class] forCellWithReuseIdentifier:@"ImageCell"];
    [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionNone];
    
    [self.view addSubview:_collectionView];
    
    if(_bigImage==nil){
        CGRect ict = CGRectMake(WIDTHPX(BTN_BACK_W), WIDTHPX(BTN_BACK_W)-20, [[UIScreen mainScreen] bounds].size.width-WIDTHPX(BTN_BACK_W)*2, [[UIScreen mainScreen] bounds].size.height-(_collectionView.bounds.size.height+WIDTHPX(BTN_BACK_W)));
        _bigImage = [[UIImageView alloc] initWithFrame:ict];
        _bigImage.contentMode = UIViewContentModeScaleAspectFit;
        _bigImage.userInteractionEnabled = YES;
        //_bigImage.autoresizingMask =
        self.selectedIndex = 0;
        [_bigImage setImage:[UIImage imageNamed:[self.images objectAtIndex:0].ImageUrl]];
        

        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];

        [_bigImage addGestureRecognizer:pan];
        
        [self.view addSubview:_bigImage];
    }
    
}


-(void)panAction:(UIPanGestureRecognizer *)recognizer{
    
    if(recognizer.state != UIGestureRecognizerStateEnded){
        return ;
    }
    
    CGPoint offset = [recognizer translationInView:_bigImage];
    if ((fabs(offset.y) >= fabs(offset.x))) {
        return;
    }

    if(fabs(offset.x)<PANWIDTH){
        return;
    }
    
    //向右滑动
    if(offset.x>0){
        if(self.selectedIndex<=0){
            return;
        }
        self.selectedIndex--;
    }
    else{
        //向左滑动
        if(self.selectedIndex>=self.images.count-1){
            return;
        }
        self.selectedIndex++;
    }
    [_bigImage setImage:[UIImage imageNamed:[self.images objectAtIndex:self.selectedIndex].ImageUrl]];
    [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:self.selectedIndex inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionNone];
}




-(void)backLocalHtmlVC{
    [self dismissViewControllerAnimated:NO completion:nil];
    //[self.navigationController popViewControllerAnimated:NO];
    [[NSNotificationCenter  defaultCenter]postNotificationName:@"back" object:nil];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ImageCell *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([ImageCell class]) forIndexPath:indexPath];
    NSLog(@"image:%@",[self.images objectAtIndex:indexPath.row].TmpImageUrl);
    cell.image.image = [UIImage imageNamed:[self.images objectAtIndex:indexPath.row].TmpImageUrl];
    UIButton *imageBtn = cell.imageBtn;
    [imageBtn addTarget:self action:@selector(imageBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    cell.selectedBackgroundView =  [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.layer.borderColor = UIColorFromHEXWithAlpha(0xb79d82,1).CGColor;
    cell.selectedBackgroundView.layer.borderWidth = 2.0;
    //cell.selected =YES;
    //[self.collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.images count];
}



- (CGSize)collectionView:(nonnull UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return CGSizeMake(COL_WIDTH, _collectionView.bounds.size.height);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
   // [self.collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:nil];
    NSLog(@"hahahahaha");
}




-(void)imageBtnClick:(id)sender{
    UIView *v = [sender superview];
    UICollectionViewCell *cell = (UICollectionViewCell *)[v superview];

    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    
    self.selectedIndex = (int)indexPath.row;
    [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:self.selectedIndex inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionNone];
    if(_bigImage!=nil){
        [_bigImage setImage:[UIImage imageNamed:[self.images objectAtIndex:indexPath.row].ImageUrl]];
    }
}





/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
