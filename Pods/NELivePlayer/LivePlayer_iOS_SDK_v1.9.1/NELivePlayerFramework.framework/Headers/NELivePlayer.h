/*
 * NELivePlayer.h
 * NELivePlayer
 *
 * Create by biwei on 15-9-21
 * Copyright (c) 2015年 Netease. All rights reserved
 *
 * This file is part of LivePlayer.
 *
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "NELivePlayerDef.h"
#import "NELivePlayerNotication.h"

#pragma mark - 对外方法
/**
 *	@brief	播放器核心方法类
 */
@protocol NELivePlayer <NSObject>

/**
 @brief 设置播放的url
 @discussion 1）此接口需要在调用init或initWithNeedConfigAudioSession之后使用.
             2）调用详情请参考initWithNeedConfigAudioSession，设置之后一定要调用prepareToPlay才能收到准备播放信息.
 @param url url 目标地址
 @return 设置的错误信息
 */
- (NSError *)setPlayUrl:(NSURL *)url;

/**
 @brief 设置缓冲策略
 @discussion 1）在播放器初始化后，prepareToPlay之前调用.
             2）缓冲策略有直播低延时模式、直播流畅模式以及点播抗抖动模式.
             3）如果是直播，建议采用低延时模式或流畅模式，如果是点播或本地视频，建议采用抗抖动模式
 @param bufferStrategy 缓冲策略
 */
- (void)setBufferStrategy:(NELPBufferStrategy)bufferStrategy;

/**
 @brief 设置数据源
 @discussion 1）初始化视频文件为播放做准备，在播放前调用。
             2）当prepareToPlay完成时,若shouldAutoplay 为YES，则会自动调用play进行播放，若shouldAutoplay为 NO，则需手动调用play进行播放
 */
- (void)prepareToPlay;

/**
 *	@brief	开始播放
 *
 *  @discussion 如果当前正在播放，则调用该方法将无效果. 此时播放器状态为: NELPMoviePlaybackStatePlaying.
 *
 *	@return	无
 */

/**
 @brief    开始播放
 @discussion 1) 如果当前正在播放，则调用该方法将无效果.
             2) 此时播放器状态为: NELPMoviePlaybackStatePlaying.
 */
- (void)play;

/**
 *	@brief	暂停播放
 *
 *  @discussion 调用play方法继续播放。如果当前播放已经暂停，则调用该方法将无效果. 此时播放器状态为: NELPMoviePlaybackStatePaused
 *
 *  @warning 该接口只针对点播地址有效。
 *
 *	@return	无
 */

/**
 @brief    暂停播放
 @discussion 1) 调用play方法继续播放。如果当前播放已经暂停，则调用该方法将无效果.\n
             2) 此时播放器状态为: NELPMoviePlaybackStatePaused.
 */
- (void)pause;

/**
 @brief 是否正在播放

 @return YES:正在播放，NO:不在播放
 */
- (BOOL)isPlaying;

/**
 *	@brief	停止播放，并释放播放器相关资源
 *
 *  @discussion 在播放器退出时，需要调用该方法用于释放资源。 若在播放过程中需要切换URL，首先需要调用该方法停止播放，然后调用removeFromSuperview 将view移除，并将player置为nil，再初始化，prepareToPlay，最后调用play方法。
 *
 *	@return	无
 */

/**
 @brief    停止播放，并释放播放器相关资源
 @discussion 在播放器退出时，需要调用该方法用于释放资源.
 */
- (void)shutdown;

/**
 @brief    设置播放器切入后台后的播放状态
 @discussion 1) 若设置后台暂停，则在切入后台后播放器处于暂停状态，回到前台需要手动播放.\n
             2) 若设置后台继续播放，则在切入后台后音频继续播放，回到前台后音视频正常播放.\n
 @param pause YES：后台暂停 NO：继续播放
 */
- (void)setPauseInBackground:(BOOL)pause;

/**
 @brief    设置显示模式.

 @param aScalingMode 显示模式.
 */
- (void)setScalingMode: (NELPMovieScalingMode) aScalingMode;

/**
 @brief 设置静音

 @param isMute YES：开启静音 NO：关闭静音
 */
- (void)setMute: (BOOL)isMute;

/**
 @brief 设置硬件解码。

 @param isOpen isOpen  YES：硬件解码 NO：软件解码 默认：NO
 */
