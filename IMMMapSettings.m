//
//  IMMMapSettings.m
//  Moonmasons
//
//  Created by Johan Wiig on 28/10/14.
//  Copyright (c) 2014 Innology. All rights reserved.
//

#import "IMMMapSettings.h"

@implementation IMMMapSettings

@synthesize coordinate = _coordinate;


+ (id) sharedInstance
{
    static IMMMapSettings *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      instance = [[self alloc] init];
                  });
    return instance;
}

- (id) init
{
    if (self = [super init])
    {
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"mapWindow_latitude"] != nil)
        {
            _coordinate.latitude = [[NSUserDefaults standardUserDefaults] floatForKey:@"mapWindow_latitude"];
            _coordinate.longitude = [[NSUserDefaults standardUserDefaults] floatForKey:@"mapWindow_longitude"];
            _zoom= [[NSUserDefaults standardUserDefaults] floatForKey:@"mapWindow_zoom"];
        }
        else
        {
            _coordinate.latitude = 48.8493496;
            _coordinate.longitude = 2.3553982;
            _zoom = 13;;
        }
        
        NSNumber * num = [[NSUserDefaults standardUserDefaults] valueForKey:@"satelllite"];
        _satellite = (num == nil) ? false : [num boolValue];
        
        num = [[NSUserDefaults standardUserDefaults] valueForKey:@"animate"];
        _zoomToPhoto = (num == nil) ? true : [num boolValue];
    }
    return self;
}

- (void) setCoordinate:(CLLocationCoordinate2D)coordinate
{
    _coordinate = coordinate;
    [[NSUserDefaults standardUserDefaults] setFloat:_coordinate.latitude forKey:@"mapWindow_latitude"];
    [[NSUserDefaults standardUserDefaults] setFloat:_coordinate.longitude forKey:@"mapWindow_longitude"];
}

- (void) setZoom:(float)zoom
{
    _zoom = zoom;
    [[NSUserDefaults standardUserDefaults] setFloat:_zoom forKey:@"mapWindow_zoom"];
}

- (void) setSatellite:(BOOL)satellite
{
    _satellite = satellite;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:_satellite] forKey:@"satelllite"];
}

- (void) setZoomToPhoto:(BOOL)zoomToPhoto
{
    _zoomToPhoto = zoomToPhoto;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:_zoomToPhoto] forKey:@"zoomToPhoto"];
}

@end
