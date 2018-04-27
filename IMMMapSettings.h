//
//  IMMMapSettings.h
//  Moonmasons
//
//  Created by Johan Wiig on 28/10/14.
//  Copyright (c) 2014 Innology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleMaps/GoogleMaps.h>

@interface IMMMapSettings : NSObject

+ (id) sharedInstance;

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic) float zoom;

@property (nonatomic) BOOL satellite;
@property (nonatomic) BOOL zoomToPhoto;

@end
