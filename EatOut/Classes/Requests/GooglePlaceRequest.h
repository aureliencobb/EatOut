//
//  RestaurantRequest.h
//  EatOut
//
//  Created by Aurelien Cobb on 14/03/2014.
//  Copyright (c) 2014 Aurelien Cobb. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GooglePlaceRequest;

@protocol GooglePlaceRequestDelegate <NSObject>

- (void)googlePlaceRequest:(GooglePlaceRequest *)request didSucceedWithPlaces:(NSArray *)places;
- (void)googlePlaceRequest:(GooglePlaceRequest *)request didFailWithError:(NSError *)error;

@end

@interface GooglePlaceRequest : NSObject <NSURLConnectionDataDelegate>

+ (GooglePlaceRequest *)requestWithType:(NSString *)type radius:(CGFloat)radius latitude:(double)latitude longitude:(double)longitude delegate:(id<GooglePlaceRequestDelegate>)delegate;

@property (weak, nonatomic) id<GooglePlaceRequestDelegate>delegate;

- (void)cancel;

@end

