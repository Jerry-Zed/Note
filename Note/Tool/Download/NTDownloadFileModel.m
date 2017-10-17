//
//  NTDownloadFileModel.m
//  Note
//
//  Created by lili on 2017/9/29.
//  Copyright © 2017年 HS. All rights reserved.
//

#import "NTDownloadFileModel.h"
#import <objc/runtime.h>

#define Path [DownloadDir stringByAppendingPathComponent:self.path]

@interface NTDownloadFileModel ()
@property (nonatomic, strong) NSOutputStream *outputStream;
@property (nonatomic, strong) NSLock *lock;
@end

@implementation NTDownloadFileModel

- (void)dealloc {
    [_outputStream close];
    _outputStream = nil;
}

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
        self.lock = [[NSLock alloc]init];
        [self setupCurrentLength];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    unsigned int count;
    Ivar *varList = class_copyIvarList([self class], &count);
    for (int i = 0; i < count; i ++) {
        Ivar var = varList[i];
        NSString *key = [NSString stringWithUTF8String:ivar_getName(var)];
        if ([key isEqualToString:@"_lock"] || [key isEqualToString:@"_outputStream"]) {
            continue;
        }
        id value = [self valueForKey:key];
        [aCoder encodeObject:value forKey:key];
    }
}

+ (instancetype)instanceWith:(NSURL *)url {
    NSMutableArray *downloadList = [NTDownloadFileModel readList];
    for (NTDownloadFileModel *model in downloadList) {
        if ([model.url isEqualToString:url.absoluteString]) {
            [model setupCurrentLength];
            return model;
        }
    }
    NTDownloadFileModel *model = [NTDownloadFileModel new];
    model.url = url.absoluteString;
    model.path = [url pathComponents].lastObject;
    model.type = [url pathExtension];
    model.lock = [[NSLock alloc]init];
    [model setupCurrentLength];
    [model createDownloadDir];
    return model;
}

#pragma mark -- getter

- (NSOutputStream*)outputStream {
    if (_outputStream) {
        return _outputStream;
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:Path]) {
        [[NSFileManager defaultManager] createFileAtPath:Path contents:nil attributes:@{NSFileType:self.type}];
    }
    _outputStream = [NSOutputStream outputStreamToFileAtPath:Path append:YES];
//    _outputStream.delegate = self;
    return _outputStream;
}

#pragma mark -- private methods

- (void)createDownloadDir {
    if (![[NSFileManager defaultManager]fileExistsAtPath:DownloadDir isDirectory:nil]) {
        [[NSFileManager defaultManager]createDirectoryAtPath:DownloadDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

- (void)setupCurrentLength {
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:Path];
    if (isExist) {
        NSInteger fileSize = [[[[NSFileManager defaultManager] attributesOfItemAtPath:Path error:nil] objectForKey:NSFileSize] integerValue];
        self.currentLength = fileSize;
    } else {
        self.currentLength = 0;
    }
}

#pragma mark --- public methods

- (void)save {
    if (![[NSFileManager defaultManager]fileExistsAtPath:DownloadList]) {
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

- (void)del {
    BOOL success = [[NSFileManager defaultManager]removeItemAtPath:Path error:nil];
    if ([[NSFileManager defaultManager]fileExistsAtPath:DownloadList]) {
        NSMutableArray *downloadList = [[NSKeyedUnarchiver unarchiveObjectWithFile:DownloadList] mutableCopy];
        NTDownloadFileModel *target = nil;
        for (NTDownloadFileModel *model in downloadList) {
            if ([model.url isEqualToString:self.url]) {
                target = model;
            }
        }
        if (target) {
            [downloadList removeObject:target];
        }
    }
}

//+ (BOOL)downloadListExit {
//    if (![[NSFileManager defaultManager]fileExistsAtPath:DownloadDir isDirectory:nil]) {
//        [[NSFileManager defaultManager]createDirectoryAtPath:DownloadDir withIntermediateDirectories:YES attributes:nil error:nil];
//    }
//    if (![[NSFileManager defaultManager]fileExistsAtPath:DownloadList]) {
//        return NO;
//    }
//    return YES;
//}

+ (NSMutableArray*)readList {
    if (![[NSFileManager defaultManager] fileExistsAtPath:DownloadList]) {
        return nil;
    }
    NSArray *downloadList = [NSKeyedUnarchiver unarchiveObjectWithFile:DownloadList];
    return [downloadList mutableCopy];
}

- (NSInteger)writeData:(NSData*)data {
    
    if (self.outputStream.streamStatus == NSStreamStatusNotOpen) {
        [self.outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [self.outputStream open];
        //        [[NSRunLoop currentRunLoop] run];
    }
    [self.lock lock];
//    NSLog(@"呵呵哒");
    
    NSInteger writeLength = [self.outputStream write:data.bytes maxLength:data.length];
    [self.lock unlock];
    return writeLength;
}

- (void)stopWrite {
    [self.outputStream close];
    self.outputStream = nil;
}


@end
