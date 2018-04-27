//
//  IMMSettingsViewController.m
//  Moonmasons
//
//  Created by Johan Wiig on 09/10/14.
//  Copyright (c) 2014 Innology. All rights reserved.
//

#import "IMMSettingsViewController.h"
#import "IMMInstagramEngine.h"
#import "IMMTwitterEngine.h"
#import "IMMMapSettings.h"
#import "IMMSearchManager.h"

@interface IMMSettingsViewController ()

@property IMMInstagramEngine * instagramEngine;
@property IMMTwitterEngine*  twitterEngine;
@property IMMMapSettings* mapSettings;
@property IMMSearchManager* searchManager;

@end

@implementation IMMSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _instagramEngine = [IMMInstagramEngine sharedInstance];
    _twitterEngine = [IMMTwitterEngine sharedInstance];
    _mapSettings = [IMMMapSettings sharedInstance];
    _searchManager = [IMMSearchManager sharedInstance];

    
    [_instagram setOn:_instagramEngine.enabled animated:true];
    [_twitter setOn:_twitterEngine.enabled animated:true];

    [_satellite setOn:_mapSettings.satellite animated:true];
    [_zoomToPhoto setOn:_mapSettings.zoomToPhoto animated:true];
    
    _radius.minimumValue = 10.0f;
    _radius.maximumValue = 4000.0f;
    _radius.value = _searchManager.currentLocationSearch.radius;
    [_alert setOn:_searchManager.currentLocationSearch.alert animated:true];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)switchInstagram:(id)sender
{
    _instagramEngine.enabled = [sender isOn];
    NSLog(@"Instagram active=%u", _instagramEngine.enabled);
}

- (IBAction)switchTwitter:(id)sender
{
    _twitterEngine.enabled = [sender isOn];
    NSLog(@"Twitter active=%u", _twitterEngine.enabled);
}

- (IBAction)switchSatellite:(id)sender
{
    _mapSettings.satellite = [sender isOn];
}

- (IBAction)switchZoomToPhoto:(id)sender
{
    _mapSettings.zoomToPhoto = [sender isOn];
}

- (IBAction)sliderRadius:(id)sender
{
    _searchManager.currentLocationSearch.radius = [(UISlider*)sender value];
}

- (IBAction)switchAlert:(id)sender
{
    _searchManager.currentLocationSearch.alert = [sender isOn];
}

@end
