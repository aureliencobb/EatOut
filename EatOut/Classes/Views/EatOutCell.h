//
//  EatOutCell.h
//  EatOut
//
//  Created by Aurelien Cobb on 14/03/2014.
//  Copyright (c) 2014 Aurelien Cobb. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Place;

@interface EatOutCell : UITableViewCell

+ (EatOutCell *)cell;

+ (CGFloat)cellHeight;
+ (NSString *)reuseIdentifier;

- (void)updateImage:(UIImage *)image;

@property (strong, nonatomic) Place * place;

@end
