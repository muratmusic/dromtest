//
//  ImageData.m
//  DromTest
//
//  Created by Murat Dzhusupov on 02.11.16.
//  Copyright © 2016 Murat Dzhusupov. All rights reserved.
//

#import "ImageData.h"
#import "ImageCache.h"
#import "Config.h"

@interface ImageData()
@property (nonatomic, assign) ImageState currentState;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *imageUrl;
@end

@implementation ImageData

- (id)init
{
    return nil; // don't use default initializer
}

- (id)initWithUrl:(NSString *)imageUrl
{
    if (self = [super init])
    {
        self.currentState = ImageStateUndefined;
        self.image = nil;
        self.imageUrl = imageUrl;
    }
    
    return self;
}

- (void)reset
{
    self.image = nil;
    self.currentState = ImageStateUndefined;
}

- (void)loadImageOnSuccess:(void (^)())successBlock onError:(void (^)(NSError *))errorBlock
{
    self.image = nil;
    self.currentState = ImageStateLoading;
    //TODO: необходимо обрабатывать ошибку недоступной сети
    //TODO: сохранять url и загружать изображение как только сеть станет доступна ???
    __weak typeof(self) wSelf = self;
    [[ImageCache sharedInstance] loadImageWithKey:self.imageUrl completion:^(UIImage *image) {
        wSelf.image = image;
        if (nil != image)
        {
            wSelf.currentState = ImageStateReady;
            successBlock();
        }
        else
        {
            NSURL *URL = [NSURL URLWithString:wSelf.imageUrl];
            if (nil != URL)
            {
                NSURLRequest *request = [NSURLRequest requestWithURL:URL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                    timeoutInterval:TIMEOUT_INTERVAL];
                NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
                NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
                __weak typeof(self) wSelf = self;
                NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                    completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                        if (nil != data)
                        {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                UIImage *image = [UIImage imageWithData:data scale:[UIScreen mainScreen].scale];
                                if (nil != image && nil != wSelf)
                                {
                                    wSelf.image = image;
                                    [[ImageCache sharedInstance] storeImage:image withKey:wSelf.imageUrl completion:^{
                                        wSelf.currentState = ImageStateReady;
                                        successBlock();
                                    } onError:^(NSError *error) {
                                        wSelf.currentState = ImageStateUnavailable;
                                        errorBlock(nil); //TODO: обработка ошибки
                                    }];
                                }
                                else
                                {
                                    wSelf.currentState = ImageStateUnavailable;
                                    errorBlock(nil); //TODO: обработка ошибки
                                }
                            });
                        }
                        else
                        {
                            wSelf.currentState = ImageStateUnavailable;
                            errorBlock(nil); //TODO: обработка ошибки
                        }
                    }];
                    
                [task resume];
            }
            else
            {
                //TODO: обработка ошибки некорректной imageUrl-строки
                self.currentState = ImageStateUnavailable;
                errorBlock(nil);
            }
        }
    }];
}

@end
