//
//  Demo2ViewController.m
//  PPVideoPlayer
//
//  Created by cdmac on 17/3/14.
//  Copyright © 2017年 pinguo. All rights reserved.
//

#import "Demo2ViewController.h"
#import "PPVideoPlayerView.h"

#import "AppDelegate.h"

@interface Demo2ViewController ()<PPVideoPlayerViewDelegate>

@property (nonatomic,strong) PPVideoPlayerView *videoPlayer;

@property (nonatomic,assign) NSInteger testIndex;

@end

@implementation Demo2ViewController

#pragma mark - 懒加载对象
- (PPVideoPlayerView *)videoPlayer{
    if(!_videoPlayer){
        _videoPlayer = [[PPVideoPlayerView alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, self.view.frame.size.width/1.776)];
        _videoPlayer.delegate = self;
        _videoPlayer.showTopBar = YES;
        _videoPlayer.showShareButton = YES;
        _videoPlayer.showFavoritesButton = YES;
        _videoPlayer.showDownButton = YES;
        _videoPlayer.showNextButton = YES;
        _videoPlayer.showQualityButton = YES;
        _videoPlayer.showListButton = YES;
        _videoPlayer.showToTVButton = YES;
        _videoPlayer.showFullScreenButton = YES;
        _videoPlayer.showBarrageButton = YES;
        _videoPlayer.isBVControlOn = NO;
        _videoPlayer.controlStyle = PPVideoPlayerControlStyleDefault;
    }
    
    return _videoPlayer;
}

#pragma mark - 系统基类方法
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initData];
    [self initNavigationBar];
    [self initSubViews];
    [self loadData];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if(self.videoPlayer){
        [self.videoPlayer stop];
        self.videoPlayer = nil;
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(addBarrage) object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark - 自定义基类方法
/**
 *  初始化导航栏
 */
-(void)initNavigationBar{
    self.title  = @"Demo2";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"播放" style:UIBarButtonItemStylePlain target:self action:@selector(play)];
    
}

/**
 *  初始化页面初始数据
 */
-(void)initData{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.allowRotation = YES;//设置竖屏
}

/**
 *  初始化界面元素
 */
-(void)initSubViews{
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self.view addSubview:self.videoPlayer];
    [self.view bringSubviewToFront:self.videoPlayer];
}

/**
 *  重置布局
 */
-(void)resetLayout{
    
}

/**
 *  加载数据
 */
-(void)loadData{
    //NSURL *movieUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"cdvideo" ofType:@"mp4"]];
    NSURL *movieUrl = [NSURL URLWithString:@"http://1252065688.vod2.myqcloud.com/d7dc3e4avodgzp1252065688/e66bae544564972818527816264/MY2sqkSHZMkA.mp4"];
    self.videoPlayer.title = @"video title2";
    self.videoPlayer.playUrl = movieUrl;
    self.videoPlayer.isLive = NO;
    self.videoPlayer.isWifiNetwork = YES;
    self.videoPlayer.isAutoPlay = NO;
    [self.videoPlayer prepareToPlay];
    //[self.videoPlayer play];
    
    
    //设置弹幕，给barrageValue设置值就好了
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        self.videoPlayer.barrageValue = @"测试1";
//    });
//
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        self.videoPlayer.barrageValue = @"测试12";
//    });
//
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        self.videoPlayer.barrageValue = @"测试3";
//    });
//
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        self.videoPlayer.barrageValue = @"测试4";
//    });
    [self addBarrage];
}

- (void)addBarrage{
    self.testIndex++;
    
    self.videoPlayer.barrageValue = [NSString stringWithFormat:@"测试字幕%ld",self.testIndex];
    
    [self performSelector:@selector(addBarrage) withObject:nil afterDelay:0.5];
}

- (void)play{
    [self.videoPlayer play];
}

/**
 *  加载新数据
 */
- (void)loadNewData{
    
}

/**
 *  加载更多数据
 */
- (void)loadMoreData{
    
}

#pragma mark - 自定义方法
- (void)setNewOrientation:(BOOL)fullscreen{
    if (fullscreen) {
        NSNumber *resetOrientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationUnknown];
        [[UIDevice currentDevice] setValue:resetOrientationTarget forKey:@"orientation"];
        
        NSNumber *orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeRight];
        [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
    }else{
        NSNumber *resetOrientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationUnknown];
        [[UIDevice currentDevice] setValue:resetOrientationTarget forKey:@"orientation"];
        
        NSNumber *orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
        [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
    }
}
#pragma mark - 事件通知

#pragma mark - 委托代理

#pragma mark --屏幕旋转
// 视图控制器旋转到某个尺寸
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    NSLog(@"%f,%f",size.width,size.height);
    if (size.height > size.width)
    {
        NSLog(@"-------当前设备方向是竖屏-------");
        if(self.videoPlayer.isFSLocked){
            //锁定状态
            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            appDelegate.allowRotation = YES;//设置横屏
            [self setNewOrientation:YES];//调用转屏代码
            self.videoPlayer.showBackButton = YES;
            self.videoPlayer.showTopBar = YES;
            self.videoPlayer.fullScreen = YES;
        }else{
            //非锁定状态
            self.videoPlayer.frame = CGRectMake(0, 20, size.width, size.width/1.776);
            self.videoPlayer.fullScreen = NO;
        }
    }
    else
    {
        NSLog(@"-------当前设备方向是横屏-------");
        if(self.videoPlayer.isFullScreen){
            return;
        }
        CGFloat height = [UIScreen mainScreen].bounds.size.width;
        CGFloat width = [UIScreen mainScreen].bounds.size.height;
        
        self.videoPlayer.frame = CGRectMake(0, 0, width, height);
        self.videoPlayer.fullScreen = YES;
    }
}

