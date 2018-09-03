//
//  PPVideoPlayerView.m
//  PPVideoPlayer
//
//  Created by xiaopin on 16/10/27.
//  Copyright © 2016年 PPKit. All rights reserved.
//

#import "PPVideoPlayerView.h"
#import "OCBarrage.h"
#import "BrightnessVolumeView.h"

@interface PPVideoPlayerView ()
{
    CGFloat pX,pY,pWidth,pHeight;
}

//弹幕对象
@property (nonatomic, strong) OCBarrageManager *barrageManager;

//播放器核心（必须）
@property (nonatomic, strong) NELivePlayerController *player; //播放器sdk
@property (nonatomic, strong) dispatch_source_t timer;

//播放器属性（只针对点播）
//当前播放时间点
//@property (nonatomic,assign) NSTimeInterval currentTime;

//用于控制topView 和 bottomView 的自动显示隐藏
@property (nonatomic,assign) BOOL controlHidden;
@property (nonatomic,strong) NSTimer *controlTimer;

//播放进度是否正在滑动
@property (nonatomic,assign) BOOL isSliding;
//弹出提示中
@property (nonatomic,assign) BOOL isAlerting;
//直播是否结束
@property (nonatomic,assign) BOOL isLiveOver;
//弹幕是否关闭
@property (nonatomic,assign) BOOL isBarrageClose;

//顶部视频信息和控制视图
@property (nonatomic,strong) UIButton *btnBack;

@property (nonatomic,strong) UIView *topView;
@property (nonatomic,strong) UILabel *labTitle;
@property (nonatomic,strong) UIButton *btnShare;
@property (nonatomic,strong) UIButton *btnFavorite;
@property (nonatomic,strong) UIButton *btnDownload;

//结束后中间显示的重播按钮
@property (nonatomic,strong) UIButton *btnReplay;
//加载提示
@property (nonatomic,strong) UIView *alertView;
@property (nonatomic,strong) UIImageView *alertImageView;
@property (nonatomic,strong) UILabel *alertLabel;
//不是Wifi网络的提示
@property (nonatomic,strong) UIView *notWifiView;
@property (nonatomic,strong) UILabel *labNotWifiMsg;
@property (nonatomic,strong) UIButton *btnContinuePlay;

//直播未开始提示
@property (nonatomic,strong) UILabel *liveNotStartedView;
//直播结束提示
@property (nonatomic,strong) UILabel *liveOverView;

//音量亮度视图
@property (nonatomic,strong) BrightnessVolumeView *BVView;
//全屏锁定
@property (nonatomic,strong) UIButton *btnFSLock;

//底部控制视图
@property (nonatomic,strong) UIView *bottomView;
@property (nonatomic,strong) UIButton *btnPlayOrPause;
@property (nonatomic,strong) UIButton *btnNextVideo;
@property (nonatomic,strong) UILabel *labLiving;
@property (nonatomic,strong) UILabel *labStartTime;
@property (nonatomic,strong) UISlider *playProgress;
@property (nonatomic,strong) UIProgressView *loadedProgress;
@property (nonatomic,strong) UILabel *labEndTime;
@property (nonatomic,strong) UIButton *btnQuality;
@property (nonatomic,strong) UIButton *btnVideoList;
@property (nonatomic,strong) UIButton *btnToTV;
@property (nonatomic,strong) UIButton *btnBarrage;
@property (nonatomic,strong) UIButton *btnFullScreen;

@end

@implementation PPVideoPlayerView

#pragma mark - 懒加载

- (NELivePlayerController *)player{
    if(!_player){
        [NELivePlayerController setLogLevel:NELP_LOG_VERBOSE];
        
        NSError *error = nil;
        _player = [[NELivePlayerController alloc] initWithContentURL:self.playUrl error:&error];
        if (_player == nil) {
            NSLog(@"player initilize failed, please tay again.error = [%@]!", error);
        }
        _player.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _player.view.frame = self.bounds;
        [self addSubview:_player.view];
        [self sendSubviewToBack:_player.view];
        
        self.autoresizesSubviews = YES;
        
        if (self.isLive) {
            [_player setBufferStrategy:NELPLowDelay]; // 直播低延时模式
        } else {
            [_player setBufferStrategy:NELPAntiJitter]; // 点播抗抖动
        }
        [_player setScalingMode:NELPMovieScalingModeNone]; // 设置画面显示模式，默认原始大小
        [_player setShouldAutoplay:NO]; // 设置prepareToPlay完成后是否自动播放
        [_player setHardwareDecoder:YES]; // 设置解码模式，是否开启硬件解码
        [_player setPauseInBackground:YES]; // 设置切入后台时的状态，暂停还是继续播放
        [_player setPlaybackTimeout:15 *1000]; // 设置拉流超时时间
    }
    return _player;
}

#pragma mark - ---头
-(UIView *)topView{
    if(!_topView){
        _topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 40)];
        _topView.backgroundColor = [UIColor colorWithRed:70/255 green:70/255 blue:70/255 alpha:0.8];
        _topView.alpha = 0;
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

