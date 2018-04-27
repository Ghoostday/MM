//
//  IMMSearchEngineTest.m
//  Moonmasons
//
//  Created by Johan Wiig on 09/11/14.
//  Copyright (c) 2014 Innology. All rights reserved.
//


#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "IMMSearchEngine.h"
#import "IMMSearchManager.h"
#import "IMMConfigManager.h"

@interface IMMSearchEngineTest : XCTestCase

@property IMMSearchEngine * searchEngine;
@property IMMSearchManager * searchManager;

@end

@implementation IMMSearchEngineTest

IMMSearch * search1;
IMMSearch * search2;
IMMSearch * search3;
IMMSearch * search4;

- (void)setUp
{
    [super setUp];
    _searchEngine = [[IMMSearchEngine alloc] init];
    _searchManager = [IMMSearchManager sharedInstance];
    IMMConfigManager * configManager = [IMMConfigManager sharedInstance];
    
    NSLog(@"server: %@", configManager.config[@"server"]);
    _searchManager.appBase = configManager.config[@"server"];
    
    for (IMMSearch * search in _searchManager.searches)
    {
        search.boost = false;
        [_searchManager update:search];
    }
    
    float radius = 111400.0;
    CLLocationCoordinate2D coordinate;
    
    coordinate.latitude = 0.0;
    coordinate.longitude = 1.0f;
    search1 = [[IMMSearch alloc ]initWithCoordinates:coordinate];
    search1.radius = 100;
    [_searchManager add:search1];
    search1.boost = true;
    [_searchManager update:search1];
    search1.active = false;
    [NSThread sleepForTimeInterval:2.0];
    
    coordinate.latitude = 0.0;
    coordinate.longitude = 0.5f;
    search2 = [[IMMSearch alloc] initWithCoordinates:coordinate];
    search2.radius = 1000;
    [_searchManager add:search2];
    search2.boost = true;
    [_searchManager update:search2];
    search2.active = false;
    [NSThread sleepForTimeInterval:2.0];

    coordinate.latitude = 0.0;
    coordinate.longitude = 0.0f;
    search3 = [[IMMSearch alloc] initWithCoordinates:coordinate];
    search3.radius = 2000;
    [_searchManager add:search3];
    search3.boost = true;
    [_searchManager update:search3];
    search3.active = false;
    [NSThread sleepForTimeInterval:2.0];

    coordinate.latitude = 0.0;
    coordinate.longitude = 0.0f;
    search4 = [[IMMSearch alloc] initWithCoordinates:coordinate];
    search4.boost = false;
    search4.radius = radius;
    search4.active = true;
    [_searchManager add:search4];
}

- (void)tearDown
{
    [_searchManager remove:search1];
    [_searchManager remove:search2];
    [_searchManager remove:search3];
    [_searchManager remove:search4];
    [super tearDown];
}

- (void) testPromotedSearches
{
    NSMutableArray * searches = [_searchManager promotedSearches];
    XCTAssertEqual(searches.count, 3);
    
    XCTAssertEqualWithAccuracy(((IMMSearch*)searches[0]).position.longitude, 0.0, 0.0001);
    XCTAssertEqualWithAccuracy(((IMMSearch*)searches[0]).rank, 0.6, 0.01);
    
    XCTAssertEqualWithAccuracy(((IMMSearch*)searches[1]).position.longitude, 0.5, 0.0001);
    XCTAssertEqualWithAccuracy(((IMMSearch*)searches[1]).rank, 0.4, 0.01);
    
    XCTAssertEqualWithAccuracy(((IMMSearch*)searches[2]).position.longitude, 1.0, 0.0001);
    XCTAssertEqualWithAccuracy(((IMMSearch*)searches[2]).rank, 0.0, 0.01);
}

@end
