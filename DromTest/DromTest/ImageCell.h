//
//  ImageCell.h
//  DromTest
//
//  Created by Murat Dzhusupov on 01.11.16.
//  Copyright © 2016 Murat Dzhusupov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ImageData;

@interface ImageCell : UICollectionViewCell
@property (nonatomic, assign) CGFloat normalOriginY;
- (void)updateWithImageData:(ImageData *)imageData;
@end
