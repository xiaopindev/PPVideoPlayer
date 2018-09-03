//
//  Created by zlcode on 2017/4/19.
//  Copyright © 2017年 zlcode. All rights reserved.
//

#import "BrightnessVolumeView.h"
#import <AVFoundation/AVFoundation.h>

CGFloat const gestureMinimumTranslation = 20.0 ;

typedef enum : NSInteger {
    
    kCameraMoveDirectionNone,
    
    kCameraMoveDirectionUp,
    
    kCameraMoveDirectionDown,
    
    kCameraMoveDirectionRight,
    
    kCameraMoveDirectionLeft
    
} CameraMoveDirection ;

@interface BrightnessVolumeView()
{
    CameraMoveDirection direction;
}

@property (nonatomic,strong) MPVolumeView *volumeView;

@end

@implementation BrightnessVolumeView

#pragma mark - xib初始化入口
- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self addPanGesture];
        [BrightnessView sharedBrightnessView];
    }
    return self;
}

#pragma mark - 代码初始化入口
- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self addPanGesture];
        [BrightnessView sharedBrightnessView];
    }
    return self;
}

#pragma mark - 添加拖动手势
- (void)addPanGesture{
    // 拖动手势
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self addGestureRecognizer:panRecognizer];
}

#pragma mark -  处理音量和亮度
- (void)handlePan:(UIPanGestureRecognizer*)gesture
{
#if 1
    CGPoint location = [gesture locationInView:self];
    CGPoint point = [gesture translationInView:gesture.view];
    // 音量
    if (location.x > ZLScreenWidth * 0.5) {
        
        //移除亮度UI
        [[BrightnessView sharedBrightnessView] disAppearBrightnessView];
        
        if (gesture.state == UIGestureRecognizerStateBegan) {
            self.lastVolume = [self bfGetCurrentVolume];
        }
        
        float volumeDelta = point.y / (gesture.view.bounds.size.height) * 0.5;
        float newVolume = self.lastVolume - volumeDelta;
        
        [self bfSetVolume:newVolume];
        
    } else {// 亮度
        
        //移除音量UI
        
        if (gesture.state == UIGestureRecognizerStateBegan) {
            self.lastBrightness = [UIScreen mainScreen].brightness;
        }
        
        float volumeDelta = point.y / (gesture.view.bounds.size.height) * 0.5;
        float newVolume = self.lastBrightness - volumeDelta;
        
        [[UIScreen mainScreen] setBrightness:newVolume];
    }
#else
    //方向确定
    CGPoint translation = [gesture translationInView: self];
    if (gesture.state == UIGestureRecognizerStateBegan ){
        NSLog (@ "kCameraMoveDirectionNone" );
        direction = kCameraMoveDirectionNone;
    } else if (gesture.state == UIGestureRecognizerStateChanged && direction == kCameraMoveDirectionNone) {
        direction = [self determineCameraDirectionIfNeeded:translation];
        // ok, now initiate movement in the direction indicated by the user's gesture
        switch (direction) {
            case kCameraMoveDirectionDown:
                NSLog (@ "Start moving down" );
                break ;
            case kCameraMoveDirectionUp:
                NSLog (@ "Start moving up" );
                break ;
            case kCameraMoveDirectionRight:
                NSLog (@ "Start moving right" );
                break ;
            case kCameraMoveDirectionLeft:
                NSLog (@ "Start moving left" );
                break ;
            default :
                NSLog (@ "Start moving None" );
                break ;
        }
    } else if (gesture.state == UIGestureRecognizerStateEnded ) {
        // now tell the camera to stop
        NSLog (@ "Stop" );
    }
    
    CGPoint location = [gesture locationInView:self];
    CGPoint point = [gesture translationInView:gesture.view];
    
    if(direction == kCameraMoveDirectionDown || direction == kCameraMoveDirectionUp){
        // 音量
        if (location.x > ZLScreenWidth * 0.5) {

            //移除亮度UI
            [[BrightnessView sharedBrightnessView] disAppearBrightnessView];

            if (gesture.state == UIGestureRecognizerStateBegan) {
                self.lastVolume = [self bfGetCurrentVolume];
            }

            float volumeDelta = point.y / (gesture.view.bounds.size.height) * 0.5;
            float newVolume = self.lastVolume - volumeDelta;

            [self bfSetVolume:newVolume];

        } else {// 亮度

            //移除音量UI

            if (gesture.state == UIGestureRecognizerStateBegan) {
                self.lastBrightness = [UIScreen mainScreen].brightness;
            }

            float volumeDelta = point.y / (gesture.view.bounds.size.height) * 0.5;
            float newVolume = self.lastBrightness - volumeDelta;

            [[UIScreen mainScreen] setBrightness:newVolume];
        }
    }else if(direction == kCameraMoveDirectionLeft || direction == kCameraMoveDirectionRight){
        NSLog(@"左右移动");
    }
#endif
}

// This method will determine whether the direction of the user's swipe

- ( CameraMoveDirection )determineCameraDirectionIfNeeded:( CGPoint)translation{
    if (direction != kCameraMoveDirectionNone)
        return direction;
    // determine if horizontal swipe only if you meet some minimum velocity
    if (fabs(translation.x) > gestureMinimumTranslation){
        BOOL gestureHorizontal = NO;
        if (translation.y == 0.0 )
            gestureHorizontal = YES;
        else
            gestureHorizontal = (fabs(translation.x / translation.y) > 5.0 );
        if (gestureHorizontal){
            if (translation.x > 0.0 )
                return kCameraMoveDirectionRight;
            else
                return kCameraMoveDirectionLeft;
        }
    }
    
    // determine if vertical swipe only if you meet some minimum velocity
    else if (fabs(translation.y) > gestureMinimumTranslation){
        BOOL gestureVertical = NO;
        if (translation.x == 0.0 )
            gestureVertical = YES;
        else
            gestureVertical = (fabs(translation.y / translation.x) > 5.0 );
        if (gestureVertical){
            if (translation.y > 0.0 )
                return kCameraMoveDirectionDown;
            else
                return kCameraMoveDirectionUp;
        }
    }
    return direction;
}

- (float)bfGetCurrentVolume {
    // 通过控制系统声音 控制音量
    if (_volumeViewSlider) {
        return _volumeViewSlider.value;
    }
    MPVolumeView *volumeView = [[MPVolumeView alloc] init];
    for (UIView *view in [volumeView subviews]){
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
            _volumeViewSlider = (UISlider*)view;
            break;
        }
    }
    
    // 解决初始状态下获取不到系统音量
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    CGFloat systemVolume = audioSession.outputVolume;
    
    return systemVolume;
}

#pragma mark - 控制音量
- (void)bfSetVolume:(float)newVolume {
    // 通过控制系统声音 控制音量
    newVolume = newVolume > 1 ? 1 : newVolume;
    newVolume = newVolume < 0 ? 0 : newVolume;
    
    [self.volumeViewSlider setValue:newVolume animated:NO];
}

@end
