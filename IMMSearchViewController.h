//
//  IMMSearchViewController.h
//  Moonmasons
//
//  Created by Johan Wiig on 16/09/14.
//  Copyright (c) 2014 Innology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>

@interface IMMSearchViewController : UIViewController <GMSMapViewDelegate>


@property (strong, nonatomic) IBOutlet GMSMapView *mapView;
@property (strong, nonatomic) IBOutlet UIView *detailsPanel;
@property (strong, nonatomic) IBOutlet UISlider *radius;
@property (strong, nonatomic) IBOutlet UISwitch *active;
@property (strong, nonatomic) IBOutlet UISwitch *negative;
@property (strong, nonatomic) IBOutlet UISwitch *boost;
@property (strong, nonatomic) IBOutlet UISwitch *alert;

@end
