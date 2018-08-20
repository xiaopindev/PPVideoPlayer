//
//  Demo1ViewController.h
//  PPVideoPlayer
//
//  Created by cdmac on 17/3/14.
//  Copyright © 2017年 pinguo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <NELivePlayerFramework/NELivePlayerFramework.h>


/**
 网易SDK未封装使用
 */
@interface Demo1ViewController : UIViewController

@property (nonatomic, strong) NELivePlayerController *player; //播放器sdk

@end