-(UIButton *)btnShare{
    if(!_btnShare){
        _btnShare = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnShare.frame = CGRectMake(0, 10, 20, 20);
        [_btnShare setImage:[self imagesNamedFromCustomBundle:@"PPKit_vp_share"] forState:UIControlStateNormal];
        [_btnShare addTarget:self action:@selector(shareAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnShare;
}

-(UIButton *)btnFavorite{
    if(!_btnFavorite){
        _btnFavorite = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnFavorite.frame = CGRectMake(0, 10, 20, 20);
        [_btnFavorite setImage:[self imagesNamedFromCustomBundle:@"PPKit_vp_favorite_empty"] forState:UIControlStateNormal];
        [_btnFavorite addTarget:self action:@selector(favoriteAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnFavorite;
}

-(UIButton *)btnDownload{
    if(!_btnDownload){
        _btnDownload = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnDownload.frame = CGRectMake(0, 10, 20, 20);
        [_btnDownload setImage:[self imagesNamedFromCustomBundle:@"PPKit_vp_download"] forState:UIControlStateNormal];
        [_btnDownload addTarget:self action:@selector(downloadAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnDownload;
}

#pragma mark - ---中
-(UIButton *)btnReplay{
    if(!_btnReplay){
        _btnReplay = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btnReplay setImage:[self imagesNamedFromCustomBundle:@"PPKit_vp_play_big"] forState:UIControlStateNormal];
        [_btnReplay addTarget:self action:@selector(play) forControlEvents:UIControlEventTouchUpInside];
    }
    pX = (self.bounds.size.width - 55)/2;
    pY = (self.bounds.size.height - 50)/2;
    _btnReplay.frame = CGRectMake(pX, pY, 55, 50);
    return _btnReplay;
}

- (UIView *)alertView{
    if(!_alertView){
        _alertView = [[UIView alloc] initWithFrame:CGRectMake(0, pY, self.bounds.size.width, 70)];
        [_alertView addSubview:self.alertImageView];
        [_alertView addSubview:self.alertLabel];
    }
    pY = (self.bounds.size.height - 70)/2;
    _alertView.frame = CGRectMake(0, pY, self.bounds.size.width, 70);
    return _alertView;
}

- (UIImageView *)alertImageView{
    if(!_alertImageView){
        _alertImageView = [[UIImageView alloc] initWithFrame:CGRectMake(pX, 0, 50, 50)];
        _alertImageView.image = [self imagesNamedFromCustomBundle:@"PPKit_vp_logo"];
        _alertImageView.contentMode = UIViewContentModeScaleToFill;
    }
    pX = (self.alertView.frame.size.width - 50)/2;
    _alertImageView.frame = CGRectMake(pX, 0, 50, 50);
    return _alertImageView;
}

- (UILabel *)alertLabel{
    if(!_alertLabel){
        _alertLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, self.alertView.frame.size.width, 20)];
        _alertLabel.textColor = [UIColor lightGrayColor];
        _alertLabel.textAlignment = NSTextAlignmentCenter;
        _alertLabel.font = [UIFont systemFontOfSize:10];
    }
    _alertLabel.frame = CGRectMake(0, 50, self.alertView.frame.size.width, 20);
    return _alertLabel;
}

-(UIView *)notWifiView{
    if(!_notWifiView){
        _notWifiView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
        _notWifiView.backgroundColor = [UIColor blackColor];
    }
    _notWifiView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    return _notWifiView;
}

-(UILabel *)labNotWifiMsg{
    if(!_labNotWifiMsg){
        _labNotWifiMsg = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
        _labNotWifiMsg.text = @"正在使用非Wifi网络\n播放将会产生流量费用";
        _labNotWifiMsg.textAlignment = NSTextAlignmentCenter;
        _labNotWifiMsg.textColor = [UIColor whiteColor];
        _labNotWifiMsg.font = [UIFont systemFontOfSize:16];
        _labNotWifiMsg.numberOfLines = 2;
        _labNotWifiMsg.lineBreakMode = NSLineBreakByWordWrapping;
    }
    pY = (self.bounds.size.height - 50)/2 - 20;
    _labNotWifiMsg.frame = CGRectMake(0, pY, self.bounds.size.width, 50);
    return _labNotWifiMsg;
}

-(UIButton *)btnContinuePlay{
    if(!_btnContinuePlay){
        _btnContinuePlay = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnContinuePlay.backgroundColor = [UIColor redColor];
        _btnContinuePlay.titleLabel.font = [UIFont systemFontOfSize:15];
        _btnContinuePlay.layer.cornerRadius = 20;
        _btnContinuePlay.layer.masksToBounds = YES;
        [_btnContinuePlay setTitle:@"继续播放" forState:UIControlStateNormal];
        [_btnContinuePlay setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_btnContinuePlay addTarget:self action:@selector(continuePlayAction) forControlEvents:UIControlEventTouchUpInside];
    }
    pX = (self.bounds.size.width - 90)/2;
    pY = (self.bounds.size.height - 50)/2 + 40;
    _btnContinuePlay.frame = CGRectMake(pX, pY, 90, 40);
    return _btnContinuePlay;
}

-(UILabel *)liveNotStartedView{
    if(!_liveNotStartedView){
        _liveNotStartedView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
        _liveNotStartedView.text = @"主播正在赶来路上";
        _liveNotStartedView.textAlignment = NSTextAlignmentCenter;
        _liveNotStartedView.textColor = [UIColor lightGrayColor];
        _liveNotStartedView.backgroundColor = [UIColor blackColor];
        _liveNotStartedView.font = [UIFont systemFontOfSize:20];
    }
    return _liveNotStartedView;
}

-(UILabel *)liveOverView{
    if(!_liveOverView){
        _liveOverView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
        _liveOverView.text = @"当前直播已结束";
        _liveOverView.textAlignment = NSTextAlignmentCenter;
        _liveOverView.textColor = [UIColor lightGrayColor];
        _liveOverView.backgroundColor = [UIColor blackColor];
        _liveOverView.font = [UIFont systemFontOfSize:20];
    }
    return _liveOverView;
}

-(BrightnessVolumeView *)BVView{
    if(!_BVView){
        _BVView = [[BrightnessVolumeView alloc] initWithFrame:self.bounds];
    }
    return _BVView;
}

-(UIButton *)btnFSLock{
    if(!_btnFSLock){
        _btnFSLock = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btnFSLock setImage:[self imagesNamedFromCustomBundle:@"PPKit_vp_screen_open"] forState:UIControlStateNormal];
        [_btnFSLock addTarget:self action:@selector(fslockAction) forControlEvents:UIControlEventTouchUpInside];
    
    }
    
    CGFloat pvY = (self.bounds.size.height - 30)/2;
    _btnFSLock.frame = CGRectMake(30, pvY, 30, 30);
    
    return _btnFSLock;
}

#pragma mark - ---尾
-(UIView *)bottomView{
    if(!_bottomView){
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height-40, self.bounds.size.width, 40)];
        _bottomView.backgroundColor = [UIColor colorWithRed:70/255 green:70/255 blue:70/255 alpha:0.8];
        _bottomView.alpha = 0;
    }
    return _bottomView;
}

-(UIButton *)btnPlayOrPause{
    if(!_btnPlayOrPause){
        _btnPlayOrPause = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnPlayOrPause.frame = CGRectMake(0, 10, 20, 20);
        [_btnPlayOrPause setImage:[self imagesNamedFromCustomBundle:@"PPKit_vp_play"] forState:UIControlStateNormal];
        [_btnPlayOrPause addTarget:self action:@selector(playOrPauseAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnPlayOrPause;
}

-(UIButton *)btnNextVideo{
    if(!_btnNextVideo){
        _btnNextVideo = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnNextVideo.frame = CGRectMake(0, 10, 20, 20);
        [_btnNextVideo setImage:[self imagesNamedFromCustomBundle:@"PPKit_vp_next"] forState:UIControlStateNormal];
        [_btnNextVideo addTarget:self action:@selector(nextVideoAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnNextVideo;
}

-(UILabel *)labLiving{
    if(!_labLiving){
        _labLiving = [[UILabel alloc] initWithFrame:CGRectZero];
        _labLiving.text = @"正在直播";
        _labLiving.textColor = [UIColor whiteColor];
        _labLiving.textAlignment = NSTextAlignmentLeft;
        _labLiving.font = [UIFont systemFontOfSize:16];
    }
    return _labLiving;
}

-(UILabel *)labStartTime{
    if(!_labStartTime){
        _labStartTime = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 40, 30)];
        _labStartTime.textAlignment = NSTextAlignmentCenter;
        _labStartTime.textColor = [UIColor whiteColor];
        _labStartTime.font = [UIFont systemFontOfSize:12];
        _labStartTime.text = @"0:00:00";
    }
    return _labStartTime;
}

-(UISlider *)playProgress{
    if(!_playProgress){
        _playProgress = [[UISlider alloc] initWithFrame:CGRectMake(0, 5, 0, 30)];
        _playProgress.value = 0.0;
        _playProgress.maximumTrackTintColor = [UIColor clearColor];
        //设置播放进度颜色
        _playProgress.minimumTrackTintColor = [UIColor orangeColor];
        [_playProgress setThumbImage:[self imagesNamedFromCustomBundle:@"PPKit_vp_slider"] forState:UIControlStateNormal];
        
        [_playProgress addTarget:self action:@selector(playerSliderTouchDown:) forControlEvents:UIControlEventTouchDown];
        [_playProgress addTarget:self action:@selector(playerSliderTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [_playProgress addTarget:self action:@selector(playerSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _playProgress;
}

- (UIProgressView *)loadedProgress{
    if(!_loadedProgress){
        _loadedProgress = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 5, 0, 30)];
        //_loadedProgress.progress = 0.5;
        //设置已经缓存进度颜色
        _loadedProgress.progressTintColor = [UIColor whiteColor];
    }
    return _loadedProgress;
}

-(UILabel *)labEndTime{
    if(!_labEndTime){
        _labEndTime = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 40, 30)];
        _labEndTime.textAlignment = NSTextAlignmentCenter;
        _labEndTime.textColor = [UIColor whiteColor];
        _labEndTime.font = [UIFont systemFontOfSize:12];
        _labEndTime.text = @"0:00:00";
    }
    return _labEndTime;
}

-(UIButton *)btnQuality{
    if(!_btnQuality){
        _btnQuality = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnQuality.frame = CGRectMake(0, 5, 50, 30);
        _btnQuality.backgroundColor = [UIColor grayColor];
        _btnQuality.titleLabel.font = [UIFont systemFontOfSize:12];
        [_btnQuality setTitle:@"标准" forState:UIControlStateNormal];
        [_btnQuality setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_btnQuality addTarget:self action:@selector(qualityAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnQuality;
}

-(UIButton *)btnVideoList{
    if(!_btnVideoList){
        _btnVideoList = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnVideoList.frame = CGRectMake(0, 10, 20, 20);
        [_btnVideoList setImage:[self imagesNamedFromCustomBundle:@"PPKit_vp_list"] forState:UIControlStateNormal];
        [_btnVideoList addTarget:self action:@selector(videoListAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnVideoList;
}

-(UIButton *)btnToTV{
    if(!_btnToTV){
        _btnToTV = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnToTV.frame = CGRectMake(0, 10, 20, 20);
        [_btnToTV setImage:[self imagesNamedFromCustomBundle:@"PPKit_vp_toTV"] forState:UIControlStateNormal];
        [_btnToTV addTarget:self action:@selector(toTVAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnToTV;
}

-(UIButton *)btnBarrage{
    if(!_btnBarrage){
        _btnBarrage = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnBarrage.frame = CGRectMake(0, 10, 20, 20);
        [_btnBarrage setImage:[self imagesNamedFromCustomBundle:@"PPKit_vp_dan_1"] forState:UIControlStateNormal];
        [_btnBarrage addTarget:self action:@selector(barrageAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnBarrage;
}

-(UIButton *)btnFullScreen{
    if(!_btnFullScreen){
        _btnFullScreen = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnFullScreen.frame = CGRectMake(0, 10, 20, 20);
        [_btnFullScreen setImage:[self imagesNamedFromCustomBundle:@"PPKit_vp_fullscreen"] forState:UIControlStateNormal];
        [_btnFullScreen addTarget:self action:@selector(fullScreenAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnFullScreen;
}

#pragma mark - 重载方法

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]){
        //初始化默认属性
        self.backgroundColor = [UIColor blackColor];
        
        _controlHidden = YES;
        _showBackButton = YES;
        _playStatus = PPVideoPlayerStatusUnknown;
        _controlStyle = PPVideoPlayerControlStyleDefault;
        [self addSubview:self.topView];
        [self addSubview:self.bottomView];
        [self addSubview:self.btnBack];
        
        [UIView animateWithDuration:0.2 animations:^{
            self.topView.alpha = 1;
            self.bottomView.alpha = 1;
        }];
        
        //初始化弹幕对象
        self.barrageManager = [[OCBarrageManager alloc] init];
        [self addSubview:self.barrageManager.renderView];
        self.barrageManager.renderView.frame = CGRectMake(0, 40, self.bounds.size.width, self.bounds.size.height - 80);
        //    self.barrageManager.renderView.center = self.view.center;
        self.barrageManager.renderView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        //添加平移手势
        //UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panMove:)];
        //[self addGestureRecognizer:panGesture];
        
        //添加音量亮度调节视图
        [self addSubview:self.BVView];
    }
    return self;
}

//设置标题
-(void)setTitle:(NSString *)title{
    _title = title;

    self.labTitle.text = title;
}

//设置全屏
-(void)setFullScreen:(BOOL)fullScreen{
    _fullScreen = fullScreen;

    if(self.controlStyle == PPVideoPlayerControlStyleNotWifi){
        self.controlStyle = PPVideoPlayerControlStyleNotWifi;
    }else{
        if(fullScreen){
            self.controlStyle = PPVideoPlayerControlStyleFullScreen;
        }else{
            self.controlStyle = PPVideoPlayerControlStyleDefault;
        }
    }
}

- (void)setPlayStatus:(PPVideoPlayerStatus)playStatus{
    _playStatus = playStatus;
    
    [self reloadCenterControlViews];
    
    switch (playStatus) {
        case PPVideoPlayerStatusPlaying:{
            NSLog(@"PPVideoPlayerStatusPlaying");
            [self hideAlertViews];
            
            //播放时，显示未暂停按钮
            [self.btnPlayOrPause setImage:[self imagesNamedFromCustomBundle:@"PPKit_vp_pause"] forState:UIControlStateNormal];
            break;
        }
        case PPVideoPlayerStatusPause:{
            NSLog(@"PPVideoPlayerStatusPause");
            if(!self.isAlerting){
                [self.btnReplay setImage:[self imagesNamedFromCustomBundle:@"PPKit_vp_play_big"] forState:UIControlStateNormal];
                [self addSubview:self.btnReplay];
            }
            [self.btnPlayOrPause setImage:[self imagesNamedFromCustomBundle:@"PPKit_vp_play"] forState:UIControlStateNormal];
            break;
        }
        case PPVideoPlayerStatusStop:{
            NSLog(@"PPVideoPlayerStatusStop");
            [self.btnPlayOrPause setImage:[self imagesNamedFromCustomBundle:@"PPKit_vp_play"] forState:UIControlStateNormal];
            break;
        }
        case PPVideoPlayerStatusSeeking:{
            NSLog(@"PPVideoPlayerStatusSeeking");
            [self.btnPlayOrPause setImage:[self imagesNamedFromCustomBundle:@"PPKit_vp_play"] forState:UIControlStateNormal];
            break;
        }
        default:
            break;
    }

    if(self.delegate && [self.delegate respondsToSelector:@selector(PPVideoPlayerView:playStatusChanged:)]){
        [self.delegate PPVideoPlayerView:self playStatusChanged:playStatus];
    }
}

//设置控制控件样式
-(void)setControlStyle:(PPVideoPlayerControlStyle)controlStyle{
    _controlStyle = controlStyle;
    
    if(controlStyle == PPVideoPlayerControlStyleNotWifi){
        [self showNotWifiMsg];
        return;
    }
    
    [self reloadTopControlViews];
    [self reloadCenterControlViews];
    [self reloadBottomControlViews];

    //测试
//    self.btnBack.backgroundColor =[UIColor redColor];
//    self.labTitle.backgroundColor = [UIColor orangeColor];
//    self.btnToTV.backgroundColor = [UIColor redColor];
//    self.btnShare.backgroundColor = [UIColor greenColor];
//    self.btnFavorite.backgroundColor = [UIColor blueColor];
//    self.btnDownload.backgroundColor = [UIColor redColor];
//
//    self.btnPlayOrPause.backgroundColor = [UIColor redColor];
//    self.btnNextVideo.backgroundColor = [UIColor greenColor];
//
//    self.labStartTime.backgroundColor = [UIColor redColor];
//    self.labLiving.backgroundColor = [UIColor orangeColor];
//    self.labEndTime.backgroundColor = [UIColor redColor];
//    self.btnBarrage.backgroundColor = [UIColor redColor];
//    self.btnFullScreen.backgroundColor = [UIColor redColor];
//    self.btnVideoList.backgroundColor = [UIColor greenColor];
//    self.btnQuality.backgroundColor = [UIColor blueColor];
}

- (void)setCurrentTime:(NSTimeInterval)currentTime{
    if(self.player && self.playUrl){
        //播放器跳转到指定时间点
        //NSLog(@"Seek Time:%f",currentTime);
        [self.player setCurrentPlaybackTime:currentTime];
    }
}

-(void)setIsWifiNetwork:(BOOL)isWifiNetwork{
    _isWifiNetwork = isWifiNetwork;
    
    if(!isWifiNetwork){
        self.controlStyle = PPVideoPlayerControlStyleNotWifi;
    }
}

-(void)setIsLive:(BOOL)isLive{
    _isLive = isLive;
    
    [self reloadTopControlViews];
    [self reloadCenterControlViews];
    [self reloadBottomControlViews];
}

-(void)setShowTopBar:(BOOL)showTopBar{
    _showTopBar = showTopBar;
    
    [self reloadTopControlViews];
    [self reloadCenterControlViews];
    [self reloadBottomControlViews];
}

-(void)setShowBackButton:(BOOL)showBackButton{
    _showBackButton = showBackButton;
    if(!showBackButton){
        [self.btnBack removeFromSuperview];
        [self reloadTopControlViews];
    }
}

-(void)setShowShareButton:(BOOL)showShareButton{
    _showShareButton = showShareButton;
    if(!showShareButton){
        [self.btnShare removeFromSuperview];
        [self reloadTopControlViews];
    }
}

-(void)setShowFavoritesButton:(BOOL)showFavoritesButton{
    _showFavoritesButton = showFavoritesButton;
    if(!showFavoritesButton){
        [self.btnFavorite removeFromSuperview];
        [self reloadTopControlViews];
    }
}

-(void)setShowDownButton:(BOOL)showDownButton{
    _showDownButton = showDownButton;
    if(!showDownButton){
        [self.btnDownload removeFromSuperview];
        [self reloadTopControlViews];
    }
}

#pragma mark - 播放器核心操作

//装载播放
-(void)prepareToPlay{
    
    if(self.isLive){
        [self.player setBufferStrategy:NELPFluent]; //直播流畅模式
    }else{
        [self.player setBufferStrategy:NELPAntiJitter];//点播模式
    }
#if 1
    [self.player prepareToPlay]; //初始化视频文件
    
    //显示加载中
    if(self.controlStyle != PPVideoPlayerControlStyleNotWifi){
        [self showLoading];
    }
    
#else
    //模拟测试提示
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.player prepareToPlay]; //初始化视频文件
    });
    if(self.controlStyle != PPVideoPlayerControlStyleNotWifi){
        [self showLoading];
    }
//    [self showBufferLoading];
//    [self showNetworkFaild];
//    [self showNetworkStalled];
//    [self showNotWifiMsg];
//    [self showLiveOverView];
#endif
    //2.显示控制控件
    self.topView.alpha = 1;
    self.bottomView.alpha = 1;
    [self startControlTimer];
    
    //添加通知监听
    [self addNotifyObservers];
}

//播放
- (void)play{
    if(self.player && self.playUrl){
        //30秒后检测是否播放状态
        [self performSelector:@selector(checkPlayerStatus) withObject:nil afterDelay:30];
        
        //播放
        [self.player play];
        
        // 监听播放进度
        /*
         NULL 在主线程中执行，每个一秒执行一次该 Block
         */
        __weak typeof(self) weakSelf = self;
        //定时器开始执行的延时时间
        NSTimeInterval delayTime = 1.0f;
        //定时器间隔时间
        NSTimeInterval timeInterval = 0.5f;
        //创建子线程队列
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        //使用之前创建的队列来创建计时器
        _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        //设置延时执行时间，delayTime为要延时的秒数
        dispatch_time_t startDelayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayTime * NSEC_PER_SEC));
        //设置计时器
        dispatch_source_set_timer(_timer, startDelayTime, timeInterval * NSEC_PER_SEC, 0.1 * NSEC_PER_SEC);
        dispatch_source_set_event_handler(_timer, ^{
            if(!_isLive){
                // 获取当前播放进度
                NSTimeInterval currentSecond = weakSelf.player.currentPlaybackTime;
                
                // 获取当前缓存进度
                NSTimeInterval currentCache = weakSelf.player.playableDuration;
                
                // 获取视频总长度
                NSTimeInterval totalSecond = weakSelf.player.duration;
                
                //NSLog(@"当前播放进度：%f/%f/%f",currentSecond,currentCache,totalSecond);
                
                //改变播放时间和进度的状态
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.loadedProgress setProgress:currentCache/totalSecond animated:YES];
                    
                    // 更新slider, 如果正在滑动则不更新
                    if (_isSliding == NO) {
                        weakSelf.playProgress.value = currentSecond;
                        weakSelf.labStartTime.text = [weakSelf convertTime:currentSecond];
                        
                        weakSelf.playProgress.maximumValue = totalSecond;
                        weakSelf.labEndTime.text = [weakSelf convertTime:totalSecond];
                    }
                });
                
                if(weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(PPVideoPlayerView:timeChanged:)]){
                    [weakSelf.delegate PPVideoPlayerView:weakSelf timeChanged:currentSecond];
                }
            }
        });
        // 启动计时器
        dispatch_resume(_timer);
        
        if(self.delegate && [self.delegate respondsToSelector:@selector(PPVideoPlayerView:playStatusChanged:)]){
            [self.delegate PPVideoPlayerView:self playStatusChanged:PPVideoPlayerStatusPlaying];
        }
    }
}

//暂停
- (void)pause{
    if(self.player && self.playUrl){
        //播放器暂停
        [self.player pause];
        
        //销毁定时器
        if(_timer){
            dispatch_source_cancel(_timer);
        }
        
        //设置当前播放状态
        self.playStatus = PPVideoPlayerStatusPause;
        
        if(self.delegate && [self.delegate respondsToSelector:@selector(PPVideoPlayerView:playStatusChanged:)]){
            [self.delegate PPVideoPlayerView:self playStatusChanged:PPVideoPlayerStatusPause];
        }
    }
}

- (void)stop{
    //退出播放并释放相关资源
    [self.player shutdown]; // 退出播放并释放相关资源
    [self.player.view removeFromSuperview];
    self.player = nil;
    
    //销毁定时器
    if(_timer){
        dispatch_source_cancel(_timer);
    }
    [self clearControlTimer];
    
    //移除所有监听
    [self removeNotifyObservers];
    
    //停止弹幕
    [self stopBarrage];
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(PPVideoPlayerView:playStatusChanged:)]){
        [self.delegate PPVideoPlayerView:self playStatusChanged:PPVideoPlayerStatusStop];
    }
}

//检测播放状态
- (void)checkPlayerStatus{
    if(_playStatus == PPVideoPlayerStatusUnknown){
        [self showNetworkFaild];
    }
}

//开启控制视图消失定时器
- (void)startControlTimer{
    [self clearControlTimer];
    
    self.controlTimer = [NSTimer scheduledTimerWithTimeInterval:12.0f target:self selector:@selector(controlTimerGo) userInfo:nil repeats:NO];
      //iOS10写法
//    __weak typeof(self) weakSelf = self;
//    self.controlTimer = [NSTimer scheduledTimerWithTimeInterval:12.0f repeats:NO block:^(NSTimer * _Nonnull timer) {
//        //隐藏控制视图
//        [UIView animateWithDuration:0.3 animations:^{
//            weakSelf.topView.alpha = 0;
//            weakSelf.bottomView.alpha = 0;
//        }];
//        
//        //销毁定时器
//        [weakSelf clearControlTimer];
//    }];
}

- (void)controlTimerGo{
    //隐藏控制视图
    [UIView animateWithDuration:0.3 animations:^{
        self.topView.alpha = 0;
        self.bottomView.alpha = 0;
    }];
    
    //销毁定时器
    [self clearControlTimer];
}

//清楚销毁定时器资源
- (void)clearControlTimer{
    if (self.controlTimer) {
        [self.controlTimer invalidate];
        self.controlTimer = nil;
    }
}

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

- (UIImage *)imagesNamedFromCustomBundle:(NSString *)imgName{
    NSString *bundlePath = [[NSBundle mainBundle].resourcePath stringByAppendingPathComponent:@"PPVideoPlayer.bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    NSString *img_path = [bundle pathForResource:imgName ofType:@"png"];
    return [UIImage imageWithContentsOfFile:img_path];
}

#pragma mark - UI展示
/**
 重新加载顶部控件视图
 */
- (void)reloadTopControlViews{
    if(self.controlStyle == PPVideoPlayerControlStyleNotWifi){
        self.topView.alpha = 0;
        return;
    }
    
    if(!self.showTopBar){
        [self.topView removeFromSuperview];
        return;
    }
    
    self.topView.frame = CGRectMake(0, 0, self.bounds.size.width, 40);
    [self.topView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    CGFloat iconSize = 26,iconTop = 7;
    if(self.controlStyle == PPVideoPlayerControlStyleFullScreen){
        //全屏模式：返回按钮，标题，分享按钮，收藏按钮，下载按钮
        pX = 10;
        [self addSubview:self.btnBack];
        self.btnBack.frame = CGRectMake(pX, 0, 40, 40);
        CGFloat tmpX = pX + self.btnBack.frame.size.width + 5;
        
        BOOL hasRightBtn = NO;
        pX = self.topView.frame.size.width - iconSize - 5;
        if(self.showDownButton && !self.isLive){
            hasRightBtn = YES;
            [self.topView addSubview:self.btnDownload];
            self.btnDownload.frame = CGRectMake(pX, iconTop, iconSize, iconSize);
            pX = pX - iconSize - 5;
        }
        
        if(self.showFavoritesButton){
            hasRightBtn = YES;
            [self.topView addSubview:self.btnFavorite];
            self.btnFavorite.frame = CGRectMake(pX, iconTop, iconSize, iconSize);
            pX = pX - iconSize - 5;
        }
        
        if(self.showShareButton){
            hasRightBtn = YES;
            [self.topView addSubview:self.btnShare];
            self.btnShare.frame = CGRectMake(pX, iconTop, iconSize, iconSize);
            pX = pX - iconSize - 5;
        }
        
        if(!hasRightBtn){
            pX = self.topView.frame.size.width - 10;
        }else{
            pX = pX + iconSize;
        }
        
        [self.topView addSubview:self.labTitle];
        pWidth = self.topView.frame.size.width - tmpX;
        pWidth = pWidth - (self.topView.frame.size.width - pX);
        pHeight = self.topView.frame.size.height;
        self.labTitle.frame = CGRectMake(tmpX, 5, pWidth, 30);
    }else{
        //默认模式元素：返回按钮，标题
        pX = 10;
        if(self.showBackButton){
            [self addSubview:self.btnBack];
            self.btnBack.frame = CGRectMake(pX, 0, 40, 40);
            pX = pX + self.btnBack.frame.size.width + 5;
        }
        [self.topView addSubview:self.labTitle];
        pWidth = self.topView.frame.size.width - pX - 10;
        pHeight = self.topView.frame.size.height;
        self.labTitle.frame = CGRectMake(pX, 5, pWidth, 30);
    }
    
}


/**
 重新加载中间控件视图
 */
- (void)reloadCenterControlViews{
 
    //播放视图视图重置
    if(_player){
        self.player.view.frame = self.bounds;
    }
    
    //播放按钮
    if(_btnReplay){
        pX = (self.bounds.size.width - 55)/2;
        pY = (self.bounds.size.height - 50)/2;
        _btnReplay.frame = CGRectMake(pX, pY, 55, 50);
    }

    //提示信息
    if(_alertView){
        pY = (self.bounds.size.height - 70)/2;
        _alertView.frame = CGRectMake(0, pY, self.bounds.size.width, 70);
        
        pX = (_alertView.frame.size.width - 50)/2;
        _alertImageView.frame = CGRectMake(pX, 0, 50, 50);
        
        _alertLabel.frame = CGRectMake(0, 50, _alertView.frame.size.width, 20);
    }
    
    //没有Wifi视图
    
    //直播未开始
    if(_liveNotStartedView){
        _liveNotStartedView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    }
    
    //直播结束视图
    if(_liveOverView){
        _liveOverView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    }
    
    self.barrageManager.renderView.frame = CGRectMake(0, 40, self.bounds.size.width, self.bounds.size.height - 80);
    
    self.BVView.frame = self.bounds;
    
    if(self.controlStyle == PPVideoPlayerControlStyleFullScreen){
        [self addSubview:self.btnFSLock];
    }else{
        [self.btnFSLock removeFromSuperview];
    }
}

/**
 重新加载底部控件视图
 */
- (void)reloadBottomControlViews{
    if(self.controlStyle == PPVideoPlayerControlStyleNotWifi){
        self.bottomView.alpha = 0;
        return;
    }
    self.bottomView.frame = CGRectMake(0, self.bounds.size.height-40, self.bounds.size.width, 40);
    [self.bottomView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    pHeight = self.bottomView.frame.size.height;
    
    CGFloat iconSize = 26,iconTop = 7;
    if(self.controlStyle == PPVideoPlayerControlStyleFullScreen){
        //全屏模式:播放按钮，下一个视频按钮，直播标签，时间进度标签，进度条，质量播放按钮，播放列表按钮，投屏按钮，全屏按钮
        pX = 5;
        
        [self.bottomView addSubview:self.btnPlayOrPause];
        self.btnPlayOrPause.frame = CGRectMake(5, iconTop, iconSize, iconSize);
        pX = pX + self.btnPlayOrPause.frame.size.width + 5;
        
        if(self.isLive){
            //直播显示样式
            [self.bottomView addSubview:self.labLiving];
            pHeight = self.bottomView.frame.size.height;
            self.labLiving.frame = CGRectMake(pX, 5, 100, 30);
            
            pX = self.bottomView.frame.size.width - iconSize - 5;
            if(self.showFullScreenButton){
                [self.bottomView addSubview:self.btnFullScreen];
                self.btnFullScreen.frame = CGRectMake(pX, iconTop, iconSize, iconSize);
                pX = pX - self.btnFullScreen.frame.size.width - 5;
                
                [self.btnFullScreen setImage:[self imagesNamedFromCustomBundle:@"PPKit_vp_smallscreen"] forState:UIControlStateNormal];
            }
            
            if(self.showBarrageButton){
                [self.bottomView addSubview:self.btnBarrage];
                self.btnBarrage.frame = CGRectMake(pX, iconTop, iconSize, iconSize);
                pX = pX - self.btnBarrage.frame.size.width - 5;
            }
            
            if(self.showToTVButton){
                [self.bottomView addSubview:self.btnToTV];
                self.btnToTV.frame = CGRectMake(pX, iconTop, iconSize, iconSize);
                pX = pX - self.btnToTV.frame.size.width - 5;
            }
        }else{
            //点播显示样式
            CGFloat tmpX;
            if(self.showNextButton){
                [self.bottomView addSubview:self.btnNextVideo];
                self.btnNextVideo.frame = CGRectMake(pX, iconTop, iconSize, iconSize);
                pX = pX + self.btnNextVideo.frame.size.width + 5;
            }
            
            [self.bottomView addSubview:self.labStartTime];
            self.labStartTime.frame = CGRectMake(pX, 5, 50, 30);
            tmpX = pX + self.labStartTime.frame.size.width;
            
            BOOL hasRightBtn = NO;
            pX = self.bottomView.frame.size.width - iconSize - 5;
            if(self.showFullScreenButton){
                hasRightBtn = YES;
                [self.bottomView addSubview:self.btnFullScreen];
                self.btnFullScreen.frame = CGRectMake(pX, iconTop, iconSize, iconSize);
                pX = pX - self.btnFullScreen.frame.size.width - 5;
                
                [self.btnFullScreen setImage:[self imagesNamedFromCustomBundle:@"PPKit_vp_smallscreen"] forState:UIControlStateNormal];
            }
            
            if(self.showBarrageButton){
                [self.bottomView addSubview:self.btnBarrage];
                self.btnBarrage.frame = CGRectMake(pX, iconTop, iconSize, iconSize);
                pX = pX - self.btnBarrage.frame.size.width - 5;
            }
            
            if(self.showToTVButton){
                hasRightBtn = YES;
                [self.bottomView addSubview:self.btnToTV];
                self.btnToTV.frame = CGRectMake(pX, iconTop, iconSize, iconSize);
                pX = pX - self.btnToTV.frame.size.width - 5;
            }
            
            if(self.showListButton){
                hasRightBtn = YES;
                [self.bottomView addSubview:self.btnVideoList];
                self.btnVideoList.frame = CGRectMake(pX, iconTop, iconSize, iconSize);
                pX = pX - self.btnVideoList.frame.size.width - 5;
            }
            
            if(!hasRightBtn){
                pX = self.bottomView.frame.size.width - 50 - 5;
            }else{
                pX = pX - (50-iconSize);
            }
            
            [self.bottomView addSubview:self.labEndTime];
            self.labEndTime.frame = CGRectMake(pX, 5, 50, 30);
            
            [self.bottomView addSubview:self.loadedProgress];
            [self.bottomView addSubview:self.playProgress];
            pWidth = self.bottomView.frame.size.width - (self.bottomView.frame.size.width - pX) - tmpX;
            self.playProgress.frame = CGRectMake(tmpX, 10, pWidth, 20);
            self.loadedProgress.frame = CGRectMake(tmpX+2, 19, pWidth-4, 20);
        }
    }else{
        //默认模式：播放按钮，下一个视频按钮，直播标签，时间进度标签，进度条，质量播放按钮，投屏按钮，全屏按钮
        pX = 5;
        
        [self.bottomView addSubview:self.btnPlayOrPause];
        self.btnPlayOrPause.frame = CGRectMake(pX, iconTop, iconSize, iconSize);
        pX = pX + self.btnPlayOrPause.frame.size.width + 5;
        
        if(self.isLive){
            //直播显示样式
            [self.bottomView addSubview:self.labLiving];
            pHeight = self.bottomView.frame.size.height;
            self.labLiving.frame = CGRectMake(pX, 5, 100, 30);
            
            pX = self.bottomView.frame.size.width - iconSize - 5;
            if(self.showFullScreenButton){
                [self.bottomView addSubview:self.btnFullScreen];
                self.btnFullScreen.frame = CGRectMake(pX, iconTop, iconSize, iconSize);
                pX = pX - self.btnFullScreen.frame.size.width - 5;
                
                [self.btnFullScreen setImage:[self imagesNamedFromCustomBundle:@"PPKit_vp_fullscreen"] forState:UIControlStateNormal];
            }
            
            if(self.showBarrageButton){
                [self.bottomView addSubview:self.btnBarrage];
                self.btnBarrage.frame = CGRectMake(pX, iconTop, iconSize, iconSize);
                pX = pX - self.btnBarrage.frame.size.width - 5;
            }
            
            if(self.showToTVButton){
                [self.bottomView addSubview:self.btnToTV];
                self.btnToTV.frame = CGRectMake(pX, iconTop, iconSize, iconSize);
                pX = pX - self.btnToTV.frame.size.width - 5;
            }
        }else{
            //点播显示样式
            CGFloat tmpX;
            if(self.showNextButton){
                [self.bottomView addSubview:self.btnNextVideo];
                self.btnNextVideo.frame = CGRectMake(pX, iconTop, iconSize, iconSize);
                pX = pX + self.btnNextVideo.frame.size.width + 5;
            }
            
            [self.bottomView addSubview:self.labStartTime];
            self.labStartTime.frame = CGRectMake(pX, 5, 50, 30);
            tmpX = pX + self.labStartTime.frame.size.width;
            
            BOOL hasRightBtn = NO;
            pX = self.bottomView.frame.size.width - iconSize - 5;
            if(self.showFullScreenButton){
                hasRightBtn = YES;
                [self.bottomView addSubview:self.btnFullScreen];
                self.btnFullScreen.frame = CGRectMake(pX, iconTop, iconSize, iconSize);
                pX = pX - self.btnFullScreen.frame.size.width - 5;
                
                [self.btnFullScreen setImage:[self imagesNamedFromCustomBundle:@"PPKit_vp_fullscreen"] forState:UIControlStateNormal];
            }
            
            if(self.showBarrageButton){
                [self.bottomView addSubview:self.btnBarrage];
                self.btnBarrage.frame = CGRectMake(pX, iconTop, iconSize, iconSize);
                pX = pX - self.btnBarrage.frame.size.width - 5;
            }
            
            if(self.showToTVButton){
                hasRightBtn = YES;
                [self.bottomView addSubview:self.btnToTV];
                self.btnToTV.frame = CGRectMake(pX, iconTop, iconSize, iconSize);
                pX = pX - self.btnToTV.frame.size.width - 5;
            }
            
            if(!hasRightBtn){
                pX = self.bottomView.frame.size.width - 50 - 5;
            }else{
                pX = pX - (50-30);
            }
            
            [self.bottomView addSubview:self.labEndTime];
            self.labEndTime.frame = CGRectMake(pX, 5, 50, 30);
            
            [self.bottomView addSubview:self.loadedProgress];
            [self.bottomView addSubview:self.playProgress];
            pWidth = self.bottomView.frame.size.width - (self.bottomView.frame.size.width - pX) - tmpX;
            self.playProgress.frame = CGRectMake(tmpX, 10, pWidth, 20);
            self.loadedProgress.frame = CGRectMake(tmpX+2, 19, pWidth-4, 20);
        }
    }
}

/* 弹幕模块 -Begin */

-(void)setBarrageValue:(NSString *)barrageValue{
    _barrageValue = barrageValue;
    
    [self startBarrage];
}

- (void)startBarrage {
    if(!self.isBarrageClose){
        [self.barrageManager start];
        
        OCBarrageTextDescriptor *textDescriptor = [[OCBarrageTextDescriptor alloc] init];
        textDescriptor.text = self.barrageValue;
        textDescriptor.textColor = [UIColor whiteColor];
        textDescriptor.positionPriority = OCBarragePositionLow;
        textDescriptor.textFont = [UIFont systemFontOfSize:17.0];
        textDescriptor.strokeColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
        textDescriptor.strokeWidth = -1;
        textDescriptor.animationDuration = 5;
        textDescriptor.barrageCellClass = [OCBarrageTextCell class];
        
        [self.barrageManager renderBarrageDescriptor:textDescriptor];
    }
}

- (void)pasueBarrage {
    [self.barrageManager pause];
}

- (void)resumeBarrage {
    [self.barrageManager resume];
}

- (void)stopBarrage {
    [self.barrageManager stop];
}

/* 弹幕模块 - End */

#pragma mark - --播放状态提示信息
- (void)hideAlertViews{
    self.isAlerting = NO;
    
    //移除重播按钮
    if(_btnReplay){
        [_btnReplay removeFromSuperview];
    }
    
    //移除提示视图
    if(_alertView){
        [_alertView removeFromSuperview];
    }
    
    if(_notWifiView){
        [_notWifiView removeFromSuperview];
    }
}

//显示视频加载中...
- (void)showLoading{
    self.isAlerting = YES;
    [self addSubview:self.alertView];
#if 1
    NSMutableArray *loadingImages = [NSMutableArray array];
    for (int i = 1; i<=8; i++) {
        NSString *imageName = [NSString stringWithFormat:@"PPKit_vp_loading_%d",i];
        UIImage *image = [self imagesNamedFromCustomBundle:imageName];
        [loadingImages addObject:image];
    }
    self.alertImageView.animationImages = loadingImages;
    self.alertImageView.animationDuration = 2.0f;
    self.alertImageView.animationRepeatCount = 0;
#else
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"PPKit_vp_loading2" ofType:@"gif"];
    [self.alertImageView loadImageWithUrl:imagePath defaultImage:nil];
#endif
    self.alertLabel.text = @"视频加载中";

    [self.alertImageView startAnimating];
}

- (void)showBufferLoading{
    self.isAlerting = YES;
    [self addSubview:self.alertView];
    NSMutableArray *loadingImages = [NSMutableArray array];
    for (int i = 1; i<=8; i++) {
        [loadingImages addObject:[self imagesNamedFromCustomBundle:[NSString stringWithFormat:@"PPKit_vp_loading_%d",i]]];
    }
    self.alertImageView.animationImages = loadingImages;
    self.alertImageView.animationDuration = 2.0f;
    self.alertImageView.animationRepeatCount = 0;
    self.alertLabel.text = @"视频缓冲中";
    
    [self.alertImageView startAnimating];
}

//网络连接失败
- (void)showNetworkFaild{
    self.isAlerting = YES;
    [self addSubview:self.alertView];
    self.alertImageView.image = [self imagesNamedFromCustomBundle:@"PPKit_vp_netfailed"];
    self.alertLabel.text = @"网络连接失败，请重试！";
}

//网络失速
- (void)showNetworkStalled{
    self.isAlerting = YES;
    [self addSubview:self.alertView];
    self.alertImageView.image = [self imagesNamedFromCustomBundle:@"PPKit_vp_netstalled"];
    self.alertLabel.text = @"网络不太好，请稍候...";
}

//播放失败
- (void)showPlayFaild{
    self.isAlerting = YES;
    [self addSubview:self.alertView];
    self.alertImageView.image = [self imagesNamedFromCustomBundle:@"PPKit_vp_netfailed"];
    self.alertLabel.text = @"播放发生错误导致结束，请重试！";
}

//显示不是Wifi播放的消息提示
- (void)showNotWifiMsg{
    self.isAlerting = YES;
    [self.notWifiView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.notWifiView removeFromSuperview];
    [self addSubview:self.notWifiView];
    [self.notWifiView addSubview:self.labNotWifiMsg];
    [self.notWifiView addSubview:self.btnContinuePlay];
    [self bringSubviewToFront:self.btnBack];
}

//显示直播结束提示和控制
- (void)showLiveNotStartedView{
    self.isAlerting = YES;
    self.isLiveOver = YES;
    [self addSubview:self.liveNotStartedView];
    [self bringSubviewToFront:self.btnBack];
}

- (void)removeLiveNotStartedView{
    self.isAlerting = NO;
    self.isLiveOver = NO;
    [self.liveNotStartedView removeFromSuperview];
    [self bringSubviewToFront:self.btnBack];
}

//显示直播结束提示和控制
- (void)showLiveOverView{
    self.isAlerting = YES;
    self.isLiveOver = YES;
    [self addSubview:self.liveOverView];
    [self bringSubviewToFront:self.btnBack];
}

- (void)removeLiveOverView{
    self.isAlerting = NO;
    self.isLiveOver = NO;
    [self.liveOverView removeFromSuperview];
    [self bringSubviewToFront:self.btnBack];
}

//显示截图
- (void)showScreenshot{

}

#pragma mark - 触摸事件
//1.单点弹出控件视图
- (void)singleTap{
    //NSLog(@"%s",__FUNCTION__);
    if(self.isLive && self.isLiveOver){
        //如果是直播并且已经结束，不允许操作
        return;
    }
    
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
    }else{
        //显示控制视图
        
        [UIView animateWithDuration:0.2 animations:^{
            weakSelf.topView.alpha = 1;
            weakSelf.bottomView.alpha = 1;
        }];
        
        //开启定时器
        [self startControlTimer];
    }
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(PPVideoPlayerView:screenTap:)]){
        [self.delegate PPVideoPlayerView:self screenTap:nil];
    }
}

//2.双点暂停
- (void)doubleTap{
    //NSLog(@"%s",__FUNCTION__);
    if(self.isLive && self.isLiveOver){
        //如果是直播并且已经结束，不允许操作
        return;
    }
    if(self.playStatus == PPVideoPlayerStatusPlaying){
        [self pause];
        
        if(self.delegate && [self.delegate respondsToSelector:@selector(PPVideoPlayerView:screenDoubleTap:)]){
            [self.delegate PPVideoPlayerView:self screenDoubleTap:nil];
        }
    }
}

//3.左边上下滑动调亮度
//4.右边上下滑动调音量
//5.左右滑动调播放进度
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSLog(@"%s",__FUNCTION__);
//    if(self.player){
//        if(self.player.status == AVPlayerStatusUnknown){
//            NSLog(@"播放未知状态");
//        }else if (self.player.status == AVPlayerStatusFailed){
//            NSLog(@"播放失败");
//        }
//    }
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSLog(@"%s",__FUNCTION__);
    UITouch *touch = [touches anyObject];
    
    if([touch view] == self.topView || [touch view] == self.bottomView){
        [self startControlTimer];
    }else{
        if(touch.tapCount == 1){
            [self performSelector:@selector(singleTap) withObject:nil afterDelay:0.3];
        }else if (touch.tapCount == 2){
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(singleTap) object:nil];
            [self performSelector:@selector(doubleTap) withObject:nil afterDelay:0.3];
        }
    }
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSLog(@"%s",__FUNCTION__);
    UITouch *touch=[touches anyObject];
    //NSLog(@"%@",touch);
    
    //取得当前位置
    CGPoint current=[touch locationInView:self];
    //取得前一个位置
    CGPoint previous=[touch previousLocationInView:self];
    
    NSLog(@"移动前：%@",NSStringFromCGPoint(previous));
    NSLog(@"移动后：%@",NSStringFromCGPoint(current));
    
    //判断左右方向
    if(current.x > self.frame.size.width / 2){
       NSLog(@"右移动");
       CGFloat moveOffSet = current.y - previous.y;
        if(moveOffSet > 0){
           // [self.player setVolume:<#(float)#>];
        }else{
            
        }
    }else{
        NSLog(@"左移动");
      }
}

-(void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSLog(@"%s",__FUNCTION__);
}

#pragma mark - 按钮事件
- (void)continuePlayAction{
    [self hideAlertViews];
    [self showLoading];
    self.controlStyle = PPVideoPlayerControlStyleDefault;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self play];
    });
}

//返回点击
- (void)backAction{

    if(self.delegate && [self.delegate respondsToSelector:@selector(PPVideoPlayerView:backAction:)]){
        [self.delegate PPVideoPlayerView:self backAction:nil];
    }
}

//投屏点击
- (void)toTVAction{
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(PPVideoPlayerView:toTVAction:)]){
        [self.delegate PPVideoPlayerView:self toTVAction:nil];
    }
}

//分享点击
- (void)shareAction{

    if(self.delegate && [self.delegate respondsToSelector:@selector(PPVideoPlayerView:shareAction:)]){
        [self.delegate PPVideoPlayerView:self shareAction:nil];
    }
}

//收藏点击
- (void)favoriteAction{
    if(self.delegate && [self.delegate respondsToSelector:@selector(PPVideoPlayerView:favoriteAction:)]){
        [self.delegate PPVideoPlayerView:self favoriteAction:nil];
    }
}

//下载点击
- (void)downloadAction{
    if(self.delegate && [self.delegate respondsToSelector:@selector(PPVideoPlayerView:downloadAction:)]){
        [self.delegate PPVideoPlayerView:self downloadAction:nil];
    }
}

//暂停或播放点击
- (void)playOrPauseAction{
    if(self.playStatus == PPVideoPlayerStatusPlaying){
        [self pause];
    }else{
        [self play];
    }

    if(self.delegate && [self.delegate respondsToSelector:@selector(PPVideoPlayerView:playOrPauseAction:)]){
        [self.delegate PPVideoPlayerView:self playOrPauseAction:nil];
    }
}

//下一个视频点击
- (void)nextVideoAction{
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(PPVideoPlayerView:nextVideoAction:)]){
        [self.delegate PPVideoPlayerView:self nextVideoAction:nil];
    }
}

