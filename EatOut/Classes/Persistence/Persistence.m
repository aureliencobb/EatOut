//
//  Persistence.m
//  EatOut
//
//  Created by Aurelien Cobb on 16/03/2014.
//  Copyright (c) 2014 Aurelien Cobb. All rights reserved.
//

#import "Persistence.h"

NSString * const kFileName = @"storage";
NSString * const kRootKey = @"rootKey";

@implementation Persistence

+ (Persistence *)persistence {
    return [[Persistence alloc] init];
}

- (NSArray *)retrieveSavedPlaces {
    NSString * path = [self pathForPersistence];
    NSDictionary * toRead = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    NSArray * places = [toRead objectForKey:kRootKey];
    if ([places isKindOfClass:[NSArray class]]) {
        return places;
    }
    return nil;
}

- (void)savePlaces:(NSArray *)places {
    NSString * path = [self pathForPersistence];
    NSMutableDictionary * toPersist = [NSMutableDictionary dictionary];
    [toPersist setObject:places forKey:kRootKey];
    [NSKeyedArchiver archiveRootObject:toPersist toFile:path];
}

#pragma mark - Private methods

- (NSString *)pathForPersistence {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSString * path = [basePath stringByAppendingPathComponent:kFileName];
    if (![fileManager fileExistsAtPath:path]) {
        [fileManager createFileAtPath:path contents:nil attributes:nil];
    }
    return path;
}


@end
