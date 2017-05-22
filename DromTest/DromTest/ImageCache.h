//
//  ImageCache.h
//  DromTest
//
//  Created by Murat Dzhusupov on 01.11.16.
//  Copyright © 2016 Murat Dzhusupov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageCache : NSObject

+ (ImageCache *)sharedInstance;
- (void)storeImage:(UIImage *)image withKey:(NSString *)key completion:(void(^)())completion onError:(void (^)(NSError *))errorBlock;
- (void)loadImageWithKey:(NSString *)key completion:(void(^)(UIImage *))completion;
- (void)clearMemory;
- (void)clearDiskWithCompletion:(void(^)())completion;

@end
