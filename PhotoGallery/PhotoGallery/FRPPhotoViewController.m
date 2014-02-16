//
//  FRPPhotoViewController.m
//  PhotoGallery
//
//  Created by Jie Huo on 16/2/14.
//  Copyright (c) 2014 Jie Huo. All rights reserved.
//

#import "FRPPhotoViewController.h"
#import "FRPPhotoModel.h"
#import "FRPPhotoImporter.h"
#import <SVProgressHUD.h>

@interface FRPPhotoViewController ()
@property (nonatomic, assign) NSInteger photoIndex;
@property (nonatomic, strong) FRPPhotoModel *photoModel;

@property (nonatomic, weak) UIImageView *imageView;
@end

@implementation FRPPhotoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(instancetype)initWithPhotoModel:(FRPPhotoModel *)photoModel index:(NSInteger)photoIndex
{
	if (self = [super init]) {
		self.photoModel = photoModel;
		self.photoIndex = photoIndex;
	}
	
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.view.backgroundColor = [UIColor blackColor];
	
	UIImageView *imageView = [[UIImageView alloc]initWithFrame:self.view.bounds];
	RAC(imageView, image) = [RACObserve(self.photoModel, fullsizedData) map:^id(id value) {
		return [UIImage imageWithData:value];
	}];
	imageView.contentMode = UIViewContentModeScaleAspectFit;
	[self.view addSubview:imageView];
	self.imageView = imageView;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[SVProgressHUD show];
	
	[[FRPPhotoImporter fetchPhotoDetails:self.photoModel]
	 subscribeError:^(NSError *error) {
		 [SVProgressHUD showWithStatus:@"Error"];
	 }completed:^{
		 [SVProgressHUD dismiss];
	 }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