//清晰度切换点击
- (void)qualityAction{
 
    if(self.delegate && [self.delegate respondsToSelector:@selector(PPVideoPlayerView:qualityAction:)]){
        [self.delegate PPVideoPlayerView:self qualityAction:nil];
    }
}

//视频列表点击
- (void)videoListAction{
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(PPVideoPlayerView:videoListAction:)]){
        [self.delegate PPVideoPlayerView:self videoListAction:nil];
    }
}

//弹幕点击
- (void)barrageAction{
    if(self.isBarrageClose){
        [self startBarrage];
        [_btnBarrage setImage:[self imagesNamedFromCustomBundle:@"PPKit_vp_dan_1"] forState:UIControlStateNormal];
    }else{
        [self stopBarrage];
        [_btnBarrage setImage:[self imagesNamedFromCustomBundle:@"PPKit_vp_dan_0"] forState:UIControlStateNormal];
    }
    self.isBarrageClose = !self.isBarrageClose;
    if(self.delegate && [self.delegate respondsToSelector:@selector(PPVideoPlayerView:barrageAction:)]){
        [self.delegate PPVideoPlayerView:self barrageAction:nil];
    }
}

//全屏点击
- (void)fullScreenAction{

    if(self.delegate && [self.delegate respondsToSelector:@selector(PPVideoPlayerView:fullScreenAction:)]){
        [self.delegate PPVideoPlayerView:self fullScreenAction:nil];
    }
}

