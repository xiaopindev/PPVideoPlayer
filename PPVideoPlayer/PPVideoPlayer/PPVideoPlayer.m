//
//  PPVideoPlayer.m
//  PPVideoPlayer
//
//  Created by cdmac666 on 2019/9/17.
//  Copyright © 2019 pinguo. All rights reserved.
//

#import "PPVideoPlayer.h"
#import "PPPlayerControlView.h"

#import <AVFoundation/AVFoundation.h>
#import <NELivePlayerFramework/NELivePlayerFramework.h>
#import "OCBarrage.h"

@interface PPVideoPlayer()
{
    CGFloat pX,pY,pWidth,pHeight;
}

#pragma mark - 播放器控制视图

#pragma mark - 播放器对象属性
//播放器核心（必须）
@property (nonatomic, strong) NELivePlayerController *player; //播放器sdk

#pragma mark - 播放器交互控制属性
@property (nonatomic, strong) dispatch_source_t timer;

//播放器属性（只针对点播）
//当前播放时间点
@property (nonatomic,assign) NSTimeInterval currentTime;

///**
// 是否启用亮度和音量控制
// */
//@property (nonatomic,assign) BOOL enableBrightnessVolume;
////是否启用弹幕
//@property (nonatomic,assign) BOOL enableBarrage;
////播放进度是否正在滑动
//@property (nonatomic,assign) BOOL isSliding;
////直播是否结束
//@property (nonatomic,assign) BOOL isLiveEnded;

@end

@implementation PPVideoPlayer

-(PPPlayerControlView *)controlView{
    if(!_controlView){
        _controlView = [[PPPlayerControlView alloc] initWithFrame:self.bounds];
    }
    return _controlView;
}

#pragma mark - 播放器对象
- (NELivePlayerController *)player{
    if(!_player){
        [NELivePlayerController setLogLevel:NELP_LOG_VERBOSE];
        
        NSError *error = nil;
        NSURL *url = [NSURL URLWithString:[self.videoUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
        _player = [[NELivePlayerController alloc] initWithContentURL:url error:&error];
        if (_player == nil) {
            NSLog(@"player initilize failed, please tay again.error = [%@]!", error);
        }
        _player.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _player.view.frame = self.bounds;
        [self addSubview:_player.view];
        [self sendSubviewToBack:_player.view];
        
        self.autoresizesSubviews = YES;
        
        if (self.isLiveVideo) {
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

- (void)addNotifyObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(NELivePlayerDidPreparedToPlay:)
                                                 name:NELivePlayerDidPreparedToPlayNotification
                                               object:_player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(NELivePlayerPlaybackStateChanged:)
                                                 name:NELivePlayerPlaybackStateChangedNotification
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
                                             selector:@selector(NELivePlayerFirstVideoDisplayed:)
                                                 name:NELivePlayerFirstVideoDisplayedNotification
                                               object:_player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(NELivePlayerFirstAudioDisplayed:)
                                                 name:NELivePlayerFirstAudioDisplayedNotification
                                               object:_player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(NELivePlayerReleaseSuccess:)
                                                 name:NELivePlayerReleaseSueecssNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(NELivePlayerSeekComplete:)
                                                 name:NELivePlayerMoviePlayerSeekCompletedNotification
                                               object:_player];
}

- (void)removeNotifyObservers{
    //移除所有播放消息通知
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NELivePlayerDidPreparedToPlayNotification object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NELivePlayerLoadStateChangedNotification object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NELivePlayerPlaybackFinishedNotification object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NELivePlayerFirstVideoDisplayedNotification object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NELivePlayerFirstAudioDisplayedNotification object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NELivePlayerMoviePlayerSeekCompletedNotification object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NELivePlayerReleaseSueecssNotification object:_player];
}

- (void)destroyPlayer {
    if (self.player){
        [self.player shutdown]; // 退出播放并释放相关资源
        [self.player.view removeFromSuperview];
        self.player = nil;
    }
}

#pragma mark - 播放器通知事件
- (void)NELivePlayerDidPreparedToPlay:(NSNotification*)notification {
    //add some methods
    NSLog(@"[NELivePlayer Demo] 收到 NELivePlayerDidPreparedToPlayNotification 通知");
    
    //获取视频信息，主要是为了告诉界面的可视范围，方便字幕显示
    NELPVideoInfo info;
    memset(&info, 0, sizeof(NELPVideoInfo));
    [_player getVideoInfo:&info];
    if(!self.isWifiNetwork){
        //没有Wifi，提示信息
        self.controlView.tipStyle = PPVideoPlayerTipStyleNotWifi;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if(self.autoPlay){
                [self play]; //开始播放
            }
        });
    }else{
        if(self.autoPlay){
            [self play]; //开始播放
        }
    }
}

