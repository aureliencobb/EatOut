//
//  Persistence.h
//  EatOut
//
//  Created by Aurelien Cobb on 16/03/2014.
//  Copyright (c) 2014 Aurelien Cobb. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Persistence : NSObject

+ (Persistence *)persistence;

- (NSArray *)retrieveSavedPlaces;
- (void)savePlaces:(NSArray *)places;

@end