- (void)setHardwareDecoder :(BOOL)isOpen;

/**
 设置镜像显示

 @param isMirror 是否镜像显示
 */
- (void)setMirrorDisplay :(BOOL)isMirror;

/**
 设置循环次数

 @param count 循环次数
 */
- (void)setLoopPlayCount:(int)count;

/**
 @brief    截图
 @discussion 调用prepareToPlay方法，播放器发出NELivePlayerDidPreparedToPlayNotification通知后，才能调用该方法。
 @return 截图结果，以UIImage格式保存
 */
- (UIImage *)getSnapshot;

/**
 @brief    获取视频信息
 @discussion 1） 调用prepareToPlay方法，播放器发出NELivePlayerDidPreparedToPlayNotification通知后，调用该方法才能获取到有效的视频信息。\\n
             2)  其中帧率和码率都是从视频头中读取，若头中没有该信息，则返回0.
 @param videoInfo 视频信息
 */
- (void)getVideoInfo :(NELPVideoInfo *)videoInfo;

/**
 @brief    获取音频信息
 @discussion 调用prepareToPlay方法，播放器发出NELivePlayerDidPreparedToPlayNotification通知后，调用该方法才能获取到有效的音频信息。
 @param audioInfo 音频信息
 */
- (void)getAudioInfo :(NELPAudioInfo *)audioInfo;

/**
 * @brief	设置播放速度，仅适用于点播
 *
 * @param	speed 	播放速度(范围 0.5 ~ 2.0)
 *
 * @return	无
 */

/**
 @brief 设置播放速度，仅适用于点播。
 @discussion 取值范围 (0.5 ~ 2.0)，默认1.0
 */
@property (nonatomic) float playbackSpeed;

/**
 @brief 设置播放音量

 @param volume 音量大小(范围 0.0 ~ 1.0，0.0为最小，1.0为最大)
 */
- (void)setVolume:(float)volume;

/**
 @brief 设置拉流超时时间，在prepareToPlay之前调用

 @param timeout 超时时间 (单位: 毫秒 ms 范围:0 ~ 30000ms)
 */
- (void)setPlaybackTimeout:(long)timeout;


/**
 @brief 解密模块初始化，并校验密钥是否正确

 @param transferToken 获取密钥的令牌
 @param accid 视频云用户创建的其子用户id
 @param appKey 开发者平台分配的AppKey
 @param token 视频云用户子用户的token
 @param complete 异步返回密钥检测结果
 @discussion 该接口不可与setDecryptionKey:complete:同时使用
 */
- (void)setDecryptionTransferToken:(NSString *)transferToken
                             accid:(NSString *)accid
                            appKey:(NSString *)appKey
                             token:(NSString *)token
                          complete:(void(^)(NELPKeyCheckResult ret))complete;

/**
 @brief 设置flv加密视频解密所需的密钥,在已知密钥的情况下可以调用该接口进行解密
 @param key 密钥
 @param complete 异步返回密钥检测结果
 @discussion 该接口不可与setDecryptionTransferToken:accid:appKey:token:complete:接口同时使用, 在prepareToPlay前调用
 */
- (void)setDecryptionKey:(NSString *)key
                complete:(void(^)(NELPKeyCheckResult ret))complete;

/**
 @brief 播放过程中切换播放地址

 @param aUrl 待切换的播放地址
 @return >= 0 切换成功， < 0 切换失败
 */
- (int)switchContentUrl:(NSURL *)aUrl;


/**
 @brief 播放过程中切换播放地址

 @param aUrl 待切换的播放地址
 @param file 字幕文件
 @return >= 0 切换成功， < 0 切换失败
 */
- (int)switchContentUrl:(NSURL *)aUrl subtitle:(NSURL *)file;

/**
 @brief 加密视频的切换
 @param aUrl 待切换的播放地址
 @param transferToken 获取密钥的令牌
 @param accid 视频云用户创建的其子用户id
 @param appKey 开发者平台分配的AppKey
 @param token 视频云用户子用户的token
 @param complete 异步返回密钥检测结果
 @discussion 切换成功后直接播放，不需要调用prepareToPlay。
 */
- (void)switchDecryptionUrl:(NSURL *)aUrl
              transferToken:(NSString *)transferToken
                      accid:(NSString *)accid
                     appKey:(NSString *)appKey
                      token:(NSString *)token
                   complete:(void(^)(NELPKeyCheckResult ret))complete;

