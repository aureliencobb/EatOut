//
//  Place.h
//  EatOut
//
//  Created by Aurelien Cobb on 15/03/2014.
//  Copyright (c) 2014 Aurelien Cobb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>


@interface Place : NSObject <MKAnnotation, NSCoding>

@property (copy, nonatomic) NSString * placeID;
@property (copy, nonatomic) NSString * name;
@property (copy, nonatomic) NSString * vicinity;
@property (assign, nonatomic) CGFloat rating;
@property (assign, nonatomic) CLLocationCoordinate2D coordinate;
//@property (assign, nonatomic) double latitude;
//@property (assign, nonatomic) double longitude;
@property (copy, nonatomic) NSString * iconUrlStr;
@property (strong, nonatomic) NSData * icon;

@end
