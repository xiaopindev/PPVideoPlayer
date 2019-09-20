//
//  PPPlayerControlView.m
//  PPVideoPlayer
//
//  Created by cdmac666 on 2019/9/19.
//  Copyright © 2019 pinguo. All rights reserved.
//

#import "PPPlayerControlView.h"

@interface PPPlayerControlView ()
{
    CGFloat pX,pY,pWidth,pHeight;
}

//自定义控制UI
@property (nonatomic,strong) UIView *topView;
@property (nonatomic,strong) UIButton *btnBack;
@property (nonatomic,strong) UILabel *labTitle;
@property (nonatomic,strong) UIButton *btnToTV;
@property (nonatomic,strong) UIButton *btnShare;
@property (nonatomic,strong) UIButton *btnFavorite;
@property (nonatomic,strong) UIButton *btnDownload;
//提示信息
@property (nonatomic,strong) UIView *tipView;
//中间视图
@property (nonatomic,strong) UIView *centerView;
@property (nonatomic,strong) UIButton *btnPlayPause;
//底部栏
@property (nonatomic,strong) UIView *bottomView;
@property (nonatomic,strong) UIButton *btnSound;
@property (nonatomic,strong) UILabel *labLiving;
@property (nonatomic,strong) UILabel *labStartTime;
@property (nonatomic,strong) UISlider *playProgress;
@property (nonatomic,strong) UIProgressView *loadedProgress;
@property (nonatomic,strong) UILabel *labEndTime;
@property (nonatomic,strong) UIButton *btnQuality;
@property (nonatomic,strong) UIButton *btnBarrage;
@property (nonatomic,strong) UIButton *btnFullScreen;

//用于控制topView 和 bottomView 的自动显示隐藏
@property (nonatomic,assign) BOOL controlHidden;
@property (nonatomic,strong) NSTimer *controlTimer;

@end

@implementation PPPlayerControlView

//MARK: 属性懒加载
//MARK: ---头
-(UIView *)topView{
    if(!_topView){
        _topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 50)];
        _topView.alpha = 1;
    }
    return _topView;
}

