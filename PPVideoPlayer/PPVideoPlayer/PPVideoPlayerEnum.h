//
//  PPVideoPlayerEnum.h
//  PPVideoPlayer
//
//  Created by cdmac666 on 2019/9/17.
//  Copyright © 2019 pinguo. All rights reserved.
//

#ifndef PPVideoPlayerEnum_h
#define PPVideoPlayerEnum_h

typedef enum : NSUInteger {
    //默认状态
    PPVideoPlayerStatusUnknown,
    //暂停
    PPVideoPlayerStatusPause,
    //播放中
    PPVideoPlayerStatusPlaying,
    //跳播中
    PPVideoPlayerStatusSeeking,
    //停止
    PPVideoPlayerStatusStop,
} PPVideoPlayerStatus;

typedef enum : NSUInteger {
    //提示：无
    PPVideoPlayerTipStyleNone,
    //提示：加载中
    PPVideoPlayerTipStyleLoading,
    //提示：加载失败
    PPVideoPlayerTipStyleLoadFailed,
    //提示：直播未开始
    PPVideoPlayerTipStyleLiveNotStart,
    //提示：直播结束
    PPVideoPlayerTipStyleLiveEnd,
    //提示：非Wifi网络
    PPVideoPlayerTipStyleNotWifi,
} PPVideoPlayerTipStyle;

#endif /* PPVideoPlayerEnum_h */
