//
//  ViewController.m
//  Note
//
//  Created by 王恺靖 on 2017/9/20.
//  Copyright © 2017年 HS. All rights reserved.
//

#import "NTDownloadController.h"
#import "NTDownloadFileModel.h"
#import "NTDownloadStatusCell.h"

@interface NTDownloadController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSMutableArray<NTDownloadManager*> *downloadMngs;
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation NTDownloadController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSLog(@"%@",[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:@"download"]);
    //    NSString *url = @"http://sw.bos.baidu.com/sw-search-sp/software/654897a806dc0/FileZilla_3.17.0.1_macosx-x86.zip";
    //    NTDownloadTask *task = [HttpDownloadTool download:url];
    //    task.downloadProgress = ^(float progress) {
    ////        NSLog(@"%f",progress);
    //    };
    [self.view addSubview:self.tableView];
    //    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc]initWithTitle:@"" style:<#(UIBarButtonItemStyle)#> target:<#(nullable id)#> action:<#(nullable SEL)#>]];
}

- (UITableView*)tableView {
    if (_tableView) {
        return _tableView;
    }
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0,SCREEN_WIDTH, SCREEN_HEIGHT) style:UITableViewStyleGrouped];
    [_tableView registerNib:[UINib nibWithNibName:@"NTDownloadStatusCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    return _tableView;
}

- (NSMutableArray<NTDownloadManager*>*)downloadMngs {
    if (_downloadMngs) {
        return _downloadMngs;
    }
    _downloadMngs = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray *downloadList = [NTDownloadFileModel readList];
    for (NTDownloadFileModel *model in downloadList) {
        NTDownloadManager *task = [[NTDownloadManager alloc]initWithModel:model];
        [_downloadMngs addObject:task];
    }
    return _downloadMngs;
}


-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NTDownloadStatusCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.mng = self.downloadMngs[indexPath.row];
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.downloadMngs.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.5;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 1;
}



@end

