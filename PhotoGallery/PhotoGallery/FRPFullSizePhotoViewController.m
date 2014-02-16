//
//  FRPFullSizePhotoViewController.m
//  PhotoGallery
//
//  Created by Jie Huo on 16/2/14.
//  Copyright (c) 2014 Jie Huo. All rights reserved.
//

#import "FRPFullSizePhotoViewController.h"
#import "FRPPhotoModel.h"
#import "FRPPhotoViewController.h"

@interface FRPFullSizePhotoViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate>
@property (nonatomic, strong) NSArray *photoModelArray;
@property (nonatomic, strong) UIPageViewController *pageViewController;
@end

@implementation FRPFullSizePhotoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(instancetype)initWithPhotoModels:(NSArray *)photoModelArray currentPhotoIndex:(NSInteger)photoIndex
{
	if (self = [super init]) {
		self.photoModelArray = photoModelArray;
		self.title = [self.photoModelArray[photoIndex] photoName];
		
		self.pageViewController = [[UIPageViewController alloc]initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:@{UIPageViewControllerOptionInterPageSpacingKey: @30}];
		self.pageViewController.dataSource = self;
		self.pageViewController.delegate = self;
		[self addChildViewController:self.pageViewController];
		
		[self.pageViewController setViewControllers:@[[self photoViewControllerForIndex:photoIndex]]
										  direction:UIPageViewControllerNavigationDirectionForward
										   animated:NO
										 completion:nil];
		
	}
	
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.view.backgroundColor = [UIColor blackColor];
	self.pageViewController.view.frame = self.view.bounds;
	[self.view addSubview:self.pageViewController.view];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - pageview
-(void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
	self.title = [[self.pageViewController.viewControllers.firstObject photoModel]photoName];
	[self.delegate userDidScroll:self toPhotoAtIndex:[self.pageViewController.viewControllers.firstObject photoIndex]];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(FRPPhotoViewController *)viewController
{
	return [self photoViewControllerForIndex:viewController.photoIndex + 1];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(FRPPhotoViewController *)viewController
{
	return [self photoViewControllerForIndex:viewController.photoIndex - 1];
}

#pragma mark - 
- (FRPPhotoViewController *)photoViewControllerForIndex:(NSInteger)index
{
	if (index >= 0 && index < self.photoModelArray.count) {
		FRPPhotoModel *photoModel = self.photoModelArray[index];
		
		FRPPhotoViewController *vc = [[FRPPhotoViewController alloc]initWithPhotoModel:photoModel index:index];
		return vc;
	}
	
	return nil;
}

@end
