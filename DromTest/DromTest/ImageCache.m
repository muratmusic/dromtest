//
//  ImageCache.m
//  DromTest
//
//  Created by Murat Dzhusupov on 01.11.16.
//  Copyright © 2016 Murat Dzhusupov. All rights reserved.
//

#import "ImageCache.h"
#import <CommonCrypto/CommonDigest.h>

@interface ImageCache()
@property (nonatomic, strong) NSCache *memCache;
@property (nonatomic, strong) NSString *diskCachePath;
@end

@implementation ImageCache

+ (ImageCache *)sharedInstance
{
    // structure used to test whether the block has completed or not
    static dispatch_once_t p = 0;
     
    // initialize sharedObject as nil (first call only)
    __strong static ImageCache *_sharedObject = nil;
     
    // executes a block object once and only once for the lifetime of an application
    dispatch_once(&p, ^{
        _sharedObject = [[self alloc] init];
    });
     
    // returns the same object each time
    return _sharedObject;
}

- (id)init
{
    if (self = [super init])
    {
        self.memCache = [[NSCache alloc] init];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        if ([paths count] > 0)
        {
            NSString *commonCachePath = paths[0];
            self.diskCachePath = [commonCachePath stringByAppendingPathComponent:@"DromTest"];
        }
    }
    
    return self;
}

- (void)storeImage:(UIImage *)image withKey:(NSString *)key completion:(void(^)())completion onError:(void (^)(NSError *))errorBlock
{
    if (nil != image)
    {
        [self.memCache setObject:image forKey:key];
        
        __weak typeof(self) wSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            NSString *filePath = [self.diskCachePath stringByAppendingPathComponent:[wSelf cachedFileNameForKey:key]];
            NSData *data = UIImagePNGRepresentation(image);
            NSFileManager *fileManager = [NSFileManager defaultManager];
            [fileManager createDirectoryAtPath:wSelf.diskCachePath withIntermediateDirectories:YES attributes:nil error:NULL];
            [fileManager createFileAtPath:filePath contents:data attributes:nil];
            
            //TODO: добавить проверку на error != NULL и в случае ошибки вызывать errorBlock(error)
        
            if (nil != wSelf)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (nil != wSelf) {
                        completion();
                    }
                });
            }
        });
    } // if (nil != image)
    else
    {
        errorBlock(nil); //TODO: сформировать NSError объект
    }
}

- (void)loadImageWithKey:(NSString *)key completion:(void(^)(UIImage *))completion
{
    UIImage *image = [self.memCache objectForKey:key];
    if (nil != image && [image isMemberOfClass:[UIImage class]])
    {
        completion(image);
    }
    else // если нет в memory cache то пробуем из кэш-файлов
    {
        __weak typeof(self) wSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            NSString *filePath = [self.diskCachePath stringByAppendingPathComponent:[wSelf cachedFileNameForKey:key]];
            UIImage *image = [UIImage imageWithContentsOfFile:filePath];
            CGFloat scale = [UIScreen mainScreen].scale;
            if (1.f == scale)
            {
                // даже если nil == image
                dispatch_async(dispatch_get_main_queue(), ^{ completion(image); });
            }
            else
            {
                CGImageRef cgImage = image.CGImage;
                image = [UIImage imageWithCGImage:cgImage scale:scale orientation:image.imageOrientation];
                
                // даже если nil == image
                dispatch_async(dispatch_get_main_queue(), ^{ completion(image); });
            }
        });
    }
}

- (void)clearMemory
{
    [self.memCache removeAllObjects];
}

- (void)clearDiskWithCompletion:(void(^)())completion
{
    __weak typeof(self) wSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [[NSFileManager defaultManager] removeItemAtPath:wSelf.diskCachePath error:NULL];
        [[NSFileManager defaultManager] createDirectoryAtPath:wSelf.diskCachePath withIntermediateDirectories:YES attributes:nil error:NULL];
    
        dispatch_async(dispatch_get_main_queue(), ^{ completion(); });
    });
}

- (NSString *)cachedFileNameForKey:(NSString *)key
{
    const char *str = [key UTF8String];
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
        r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];

    return filename;
}

@end
