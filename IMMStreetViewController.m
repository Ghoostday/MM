//
//  IMMStreetViewController.m
//  Moonmasons
//
//  Created by Johan Wiig on 23/10/14.
//  Copyright (c) 2014 Innology. All rights reserved.
//

#import "IMMStreetViewController.h"
#import "IMMMapSettings.h"
#import <QuartzCore/QuartzCore.h>

@interface IMMStreetViewController ()

@property IMMMapSettings * mapSettings;

@end

@implementation IMMStreetViewController

GMSPanoramaView * streetView;
GMSMapView * mapView;
GMSMarker * marker;
float bearingFromStreetToPhoto;

static bool showStreetView = false;
static bool didZoomToPhoto = false;



- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"Opening street view for lat = %f, lng = %f", _coordinate.latitude, _coordinate.longitude);
    didZoomToPhoto = false;

    _mapSettings = [IMMMapSettings sharedInstance];

    streetView = [GMSPanoramaView panoramaWithFrame:CGRectZero nearCoordinate:_coordinate];
    streetView.delegate = self;
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithTarget:_mapSettings.coordinate zoom:_mapSettings.zoom];
    mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    mapView.myLocationEnabled = YES;
    mapView.settings.myLocationButton = YES;
    mapView.settings.compassButton = YES;
    mapView.mapType = (_mapSettings.satellite) ? kGMSTypeHybrid : kGMSTypeNormal;

    marker = [[GMSMarker alloc] init];
    marker.position = _coordinate;
    marker.appearAnimation = kGMSMarkerAnimationPop;
    marker.icon = [UIImage imageNamed:@"pin-photo.png"];
    marker.map = mapView;
    
    self.view = mapView;
}

- (void) panoramaView:(GMSPanoramaView *)view
    didMoveToPanorama:(GMSPanorama *)panorama
       nearCoordinate:(CLLocationCoordinate2D)coordinate
{
    NSLog(@"didMoveToPanorama");
    
    if (!didZoomToPhoto)
    {
        didZoomToPhoto = true;

        [streetView moveNearCoordinate:_coordinate];
        bearingFromStreetToPhoto = [self headingFromCoordinate:panorama.coordinate toCoordinate:_coordinate];
        streetView.camera = [GMSPanoramaCamera cameraWithHeading:bearingFromStreetToPhoto pitch:0.0f zoom:1.0f];
        
        if (true)
        {
            [CATransaction begin];
            [CATransaction setAnimationDuration: 0.5f];
            [CATransaction setValue:^
             {
                 [CATransaction begin];
                 [CATransaction setAnimationDuration: 1.5f];
                 [mapView animateToZoom:18.0f];
                 [mapView animateToBearing:bearingFromStreetToPhoto];
                 [mapView animateToViewingAngle:45.0f];
                 [CATransaction commit];
                 
             } forKey:kCATransactionCompletionBlock];
            [mapView animateToLocation:_coordinate];
            [CATransaction commit];
        }
    }
}

- (IBAction)buttonStreetViewToggle:(id)sender
{
    showStreetView = !showStreetView;
    [_buttonStreetView setTitle: (showStreetView ? @"Plan" : @"Street View") forState: UIControlStateNormal];
    
    if (showStreetView)
    {
        [CATransaction begin];
        [CATransaction setAnimationDuration: 0.5f];
        [CATransaction setValue:^
         {
             self.view = streetView;
         } forKey:kCATransactionCompletionBlock];
        [mapView animateToZoom:25.0f];
        [CATransaction commit];
    }
    else
    {
        self.view = mapView;
        [CATransaction begin];
        [CATransaction setAnimationDuration: 0.5f];
        [mapView animateToZoom:18.0f];
        [CATransaction commit];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#define degreesToRadians(x) (M_PI * x / 180.0)
#define radiandsToDegrees(x) (x * 180.0 / M_PI)

- (float)headingFromCoordinate:(CLLocationCoordinate2D)fromLoc toCoordinate:(CLLocationCoordinate2D)toLoc
{
    float fLat = degreesToRadians(fromLoc.latitude);
    float fLng = degreesToRadians(fromLoc.longitude);
    float tLat = degreesToRadians(toLoc.latitude);
    float tLng = degreesToRadians(toLoc.longitude);
    
    float degree = radiandsToDegrees(atan2(sin(tLng-fLng)*cos(tLat), cos(fLat)*sin(tLat)-sin(fLat)*cos(tLat)*cos(tLng-fLng)));
    
    if (degree >= 0) {
        NSLog(@"From lat = %f, lng = %f to lat = %f, lng = %f => heading = %f", fromLoc.latitude, fromLoc.longitude, toLoc.latitude, toLoc.longitude, degree);
        return degree;
    } else {
        NSLog(@"From lat = %f, lng = %f to lat = %f, lng = %f => heading = %f", fromLoc.latitude, fromLoc.longitude, toLoc.latitude, toLoc.longitude, degree+360);
        return 360+degree;
    }
}

@end
