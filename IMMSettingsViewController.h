//
//  IMMSettingsViewController.h
//  Moonmasons
//
//  Created by Johan Wiig on 09/10/14.
//  Copyright (c) 2014 Innology. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IMMSettingsViewController : UIViewController

@property (strong, nonatomic) IBOutlet UISwitch *instagram;
@property (strong, nonatomic) IBOutlet UISwitch *twitter;
@property (strong, nonatomic) IBOutlet UISwitch *satellite;
@property (strong, nonatomic) IBOutlet UISwitch *zoomToPhoto;
@property (strong, nonatomic) IBOutlet UISlider *radius;
@property (strong, nonatomic) IBOutlet UISwitch *alert;

@end