/**
 @brief 已知密钥的情况下可以调用该接口进行切换
 @param aUrl 待切换的播放地址
 @param key 密钥
 @param complete 异步返回密钥检测结果
 @discussion 切换成功后直接播放，不需要调用prepareToPlay。
 */
- (void)switchDecryptionKeyUrl:(NSURL *)aUrl
                           key:(NSString *)key
                      complete:(void(^)(NELPKeyCheckResult ret))complete;

/**
 @brief 注册获取视频帧数据的回调(只支持软件解码)

 @param neVFormat 回调的视频数据格式
 @param videoRawDataCB 获取视频数据的回调函数
 @return < 0 获取失败
 */
- (int)registerGetVideoRawDataCB:(NELPVideoFormatE)neVFormat and:(NELPVideoRawDataCB)videoRawDataCB;

/**
 @brief 注册获取音频帧数据的回调
 @param audioRawDataCB 获取音频数据的回调函数
 @return < 0 获取失败
 */
- (int)registerGetAudioRawDataCB:(NELPAudioRawDataCB)audioRawDataCB;

/**
 @brief    用于点播切换分辨率
 @param mediaType 清晰度类型
 @param completionBlock 切换结果
 @discussion 只针对于点播，直播调用该接口无效
 */
- (void)switchMultiMedia:(NELPMultiMediaType)mediaType
                complete:(void(^)(NELPSwitchStreamResult ret))completionBlock;

/**
 @brief      用于显示的view (只读)
 @discussion 该view中不包含播放控制组件，只用于显示视频图像
 */
@property(nonatomic, readonly)  UIView *view;

/**
 @brief    获取多媒体文件总时长(单位: 秒) (只读)
 @discussion 1) 调用prepareToPlay方法后，不能立即获得duration值。只有在播放器发送NELivePlayerDidPreparedToPlayNotification通知后，获取的duration值才有效。\\\n
             2) isPreparedToPlay值为YES时，duration值才有效。\\\n
             3) 如果播放的是直播视频，则duration值为0。
 */
@property(nonatomic, readonly)  NSTimeInterval duration;

/**
 @brief    获取当前可播放的视频时长(单位：秒) (只读)
 @discussion 当播放网络视频时，该值表示已经缓冲的视频的最大时长，若此时网络端开，则只能播放到该时刻为止。
 */
@property(nonatomic, readonly)  NSTimeInterval playableDuration;

/**
 @brief 当前视频文件是否完成初始化（只读）
 @discussion 调用prepareToPlay方法后，如果播放器完成视频文件的初始化，会发送NELivePlayerDidPreparedToPlayNotification通知，并将isPreparedToPlay置为YES。
 */
@property(nonatomic, readonly)  BOOL isPreparedToPlay;

/**
 @brief    获取当前播放状态 (只读)
 @discussion 播放状态的变换如下：1) 播放器调用initWithContentURL方法后处于NELPMoviePlaybackStatePaused状态。
             2) 调用prepareToPlay方法，如果完成对视频文件的初始化则进入NELPMoviePlaybackStatePlaying状态。
             3) 当调用setCurrentPlaybackTime方法时转成NELPMoviePlaybackStateSeeking状态。
             4) 调用pause方法转NELPMoviePlaybackStatePaused状态，调用stop方法转到NELPMoviePlaybackStateStopped状态。
 */
@property(nonatomic, readonly)  NELPMoviePlaybackState playbackState;

/**
 @brief    获取当前加载状态 (只读)
 @discussion 加载状态的变换如下：
            1) 调用prepareToPlay方法，当视频文件初始化完成后，播放器会收到NELivePlayerLoadStateChangedNotification通知，此时的加载状态为 NELPMovieLoadStatePlayable。
            2) 当播放器需要缓冲的时候，缓冲开始时，播放会暂停，此时播放器会收到NELivePlayerLoadStateChangedNotification通知，此时的加载状态为 NEPMovieLoadStateStalled。
            3) 当缓冲结束时，播放会继续，此时播放器会收到NELivePlayerLoadStateChangedNotification通知，此时的加载状态为 NELPMovieLoadStatePlaythroughOK
 */
@property(nonatomic, readonly)  NELPMovieLoadState loadState;

