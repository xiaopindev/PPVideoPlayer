/*
 * NELivePlayerController.h
 * NELivePlayer
 *
 * Create by biwei on 15-9-21
 * Copyright (c) 2015年 Netease. All rights reserved
 *
 * This file is part of LivePlayer.
 *
 */

#import "NELivePlayer.h"

/************************************初始化方法使用*******************************************************************************
*  initWithContentURL:error: 方法 = （new/init/initWithNeedConfigAudioSession:）方法 + setPlayUrl: 方法                           
*
*  初始化->准备播放的调用流程如下:
*
*  1）使用initWithContentURL:error:初始化                         2）使用new/init/initWithNeedConfigAudioSession:初始化
*             |                                                                  |
*        set 参数 A -> set 参数 B ... -> set 参数 N                           setPlayUrl: (首先设置)
*                                    |                                           |
*                             prepareToPlay方法                              set 参数 A -> set 参数 B ... -> set 参数 N
*                                                                                                             |
*                                                                                                       prepareToPlay方法
*
*******************************************************************************************************************************/

/**
 *	@brief	播放器核心功能类
 */
@interface NELivePlayerController : NSObject <NELivePlayer>

/**
 @brief    初始化播放器

 @param isNeed 是否需要内部配置audiosession
 @return 返回播放器实例
 */
- (instancetype)initWithNeedConfigAudioSession:(BOOL)isNeed;

/**
 @brief    初始化播放器，输入播放文件路径

 @param aUrl 播放文件的路径
 @param error 初始化错误原因
 @return 返回播放器实例
 */
- (id)initWithContentURL:(NSURL *)aUrl
                   error:(NSError **)error;

/**
 @brief    初始化播放器，输入播放文件路径

 @param aUrl 播放文件的路径
 @param isNeed 是否需要内部配置audio session
 @param error 初始化错误原因
 @return 返回播放器实例
 */
- (id)initWithContentURL:(NSURL *)aUrl
  needConfigAudioSession:(BOOL)isNeed
                   error:(NSError **)error;

/**
 @brief 设置预调度结果有效期

 @param validity 有效期(单位秒)。默认：30*60 最小取值：60
 */
+ (void)setPreloadResultValidityS:(NSInteger)validity;

/**
 @brief 增加预调度任务

 @param urls 预调度的url
 */
+ (void)addPreloadUrls:(NSArray <NSString *>*)urls;

/**
 @brief 移除预调度任务

 @param urls 预调度的url
 */
+ (void)removePreloadUrls:(NSArray <NSString *>*)urls;

/**
 @brief 查询预调度任务

 @param complete 查询完成。结果提取key:NELivePlayerPreloadUrlKey(url) 和 NELivePlayerPreloadStateKey(状态)
 */
+ (void)queryPreloadTasks:(void (^)(NSArray <NSDictionary *> *tasks))complete;

/**
 @brief    设置日志级别
 
 @param logLevel 日志级别
 */
+ (void)setLogLevel:(NELPLogLevel)logLevel;

/**
 @brief    设置日志信息回调
 
 @param logCallBack 日志回调
 */
+ (void)setLogCallback:(NELivePlayerLogCallback)logCallBack;

/**
 @brief 获取当前日志的路径
 @discussion 需要对日志操作，请在当前实例析构前使用日志以确保日志存在，不可删除该路径下的日志。
 @return 日志的路径
 */
+ (NSString *)getLogPath;

/**
 @brief 获取当前SDK版本号
 
 @return SDK版本号
 */
+ (NSString *)getSDKVersion;

/**
 是否支持h.265解码
 */
+ (BOOL)isSupportHEVCDecode;

@end
