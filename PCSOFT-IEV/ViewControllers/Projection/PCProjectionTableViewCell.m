//
//  PCProjectionTableViewCell.m
//  ERPMobile
//
//  Created by Sameer Ghate on 08/09/14.
//  Copyright (c) 2014 Sameer Ghate. All rights reserved.
//

#import "PCProjectionTableViewCell.h"

@implementation PCProjectionTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)drawRect:(CGRect)rect
{
    self.bgImgView.layer.cornerRadius = 10.0f;
    self.bgImgView.layer.borderWidth = 2.0f;
    self.bgImgView.layer.borderColor = (__bridge CGColorRef)([UIColor blackColor]);
    self.bgImgView.clipsToBounds = YES;
}
@end