//全屏锁定/解锁
- (void)fslockAction{
    self.isFSLocked = !self.isFSLocked;
    
    if(self.isFSLocked){
        //锁定全屏
        [self.btnFSLock setImage:[self imagesNamedFromCustomBundle:@"PPKit_vp_screen_close"] forState:UIControlStateNormal];
    }else{
        //解锁全屏
        [self.btnFSLock setImage:[self imagesNamedFromCustomBundle:@"PPKit_vp_screen_open"] forState:UIControlStateNormal];
    }
}

#pragma mark - Slider事件
- (void)playerSliderTouchDown:(id)sender {
    [self pause];
}

- (void)playerSliderTouchUpInside:(id)sender {
    _isSliding = NO; // 滑动结束
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self play];
    });
}

- (void)playerSliderValueChanged:(id)sender {
    _isSliding = YES;
    
    [self pause];
    
    //设置视频播放时间点
    self.currentTime = self.playProgress.value;
    self.labStartTime.text = [self convertTime:self.playProgress.value];
    
}

#pragma mark - 监听事件

/**
 移除通知监听
 */
- (void)removeNotifyObservers{
    NSLog(@"%s",__FUNCTION__);
    
    //移除所有播放消息通知
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NELivePlayerDidPreparedToPlayNotification object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NELivePlayerLoadStateChangedNotification object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NELivePlayerPlaybackFinishedNotification object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NELivePlayerFirstVideoDisplayedNotification object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NELivePlayerFirstAudioDisplayedNotification object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NELivePlayerVideoParseErrorNotification object:_player];
    if(!self.isLive){
        [[NSNotificationCenter defaultCenter]removeObserver:self name:NELivePlayerMoviePlayerSeekCompletedNotification object:_player];
    }
    //[[NSNotificationCenter defaultCenter]removeObserver:self name:NELivePlayerReleaseSueecssNotification object:_player];
}

