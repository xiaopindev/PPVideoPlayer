//
//  PPPlayerControlView.h
//  PPVideoPlayer
//
//  Created by cdmac666 on 2019/9/19.
//  Copyright © 2019 pinguo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPVideoPlayerEnum.h"

NS_ASSUME_NONNULL_BEGIN

@class PPPlayerControlView;

@protocol PPPlayerControlViewDelegate <NSObject>

@optional
- (void)PPPlayerControlView:(PPPlayerControlView*)view shareAction:(id)sender;
- (void)PPPlayerControlView:(PPPlayerControlView*)view playpauseAction:(id)sender;
- (void)PPPlayerControlView:(PPPlayerControlView*)view previousAction:(id)sender;
- (void)PPPlayerControlView:(PPPlayerControlView*)view nextAction:(id)sender;
- (void)PPPlayerControlView:(PPPlayerControlView*)view soundAction:(id)sender;
- (void)PPPlayerControlView:(PPPlayerControlView*)view seekAction:(NSTimeInterval)seekTime;
- (void)PPPlayerControlView:(PPPlayerControlView*)view qualityAction:(id)sender;
- (void)PPPlayerControlView:(PPPlayerControlView*)view barrageAction:(id)sender;
- (void)PPPlayerControlView:(PPPlayerControlView*)view fullscreenAction:(id)sender;
- (void)PPPlayerControlView:(PPPlayerControlView*)view lockscreenAction:(id)sender;
- (void)PPPlayerControlView:(PPPlayerControlView*)view favoritesAction:(id)sender;
- (void)PPPlayerControlView:(PPPlayerControlView*)view downloadAction:(id)sender;
- (void)PPPlayerControlView:(PPPlayerControlView*)view toTVAction:(id)sender;
- (void)PPPlayerControlView:(PPPlayerControlView*)view speedAction:(float)value;
@end

@interface PPPlayerControlView : UIView

@property (nonatomic,weak) id<PPPlayerControlViewDelegate> delegate;

//显示顶部控制栏
@property (nonatomic,assign) BOOL showTopView;
//显示返回按钮,默认YES
@property (nonatomic,assign) BOOL showBackButton;
//显示分享按钮
@property (nonatomic,assign) BOOL showShareButton;
//显示收藏按钮
@property (nonatomic,assign) BOOL showFavoritesButton;
//显示下载按钮
@property (nonatomic,assign) BOOL showDownButton;
//显示播放质量按钮
@property (nonatomic,assign) BOOL showQualityButton;
//显示投屏按钮
@property (nonatomic,assign) BOOL showToTVButton;
//显示弹幕按钮
@property (nonatomic,assign) BOOL showBarrageButton;
//显示全屏按钮
@property (nonatomic,assign) BOOL showFullScreenButton;

/**
 是否是直播，默认NO
 */
@property (nonatomic,assign) BOOL isLiveVideo;
/**
 全屏状态,默认NO
 */
@property (nonatomic,assign,getter=isFullScreen) BOOL fullScreen;
/**
 提示样式
 */
@property (nonatomic,assign) PPVideoPlayerTipStyle tipStyle;
@property (nonatomic,assign) PPVideoPlayerStatus playStatus;

/**
 刷新布局，每次横竖屏切换需要调用
 */
- (void)refreshLayout;

//开启控制视图消失定时器
- (void)startControlTimer;

//清楚销毁定时器资源
- (void)clearControlTimer;

@end

NS_ASSUME_NONNULL_END