- (void)NELivePlayerPlaybackStateChanged:(NSNotification*)notification {
    NSLog(@"[NELivePlayer Demo] 收到 NELivePlayerPlaybackStateChangedNotification 通知");
    self.controlView.tipStyle = PPVideoPlayerTipStyleNone;
    switch (self.player.playbackState) {
        case NELPMoviePlaybackStatePaused:{
            NSLog(@"NELPMoviePlaybackStatePaused");
            self.playStatus = PPVideoPlayerStatusPause;
            break;
        }
        case NELPMoviePlaybackStateStopped:{
            NSLog(@"NELPMoviePlaybackStateStopped");
            self.playStatus = PPVideoPlayerStatusStop;
            break;
        }
        case NELPMoviePlaybackStatePlaying:{
            NSLog(@"NELPMoviePlaybackStatePlaying");
            self.playStatus = PPVideoPlayerStatusPlaying;
            break;
        }
        case NELPMoviePlaybackStateSeeking:{
            NSLog(@"NELPMoviePlaybackStateSeeking");
            self.playStatus = PPVideoPlayerStatusSeeking;
            break;
        }
        default:
            break;
    }
}

- (void)NeLivePlayerloadStateChanged:(NSNotification*)notification {
    NSLog(@"[NELivePlayer Demo] 收到 NELivePlayerLoadStateChangedNotification 通知");
    
    NELPMovieLoadState nelpLoadState = _player.loadState;
    
    if (nelpLoadState == NELPMovieLoadStatePlaythroughOK)
    {
        //视频缓存完成
        NSLog(@"finish buffering");
        self.controlView.tipStyle = PPVideoPlayerTipStyleNone;
    }
    else if (nelpLoadState == NELPMovieLoadStateStalled)
    {
        //视频开始缓存
        NSLog(@"begin buffering");
        self.controlView.tipStyle = PPVideoPlayerTipStyleLoading;
    }
}

- (void)NELivePlayerPlayBackFinished:(NSNotification*)notification {
    NSLog(@"[NELivePlayer Demo] 收到 NELivePlayerPlaybackFinishedNotification 通知");
    
    switch ([[[notification userInfo] valueForKey:NELivePlayerPlaybackDidFinishReasonUserInfoKey] intValue])
    {
        case NELPMovieFinishReasonPlaybackEnded:
            if (self.isLiveVideo) {
                //直播结束提示，并保持连接状态
                self.controlView.tipStyle = PPVideoPlayerTipStyleLiveEnd;
            }else{
                //普通视频播放结束,回到播放0点位置，截取1秒图显示
                self.controlView.tipStyle = PPVideoPlayerTipStyleNone;
                
                [self.player setCurrentPlaybackTime:0];
                //self.controlView.playProgress.value = 0;
                //self.controlView.labStartTime.text = @"00:00";
                [self pause];
            }
            break;
            
        case NELPMovieFinishReasonPlaybackError:
        {
            //播放失败，销毁播放器，并返回或提示
            self.controlView.tipStyle = PPVideoPlayerTipStyleLoadFailed;
            break;
        }
            
        case NELPMovieFinishReasonUserExited:
            break;
            
        default:
            break;
    }
}

- (void)NELivePlayerFirstVideoDisplayed:(NSNotification*)notification {
    NSLog(@"[NELivePlayer Demo] 收到 NELivePlayerFirstVideoDisplayedNotification 通知");
}

- (void)NELivePlayerFirstAudioDisplayed:(NSNotification*)notification {
    NSLog(@"[NELivePlayer Demo] 收到 NELivePlayerFirstAudioDisplayedNotification 通知");
}

- (void)NELivePlayerSeekComplete:(NSNotification*)notification {
    NSLog(@"[NELivePlayer Demo] 收到 NELivePlayerMoviePlayerSeekCompletedNotification 通知");
    
}