- (void)addNotifyObservers{
    NSLog(@"%s",__FUNCTION__);

    //添加播放器监听
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(NELivePlayerDidPreparedToPlay:)
                                                 name:NELivePlayerDidPreparedToPlayNotification
                                               object:_player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(NeLivePlayerloadStateChanged:)
                                                 name:NELivePlayerLoadStateChangedNotification
                                               object:_player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(NELivePlayerPlayBackFinished:)
                                                 name:NELivePlayerPlaybackFinishedNotification
                                               object:_player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(NELivePlayerPlaybackStateChanged:)
                                                 name:NELivePlayerPlaybackStateChangedNotification
                                               object:_player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(NELivePlayerFirstVideoDisplayed:)
                                                 name:NELivePlayerFirstVideoDisplayedNotification
                                               object:_player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(NELivePlayerFirstAudioDisplayed:)
                                                 name:NELivePlayerFirstAudioDisplayedNotification
                                               object:_player];
    
    if(!self.isLive){
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(NELivePlayerMoviePlayerSeekCompleted:)
                                                     name:NELivePlayerMoviePlayerSeekCompletedNotification
                                                   object:_player];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(NELivePlayerReleaseSuccess:)
                                                 name:NELivePlayerReleaseSueecssNotification
                                               object:_player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(NELivePlayerVideoParseError:)
                                                 name:NELivePlayerVideoParseErrorNotification
                                               object:_player];
}

