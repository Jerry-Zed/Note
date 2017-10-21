//
//  NTDownloadStatusCell.m
//  Note
//
//  Created by lili on 2017/10/16.
//  Copyright © 2017年 HS. All rights reserved.
//

#import "NTDownloadStatusCell.h"
@interface NTDownloadStatusCell ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIButton *actionButton;


@end

@implementation NTDownloadStatusCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.progressView.progress = 0;
}

- (void)setTask:(NTDownloadTask *)task {
    _task = task;
    WEAKSELF;
    self.nameLabel.text = task.model.path;
    if (task.model.totalLength) {
        [tself setupProgress:task.model.currentLength * 1.0 / task.model.totalLength];
    }
    self.task.downloadProgress = ^(float progress) {
        [tself setupProgress:progress];
    };
}

- (void)setupProgress:(float)progress {
    self.progressView.progress = progress;
    if (progress >= 1.0) {
        [self.actionButton setTitle:@"完成" forState:UIControlStateNormal];
        self.actionButton.enabled = NO;
    }
}

- (IBAction)click:(UIButton*)sender {
    if (self.task.status == 0) {
        [sender setTitle:@"暂停" forState:UIControlStateNormal];
        [self.task start];
        return;
    }
    [sender setTitle:@"开始" forState:UIControlStateNormal];
    [self.task cancel];
}

@end
