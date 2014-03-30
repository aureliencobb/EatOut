//
//  EatOutCell.m
//  EatOut
//
//  Created by Aurelien Cobb on 14/03/2014.
//  Copyright (c) 2014 Aurelien Cobb. All rights reserved.
//

#import "EatOutCell.h"
#import "Place.h"

const CGFloat kEatOutCellHeight = 60.0;
const CGFloat kMaxRating = 5.0;
NSString * const kCellIdentifierr = @"EatOutCellIdentifier";

@interface EatOutCell()

@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UILabel *labelVicinity;
@property (weak, nonatomic) IBOutlet UILabel *labelRating;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewIcon;


@end

@implementation EatOutCell

+ (EatOutCell *)cell {
    EatOutCell * cell = [[[NSBundle mainBundle] loadNibNamed:@"EatOutCell" owner:self options:nil] lastObject];
    return cell;
}

+ (CGFloat)cellHeight {
    return kEatOutCellHeight;
}

+ (NSString *)reuseIdentifier {
    return kCellIdentifierr;
}

- (void)updateImage:(UIImage *)image {
    self.imageViewIcon.image = image;
}

- (void)setPlace:(Place *)place {
    _place = place;
    self.labelName.text = place.name;
    self.labelVicinity.text = place.vicinity;
    self.labelRating.text = [NSString stringWithFormat:@"%.01f", place.rating];
    self.labelRating.textColor = [self colorForRating:place.rating];
    self.imageViewIcon.image = [UIImage imageWithData:place.icon];
}

- (UIColor *)colorForRating:(CGFloat)rating {
    rating = MAX(0.0, rating);
    rating = MIN(kMaxRating, rating);
    return [UIColor colorWithRed:(kMaxRating-rating)/kMaxRating green:(rating/kMaxRating) blue:0.0 alpha:1.0];
}

@end