//调用prepareToPlay后，播放器初始化视频文件完成后的消息通知
- (void)NELivePlayerDidPreparedToPlay:(NSNotification*)notification
{
    //add some methods
    NSLog(@"NELivePlayerDidPreparedToPlay");
    
    //获取视频信息，主要是为了告诉界面的可视范围，方便字幕显示
    NELPVideoInfo info;
    memset(&info, 0, sizeof(NELPVideoInfo));
    [_player getVideoInfo:&info];
    
    if(self.isWifiNetwork && self.isAutoPlay){
        [self play]; //开始播放
    }else{
        [self hideAlertViews];
    }
}

//播放器加载状态发生改变时的消息通知
- (void)NeLivePlayerloadStateChanged:(NSNotification*)notification
{
    NELPMovieLoadState nelpLoadState = _player.loadState;

    if (nelpLoadState == NELPMovieLoadStatePlaythroughOK)
    {
        NSLog(@"NELPMovieLoadStatePlaythroughOK");
        //完成缓冲，隐藏提示(播放的时候会处理隐藏)
        //[self hideAlertViews];
    }
    else if (nelpLoadState == NELPMovieLoadStateStalled)
    {
        NSLog(@"NELPMovieLoadStateStalled");
        //显示开始缓冲提示
        [self showBufferLoading];
    }
}