- (void)NELivePlayerReleaseSuccess:(NSNotification*)notification {
    NSLog(@"[NELivePlayer Demo] 收到 NELivePlayerReleaseSueecssNotification 通知");
    //销毁定时器
    if(_timer){
        dispatch_source_cancel(_timer);
    }
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NELivePlayerReleaseSueecssNotification object:_player];
    
    //[self stopBarrage];
}
#pragma mark - 播放器核心操作

//装载播放
-(void)prepareToPlay{
    
    if(self.isLiveVideo){
        [self.player setBufferStrategy:NELPFluent]; //直播流畅模式
    }else{
        [self.player setBufferStrategy:NELPAntiJitter];//点播模式
    }
    
    [self.player prepareToPlay]; //初始化视频文件
    
    self.playStatus = PPVideoPlayerStatusUnknown;
    
    //显示控制控件
    //[self.controlView startControlTimer];
    
    //添加通知监听
    [self addNotifyObservers];
}

//播放
- (void)play{
    if(self.player && self.videoUrl){
        //30秒后检测是否播放状态
        //[self performSelector:@selector(checkPlayerStatus) withObject:nil afterDelay:30];
        
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
            if(!_isLiveVideo){
                // 获取当前播放进度
                NSTimeInterval currentSecond = weakSelf.player.currentPlaybackTime;
                
                // 获取当前缓存进度
                NSTimeInterval currentCache = weakSelf.player.playableDuration;
                
                // 获取视频总长度
                NSTimeInterval totalSecond = weakSelf.player.duration;
                
                //NSLog(@"当前播放进度：%f/%f/%f",currentSecond,currentCache,totalSecond);
                
                //改变播放时间和进度的状态
                dispatch_async(dispatch_get_main_queue(), ^{
//                    [weakSelf.controlView.loadedProgress setProgress:currentCache/totalSecond animated:YES];
                    
                    // 更新slider, 如果正在滑动则不更新
//                    if (_isSliding == NO) {
//                        weakSelf.controlView.playProgress.value = currentSecond;
//                        weakSelf.controlView.labStartTime.text = [weakSelf convertTime:currentSecond];
//
//                        weakSelf.controlView.playProgress.maximumValue = totalSecond;
//                        weakSelf.controlView.labEndTime.text = [weakSelf convertTime:totalSecond];
//                    }
                });
            }
        });
        // 启动计时器
        dispatch_resume(_timer);
    }
}

//暂停
- (void)pause{
    if(self.player && self.videoUrl){
        //播放器暂停
        [self.player pause];
        
        //销毁定时器
        if(_timer){
            dispatch_source_cancel(_timer);
        }
        
        //设置当前播放状态
        _playStatus = PPVideoPlayerStatusPause;
    }
}

//停止
- (void)stop{
    //退出播放并释放相关资源
    [self.player shutdown]; // 退出播放并释放相关资源
    [self.player.view removeFromSuperview];
    self.player = nil;
    
    //销毁定时器
    if(_timer){
        dispatch_source_cancel(_timer);
    }
    [self.controlView clearControlTimer];
    
    //移除所有监听
    [self removeNotifyObservers];
    
    //停止弹幕
    //[self stopBarrage];
}

#pragma mark - 重载方法
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]){
        //初始化默认属性
        self.backgroundColor = [UIColor blackColor];
    
        _playStatus = PPVideoPlayerStatusUnknown;
        
        [self addSubview:self.controlView];
    }
    return self;
}

#pragma mark - 自定义方法
-(void)setFullScreen:(BOOL)fullScreen{
    _fullScreen = fullScreen;
    
    self.controlView.frame = self.bounds;
    [self.controlView refreshLayout];
}

-(void)setIsLiveVideo:(BOOL)isLiveVideo{
    _isLiveVideo = isLiveVideo;
    
    self.controlView.isLiveVideo = isLiveVideo;
}

