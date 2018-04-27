//
//  IMMCurrentLocationSearch.m
//  Moonmasons
//
//  Created by Johan Wiig on 27/10/14.
//  Copyright (c) 2014 Innology. All rights reserved.
//

#import "IMMCurrentLocationSearch.h"

@implementation IMMCurrentLocationSearch

- (instancetype)init
{
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = 0.0;
    coordinate.longitude = 0.0;
    NSNumber * radiusObj = [[NSUserDefaults standardUserDefaults] valueForKey:@"CurrentLocationSearch_radius"];
    float radius = 500;
    if (radiusObj)
    {
        radius = [radiusObj floatValue];
    }

    if (self = [super initWithCoordinates:coordinate radius:radius])
    {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.delegate = self;
        [_locationManager requestWhenInUseAuthorization];
        [_locationManager startUpdatingLocation];
        
        NSNumber * alert = [[NSUserDefaults standardUserDefaults] valueForKey:@"CurrentLocationSearch_alert"];
        if (alert)
        {
            self.alert = [alert boolValue];
        }
        
        self.active = false;
    }
    return self;
}

- (void)locationManager:(CLLocationManager *)manager
   didUpdateToLocation:(CLLocation *)newLocation
          fromLocation:(CLLocation *)oldLocation
{
    self.position = newLocation.coordinate;
    self.active = true;
}

- (void) setRadius:(float)radius
{
    [super setRadius:radius];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:radius] forKey:@"CurrentLocationSearch_radius"];
}

- (void) setAlert:(BOOL)alert
{
    [super setAlert:alert];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:alert] forKey:@"CurrentLocationSearch_alert"];
}

- (void) updateCircleColor
{
    self.circle.fillColor = [UIColor colorWithRed:0 green:0 blue:0.9 alpha:0.05];
    self.circle.strokeColor = [UIColor colorWithRed:0 green:0 blue:0.9 alpha:0.2];
    self.circle.strokeWidth = 1;
}

@end
