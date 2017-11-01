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
            if ([name isEqualToString:@"_currentLength"]) {
                continue;
            }
            id value = [coder decodeObjectForKey:name];
            if (value) {
                [self setValue:value forKey:name];
            }
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
//        self.currentLength = fileSize;
        [self setValue:@(fileSize) forKey:@"currentLength"];
    } else {
        [self setValue:@(0) forKey:@"currentLength"];
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
    
    
    [self.lock lock];
    if (self.outputStream.streamStatus == NSStreamStatusNotOpen) {
        [self.outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [self.outputStream open];
        NSLog(@"打开流");
    }
    NSInteger writeLength = 0;
    NSInteger location = 0;
    int size = 1024;
    
    while (location < data.length) {
        unsigned int len = data.length - location < 1024 ? (int)(data.length - location) : size;
        uint8_t buf[len];
        [data getBytes:buf range:NSMakeRange(location, len)];
        writeLength = [self.outputStream write:buf maxLength:len];
        if (writeLength < 0) {
            NSLog(@"写入出错");
            break;
        } else {
            [self setValue:@(self.currentLength + writeLength) forKey:@"currentLength"];
            location += writeLength;
        }
    }
    
    [self.lock unlock];
    return writeLength;
}

- (void)stopWrite {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self.lock lock];
        [self.outputStream close];
        self.outputStream = nil;
        [self.lock unlock];
    });
}


@end
