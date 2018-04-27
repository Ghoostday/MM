//
//  IMMSearchManagerTest.m
//  Moonmasons
//
//  Created by Johan Wiig on 20/11/14.
//  Copyright (c) 2014 Innology. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Foundation/Foundation.h>
#import "IMMSearchManager.h"

@interface IMMSearchManagerTest : XCTestCase

@property IMMSearchManager * searchManager;

@end

@implementation IMMSearchManagerTest

IMMSearch * search;

- (void)setUp
{
    [super setUp];

    _searchManager = [IMMSearchManager sharedInstance];
    
    IMMPhoto * photo1 = [[IMMPhoto alloc] init];
    photo1.userId = ((IMMProviderEngine*)_searchManager.engines[0]).userId;

    IMMPhoto * photo2 = [[IMMPhoto alloc] init];
    photo2.userId = ((IMMProviderEngine*)_searchManager.engines[0]).userId;

    CLLocationCoordinate2D coordinate;
    search = [[IMMSearch alloc] initWithCoordinates:(CLLocationCoordinate2D)coordinate radius:1000];
    [search.result addObject:photo1];
    [search.result addObject:photo2];
    
    
    [_searchManager add:search];
}

- (void)tearDown
{
    [_searchManager remove:search];
    [super tearDown];
}

- (void) testCanBoostPhoto
{
    _searchManager.photosNeededToBoost = 1;
    XCTAssertEqual([_searchManager canBoost:search], IMMCanBoostZoneResultYes);

    _searchManager.photosNeededToBoost = 2;
    XCTAssertEqual([_searchManager canBoost:search], IMMCanBoostZoneResultYes);

    _searchManager.photosNeededToBoost = 3;
    XCTAssertEqual([_searchManager canBoost:search], IMMCanBoostZoneResultPhotoLimit);
}

@end