//播放器播放完成或播放发生错误时的消息通知
- (void)NELivePlayerPlayBackFinished:(NSNotification*)notification
{
    switch ([[[notification userInfo] valueForKey:NELivePlayerPlaybackDidFinishReasonUserInfoKey] intValue])
    {
        case NELPMovieFinishReasonPlaybackEnded:
            NSLog(@"NELPMovieFinishReasonPlaybackEnded");
            //正常播放结束
            if (self.isLive) {
                //直播结束,提示信息
                NSLog(@"直播结束");
                [self showLiveOverView];
            }else{
                //点播结束，回到播放0点位置，截取1秒图显示
                NSLog(@"点播结束");
                [self.player setCurrentPlaybackTime:0];
                self.playProgress.value = 0;
                self.labStartTime.text = @"00:00";
                
                //显示截图
                [self showScreenshot];
                
                //显示重播按钮
                [self.btnReplay setImage:[self imagesNamedFromCustomBundle:@"PPKit_vp_replay"] forState:UIControlStateNormal];
                [self addSubview:self.btnReplay];
            }
            
            break;
            
        case NELPMovieFinishReasonPlaybackError:
            //播放发生错误导致结束
            NSLog(@"NELPMovieFinishReasonPlaybackError");
            [self showPlayFaild];
            break;
            
        case NELPMovieFinishReasonUserExited:
            //人为退出(暂未使用，保留值)
            if (self.isLive) {
                //直播结束,提示信息
                NSLog(@"直播结束");
                [self showLiveOverView];
            }
            break;
            
        default:
            break;
    }
    
    //销毁定时器
    if(_timer){
        dispatch_source_cancel(_timer);
    }
    
    //停止弹幕
    [self stopBarrage];
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(PPVideoPlayerView:playStatusChanged:)]){
        [self.delegate PPVideoPlayerView:self playStatusChanged:PPVideoPlayerStatusStop];
    }
}

