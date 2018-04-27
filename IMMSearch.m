//
//  IMMSearch.m
//  Moonmasons
//
//  Created by Johan Wiig on 07/10/14.
//  Copyright (c) 2014 Innology. All rights reserved.
//

#import "IMMSearch.h"

@implementation IMMSearch

@synthesize radius = _radius;

-(instancetype)initWithCoordinates:(CLLocationCoordinate2D)coordinate
{
    return [self initWithCoordinates:coordinate radius:500];
}

-(instancetype)initWithCoordinates:(CLLocationCoordinate2D)coordinate radius:(float)radius
{
    if (self = [super init])
    {
        self.position = coordinate;
        self.radius = radius;
        self.appearAnimation = kGMSMarkerAnimationPop;
        self.icon = [UIImage imageNamed:@"pin-mm.png"];
        
        _circle = [GMSCircle circleWithPosition:coordinate radius:_radius];
        
        _active = true;
        _negative = false;
        _boost = false;
        _rank = 0.0;
        
        [self updateCircleColor];
        
        _result = [[NSMutableArray alloc] init];
        
        return self;
    }
    return nil;
}

- (id) init
{
    if (self = [super init])
    {
        [self checkGeometry];
    }
    return self;
}

- (BOOL) isCoveringPhoto:(IMMPhoto*)photo
{
    CLLocation *searchLocation = [[CLLocation alloc] initWithLatitude:self.position.latitude longitude:self.position.longitude];
    CLLocation *photoLocation = [[CLLocation alloc] initWithLatitude:photo.coordinate.latitude longitude:photo.coordinate.longitude];
    CLLocationDistance distance = [searchLocation distanceFromLocation:photoLocation];
    return distance < self.radius;
}

- (void) setMap:(GMSMapView *)map
{
    [super setMap:map];
    _circle.map = map;
}

- (void) setPosition:(CLLocationCoordinate2D)position
{
    [super setPosition:position];
    _circle.position = position;
}

- (void) setRadius:(float)radius
{
    _radius = radius;
    _circle.radius = radius;
}

- (void) setActive:(BOOL)active
{
    _active = active;
    [self updateCircleColor];
}

- (void) setNegative:(BOOL)negative
{
    _negative = negative;
    _alert = NO;
    _boost = NO;
    [self updateCircleColor];
}

- (void) setAlert:(BOOL)alert
{
    _alert = alert;
    [self updateCircleColor];
}

- (void) updateCircleColor
{
    if (!_active)
    {
        _circle.fillColor = [UIColor colorWithRed:0.5 green:0.25 blue:0.25 alpha:0.2];
        _circle.strokeColor = [UIColor grayColor];
    }
    else if (_negative)
    {
        _circle.fillColor = [UIColor colorWithRed:0.9 green:0 blue:0 alpha:0.2];
        _circle.strokeColor = [UIColor redColor];
    }
    else if(_alert)
    {
        _circle.fillColor = [UIColor colorWithRed:1 green:0.6 blue:0 alpha:0.2];
        _circle.strokeColor = [UIColor colorWithRed:1 green:0.6 blue:0 alpha:1];
    }
    else
    {
        _circle.fillColor = [UIColor colorWithRed:0 green:0.9 blue:0 alpha:0.2];
        _circle.strokeColor = [UIColor greenColor];
    }
    _circle.strokeWidth = 1;
}

- (void) checkGeometry
{
    if (self.position.latitude <= -179.0 || self.position.longitude <= -179.0)
    {
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = 0.0;
        coordinate.longitude = 0.0;
        self.position = coordinate;
    }

    if (self.radius <= 0)
    {
        self.radius = 10;
    }
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeFloat:self.position.latitude forKey:@"search_radius_latitude"];
    [coder encodeFloat:self.position.longitude forKey:@"search_radius_longitude"];
    [coder encodeInt:self.radius forKey:@"search_radius"];
    [coder encodeBool:_active forKey:@"search_active"];
    [coder encodeBool:_negative forKey:@"search_negative"];
    [coder encodeBool:_boost forKey:@"search_boost"];
    [coder encodeBool:_alert forKey:@"search_alert"];
}

- (id)initWithCoder:(NSCoder *)coder
{
    if (self = [super init])
    {
        CLLocationCoordinate2D coordinate;
        coordinate.latitude = [coder decodeFloatForKey:@"search_radius_latitude"];
        coordinate.longitude = [coder decodeFloatForKey:@"search_radius_longitude"];
        self.position = coordinate;
        self.appearAnimation = kGMSMarkerAnimationPop;
        self.radius = [coder decodeIntForKey:@"search_radius"];
        self.icon = [UIImage imageNamed:@"pin-mm.png"];

        _circle = [GMSCircle circleWithPosition:coordinate radius:_radius];
        
        _active = [coder decodeBoolForKey:@"search_active"];
        _negative = [coder decodeBoolForKey:@"search_negative"];
        _boost = [coder decodeBoolForKey:@"search_boost"];
        _alert = [coder decodeBoolForKey:@"search_alert"];
        
        [self checkGeometry];
        
        [self updateCircleColor];
    }
    return self;
}

@end
