//
//  FRPGalleryViewController.m
//  PhotoGallery
//
//  Created by Jie Huo on 13/2/14.
//  Copyright (c) 2014 Jie Huo. All rights reserved.
//

#import "FRPGalleryViewController.h"
#import "FRPGalleryFlowLayout.h"
#import "FRPPhotoImporter.h"
#import "FRPCell.h"
#import "FRPFullSizePhotoViewController.h"

@interface FRPGalleryViewController () <FRPFullSizePhotoViewControllerDelegate>
@property (nonatomic, strong) NSArray *photosArray;
@end

static NSString *cellIdentifier = @"cell";
@implementation FRPGalleryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)init
{
	FRPGalleryFlowLayout *flowLayout = [[FRPGalleryFlowLayout alloc]init];
	
	self = [self initWithCollectionViewLayout:flowLayout];
	if (!self) {
		return nil;
	}
	
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	
	self.title = @"Popular on 500 px";
	
	[self.collectionView registerClass:[FRPCell class] forCellWithReuseIdentifier:cellIdentifier];
	
	@weakify(self);
	[RACObserve(self, photosArray) subscribeNext:^(id x) {
		@strongify(self);
		[self.collectionView reloadData];
	}];
	
	[self loadPopularPhotos];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - load photos
- (void)loadPopularPhotos{
	[[FRPPhotoImporter importPhotos] subscribeNext:^(id x) {
		self.photosArray = x;
	} error:^(NSError *error) {
		NSLog(@"Couldn't fetch photos from 500px:%@", error);
	}];
}

#pragma mark - UICollectionView data source
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return self.photosArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	FRPCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
	
	[cell setPhotoModel:self.photosArray[indexPath.row]];
	
	return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	FRPFullSizePhotoViewController *vc = [[FRPFullSizePhotoViewController alloc]initWithPhotoModels:self.photosArray currentPhotoIndex:indexPath.item];
	
	vc.delegate = self;
	[self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - FullSizeViewControllerDelegate
-(void)userDidScroll:(FRPFullSizePhotoViewController *)viewController toPhotoAtIndex:(NSInteger)index
{
	[self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
}
@end