#pragma mark - PPVideoPlayerViewDelegate

/**
 播放时间改变
 
 @param view           <#view description#>
 @param currentSencond <#currentSencond description#>
 */
- (void)PPVideoPlayerView:(PPVideoPlayerView*)view timeChanged:(NSTimeInterval)currentSencond{
    //NSLog(@"%s-%f",__FUNCTION__,currentSencond);
}


/**
 播放状态改变
 
 @param view   <#view description#>
 @param status <#status description#>
 */
- (void)PPVideoPlayerView:(PPVideoPlayerView*)view playStatusChanged:(PPVideoPlayerStatus)status{
    
    if(status == PPVideoPlayerStatusPlaying){
        NSLog(@"%s-正在播放中",__FUNCTION__);
    }else if(status == PPVideoPlayerStatusPause){
        NSLog(@"%s-暂停",__FUNCTION__);
    }else if(status == PPVideoPlayerStatusStop){
        NSLog(@"%s-停止",__FUNCTION__);
    }else{
        NSLog(@"%s-未知",__FUNCTION__);
    }
}

/**
 播放屏幕单击
 
 @param view   <#view description#>
 @param sender <#sender description#>
 */
- (void)PPVideoPlayerView:(PPVideoPlayerView*)view screenTap:(id)sender{
    NSLog(@"%s",__FUNCTION__);
}

/**
 播放屏幕双击
 
 @param view   <#view description#>
 @param sender <#sender description#>
 */
- (void)PPVideoPlayerView:(PPVideoPlayerView*)view screenDoubleTap:(id)sender{
    NSLog(@"%s",__FUNCTION__);
}

/**
 返回按钮点击
 
 @param view   <#view description#>
 @param sender <#sender description#>
 */
- (void)PPVideoPlayerView:(PPVideoPlayerView*)view backAction:(id)sender{
    NSLog(@"%s",__FUNCTION__);
    if(self.videoPlayer.fullScreen){
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        appDelegate.allowRotation = NO;//设置竖屏
        [self setNewOrientation:NO];//调用转屏代码
        appDelegate.allowRotation = YES;
        
        self.videoPlayer.showBackButton = NO;
        self.videoPlayer.showTopBar = NO;
        self.videoPlayer.fullScreen = NO;
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}


/**
 投屏按钮点击
 
 @param view   <#view description#>
 @param sender <#sender description#>
 */
- (void)PPVideoPlayerView:(PPVideoPlayerView*)view toTVAction:(id)sender{
    NSLog(@"%s",__FUNCTION__);
}


/**
 分享按钮点击
 
 @param view   <#view description#>
 @param sender <#sender description#>
 */
- (void)PPVideoPlayerView:(PPVideoPlayerView*)view shareAction:(id)sender{
    NSLog(@"%s",__FUNCTION__);
}


/**
 收藏按钮点击
 
 @param view   <#view description#>
 @param sender <#sender description#>
 */
- (void)PPVideoPlayerView:(PPVideoPlayerView*)view favoriteAction:(id)sender{
    NSLog(@"%s",__FUNCTION__);
}


/**
 下载按钮点击
 
 @param view   <#view description#>
 @param sender <#sender description#>
 */
- (void)PPVideoPlayerView:(PPVideoPlayerView*)view downloadAction:(id)sender{
    NSLog(@"%s",__FUNCTION__);
}


/**
 更多按钮点击
 
 @param view   <#view description#>
 @param sender <#sender description#>
 */
- (void)PPVideoPlayerView:(PPVideoPlayerView*)view moreAction:(id)sender{
    NSLog(@"%s",__FUNCTION__);
}


/**
 播放暂停按钮点击
 
 @param view   <#view description#>
 @param sender <#sender description#>
 */
- (void)PPVideoPlayerView:(PPVideoPlayerView*)view playOrPauseAction:(id)sender{
    NSLog(@"%s",__FUNCTION__);
}


/**
 下一个视频按钮点击
 
 @param view   <#view description#>
 @param sender <#sender description#>
 */
- (void)PPVideoPlayerView:(PPVideoPlayerView*)view nextVideoAction:(id)sender{
    NSLog(@"%s",__FUNCTION__);
}


/**
 播放质量切换按钮点击
 
 @param view   <#view description#>
 @param sender <#sender description#>
 */
- (void)PPVideoPlayerView:(PPVideoPlayerView*)view qualityAction:(id)sender{
    NSLog(@"%s",__FUNCTION__);
}


/**
 播放列表按钮点击
 
 @param view   <#view description#>
 @param sender <#sender description#>
 */
- (void)PPVideoPlayerView:(PPVideoPlayerView*)view videoListAction:(id)sender{
    NSLog(@"%s",__FUNCTION__);
}


/**
 全屏/取消全屏点击
 
 @param view   <#view description#>
 @param sender <#sender description#>
 */
- (void)PPVideoPlayerView:(PPVideoPlayerView*)view fullScreenAction:(id)sender{
    NSLog(@"%s",__FUNCTION__);
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if(self.videoPlayer.fullScreen){
        appDelegate.allowRotation = NO;//设置竖屏
        [self setNewOrientation:NO];//调用转屏代码
        self.videoPlayer.showBackButton = NO;
        self.videoPlayer.showTopBar = NO;
        self.videoPlayer.fullScreen = NO;
    }else{
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        appDelegate.allowRotation = YES;//设置横屏
        [self setNewOrientation:YES];//调用转屏代码
        self.videoPlayer.showBackButton = YES;
        self.videoPlayer.showTopBar = YES;
        self.videoPlayer.fullScreen = YES;
    }
    appDelegate.allowRotation = YES;
}

@end
