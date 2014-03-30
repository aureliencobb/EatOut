//
//  RestaurantRequest.m
//  EatOut
//
//  Created by Aurelien Cobb on 14/03/2014.
//  Copyright (c) 2014 Aurelien Cobb. All rights reserved.
//

#import "GooglePlaceRequest.h"
#import "Place.h"

NSString * const GoogleURL      = @"https://maps.googleapis.com/maps/api/place/search/json";
NSString * const GoogleParams   = @"%@?location=%f,%f&radius=%g&types=%@&sensor=true&key=%@";

NSString * const kResultsKey    = @"results";
NSString * const kIDKey         = @"id";
NSString * const kNameKey       = @"name";
NSString * const kVicinityKey   = @"vicinity";
NSString * const kRatingKey     = @"rating";
NSString * const kGeometryKey   = @"geometry";
NSString * const kLocationKey   = @"location";
NSString * const kLatKey        = @"lat";
NSString * const kLngKey        = @"lng";
NSString * const kIconKey       = @"icon";

const CGFloat kRequestTimeoutInterval = 25.0;

@interface GooglePlaceRequest()

@property (strong, nonatomic) NSMutableData * data;
@property (strong, nonatomic) NSURLConnection * urlConnection;

@end

@implementation GooglePlaceRequest

#pragma mark - Lifecycle, interface methods

+ (GooglePlaceRequest *)requestWithType:(NSString *)type radius:(CGFloat)radius latitude:(double)latitude longitude:(double)longitude delegate:(id<GooglePlaceRequestDelegate>)delegate {
    GooglePlaceRequest * placeRequest = [[GooglePlaceRequest alloc] initWithType:type radius:radius latitude:latitude longitude:longitude delegate:delegate];
    return placeRequest;
}

- (instancetype)initWithType:(NSString *)type radius:(CGFloat)radius latitude:(double)latitude longitude:(double)longitude delegate:(id<GooglePlaceRequestDelegate>)delegate {
    self = [super init];
    if (self) {
        NSString * urlString = [NSString stringWithFormat:GoogleParams, GoogleURL, latitude, longitude, radius, type, GOOGLE_API_KEY];
        NSURL * url = [NSURL URLWithString:urlString];
        NSMutableURLRequest * urlRequest = [NSMutableURLRequest requestWithURL:url];
        urlRequest.timeoutInterval = kRequestTimeoutInterval;
        NSURLConnection * connection = [NSURLConnection connectionWithRequest:urlRequest delegate:self];
        self.delegate = delegate;
        self.urlConnection = connection;
    }
    return self;
}

- (void)cancel {
    [self.urlConnection cancel];
}

#pragma mark - Getters / Setters

- (NSMutableData *)data {
    if (!_data) {
        _data = [[NSMutableData alloc] init];
    }
    return _data;
}

#pragma mark - Private methods

- (void)parseData {
    NSError * error;
    NSDictionary * dataAsDict = [NSJSONSerialization JSONObjectWithData:self.data options:0 error:&error];
    if (error) {
        [self notifyDelegateOfError:error];
        return;
    }
    NSArray * results = [dataAsDict objectForKey:kResultsKey];
    NSMutableArray * places = [[NSMutableArray alloc] initWithCapacity:results.count];
    [results enumerateObjectsUsingBlock:^(NSDictionary * result, NSUInteger idx, BOOL *stop) {
        if ([result isKindOfClass:[NSDictionary class]]) {
            Place * place = [[Place alloc] init];
            place.placeID = [result objectForKey:kIDKey];
            place.name = [result objectForKey:kNameKey];
            place.vicinity = [result objectForKey:kVicinityKey];
            place.rating = [[result objectForKey:kRatingKey] floatValue];
            NSDictionary * geometry = [result objectForKey:kGeometryKey];
            NSDictionary * location = [geometry objectForKey:kLocationKey];
            CLLocationCoordinate2D coordinate;
            coordinate.latitude = [[location objectForKey:kLatKey] doubleValue];
            coordinate.longitude = [[location objectForKey:kLngKey] doubleValue];
            place.coordinate = coordinate;
            place.iconUrlStr = [result objectForKey:kIconKey];
            [places addObject:place];
        }
    }];
    if ([self.delegate respondsToSelector:@selector(googlePlaceRequest:didSucceedWithPlaces:)]) {
        [self.delegate googlePlaceRequest:self didSucceedWithPlaces:places];
    }
}

- (void)notifyDelegateOfError:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(googlePlaceRequest:didFailWithError:)]) {
        [self.delegate googlePlaceRequest:self didFailWithError:error];
    }
}

#pragma mark - NSURLConnectionDataDelegate methods

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.data appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self notifyDelegateOfError:error];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self parseData];
}

@end
