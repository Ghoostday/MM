//
//  IMMPictureTableViewCell.h
//  Moonmasons
//
//  Created by Johan Wiig on 10/10/14.
//  Copyright (c) 2014 Innology. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IMMPictureTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *photoView;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UIImageView *star;

@end
