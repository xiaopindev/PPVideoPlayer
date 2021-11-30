# OC自定义UI播放器，基于网易播放器SDK,支持直播、点播视频播放，支持弹幕功能和常见需求功能，简单易用。
# 当前版本v2.0

现在源代码以后先：pod install 

使用方法：

1、手动添加

            a.下载PPVideoPlayer SDK, 把PPVideoPlayer目录copy到你项目工程中的指定目录下
   
            b.在你的Podfile文件中增加：pod 'NELivePlayer', '~> 2.8.0' ， SDK所需要的第三方播放器
  
2.Cocoapods添加(由于加上第三方库，验证出错，无法提交到Cocoapods，请使用手动方式)

             pod 'PPVideoPlayer', '~> 2.0'
  
3.引入头文件

          #import "PPVideoPlayerView.h"
          
4.声明属性和协议

        @interface Demo2ViewController ()<PPVideoPlayerViewDelegate>

        @property (nonatomic,strong) PPVideoPlayerView *videoPlayer;

        @end

5.添加属性懒加载

      - (PPVideoPlayerView *)videoPlayer{
              if(!_videoPlayer){
                _videoPlayer = [[PPVideoPlayerView alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, self.view.frame.size.width/1.776)];
                _videoPlayer.delegate = self;
                _videoPlayer.showTopBar = YES;
                _videoPlayer.showShareButton = YES;
                _videoPlayer.showFavoritesButton = YES;
                _videoPlayer.showDownButton = YES;
                _videoPlayer.showNextButton = YES;
                _videoPlayer.showQualityButton = YES;
                _videoPlayer.showListButton = YES;
                _videoPlayer.showToTVButton = YES;
                _videoPlayer.showFullScreenButton = YES;
                _videoPlayer.showBarrageButton = YES;
                _videoPlayer.controlStyle = PPVideoPlayerControlStyleDefault;
            }

            return _videoPlayer;
        }
        
 6.设置属性和播放
    
        NSURL *movieUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"cdvideo" ofType:@"mp4"]];
        self.videoPlayer.title = @"video title2";//显示标题
        self.videoPlayer.playUrl = movieUrl;//播放地址
        self.videoPlayer.isLive = NO;//是否是直播
        self.videoPlayer.isWifiNetwork = YES;//是否shiwifi
        self.videoPlayer.isAutoPlay = NO;//是否自动播放
        [self.videoPlayer prepareToPlay];//预播放
        //[self.videoPlayer play];
        
7.协议

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
           弹幕按钮点击

           @param view   <#view description#>
           @param sender <#sender description#>
           */
          - (void)PPVideoPlayerView:(PPVideoPlayerView*)view barrageAction:(id)sender;

          /**
           全屏/取消全屏点击

           @param view   <#view description#>
           @param sender <#sender description#>
           */
          - (void)PPVideoPlayerView:(PPVideoPlayerView*)view fullScreenAction:(id)sender;
        @end
        
 8.弹幕功能和屏幕旋转自视频屏幕实现方案等， 请下载SDK，详情见Demo示例。


    
