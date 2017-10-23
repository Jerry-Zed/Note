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

- (void)setMng:(NTDownloadManager *)mng {
    WEAKSELF;
    _mng = mng;
    self.nameLabel.text = mng.fileModel.path;
    if (mng.fileModel.totalLength) {
        [tself setupProgress:mng.fileModel.currentLength * 1.0 / mng.fileModel.totalLength];
    }
    self.mng.downloadProgress = ^(float progress) {
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
    if (self.mng.status == 0) {
        [sender setTitle:@"暂停" forState:UIControlStateNormal];
        [self.mng start];
        return;
    }
    [sender setTitle:@"开始" forState:UIControlStateNormal];
    [self.mng cancel];
}

@end