/**
 *	@brief	设置播放器初始化视频文件完成后是否自动播放，默认自动播放
 *
 *  @param 	shouldAutoplay 	YES：自动播放 NO：手动播放
 *
 *  @discussion 当设置为YES后，则在调用prepareToPlay初始化视频文件完成后会自动调用play方法进行播放
 *
 *	@return	无
 */

/**
 @brief    设置播放器初始化视频文件完成后是否自动播放，默认自动播放
 @discussion 1) YES：自动播放 NO：手动播放。
             2) 当设置为YES后，则在调用prepareToPlay初始化视频文件完成后会自动调用play方法进行播放。
 */
@property(nonatomic) BOOL shouldAutoplay;

/**
 @brief    设置播放idx多分辨率文件时，遇到卡顿是否自动切换低分辨率
 @discussion 1) YES：自动切换 NO：不自动切换。
             2) 方法仅对idx多分辨率文件有效。
 */
@property(nonatomic, assign) BOOL autoSwitchDefinition;

/**
 @brief    设置当前播放时间点(单位：秒)(用于seek操作)以及获取当前播放的时间点
 @discussion 需要在播放器发送NELivePlayerDidPreparedToPlayNotification通知后，才能调用该set方法设置到某一时间点播放，此时isPreparedToPlay的值为 YES
 */
@property(nonatomic)  NSTimeInterval currentPlaybackTime;

/**
 @brief 真实时间戳(只读)
 */
@property (nonatomic, readonly) NSTimeInterval currentPlaybackRealTime;

/**
 @brief 真实时间戳监听
 @param intervalMS 查询间隔，单位毫秒
 @param callback 查询结果
 */
- (void)setRealTimeListenerWithIntervalMS:(NSTimeInterval)intervalMS
                                 callback:(NELPTimestampCallCB)callback;

/**
 @brief 同步时间戳（只读）
 */
@property (nonatomic, readonly) int64_t currentSyncTimestamp;

/**
 @brief 同步时间戳监听
 @param intervalMS 查询间隔，单位毫秒
 @param callback 查询结果
 */
- (void)setSyncTimestampListenerWithIntervalMS:(NSTimeInterval)intervalMS
                                      callback:(NELPTimestampCallCB)callback;


/**
 @brief 接收同步数据的开关

 @param isOpen YES： 开  NO：关 默认：NO
 */
- (void)setOpenReceiveSyncData:(BOOL)isOpen;

/**
 @brief 设置自定义的透传信息回调

 @param contentCB 回调的信息
 */
- (void)registerSyncContentCB:(NELPSyncContentCB)contentCB;

/**
 @brief 设置外挂字幕文件（仅支持点播，格式SRT）
 @discussion 可以通过传递不同的文件路径完成字幕切换，设置为NULL时清空字幕。
 @param file 文件路径URL.请务必传入 [`NSURL` fileURLWithPath:path]" 生成的对象！
 @return 设置成功返回nil 失败返回具体错误类型
 */
- (NSError *)setLocalSubtitleFile:(NSURL *)file;

/**
 @brief 设置字幕文件显示状态回调（仅支持点播）
 @discussion 字幕回调的信息不处理字幕中的格式信息，需要应用层根据业务需求自行处理。
 @param block 回调
 */
- (void)registSubtitleStatBlock:(NELivePlayerSubtitleBlock)block;

@end

#pragma mark - 相关模型
/**
 * 分辨率通知信息携带的模型
 */
@interface NELivePlayerMulitDefinitionModel : NSObject
/**
 * 支持的分辨率 @(NELPMultiMediaType)
 */
@property (nonatomic, strong) NSArray <NSNumber *> *resolutions;
/**
 * 正在播放的分辨率
 */
@property (nonatomic, assign) NELPMultiMediaType isUsed;
@end

/**
 * HTTP通知信息携带的模型
 */
@interface NELivePlayerHttpCodeModel : NSObject
/**
 * http 请求返回状态码
 */
@property (nonatomic, assign) int code;
/**
 * http 请求返回Header
 */
@property (nonatomic, copy) NSString *header;
@end

/**
 * 自定义透传信息模型
 */
@interface NELivePlayerSyncContent : NSObject
/**
 * 透传的信息
 */
@property (nonatomic, strong) NSArray <NSString *>*contents;
@end
