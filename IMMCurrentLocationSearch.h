//
//  IMMCurrentLocationSearch.h
//  Moonmasons
//
//  Created by Johan Wiig on 27/10/14.
//  Copyright (c) 2014 Innology. All rights reserved.
//

#import "IMMSearch.h"
#import <CoreLocation/CoreLocation.h>

@interface IMMCurrentLocationSearch : IMMSearch <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property NSTimer * timer;

@end
