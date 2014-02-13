//
//  FRPGalleryFlowLayout.m
//  PhotoGallery
//
//  Created by Jie Huo on 13/2/14.
//  Copyright (c) 2014 Jie Huo. All rights reserved.
//

#import "FRPGalleryFlowLayout.h"

@implementation FRPGalleryFlowLayout

-(instancetype)init
{
	if (self = [super init]) {
		self.itemSize = CGSizeMake(145, 145);
		self.minimumLineSpacing = 10;
		self.minimumInteritemSpacing = 10;
		self.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
	}
	
	return self;
}
@end
