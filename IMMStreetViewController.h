//
//  IMMStreetViewController.h
//  Moonmasons
//
//  Created by Johan Wiig on 23/10/14.
//  Copyright (c) 2014 Innology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>

@interface IMMStreetViewController : UIViewController <GMSPanoramaViewDelegate>

@property CLLocationCoordinate2D coordinate;
@property (strong, nonatomic) IBOutlet UIButton *buttonStreetView;

@end
