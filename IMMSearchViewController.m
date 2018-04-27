//
//  IMMSearchViewController.m
//  Moonmasons
//
//  Created by Johan Wiig on 16/09/14.
//  Copyright (c) 2014 Innology. All rights reserved.
//

#import "IMMSearchViewController.h"
#import "IMMAuthViewController.h"
#import "IMMSearch.h"
#import "IMMSearchResultsTableViewController.h"
#import "IMMSearchManager.h"
#import "IMMMapSettings.h"

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)


@interface IMMSearchViewController ()

@property IMMSearchManager * searchManager;
@property IMMSearch * editSearch;
@property IMMMapSettings * mapSettings;

@end

@implementation IMMSearchViewController


- (void)viewDidLoad
{
    NSLog(@"View did load!");
    [super viewDidLoad];
    
    _mapSettings = [IMMMapSettings sharedInstance];
    _mapView.camera = [GMSCameraPosition cameraWithTarget:_mapSettings.coordinate zoom:_mapSettings.zoom];
    
    _mapView.delegate = self;
    _mapView.myLocationEnabled = YES;
    _mapView.settings.myLocationButton = YES;
    _mapView.settings.compassButton = YES;
    
    _detailsPanel.hidden = true;
    _radius.minimumValue = 10.0f;
    _radius.maximumValue = 4000.0f;

    _searchManager = [IMMSearchManager sharedInstance];

    for (IMMSearch * search in _searchManager.searches)
    {
        NSLog(@"Adding Search lat = %f, lng = %f, radius = %f", search.position.latitude, search.position.longitude, search.radius);
        search.map = _mapView;
    }
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSLog(@"View did viewDidAppear!");
    
    _searchManager.currentLocationSearch.circle.map = _mapView;

    _mapView.mapType = (_mapSettings.satellite) ? kGMSTypeHybrid : kGMSTypeNormal;

    [self hideDetailsPanelWithAnimation:true];

    NSLog(@"_model.searchEnginesEnabled = %ld", _searchManager.searchEnginesEnabled);
    if (_searchManager.searchEnginesEnabled == 0)
    {
        [self performSegueWithIdentifier: @"segueAuthMenu" sender: self];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


//  DETAILS PANEL CALLBACKS
- (IBAction)buttonClose:(id)sender
{
    [self hideDetailsPanelWithAnimation:true];
    _editSearch = nil;
}

- (IBAction)buttonDelete:(id)sender
{
    [_searchManager remove:_editSearch];
    _editSearch.map = nil;
    _editSearch = nil;
    [self hideDetailsPanelWithAnimation:true];
    
}

- (IBAction)sliderRadius:(id)sender
{
    _editSearch.radius = [(UISlider*)sender value];
}

- (IBAction)sliderRadiusRelease:(id)sender
{
    [_searchManager update:_editSearch];
}

- (IBAction)switchActive:(id)sender
{
    _editSearch.active = [sender isOn];
    [_searchManager update:_editSearch];
}

- (IBAction)switchNegative:(id)sender
{
    _editSearch.negative = [sender isOn];
    [_searchManager update:_editSearch];
    [self syncToNegative];
}

- (IBAction)switchAlert:(id)sender
{
    _editSearch.alert = [sender isOn];
    [_searchManager update:_editSearch];
}

- (IBAction)switchBoost:(id)sender
{
    if ([sender isOn])
    {
        int canBoost = [_searchManager canBoost:_editSearch];
        if (canBoost != IMMCanBoostZoneResultYes)
        {
            NSString * message = @"Boost immposible";
            switch (canBoost)
            {
                case IMMCanBoostZoneResultPhotoLimit:
                    message = [NSString stringWithFormat:@"Assurez-vous d'avoir au moins %u photo visible dans les résultats de recherche pour cette zone", _searchManager.photosNeededToBoost];
                    break;

                case IMMCanBoostZoneResultZoneLimit:
                    message = [NSString stringWithFormat:@"Vous avez déjà boosté %u zones", _searchManager.maxBoostZones];
                    break;

                default:
                    break;
            }
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Boost impossible"
                                                            message:message
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            [_boost setOn:false];
            return;
        }
        _editSearch.boost = true;
        [_searchManager update:_editSearch];
    }
    else
    {
        _editSearch.boost = false;
        [_searchManager update:_editSearch];
    }
}

- (void) syncToNegative
{
    if (_editSearch.negative)
    {
        [_alert setOn:NO];
        [_boost setOn:NO];
    }
    [_alert setEnabled:!_editSearch.negative];
    [_boost setEnabled:!_editSearch.negative];
}

//  MAP MANAGEMENT

//  Persist camera position
- (void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)cameraPosition
{
    NSLog(@"Region changed");
    _mapSettings.zoom = cameraPosition.zoom;
    _mapSettings.coordinate = cameraPosition.target;
}

- (BOOL) mapView:(GMSMapView *) mapView didTapMarker:(GMSMarker *)marker
{
    NSLog(@"didTapMarker %@", marker);
    
    [self showDetailsPanel];
    
    _editSearch = (IMMSearch*) marker;
    
    _radius.value = _editSearch.circle.radius;
    [_active setOn:_editSearch.active animated:true];
    [_negative setOn:_editSearch.negative animated:true];
    [_boost setOn:_editSearch.boost animated:true];
    [_alert setOn:_editSearch.alert];
    
    [self syncToNegative];

    
    [_searchManager isBoosted:_editSearch callback:^(BOOL isBoosted)
    {
        dispatch_async(dispatch_get_main_queue(), ^
        {
            NSLog(@"isBoosted = %u", isBoosted);
            [_boost setOn:isBoosted];
        });
     }];

    return YES;
}

- (void) mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    [self hideDetailsPanelWithAnimation:true];
}


- (void) mapView:(GMSMapView *)mapView didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    IMMSearch * search = [[IMMSearch alloc] initWithCoordinates:coordinate];
    [_searchManager add:search];
    search.map = _mapView;
    NSLog(@"click: latitude = %f, longitude = %f, circlecount = %lu", coordinate.latitude, coordinate.longitude, (unsigned long)_searchManager.searches.count);
}


//  DETAIL PANEL ANIMATION
- (void) showDetailsPanel
{
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^
     {
         CGRect newFrame = _detailsPanel.frame;
         CGRect screen = [[UIScreen mainScreen] bounds];
         newFrame.origin.y = screen.size.height - newFrame.size.height;
         _detailsPanel.frame = newFrame;
         _detailsPanel.hidden = false;
         
     } completion:nil];
}

- (void) hideDetailsPanelWithAnimation:(BOOL)animation
{
    CGRect newFrame = _detailsPanel.frame;
    CGRect screen = [[UIScreen mainScreen] bounds];
    newFrame.origin.y = screen.size.height;
    NSLog(@"y = %f", screen.size.height);
    if (animation)
    {
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^
         {
             _detailsPanel.frame = newFrame;
         } completion:^(BOOL b)
            {
                _detailsPanel.hidden = true;
            }];
    }
    else
    {
        _detailsPanel.frame = newFrame;
        _detailsPanel.hidden = true;
    }
}

//  NAVIGATION MANAGEMENT
- (IBAction)unwindToSearchView:(UIStoryboardSegue *)segue
{
    NSLog(@"IMMSearchViewController::unwindToSearchView: %@", segue.identifier);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"IMMSearchViewController::prepareForSegue: %@", segue.identifier);
    [self hideDetailsPanelWithAnimation:true];
}



@end
