//
//  FRPPhotoImporter.m
//  PhotoGallery
//
//  Created by Jie Huo on 13/2/14.
//  Copyright (c) 2014 Jie Huo. All rights reserved.
//

#import "FRPPhotoImporter.h"
#import "FRPPhotoModel.h"

@implementation FRPPhotoImporter
+(RACReplaySubject *)importPhotos{
	RACReplaySubject *subject = [RACReplaySubject subject];
	
	NSURLRequest *request = [self popularURLRequest];
	
	[NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
		if (data) {
			id results = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
			
			[subject sendNext:[[[results[@"photos"] rac_sequence] map:^id(NSDictionary *photoDictionary) {
				FRPPhotoModel *model = [FRPPhotoModel new];
				
				[self configurePhotoModel:model withDictionary:photoDictionary];
				[self downloadThumbnailForPhotoModel:model];
				
				return model;
			}] array]];
		}else{
			[subject sendError:connectionError];
		}
	}];
	
	return subject;
}

+(NSURLRequest *)popularURLRequest
{
	return [AppDelegate.apiHelper urlRequestForPhotoFeature:PXAPIHelperPhotoFeaturePopular resultsPerPage:100 page:0 photoSizes:PXPhotoModelSizeThumbnail sortOrder:PXAPIHelperSortOrderRating except:PXPhotoModelCategoryNude];
}

+(void)configurePhotoModel:(FRPPhotoModel *)model withDictionary:(NSDictionary *)dictionary{
	model.photoName = dictionary[@"name"];
	model.identifier = dictionary[@"id"];
	model.photographerName = dictionary[@"user"][@"username"];
	model.rating = dictionary[@"rating"];
	model.thumbnailURL = [self urlForImageSize:3 inArray:dictionary[@"images"]];
	
	if (dictionary[@"comments_count"]) {
		model.fullsizedURL = [self urlForImageSize:4 inArray:dictionary[@"images"]];
	}
}

+(NSString *)urlForImageSize:(NSInteger)size	 inArray:(NSArray *)array
{
	return [[[[[array rac_sequence] filter:^BOOL(NSDictionary *value) {
		return [value[@"size"] integerValue] == size;
	}] map:^id(id value) {
		return value[@"url"];
	}] array]firstObject];
}

+(void)downloadThumbnailForPhotoModel:(FRPPhotoModel *)photoModel{
//	[self download:photoModel.thumbnailURL withCompletion:^(NSData *data) {
//		photoModel.thumbnailData = data;
//	}];
	RAC(photoModel, thumbnailData) = [self download:photoModel.thumbnailURL];
}

+(void)downloadFullSizedImageForPhotoModel:(FRPPhotoModel *)photoModel{
//	[self download:photoModel.fullsizedURL withCompletion:^(NSData *data) {
//		photoModel.fullsizedData = data;
//	}];
	RAC(photoModel, fullsizedData) = [self download:photoModel.fullsizedURL];
}

+ (void)download:(NSString *)urlString withCompletion:(void(^)(NSData *data))completion{
	NSAssert(urlString, @"URL must not be nil");

	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
	[NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
		completion(data);
	}];
}

+(RACSignal *)download:(NSString *)urlString {
	NSAssert(urlString, @"URL must not be nil");
	
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
	
	return [[[NSURLConnection rac_sendAsynchronousRequest:request]
			 map:^id(RACTuple *value) {
				 return [value second];
			 }] deliverOn:[RACScheduler mainThreadScheduler]];
}

+ (NSURLRequest *)photoURLRequest: (FRPPhotoModel *)photoModel
{
	return [AppDelegate.apiHelper urlRequestForPhotoID:photoModel.identifier.integerValue];
}

+ (RACSignal *)fetchPhotoDetails:(FRPPhotoModel *)photoModel{
//	RACReplaySubject *subject = [RACReplaySubject subject];
//	
//	NSURLRequest *request = [self photoURLRequest:photoModel];
//	[NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
//		if (data) {
//			id results = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil][@"photo"];
//			[self configurePhotoModel:photoModel withDictionary:results];
//			
//			[self downloadFullSizedImageForPhotoModel:photoModel];
//			
//			[subject sendNext:photoModel];
//			[subject sendCompleted];
//		}else{
//			[subject sendError:connectionError];
//		}
//	}];
//	
//	return subject;
	NSURLRequest *request = [self photoURLRequest:photoModel];
	return [[[[[[NSURLConnection rac_sendAsynchronousRequest:request] map:^id(RACTuple *value) {
		return [value second];
	}] deliverOn:[RACScheduler mainThreadScheduler]] map:^id(NSData *data) {
		id results = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil][@"photo"];
		
		[self configurePhotoModel:photoModel withDictionary:results];
		[self downloadFullSizedImageForPhotoModel:photoModel];
		
		return photoModel;
	}] publish] autoconnect];
}
@end
