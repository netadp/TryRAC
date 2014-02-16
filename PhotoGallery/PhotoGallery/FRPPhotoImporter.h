//
//  FRPPhotoImporter.h
//  PhotoGallery
//
//  Created by Jie Huo on 13/2/14.
//  Copyright (c) 2014 Jie Huo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FRPPhotoModel;
@interface FRPPhotoImporter : NSObject
+ (RACSignal *)importPhotos;
+ (RACSignal *)fetchPhotoDetails:(FRPPhotoModel *)photoModel;
@end
