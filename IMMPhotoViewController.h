//
//  IMMPhotoViewController.h
//  Moonmasons
//
//  Created by Johan Wiig on 08/10/14.
//  Copyright (c) 2014 Innology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMMPhoto.h"

@interface IMMPhotoViewController : UIViewController

@property NSMutableArray * photos;
@property long index;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UISwitch *boost;
@property (strong, nonatomic) IBOutlet UILabel *likes;
@property (strong, nonatomic) IBOutlet UILabel *time;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@end
