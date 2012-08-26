//
//  LARRadarPointCell.m
//  LARA
//
//  Created by Chris Stephan on 6/27/12.
//  Copyright (c) 2012 Endozemedia. All rights reserved.
//

#import "LARRadarPointCell.h"

@implementation LARRadarPointCell
@synthesize nameLabel = _nameLabel;
@synthesize subLabel = _subLabel;
@synthesize removeButton = _removeButton;
@synthesize updateButton = _updateButton;
@synthesize iconView = _iconView;
@synthesize backgroundImage = _backgroundImage;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
