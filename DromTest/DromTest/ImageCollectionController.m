//
//  ImageCollectionController.m
//  DromTest
//
//  Created by Murat Dzhusupov on 15.10.16.
//  Copyright © 2016 Murat Dzhusupov. All rights reserved.
//

#import "ImageCollectionController.h"
#import "ImageCollectionLayout.h"
#import "Config.h"
#import "ImageCell.h"
#import "ImageCache.h"
#import "ImageData.h"

@interface ImageCollectionController ()
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) NSMutableArray *dataItems;
@property (nonatomic, strong) ImageCache *imageCache;
@end

@implementation ImageCollectionController

- (id)init
{
    ImageCollectionLayout *layout = [[ImageCollectionLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(CELLS_MARGIN, CELLS_MARGIN, CELLS_MARGIN, CELLS_MARGIN);

    if (self = [super initWithCollectionViewLayout:layout])
    {
        self.dataItems = [NSMutableArray array];
        self.imageCache = [[ImageCache alloc] init];
        [self.collectionView registerClass:[ImageCell class] forCellWithReuseIdentifier:CELL_IDENTIFIER];
        self.refreshControl = [[UIRefreshControl alloc] init];
        [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
        [self.collectionView addSubview:self.refreshControl];
        self.collectionView.alwaysBounceVertical = YES;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.collectionView.backgroundColor = [UIColor grayColor];
    self.title = @"Тестовое задание";
    
    [self resetDataItems];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [[ImageCache sharedInstance] clearMemory];
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                               duration:(NSTimeInterval)duration
{
    [self.collectionView.collectionViewLayout invalidateLayout];
}

- (void)refresh
{
    [self resetDataItems];

    [[ImageCache sharedInstance] clearMemory];
    __weak typeof(self) wSelf = self;
    [[ImageCache sharedInstance] clearDiskWithCompletion:^() {
        [wSelf.collectionView reloadData];
        [wSelf.refreshControl endRefreshing];
    }];
}

- (void)resetDataItems
{
    [self.dataItems removeAllObjects];

    NSArray *imageURLs = @[@"http://simonwiddowson.typepad.com/files/countryside-800x600.jpg",
        @"http://simonwiddowson.typepad.com/files/grass-800x600.jpg",
        @"http://simonwiddowson.typepad.com/files/grass-bank-800x600.jpg",
        @"http://www.visit-montenegro.com/downloads/wallpaper-800x600-1.jpg",
        @"http://www.visit-montenegro.com/downloads/wallpaper-800x600-3.jpg",
        @"http://www.visit-montenegro.com/downloads/wallpaper-800x600-4.jpg"];
    
    for (NSString *url in imageURLs)
    {
        ImageData *dataItem = [[ImageData alloc] initWithUrl:url];
        [self.dataItems addObject:dataItem];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout
sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    const CGFloat side = [UIScreen mainScreen].bounds.size.width - 2.f * CELLS_MARGIN;
    return CGSizeMake(side, side);
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [self.dataItems count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CELL_IDENTIFIER forIndexPath:indexPath];
    ImageData *imageData = self.dataItems[indexPath.section];
    if (ImageStateUndefined == imageData.currentState)
    {
        [imageData loadImageOnSuccess:^{
            if ([self.dataItems containsObject:imageData]) // если ячейку не удалили иначе крэш
            {
                [collectionView reloadItemsAtIndexPaths:@[indexPath]];
            }
        } onError:^(NSError *error) {
            if ([self.dataItems containsObject:imageData]) // если ячейку не удалили иначе крэш
            {
                [collectionView reloadItemsAtIndexPaths:@[indexPath]];
            }
        }];
    }
    [cell updateWithImageData:imageData];

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.dataItems removeObjectAtIndex:indexPath.section];
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:indexPath.section];

    [collectionView performBatchUpdates:^ {
        [collectionView deleteSections:indexSet];
    } completion:^(BOOL finished) {
        [collectionView reloadData];
    }];
}


@end