- (void)setPlayStatus:(PPVideoPlayerStatus)playStatus{
    _playStatus = playStatus;
    
    self.controlView.playStatus = playStatus;

    if (playStatus == PPVideoPlayerStatusPlaying){
        self.controlView.tipStyle = PPVideoPlayerTipStyleNone;
        //隐藏（播放/暂停）按钮,暂停操作状态
        //[self.btnPlayPause setImage:[self imagesNamedFromCustomBundle:@"PPKit_vp_pause_big"] forState:UIControlStateNormal];
        //[self.btnPlayPause removeFromSuperview];
    }else{
        //显示（播放/暂停）按钮,播放操作状态
        //[self.controlView.btnPlayPause setImage:[self imagesNamedFromCustomBundle:@"PPKit_vp_play_big"] forState:UIControlStateNormal];
        //[self addSubview:self.btnPlayPause];
    }
}

- (void)setCurrentTime:(NSTimeInterval)currentTime{
    if(self.player && self.videoUrl){
        //播放器跳转到指定时间点
        //NSLog(@"Seek Time:%f",currentTime);
        [self.player setCurrentPlaybackTime:currentTime];
    }
}

-(void)appendBarrage:(NSString *)value{
    
}

#pragma mark - 操作事件

//MARK: 委托代理

//MARK: >>>PPPlayerControlViewDelegate
//返回操作
- (void)PPPlayerControlView:(PPPlayerControlView*)view shareAction:(id)sender{
    NSLog(@"%s",__FUNCTION__);
    if ([self.delegate respondsToSelector:@selector(PPVideoPlayer:shareAction:)]){
        [self.delegate PPVideoPlayer:self shareAction:self];
    }
}
//播放操作
- (void)PPPlayerControlView:(PPPlayerControlView*)view playAction:(id)sender{
    NSLog(@"%s",__FUNCTION__);
    [self play];
}
//暂停操作
- (void)PPPlayerControlView:(PPPlayerControlView*)view pauseAction:(id)sender{
    NSLog(@"%s",__FUNCTION__);
    [self pause];
}
//播放上一个视频
- (void)PPPlayerControlView:(PPPlayerControlView*)view previousAction:(id)sender{
    NSLog(@"%s",__FUNCTION__);
}
//播放下一个视频
- (void)PPPlayerControlView:(PPPlayerControlView*)view nextAction:(id)sender{
    NSLog(@"%s",__FUNCTION__);
}
//声音开启关闭操作
- (void)PPPlayerControlView:(PPPlayerControlView*)view soundAction:(id)sender{
    NSLog(@"%s",__FUNCTION__);
}
//指定时间点播放操作
- (void)PPPlayerControlView:(PPPlayerControlView*)view seekAction:(NSTimeInterval)seekTime{
    NSLog(@"%s",__FUNCTION__);
}
//清晰度切换操作
- (void)PPPlayerControlView:(PPPlayerControlView*)view qualityAction:(id)sender{
    NSLog(@"%s",__FUNCTION__);
}
//弹幕开关操作
- (void)PPPlayerControlView:(PPPlayerControlView*)view barrageAction:(id)sender{
    NSLog(@"%s",__FUNCTION__);
}
//全屏切换操作
- (void)PPPlayerControlView:(PPPlayerControlView*)view fullscreenAction:(id)sender{
    NSLog(@"%s",__FUNCTION__);
    if ([self.delegate respondsToSelector:@selector(PPVideoPlayer:fullScreenAction:)]){
        [self.delegate PPVideoPlayer:self fullScreenAction:self];
    }
}
//收藏操作
- (void)PPPlayerControlView:(PPPlayerControlView*)view favoritesAction:(id)sender{
    NSLog(@"%s",__FUNCTION__);
}
//下载操作
- (void)PPPlayerControlView:(PPPlayerControlView*)view downloadAction:(id)sender{
    NSLog(@"%s",__FUNCTION__);
    if ([self.delegate respondsToSelector:@selector(PPVideoPlayer:downloadAction:)]){
        [self.delegate PPVideoPlayer:self downloadAction:self];
    }
}
//投屏操作
- (void)PPPlayerControlView:(PPPlayerControlView*)view toTVAction:(id)sender{
    NSLog(@"%s",__FUNCTION__);
    if ([self.delegate respondsToSelector:@selector(PPVideoPlayer:toTVAction:)]){
        [self.delegate PPVideoPlayer:self toTVAction:self];
    }
}
//速率切换操作
- (void)PPPlayerControlView:(PPPlayerControlView*)view speedAction:(float)value{
    NSLog(@"%s",__FUNCTION__);
}
@end
