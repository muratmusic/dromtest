//
//  ImageCell.m
//  DromTest
//
//  Created by Murat Dzhusupov on 01.11.16.
//  Copyright © 2016 Murat Dzhusupov. All rights reserved.
//

#import "ImageCell.h"
#import "ImageData.h"

@interface ImageCell()
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIActivityIndicatorView *loadingIndicator;
@end

@implementation ImageCell

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor lightGrayColor];
        
        self.imageView = [[UIImageView alloc] init];
        [self addSubview:self.imageView];
        [self.imageView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:
            @"H:|[imageView]|" options:0 metrics:nil views:@{ @"imageView" : self.imageView }]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:
            @"V:|[imageView]|" options:0 metrics:nil views:@{ @"imageView" : self.imageView }]];
        
        self.loadingIndicator = [[UIActivityIndicatorView alloc]
            initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        self.loadingIndicator.color = [UIColor blackColor];
        [self addSubview:self.loadingIndicator];
        [self.loadingIndicator setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:
            NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.loadingIndicator
            attribute:NSLayoutAttributeCenterX multiplier:1.f constant:0.f]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:
            NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.loadingIndicator
            attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0.f]];
    }
    
    return self;
}

- (void)updateWithImageData:(ImageData *)imageData
{
    switch (imageData.currentState) {
        case ImageStateLoading:
            self.imageView.image = nil;
            [self.loadingIndicator startAnimating];
            break;
        case ImageStateReady:
            self.imageView.image = imageData.image;
            [self.loadingIndicator stopAnimating];
            break;
        case ImageStateUnavailable:
            [self.loadingIndicator stopAnimating];
            self.imageView.image = [UIImage imageNamed:@"no_image.png"];
            break;
        case ImageStateUndefined:
        default:
            [self.loadingIndicator stopAnimating];
            self.imageView.image = nil;
            break;
    }
}

@end
