//
//  Demo4ViewController.m
//  PPVideoPlayer
//
//  Created by cdmac666 on 2019/9/18.
//  Copyright © 2019 pinguo. All rights reserved.
//

#import "Demo4ViewController.h"
#import "PPVideoPlayer/PPVideoPlayer.h"

#import "AppDelegate.h"

@interface Demo4ViewController ()<PPVideoPlayerDelegate>

@property (nonatomic,strong) PPVideoPlayer *videoPlayer;

@end

@implementation Demo4ViewController

#pragma mark - 懒加载对象
- (PPVideoPlayer *)videoPlayer{
    if(!_videoPlayer){
        _videoPlayer = [[PPVideoPlayer alloc] initWithFrame:CGRectMake(0, 200, self.view.frame.size.width, self.view.frame.size.width/1.777)];
        _videoPlayer.delegate = self;
        _videoPlayer.autoPlay = YES;
        _videoPlayer.isLiveVideo = YES;
        _videoPlayer.controlView.showTopView = YES;
        _videoPlayer.controlView.showBackButton = YES;
        _videoPlayer.controlView.showShareButton = YES;
        _videoPlayer.controlView.showFavoritesButton = YES;
        _videoPlayer.controlView.showDownButton = YES;
        _videoPlayer.controlView.showQualityButton = YES;
        _videoPlayer.controlView.showToTVButton = YES;
        _videoPlayer.controlView.showFullScreenButton = YES;
        _videoPlayer.controlView.showBarrageButton = YES;
        _videoPlayer.controlView.tipStyle = PPVideoPlayerTipStyleNone;
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
    
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if(self.videoPlayer){
        [self.videoPlayer stop];
        self.videoPlayer = nil;
    }
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
    self.title  = @"自定义UI播放器";
    
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
    
    [self.view addSubview:self.videoPlayer];
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

    /*
     流媒体测试地址：
     
     香港卫视： rtmp://live.hkstv.hk.lxdns.com/live/hks
     香港财经：rtmp://202.69.69.180:443/webcast/bshdlive-pc
     韩国朝鲜日报：rtmp://live.chosun.gscdn.com/live/tvchosun1.stream
     湖南卫视：rtmp://58.200.131.2:1935/livetv/hunantv
     CEN-中经电视： rtmp://116.213.200.53/tslsChannelLive/PCG0DuD/live
     CCTV证券资讯： rtmp://live.cctvcj.com/cctvcj/live1

     3，HTTP协议直播源
     香港卫视：http://live.hkstv.hk.lxdns.com/live/hks/playlist.m3u8
     CCTV1高清：http://ivi.bupt.edu.cn/hls/cctv1hd.m3u8
     CCTV3高清：http://ivi.bupt.edu.cn/hls/cctv3hd.m3u8
     CCTV5高清：http://ivi.bupt.edu.cn/hls/cctv5hd.m3u8
     CCTV5+高清：http://ivi.bupt.edu.cn/hls/cctv5phd.m3u8
     CCTV6高清：http://ivi.bupt.edu.cn/hls/cctv6hd.m3u8
     
     点播：
     http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4
     http://vjs.zencdn.net/v/oceans.mp4
     https://media.w3.org/2010/05/sintel/trailer.mp4
     http://1252065688.vod2.myqcloud.com/d7dc3e4avodgzp1252065688/e66bae544564972818527816264/MY2sqkSHZMkA.mp4
     抖音测试地址
     http://video8.miliyo.com/a/a2/c1/a2c111c4b0dc3af74ac19b446e19f469.mp4
     http://video8.miliyo.com/a/28/c0/28c04dfb37e23fc2b61d024120d38677.mp4

     */
    self.videoPlayer.title = @"测试视频标题";
    self.videoPlayer.videoUrl = @"rtmp://58.200.131.2:1935/livetv/hunantv";
    //self.videoPlayer.videoUrl = videoURL1;
    self.videoPlayer.isWifiNetwork = YES;
    [self.videoPlayer prepareToPlay];
    //[self.videoPlayer play];
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
#pragma mark --屏幕旋转
// 视图控制器旋转到某个尺寸
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    NSLog(@"%f,%f",size.width,size.height);
    if (size.height > size.width)
    {
        NSLog(@"-------当前设备方向是竖屏-------");
        if(self.videoPlayer.enableLockScreen){
            //锁定状态
            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            appDelegate.allowRotation = YES;//设置横屏
            [self setNewOrientation:YES];//调用转屏代码
            self.videoPlayer.fullScreen = YES;
        }else{
            //非锁定状态
            self.videoPlayer.frame = CGRectMake(0, 200, size.width, size.width/1.777);
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
#pragma mark - 委托代理
/**
 返回按钮点击
 
 @param view   <#view description#>
 @param sender <#sender description#>
 */
- (void)PPVideoPlayer:(PPVideoPlayer*)view backAction:(id)sender{
    NSLog(@"%s",__FUNCTION__);
    if(self.videoPlayer.fullScreen){
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        appDelegate.allowRotation = NO;//设置竖屏
        [self setNewOrientation:NO];//调用转屏代码
        appDelegate.allowRotation = YES;

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
- (void)PPVideoPlayer:(PPVideoPlayer*)view toTVAction:(id)sender{
    
}

/**
 分享按钮点击
 
 @param view   <#view description#>
 @param sender <#sender description#>
 */
- (void)PPVideoPlayer:(PPVideoPlayer*)view shareAction:(id)sender{
    NSLog(@"%s",__FUNCTION__);
}

/**
 下载按钮点击
 
 @param view   <#view description#>
 @param sender <#sender description#>
 */
- (void)PPVideoPlayer:(PPVideoPlayer*)view downloadAction:(id)sender{
    NSLog(@"%s",__FUNCTION__);
}

/**
 全屏/取消全屏点击
 
 @param view   <#view description#>
 @param sender <#sender description#>
 */
- (void)PPVideoPlayer:(PPVideoPlayer*)view fullScreenAction:(id)sender{
    NSLog(@"%s",__FUNCTION__);
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if(self.videoPlayer.fullScreen){
        appDelegate.allowRotation = NO;//设置竖屏
        [self setNewOrientation:NO];//调用转屏代码
        self.videoPlayer.fullScreen = NO;
    }else{
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        appDelegate.allowRotation = YES;//设置横屏
        [self setNewOrientation:YES];//调用转屏代码
        self.videoPlayer.fullScreen = YES;
    }
    appDelegate.allowRotation = YES;
}

@end