-(UIButton *)btnBack{
    if(!_btnBack){
        _btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnBack.frame = CGRectMake(10, 5, 30, 30);
        [_btnBack setImage:[self imagesNamedFromCustomBundle:@"PPKit_vp_back"] forState:UIControlStateNormal];
        [_btnBack addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnBack;
}

-(UILabel *)labTitle{
    if(!_labTitle){
        _labTitle = [[UILabel alloc] initWithFrame:CGRectZero];
        _labTitle.textColor = [UIColor whiteColor];
        _labTitle.textAlignment = NSTextAlignmentLeft;
        _labTitle.font = [UIFont systemFontOfSize:15];
    }
    return _labTitle;
}

-(UIButton *)btnToTV{
    if(!_btnToTV){
        _btnToTV = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnToTV.frame = CGRectMake(0, 5, 30, 30);
        [_btnToTV setImage:[self imagesNamedFromCustomBundle:@"PPKit_vp_toTV"] forState:UIControlStateNormal];
        [_btnToTV addTarget:self action:@selector(toTVAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnToTV;
}

-(UIButton *)btnShare{
    if(!_btnShare){
        _btnShare = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnShare.frame = CGRectMake(0, 5, 30, 30);
        [_btnShare setImage:[self imagesNamedFromCustomBundle:@"PPKit_vp_share"] forState:UIControlStateNormal];
        [_btnShare addTarget:self action:@selector(shareAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnShare;
}

-(UIButton *)btnFavorite{
    if(!_btnFavorite){
        _btnFavorite = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnFavorite.frame = CGRectMake(0, 5, 30, 30);
        [_btnFavorite setImage:[self imagesNamedFromCustomBundle:@"PPKit_vp_favorite_empty"] forState:UIControlStateNormal];
        [_btnFavorite addTarget:self action:@selector(favoriteAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnFavorite;
}

-(UIButton *)btnDownload{
    if(!_btnDownload){
        _btnDownload = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnDownload.frame = CGRectMake(0, 5, 30, 30);
        [_btnDownload setImage:[self imagesNamedFromCustomBundle:@"PPKit_vp_download"] forState:UIControlStateNormal];
        [_btnDownload addTarget:self action:@selector(downloadAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnDownload;
}

//MARK: ---中
-(UIView *)tipView{
    if(!_tipView){
        _tipView = [[UIView alloc] initWithFrame:self.bounds];
    }
    return _tipView;
}

-(UIView *)centerView{
    if(!_centerView){
        _centerView = [[UIView alloc] initWithFrame:self.bounds];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap)];
        [_centerView addGestureRecognizer:tapGesture];
    }
    return _centerView;
}

-(UIButton *)btnPlayPause{
    if(!_btnPlayPause){
        _btnPlayPause = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btnPlayPause setImage:[self imagesNamedFromCustomBundle:@"PPKit_vp_play_big"] forState:UIControlStateNormal];
        [_btnPlayPause addTarget:self action:@selector(playpauseAction) forControlEvents:UIControlEventTouchUpInside];
    }
    pX = (self.bounds.size.width - 50)/2;
    pY = (self.bounds.size.height - 50)/2;
    _btnPlayPause.frame = CGRectMake(pX, pY, 50, 50);
    return _btnPlayPause;
}

//MARK: 尾
-(UIView *)bottomView{
    if(!_bottomView){
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height-40, self.bounds.size.width, 40)];
        _bottomView.alpha = 1;
    }
    return _bottomView;
}

//MARK: 入口
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]){

        [self addSubview:self.centerView];
        [self addSubview:self.topView];
        [self addSubview:self.bottomView];
    }
    return self;
}

//MARK: 自定义方法

- (void)refreshLayout{
    
}

- (void)playpauseAction{
    if ([self.delegate respondsToSelector:@selector(PPPlayerControlView:playpauseAction:)]){
        [self.delegate PPPlayerControlView:self playpauseAction:self];
    }
}

//开启控制视图消失定时器
- (void)startControlTimer{
    [self clearControlTimer];
    
    //iOS10写法
    __weak typeof(self) weakSelf = self;
    self.controlTimer = [NSTimer scheduledTimerWithTimeInterval:12.0f repeats:NO block:^(NSTimer * _Nonnull timer) {
        //隐藏控制视图
        [UIView animateWithDuration:0.3 animations:^{
            weakSelf.topView.alpha = 0;
            weakSelf.bottomView.alpha = 0;
            [weakSelf.btnPlayPause removeFromSuperview];
        }];
        
        //销毁定时器
        [weakSelf clearControlTimer];
    }];
}
//清楚销毁定时器资源
- (void)clearControlTimer{
    if (self.controlTimer) {
        [self.controlTimer invalidate];
        self.controlTimer = nil;
    }
}
//获取资源图片对象
- (UIImage *)imagesNamedFromCustomBundle:(NSString *)imgName{
    NSString *bundlePath = [[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:@"PPVideoPlayer.bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    NSString *img_path = [bundle pathForResource:imgName ofType:@"png"];
    return [UIImage imageWithContentsOfFile:img_path];
}
//时间转换
- (NSString *)convertTime:(double)second {
    // 相对格林时间
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:second];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    if (second / 3600 >= 1) {
        [formatter setDateFormat:@"HH:mm:ss"];
        NSString *showTimeNew = [formatter stringFromDate:date];
        showTimeNew = [showTimeNew substringFromIndex:1];
        return showTimeNew;
    } else {
        [formatter setDateFormat:@"mm:ss"];
        NSString *showTimeNew = [formatter stringFromDate:date];
        return showTimeNew;
    }
}

//1.单点弹出控件视图
- (void)singleTap{
    NSLog(@"%s",__FUNCTION__);
  
    self.controlHidden = !self.controlHidden;
    __weak typeof(self) weakSelf = self;
    
    if(self.controlHidden){
        //隐藏控制视图
        [UIView animateWithDuration:0.3 animations:^{
            weakSelf.topView.alpha = 0;
            weakSelf.bottomView.alpha = 0;
        }];
        
        //销毁定时器
        [self clearControlTimer];
        
        [self.btnPlayPause removeFromSuperview];
    }else{
        //显示控制视图
        
        [UIView animateWithDuration:0.2 animations:^{
            weakSelf.topView.alpha = 1;
            weakSelf.bottomView.alpha = 1;
        }];
        
        //开启定时器
        [self startControlTimer];
        
        [self addSubview:self.btnPlayPause];
    }
}
@end
