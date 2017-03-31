//
//  PPVideoPlayerView.h
//  PPVideoPlayer
//
//  Created by xiaopin on 16/10/27.
//  Copyright © 2016年 PPKit. All rights reserved.
//
//  My Blog: http://xiaopin.cnblogs.com
//  Git Hub: https://github.com/xiaopn166
//  QQ交流群：168368234
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <NELivePlayer/NELivePlayer.h>
#import <NELivePlayer/NELivePlayerController.h>

typedef enum : NSUInteger {
    PPVideoPlayerStatusUnknown,
    PPVideoPlayerStatusPause,
    PPVideoPlayerStatusPlaying,
    PPVideoPlayerStatusSeeking,
    PPVideoPlayerStatusStop,
} PPVideoPlayerStatus;

typedef enum : NSUInteger {
    PPVideoPlayerControlStyleDefault,
    PPVideoPlayerControlStyleFullScreen,
    PPVideoPlayerControlStyleNotWifi,
} PPVideoPlayerControlStyle;

@protocol PPVideoPlayerViewDelegate;

@interface PPVideoPlayerView : UIView

@property (nonatomic,weak) id<PPVideoPlayerViewDelegate> delegate;

/**
 视频标题，在顶部标题栏显示
 */
@property (nonatomic,strong) NSString *title;

/**
 视频本地或网络播放路径
 */
@property (nonatomic,strong) NSURL *playUrl;

/**
 当前是否是Wifi网络，每次都需要传递进来，用来控制界面显示状态，非Wifi情况下，不自动播放,默认NO
 */
@property (nonatomic,assign) BOOL isWifiNetwork;

/**
 全屏状态,默认NO
 */
@property (nonatomic,assign,getter=isFullScreen) BOOL fullScreen;
/**
 是否是直播，默认NO
 */
@property (nonatomic,assign) BOOL isLive;

/**
 控制控件显示的样式
 PPVideoPlayerControlStyleDefault,默认，包含：返回、标题，播放，正在直播，视频进度
 PPVideoPlayerControlStyleFullScreen,全屏尺寸的时候富控件样式，返回、标题，分享，收藏，下载，播放，下一个视频，正在直播，视频进度，投屏，全屏
 PPVideoPlayerControlStyleNotWifi,没有Wifi的显示样式
 */
@property (nonatomic,assign) PPVideoPlayerControlStyle controlStyle;

/**
 播放状态
 PPVideoPlayerStatusUnknown,未知状态,默认
 PPVideoPlayerStatusPause,暂停状态
 PPVideoPlayerStatusPlaying,播放状态
 PPVideoPlayerStatusStop,停止状态
 */
@property (nonatomic,assign,readonly) PPVideoPlayerStatus playStatus;

//即使配置了controlStyle，不过也可以自定义显示控制栏控件
//显示顶部控制栏
@property (nonatomic,assign) BOOL showTopBar;
//显示返回按钮,默认YES
@property (nonatomic,assign) BOOL showBackButton;
//显示分享按钮
@property (nonatomic,assign) BOOL showShareButton;
//显示收藏按钮
@property (nonatomic,assign) BOOL showFavoritesButton;
//显示下载按钮
@property (nonatomic,assign) BOOL showDownButton;
//显示下一个视频按钮
@property (nonatomic,assign) BOOL showNextButton;
//显示播放质量按钮
@property (nonatomic,assign) BOOL showQualityButton;
//显示播放列表按钮
@property (nonatomic,assign) BOOL showListButton;
//显示投屏按钮
@property (nonatomic,assign) BOOL showToTVButton;
//显示全屏按钮
@property (nonatomic,assign) BOOL showFullScreenButton;

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

@end

@protocol PPVideoPlayerViewDelegate <NSObject>

@optional
/**
 播放时间改变
 
 @param view           <#view description#>
 @param currentSencond <#currentSencond description#>
 */
- (void)PPVideoPlayerView:(PPVideoPlayerView*)view timeChanged:(NSTimeInterval)currentSencond;

/**
 播放状态改变
 
 @param view   <#view description#>
 @param status <#status description#>
 */
- (void)PPVideoPlayerView:(PPVideoPlayerView*)view playStatusChanged:(PPVideoPlayerStatus)status;

/**
 播放失败

 @param view   <#view description#>
 @param sender <#sender description#>
 */
- (void)PPVideoPlayerView:(PPVideoPlayerView*)view playFailed:(id)sender;

/**
 播放屏幕单击
 
 @param view   <#view description#>
 @param sender <#sender description#>
 */
- (void)PPVideoPlayerView:(PPVideoPlayerView*)view screenTap:(id)sender;

/**
 播放屏幕双击
 
 @param view   <#view description#>
 @param sender <#sender description#>
 */
- (void)PPVideoPlayerView:(PPVideoPlayerView*)view screenDoubleTap:(id)sender;

/**
 返回按钮点击
 
 @param view   <#view description#>
 @param sender <#sender description#>
 */
- (void)PPVideoPlayerView:(PPVideoPlayerView*)view backAction:(id)sender;

/**
 投屏按钮点击
 
 @param view   <#view description#>
 @param sender <#sender description#>
 */
- (void)PPVideoPlayerView:(PPVideoPlayerView*)view toTVAction:(id)sender;

/**
 分享按钮点击
 
 @param view   <#view description#>
 @param sender <#sender description#>
 */
- (void)PPVideoPlayerView:(PPVideoPlayerView*)view shareAction:(id)sender;

/**
 收藏按钮点击
 
 @param view   <#view description#>
 @param sender <#sender description#>
 */
- (void)PPVideoPlayerView:(PPVideoPlayerView*)view favoriteAction:(id)sender;

/**
 下载按钮点击
 
 @param view   <#view description#>
 @param sender <#sender description#>
 */
- (void)PPVideoPlayerView:(PPVideoPlayerView*)view downloadAction:(id)sender;

/**
 更多按钮点击

 @param view   <#view description#>
 @param sender <#sender description#>
 */
- (void)PPVideoPlayerView:(PPVideoPlayerView*)view moreAction:(id)sender;

/**
 播放暂停按钮点击
 
 @param view   <#view description#>
 @param sender <#sender description#>
 */
- (void)PPVideoPlayerView:(PPVideoPlayerView*)view playOrPauseAction:(id)sender;

/**
 下一个视频按钮点击
 
 @param view   <#view description#>
 @param sender <#sender description#>
 */
- (void)PPVideoPlayerView:(PPVideoPlayerView*)view nextVideoAction:(id)sender;

/**
 播放质量切换按钮点击
 
 @param view   <#view description#>
 @param sender <#sender description#>
 */
- (void)PPVideoPlayerView:(PPVideoPlayerView*)view qualityAction:(id)sender;

/**
 播放列表按钮点击
 
 @param view   <#view description#>
 @param sender <#sender description#>
 */
- (void)PPVideoPlayerView:(PPVideoPlayerView*)view videoListAction:(id)sender;

/**
 全屏/取消全屏点击

 @param view   <#view description#>
 @param sender <#sender description#>
 */
- (void)PPVideoPlayerView:(PPVideoPlayerView*)view fullScreenAction:(id)sender;

@end
