//
//  NTDownloadFileModel.m
//  Note
//
//  Created by lili on 2017/9/29.
//  Copyright © 2017年 HS. All rights reserved.
//

#import "NTDownloadFileModel.h"
#import <objc/runtime.h>

@implementation NTDownloadFileModel
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        unsigned int count;
        Ivar *varList = class_copyIvarList([self class], &count);
        for (int i = 0; i < count; i ++) {
            Ivar var = varList[i];
            NSString *name = [NSString stringWithUTF8String:ivar_getName(var)];
            id value = [coder decodeObjectForKey:name];
            [self setValue:value forKey:name];
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    unsigned int count;
    Ivar *varList = class_copyIvarList([self class], &count);
    for (int i = 0; i < count; i ++) {
        Ivar var = varList[i];
        NSString *key = [NSString stringWithUTF8String:ivar_getName(var)];
        id value = [self valueForKey:key];
        [aCoder encodeObject:value forKey:key];
    }
}

+ (instancetype)instanceWith:(NSURL *)url {
    NSMutableArray *downloadList = [NTDownloadFileModel readList];
    for (NTDownloadFileModel *model in downloadList) {
        if ([model.url isEqualToString:url.absoluteString]) {
            return model;
        }
    }
    NTDownloadFileModel *model = [NTDownloadFileModel new];
    model.url = url.absoluteString;
    model.path = [url pathComponents].lastObject;
    model.type = [url pathExtension];
    [model setupCurrentLength];
    return model;
}

- (void)setupCurrentLength {
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:self.path];
    if (isExist) {
        NSInteger fileSize = [[[[NSFileManager defaultManager] attributesOfItemAtPath:self.path error:nil] objectForKey:NSFileSize] integerValue];
        self.currentLength = fileSize;
    }
}

- (void)save {
    
    if (![NTDownloadFileModel downloadListExit]) {
        NSArray *downloadList = @[self];
        [NSKeyedArchiver archiveRootObject:downloadList toFile:DownloadList];
        return;
    }
    
    NSMutableArray *downloadList = [[NSKeyedUnarchiver unarchiveObjectWithFile:DownloadList] mutableCopy];
    for (int i = 0; i < downloadList.count; i ++) {
        NTDownloadFileModel *model = downloadList[i];
        if ([model.url isEqualToString:self.url]) {
            [downloadList replaceObjectAtIndex:i withObject:self];
            [NSKeyedArchiver archiveRootObject:downloadList toFile:DownloadList];
            return;
        }
    }
    [downloadList addObject:self];
    [NSKeyedArchiver archiveRootObject:downloadList toFile:DownloadList];
}

+ (BOOL)downloadListExit {
    if (![[NSFileManager defaultManager]fileExistsAtPath:DownloadDir isDirectory:nil]) {
        [[NSFileManager defaultManager]createDirectoryAtPath:DownloadDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    if (![[NSFileManager defaultManager]fileExistsAtPath:DownloadList]) {
        return NO;
    }
    return YES;
}

+ (NSMutableArray*)readList {
    if (![self downloadListExit]) {
        return nil;
    }
    
    NSArray *downloadList = [NSKeyedUnarchiver unarchiveObjectWithFile:DownloadList];
    return [downloadList mutableCopy];
}

@end
