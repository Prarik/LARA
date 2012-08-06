//
//  LARRadarPointCell.h
//  LARA
//
//  Created by Chris Stephan on 6/27/12.
//  Copyright (c) 2012 Endozemedia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LARRadarPointCell : UITableViewCell
@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet UILabel *subLabel;
@property (nonatomic, strong) IBOutlet UIButton *removeButton;
@property (nonatomic, strong )IBOutlet UIButton *updateButton;


@end
