//
//  Demo3ViewController.m
//  PPVideoPlayer
//
//  Created by cdmac666 on 2019/9/17.
//  Copyright © 2019 pinguo. All rights reserved.
//

#import "Demo3ViewController.h"
#import <AliyunPlayer/AliyunPlayer.h>

#define videoURL1 @"http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4"
#define videoURL2 @"http://vjs.zencdn.net/v/oceans.mp4"
#define videoURL3 @"https://media.w3.org/2010/05/sintel/trailer.mp4"

@interface Demo3ViewController ()<AVPDelegate>

@property (nonatomic,strong) AliPlayer *player;

@property (nonatomic,strong) UIView *playView;

@end

@implementation Demo3ViewController

#pragma mark - 懒加载对象

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
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
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
    self.title  = @"阿里播放器";
    
}

/**
 *  初始化页面初始数据
 */
-(void)initData{
    
}

/**
 *  初始化界面元素
 */
-(void)initSubViews{
    self.view.backgroundColor = [UIColor whiteColor];
    
    //集成文档： https://help.aliyun.com/document_detail/124716.html?spm=a2c4g.11186623.6.1060.57283903vIzpFS
    
    //创建一个视频播放区域
    self.playView = [[UIView alloc] initWithFrame:CGRectMake(0, 100, 300, 300/1.7777)];
    self.playView.backgroundColor = UIColor.blackColor;
    [self.view addSubview:self.playView];
    
    //创建播放器对象
    self.player = [[AliPlayer alloc] init];
    self.player.delegate = self;
    self.player.autoPlay = YES;
    //指定视频播放区域
    self.player.playerView = self.playView;

    //创建播放数据源
    /* 播放器支持4种播放源：AVPVidStsSource，AVPVidAuthSource，AVPVidMpsSource，AVPUrlSource。其中AVPUrlSource是直接的url播放，其余的三种是通过vid进行播放：AVPVidStsSource推荐点播用户使用；AVPVidAuthSource不建议使用；AVPVidMpsSource仅限MPS用户使用。
     
     //创建VidSts
     AVPVidStsSource *source = [[AVPVidStsSource alloc] init];
     source.region = self.接入区域;
     source.vid = self.视频vid;
     source.securityToken = self.安全token;
     source.accessKeySecret = self.临时akSecret;
     source.accessKeyId = self.临时akId;

     */
    
    AVPUrlSource *source = [[AVPUrlSource alloc] urlWithString:videoURL1];
    [self.player setUrlSource:source];
    [self.player prepare];
    
    
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

#pragma mark - 事件通知

#pragma mark - 委托代理
/**
 @brief 错误代理回调
 @param player 播放器player指针
 @param errorModel 播放器错误描述，参考AliVcPlayerErrorModel
 */
- (void)onError:(AliPlayer*)player errorModel:(AVPErrorModel *)errorModel {
    //提示错误，及stop播放
}
/**
 @brief 播放器事件回调
 @param player 播放器player指针
 @param eventType 播放器事件类型，@see AVPEventType
 */
-(void)onPlayerEvent:(AliPlayer*)player eventType:(AVPEventType)eventType {
    switch (eventType) {
        case AVPEventPrepareDone: {
            // 准备完成
        }
            break;
        case AVPEventAutoPlayStart:
            // 自动播放开始事件
            break;
        case AVPEventFirstRenderedStart:
            // 首帧显示
            break;
        case AVPEventCompletion:
            // 播放完成
            break;
        case AVPEventLoadingStart:
            // 缓冲开始
            break;
        case AVPEventLoadingEnd:
            // 缓冲完成
            break;
        case AVPEventSeekEnd:
            // 跳转完成
            break;
        case AVPEventLoopingStart:
            // 循环播放开始
            break;
        default:
            break;
    }
}
/**
 @brief 视频当前播放位置回调
 @param player 播放器player指针
 @param position 视频当前播放位置
 */
- (void)onCurrentPositionUpdate:(AliPlayer*)player position:(int64_t)position {
    // 更新进度条
}
/**
 @brief 视频缓存位置回调
 @param player 播放器player指针
 @param position 视频当前缓存位置
 */
- (void)onBufferedPositionUpdate:(AliPlayer*)player position:(int64_t)position {
    // 更新缓冲进度
}
/**
 @brief 获取track信息回调
 @param player 播放器player指针
 @param info track流信息数组 参考AVPTrackInfo
 */
- (void)onTrackReady:(AliPlayer*)player info:(NSArray<AVPTrackInfo*>*)info {
    // 获取多码率信息
}
/**
 @brief 字幕显示回调
 @param player 播放器player指针
 @param index 字幕显示的索引号
 @param subtitle 字幕显示的字符串
 */
- (void)onSubtitleShow:(AliPlayer*)player index:(int)index subtitle:(NSString *)subtitle {
    // 获取字幕进行显示
}
/**
 @brief 字幕隐藏回调
 @param player 播放器player指针
 @param index 字幕显示的索引号
 */
- (void)onSubtitleHide:(AliPlayer*)player index:(int)index {
    // 隐藏字幕
}
/**
 @brief 获取截图回调
 @param player 播放器player指针
 @param image 图像
 */
- (void)onCaptureScreen:(AliPlayer *)player image:(UIImage *)image {
    // 预览，保存截图
}
/**
 @brief track切换完成回调
 @param player 播放器player指针
 @param info 切换后的信息 参考AVPTrackInfo
 */
- (void)onTrackChanged:(AliPlayer*)player info:(AVPTrackInfo*)info {
    // 切换码率结果通知
}


@end
