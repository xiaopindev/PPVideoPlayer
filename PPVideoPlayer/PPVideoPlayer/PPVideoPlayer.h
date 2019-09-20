//
//  PPVideoPlayer.h
//  PPVideoPlayer
//
//  Created by cdmac666 on 2019/9/17.
//  Copyright © 2019 pinguo. All rights reserved.
//
//  My Blog: http://xiaopin.cnblogs.com
//  Git Hub: https://github.com/xiaopn166/PPVideoPlayer
//  QQ交流群：168368234
//  最后修改时间：2018-09-03
//  版本：v2.0
//

/*
 版本说明：
 v3.0
 1.重构UI交互
 2.升级网易播放器SDK至v2.4.2
 v2.0
 1.增加弹幕功能
 2.升级网易播放器SDK至v1.9.1
 v1.0
 1.使用网易组件自定义播放器界面
 2.支持直播、点播模式
 */

#import <UIKit/UIKit.h>
#import "PPVideoPlayerEnum.h"
#import "PPPlayerControlView.h"

NS_ASSUME_NONNULL_BEGIN

@class PPVideoPlayer;

@protocol PPVideoPlayerDelegate <NSObject>

@optional
/**
 返回按钮点击
 
 @param view   <#view description#>
 @param sender <#sender description#>
 */
- (void)PPVideoPlayer:(PPVideoPlayer*)view backAction:(id)sender;
/**
 投屏按钮点击
 
 @param view   <#view description#>
 @param sender <#sender description#>
 */
- (void)PPVideoPlayer:(PPVideoPlayer*)view toTVAction:(id)sender;
/**
 分享按钮点击
 
 @param view   <#view description#>
 @param sender <#sender description#>
 */
- (void)PPVideoPlayer:(PPVideoPlayer*)view shareAction:(id)sender;
/**
 下载按钮点击
 
 @param view   <#view description#>
 @param sender <#sender description#>
 */
- (void)PPVideoPlayer:(PPVideoPlayer*)view downloadAction:(id)sender;
/**
 全屏/取消全屏点击
 
 @param view   <#view description#>
 @param sender <#sender description#>
 */
- (void)PPVideoPlayer:(PPVideoPlayer*)view fullScreenAction:(id)sender;

@end

@interface PPVideoPlayer : UIView

@property (nonatomic,weak) id<PPVideoPlayerDelegate> delegate;

//自定义控制UI
@property (nonatomic,strong) PPPlayerControlView *controlView;
/**
 视频本地或网络播放路径
 */
@property (nonatomic,strong) NSString *videoUrl;
/**
 是否自动播放,默认:YES
 */
@property (nonatomic,assign) BOOL autoPlay;

/**
 视频标题，在顶部标题栏显示
 */
@property (nonatomic,strong) NSString *title;
/**
 当前是否是Wifi网络，每次都需要传递进来，用来控制界面显示状态，非Wifi情况下，不自动播放,默认NO
 */
@property (nonatomic,assign) BOOL isWifiNetwork;
/**
 是否是直播，默认NO
 */
@property (nonatomic,assign) BOOL isLiveVideo;
/**
 全屏状态,默认NO
 */
@property (nonatomic,assign,getter=isFullScreen) BOOL fullScreen;
/**
 是否启用锁屏,默认:NO
 */
@property (nonatomic,assign) BOOL enableLockScreen;

/**
 播放状态
 PPVideoPlayerStatusUnknown,未知状态,默认
 PPVideoPlayerStatusPause,暂停状态
 PPVideoPlayerStatusPlaying,播放状态
 PPVideoPlayerStatusStop,停止状态
 */
@property (nonatomic,assign,readonly) PPVideoPlayerStatus playStatus;

/**
 播放资源装载
 */
- (void)prepareToPlay;
/**
 播放
 */
- (void)play;

/**
 暂停
 */
- (void)pause;

/**
 停止
 */
- (void)stop;
/**
 追加一个弹幕

 @param value <#value description#>
 */
- (void)appendBarrage:(NSString*)value;
@end

NS_ASSUME_NONNULL_END
