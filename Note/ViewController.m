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
    NSLog(@"%@",[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:@"download"]);
    NSString *url = @"http://sw.bos.baidu.com/sw-search-sp/software/654897a806dc0/FileZilla_3.17.0.1_macosx-x86.zip";
    NTDownloadTask *task = [HttpDownloadTool download:url];
    task.downloadProgress = ^(float progress) {
//        NSLog(@"%f",progress);
    };
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
