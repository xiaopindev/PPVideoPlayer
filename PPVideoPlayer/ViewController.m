//
//  ViewController.m
//  PPVideoPlayer
//
//  Created by cdmac on 17/3/14.
//  Copyright © 2017年 pinguo. All rights reserved.
//

#import "ViewController.h"
#import "Demo1ViewController.h"
#import "Demo2ViewController.h"

#import <NELivePlayerFramework/NELivePlayerFramework.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSLog(@"当前网易播放器版本：%@",[NELivePlayerController getSDKVersion]);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)demo1Action:(id)sender {
    Demo1ViewController *demo = [[Demo1ViewController alloc] init];
    [self.navigationController pushViewController:demo animated:YES];
}
- (IBAction)demo2Action:(id)sender {
    Demo2ViewController *demo = [[Demo2ViewController alloc] init];
    [self.navigationController pushViewController:demo animated:YES];
}

@end
