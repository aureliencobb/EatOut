//
//  Place.m
//  EatOut
//
//  Created by Aurelien Cobb on 15/03/2014.
//  Copyright (c) 2014 Aurelien Cobb. All rights reserved.
//

#import "Place.h"

NSString * const kPlaceIDKey         = @"kPlaceIDKey";
NSString * const kPlaceNameKey       = @"kPlaceNameKey";
NSString * const kPlaceVicinityKey   = @"kPlaceVicinityKey";
NSString * const kPlaceRatingKey     = @"kPlaceRatingKey";
NSString * const kPlaceLatitudeKey   = @"kPlaceLatitudeKey";
NSString * const kPlaceLongitudeKey  = @"kPlaceLongitudeKey";
NSString * const kPlaceURLKey        = @"kPlaceURLKey";
NSString * const kPlaceIconKey       = @"kPlaceIconKey";

@implementation Place

#pragma mark - MKAnnotation Delegate Methods

//- (CLLocationCoordinate2D)coordinate {
//    static CLLocationCoordinate2D coords;    
//    coords.latitude = _latitude;
//    coords.longitude = _longitude;
//    return coords;
//}


- (NSString *)title {
    if (!self.name) {
        return @"No Name";
    }
    return self.name;
}

- (NSString *)subtitle {
    if (!self.vicinity) {
        return @"No Subtitle";
    }
    return self.vicinity;
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.placeID = [aDecoder decodeObjectForKey:kPlaceIDKey];
        self.name = [aDecoder decodeObjectForKey:kPlaceNameKey];
        self.vicinity = [aDecoder decodeObjectForKey:kPlaceVicinityKey];
        self.rating = [aDecoder decodeFloatForKey:kPlaceRatingKey];
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = [aDecoder decodeDoubleForKey:kPlaceLatitudeKey];
        coordinate.longitude = [aDecoder decodeDoubleForKey:kPlaceLongitudeKey];
        self.coordinate = coordinate;
        self.iconUrlStr = [aDecoder decodeObjectForKey:kPlaceURLKey];
        self.icon = [aDecoder decodeObjectForKey:kPlaceIconKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.placeID forKey:kPlaceIDKey];
    [aCoder encodeObject:self.name forKey:kPlaceNameKey];
    [aCoder encodeObject:self.vicinity forKey:kPlaceVicinityKey];
    [aCoder encodeFloat:self.rating forKey:kPlaceRatingKey];
    [aCoder encodeDouble:self.coordinate.latitude forKey:kPlaceLatitudeKey];
    [aCoder encodeDouble:self.coordinate.longitude forKey:kPlaceLongitudeKey];
    [aCoder encodeObject:self.iconUrlStr forKey:kPlaceURLKey];
    [aCoder encodeObject:self.icon forKey:kPlaceIconKey];
}

@end
