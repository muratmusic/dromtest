//
//  ImageData.h
//  DromTest
//
//  Created by Murat Dzhusupov on 02.11.16.
//  Copyright © 2016 Murat Dzhusupov. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    ImageStateUndefined, // default
    ImageStateLoading,
    ImageStateUnavailable,
    ImageStateReady
} ImageState;


@interface ImageData : NSObject

- (id)initWithUrl:(NSString *)imageUrl;
- (void)reset; // если повторное использование объекта для загрузки заново
- (void)loadImageOnSuccess:(void (^)())successBlock onError:(void (^)(NSError *))errorBlock;
- (ImageState)currentState;
- (UIImage *)image;

@end
