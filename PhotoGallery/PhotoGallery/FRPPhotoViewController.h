//
//  FRPPhotoViewController.h
//  PhotoGallery
//
//  Created by Jie Huo on 16/2/14.
//  Copyright (c) 2014 Jie Huo. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FRPPhotoModel;
@interface FRPPhotoViewController : UIViewController
- (instancetype)initWithPhotoModel:(FRPPhotoModel *)photoModel index:(NSInteger)photoIndex;

@property (nonatomic, readonly) NSInteger photoIndex;
@property (nonatomic, readonly) FRPPhotoModel *photoModel;

@end
