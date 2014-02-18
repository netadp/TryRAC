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
#import <ReactiveCocoa/RACDelegateProxy.h>

@interface FRPGalleryViewController () <UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) NSArray *photosArray;
@property (nonatomic, strong) id collectionViewDelegate;
@property (nonatomic, strong) UICollectionView *collectionView;
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
	self = [super init];
	if (!self) {
		return nil;
	}
	
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	FRPGalleryFlowLayout *flowLayout = [[FRPGalleryFlowLayout alloc]init];

	self.collectionView = [[UICollectionView alloc]initWithFrame:self.view.bounds collectionViewLayout:flowLayout];
	self.collectionView.delegate = self;
	self.collectionView.dataSource = self;
	[self.view addSubview:self.collectionView];
	self.title = @"Popular on 500 px";
	
	[self.collectionView registerClass:[FRPCell class] forCellWithReuseIdentifier:cellIdentifier];
	
	@weakify(self);
	[RACObserve(self, photosArray) subscribeNext:^(id x) {
		@strongify(self);
		[self.collectionView reloadData];
	}];
	
//	[self loadPopularPhotos];
	RACSignal *photoSignal = [FRPPhotoImporter importPhotos];
	RACSignal *photoLoaded = [photoSignal catch:^RACSignal *(NSError *error) {
		NSLog(@"Couldn't fetch photos from 500px: %@", error);
		return [RACSignal empty];
	}];
	
	RAC(self, photosArray) = photoLoaded;
	[photoLoaded subscribeCompleted:^{
		@strongify(self);
		[self.collectionView reloadData];
	}];
	
	RACDelegateProxy *viewControllerDelegate = [[RACDelegateProxy alloc]initWithProtocol:@protocol(FRPFullSizePhotoViewControllerDelegate)];
	
	[[viewControllerDelegate rac_signalForSelector:@selector(userDidScroll:toPhotoAtIndex:)
	  fromProtocol:@protocol(FRPFullSizePhotoViewControllerDelegate)] subscribeNext:^(RACTuple *value) {
		@strongify(self);
		[self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:[value.second integerValue] inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
	}];
	
	self.collectionViewDelegate = [[RACDelegateProxy alloc]initWithProtocol:@protocol(UICollectionViewDelegate)];
	[[self.collectionViewDelegate rac_signalForSelector:@selector(collectionView:didSelectItemAtIndexPath:) fromProtocol:@protocol(UICollectionViewDelegate)]
	 subscribeNext:^(RACTuple *arguments) {
		 @strongify(self);
		 FRPFullSizePhotoViewController *vc = [[FRPFullSizePhotoViewController alloc]initWithPhotoModels:self.photosArray currentPhotoIndex:[(NSIndexPath*)arguments.second item]];
		 
		 vc.delegate = (id<FRPFullSizePhotoViewControllerDelegate>)viewControllerDelegate;
		 [self.navigationController pushViewController:vc animated:YES];
	 }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - load photos
//- (void)loadPopularPhotos{
//	[[FRPPhotoImporter importPhotos] subscribeNext:^(id x) {
//		self.photosArray = x;
//	} error:^(NSError *error) {
//		NSLog(@"Couldn't fetch photos from 500px:%@", error);
//	}];
//}

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

//- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
//{
////	FRPFullSizePhotoViewController *vc = [[FRPFullSizePhotoViewController alloc]initWithPhotoModels:self.photosArray currentPhotoIndex:indexPath.item];
////	
////	vc.delegate = self;
////	[self.navigationController pushViewController:vc animated:YES];
//}

//#pragma mark - FullSizeViewControllerDelegate
//-(void)userDidScroll:(FRPFullSizePhotoViewController *)viewController toPhotoAtIndex:(NSInteger)index
//{
//	[self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
//}
@end
