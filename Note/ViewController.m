//
//  ViewController.m
//  Note
//
//  Created by 王恺靖 on 2017/9/20.
//  Copyright © 2017年 HS. All rights reserved.
//

#import "ViewController.h"
#import "HttpDownloadTool.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSString *url = @"http://cdn2.ime.sogou.com/a21a4c9d702afb52e6722da3b2566045/595cd0a0/dl/index/1499146667/sogou_mac_42b.dmg";
    NTDownloadTask *task = [HttpDownloadTool download:url];
    task.downloadProgress = ^(float progress) {
        NSLog(@"%f",progress);
    };
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
