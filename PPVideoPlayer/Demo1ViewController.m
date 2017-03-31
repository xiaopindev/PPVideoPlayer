//
//  Demo1ViewController.m
//  PPVideoPlayer
//
//  Created by cdmac on 17/3/14.
//  Copyright © 2017年 pinguo. All rights reserved.
//

#import "Demo1ViewController.h"

@interface Demo1ViewController ()

@property (nonatomic, strong) UIView *playerView;

@property (nonatomic,strong) NSString *liveUrlHTTP;
@property (nonatomic,strong) NSString *liveUrlHSL;
@property (nonatomic,strong) NSString *liveUrlRMTP;

@end

@implementation Demo1ViewController

-(id<NELivePlayer>)liveplayer{
    if(!_liveplayer){
        self.playerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 375, 250)];
        _liveplayer = [[NELivePlayerController alloc] initWithContentURL:[NSURL URLWithString:self.liveUrlHSL]];
        if (_liveplayer == nil) { // 返回空则表示初始化失败
            NSLog(@"player initilize failed, please tay again!");
        }
        _liveplayer.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _liveplayer.view.frame = self.playerView.bounds;
        [_liveplayer setScalingMode:NELPMovieScalingModeFill];
    }
    return _liveplayer;
}

-(NSString *)liveUrlHTTP{
    if(!_liveUrlHTTP){
        _liveUrlHTTP = @"http://flv5aa29f72.live.126.net/live/ecdaf25d8bfd4030b93310ef6b23b76e.flv?netease=flv5aa29f72.live.126.net";
    }
    return _liveUrlHTTP;
}

-(NSString *)liveUrlHSL{
    if(!_liveUrlHSL){
        //_liveUrlHSL = @"http://pullhls5aa29f72.live.126.net/live/ecdaf25d8bfd4030b93310ef6b23b76e/playlist.m3u8";
        _liveUrlHSL = [[NSBundle mainBundle] pathForResource:@"cdvideo" ofType:@"mp4"];
    }
    return _liveUrlHSL;
}

-(NSString *)liveUrlRMTP{
    if(!_liveUrlRMTP){
        _liveUrlRMTP = @"rtmp://v5aa29f72.live.126.net/live/ecdaf25d8bfd4030b93310ef6b23b76e";
    }
    return _liveUrlRMTP;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"viewWillAppear");
    NSLog(@"Version = %@", [self.liveplayer getSDKVersion]);
    [self.liveplayer isLogToFile:YES];
    
    [self.liveplayer setBufferStrategy:NELPFluent]; //直播流畅模式
    [self.liveplayer setScalingMode:NELPMovieScalingModeAspectFill]; //设置画面显示模式，默认原始大小
    [self.liveplayer setShouldAutoplay:YES]; //设置prepareToPlay完成后是否自动播放
    //[self.liveplayer setHardwareDecoder:isHardware]; //设置解码模式，是否开启硬件解码
    [self.liveplayer setPauseInBackground:NO]; //设置切入后台时的状态，暂停还是继续播放
    [self.liveplayer prepareToPlay]; //初始化视频文件
    
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    NSLog(@"viewDidDisappear");
    
    [self.liveplayer shutdown]; //退出播放并释放相关资源
    [self.liveplayer.view removeFromSuperview];
    self.liveplayer = nil;
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NELivePlayerDidPreparedToPlayNotification object:_liveplayer];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NELivePlayerLoadStateChangedNotification object:_liveplayer];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NELivePlayerPlaybackFinishedNotification object:_liveplayer];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NELivePlayerFirstVideoDisplayedNotification object:_liveplayer];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NELivePlayerFirstAudioDisplayedNotification object:_liveplayer];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NELivePlayerVideoParseErrorNotification object:_liveplayer];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSLog(@"viewDidLoad");
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(NELivePlayerDidPreparedToPlay:)
                                                 name:NELivePlayerDidPreparedToPlayNotification
                                               object:_liveplayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(NeLivePlayerloadStateChanged:)
                                                 name:NELivePlayerLoadStateChangedNotification
                                               object:_liveplayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(NELivePlayerPlayBackFinished:)
                                                 name:NELivePlayerPlaybackFinishedNotification
                                               object:_liveplayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(NELivePlayerFirstVideoDisplayed:)
                                                 name:NELivePlayerFirstVideoDisplayedNotification
                                               object:_liveplayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(NELivePlayerFirstAudioDisplayed:)
                                                 name:NELivePlayerFirstAudioDisplayedNotification
                                               object:_liveplayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(NELivePlayerReleaseSuccess:)
                                                 name:NELivePlayerReleaseSueecssNotification
                                               object:_liveplayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(NELivePlayerVideoParseError:)
                                                 name:NELivePlayerVideoParseErrorNotification
                                               object:_liveplayer];
    
    self.view.autoresizesSubviews = YES;
    [self.view addSubview:self.liveplayer.view];
}

- (void)NELivePlayerDidPreparedToPlay:(NSNotification*)notification
{
    //add some methods
    NSLog(@"NELivePlayerDidPreparedToPlay");
    //[self syncUIStatus:NO];
    [self.liveplayer play]; //开始播放
}

- (void)NeLivePlayerloadStateChanged:(NSNotification*)notification
{
//    NELPMovieLoadState nelpLoadState = _liveplayer.loadState;
//    
//    if (nelpLoadState == NELPMovieLoadStatePlaythroughOK)
//    {
//        NSLog(@"finish buffering");
//        self.bufferingIndicate.hidden = YES;
//        self.bufferingReminder.hidden = YES;
//        [self.bufferingIndicate stopAnimating];
//    }
//    else if (nelpLoadState == NELPMovieLoadStateStalled)
//    {
//        NSLog(@"begin buffering");
//        self.bufferingIndicate.hidden = NO;
//        self.bufferingReminder.hidden = NO;
//        [self.bufferingIndicate startAnimating];
//    }
}

- (void)NELivePlayerPlayBackFinished:(NSNotification*)notification
{
    UIAlertController *alertController = NULL;
    UIAlertAction *action = NULL;
    switch ([[[notification userInfo] valueForKey:NELivePlayerPlaybackDidFinishReasonUserInfoKey] intValue])
    {
        case NELPMovieFinishReasonPlaybackEnded:{
            alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"直播结束" preferredStyle:UIAlertControllerStyleAlert];
            action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                if (self.presentingViewController) {
                    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
                }}];
            [alertController addAction:action];
            [self presentViewController:alertController animated:YES completion:nil];
            break;
        }
        case NELPMovieFinishReasonPlaybackError:{
            alertController = [UIAlertController alertControllerWithTitle:@"注意" message:@"播放失败" preferredStyle:UIAlertControllerStyleAlert];
            action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){}];
            [alertController addAction:action];
            [self presentViewController:alertController animated:YES completion:nil];
            break;
        }
        case NELPMovieFinishReasonUserExited:
            break;
            
        default:
            break;
    }
}

- (void)NELivePlayerFirstVideoDisplayed:(NSNotification*)notification
{
    NSLog(@"first video frame rendered!");
}

- (void)NELivePlayerFirstAudioDisplayed:(NSNotification*)notification
{
    NSLog(@"first audio frame rendered!");
}

- (void)NELivePlayerVideoParseError:(NSNotification*)notification
{
    NSLog(@"video parse error!");
}

- (void)NELivePlayerReleaseSuccess:(NSNotification*)notification
{
    NSLog(@"resource release success!!!");
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NELivePlayerReleaseSueecssNotification object:_liveplayer];
}


@end
