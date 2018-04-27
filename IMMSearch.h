//
//  IMMSearch.h
//  Moonmasons
//
//  Created by Johan Wiig on 07/10/14.
//  Copyright (c) 2014 Innology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleMaps/GoogleMaps.h>
#import "IMMPhoto.h"

@interface IMMSearch : GMSMarker

- (instancetype)initWithCoordinates:(CLLocationCoordinate2D)coordinate radius:(float)radius;
- (instancetype)initWithCoordinates:(CLLocationCoordinate2D)coordinate;
- (BOOL) isCoveringPhoto:(IMMPhoto*)photo;

@property (nonatomic) float radius;
@property GMSCircle * circle;

@property (nonatomic) BOOL active;
@property (nonatomic) BOOL negative;
@property (nonatomic) BOOL alert;
@property BOOL boost;
@property float rank;

@property NSMutableArray * result;

@end