//播放器播放状态发生改变时的消息通知
- (void)NELivePlayerPlaybackStateChanged:(NSNotification*)notification
{
    [self removeLiveOverView];
    [self removeLiveNotStartedView];
    switch (self.player.playbackState) {
        case NELPMoviePlaybackStatePaused:{
            self.playStatus = PPVideoPlayerStatusPause;
            break;
        }
        case NELPMoviePlaybackStateStopped:{
            self.playStatus = PPVideoPlayerStatusStop;
            break;
        }
        case NELPMoviePlaybackStatePlaying:{
            self.playStatus = PPVideoPlayerStatusPlaying;
            break;
        }
        case NELPMoviePlaybackStateSeeking:{
            self.playStatus = PPVideoPlayerStatusSeeking;
            break;
        }
        default:
            break;
    }
}

//播放器第一帧视频显示时的消息通知
- (void)NELivePlayerFirstVideoDisplayed:(NSNotification*)notification
{
    NSLog(@"first video frame rendered!");
}

//播放器第一帧音频播放时的消息通知
- (void)NELivePlayerFirstAudioDisplayed:(NSNotification*)notification
{
    NSLog(@"first audio frame rendered!");
}

//seek完成时的消息通知，仅适用于点播，直播不支持
- (void)NELivePlayerMoviePlayerSeekCompleted:(NSNotification*)notification
{
    NSLog(@"NELivePlayerMoviePlayerSeekCompleted");
}

//视频码流包解析异常时的消息通知
- (void)NELivePlayerVideoParseError:(NSNotification*)notification
{
    NSLog(@"video parse error!");
    
    //销毁定时器
    if(_timer){
        dispatch_source_cancel(_timer);
    }
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(PPVideoPlayerView:playFailed:)]){
        [self.delegate PPVideoPlayerView:self playFailed:nil];
    }
    
    [self stopBarrage];
}

//播放器资源释放完成时的消息通知
- (void)NELivePlayerReleaseSuccess:(NSNotification*)notification
{
    NSLog(@"resource release success!!!");
    //销毁定时器
    if(_timer){
        dispatch_source_cancel(_timer);
    }
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NELivePlayerReleaseSueecssNotification object:_player];
    
    [self stopBarrage];
}

@end
