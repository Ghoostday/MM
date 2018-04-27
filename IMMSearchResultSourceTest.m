//
//  IMMSearchResultSourceTest.m
//  Moonmasons
//
//  Created by Johan Wiig on 11/11/14.
//  Copyright (c) 2014 Innology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "IMMSearchResultSource.h"
#import "IMMSearchManagerMock.h"
#import "IMMSearchEngineMock.h"
#import "IMMTableViewMock.h"
#import "IMMPhotoManagerMock.h"

@interface IMMSearchResultSourceTest : XCTestCase

@property IMMSearchManagerMock * searchManagerMock;
@property IMMPhotoManagerMock * photoManagerMock;
@property IMMSearchEngineMock * searchEngineMock;
@property IMMTableViewMock * tableViewMock;
@property IMMSearchResultSource * source;

@end

@implementation IMMSearchResultSourceTest

- (void)setUp
{
    [super setUp];
    
    _searchManagerMock = [[IMMSearchManagerMock alloc] init];
    _photoManagerMock = [[IMMPhotoManagerMock alloc] init];
    _searchEngineMock = [[IMMSearchEngineMock alloc] init];
    _tableViewMock = [[IMMTableViewMock alloc] init];
}

- (void)tearDown
{

    [super tearDown];
}

- (NSMutableArray*) organicPhotos
{
    NSMutableArray * organicPhotos = [[NSMutableArray alloc] init];
    
    IMMPhoto * organicPhoto1 = [[IMMPhoto alloc] init];
    organicPhoto1.url = [NSURL URLWithString:@"//o1"];
    organicPhoto1.date = [[NSDate alloc] init];
    [organicPhotos addObject:organicPhoto1];
    
    IMMPhoto * organicPhoto2 = [[IMMPhoto alloc] init];
    organicPhoto2.url = [NSURL URLWithString:@"//o2"];
    organicPhoto2.date = [[NSDate alloc] init];
    [organicPhotos addObject:organicPhoto2];
    
    IMMPhoto * organicPhoto3 = [[IMMPhoto alloc] init];
    organicPhoto3.url = [NSURL URLWithString:@"//o3"];
    organicPhoto3.date = [[NSDate alloc] init];
    [organicPhotos addObject:organicPhoto3];
    
    return organicPhotos;
}

- (NSMutableArray*) boostedPhotos
{
    NSMutableArray * boostedPhotos = [[NSMutableArray alloc] init];
    
    IMMPhoto * boostedPhoto1 = [[IMMPhoto alloc] init];
    boostedPhoto1.url = [NSURL URLWithString:@"//b1"];
    boostedPhoto1.date = [[NSDate alloc] init];
    boostedPhoto1.boost = 1;
    boostedPhoto1.rank = 1;
    [boostedPhotos addObject:boostedPhoto1];
    
    IMMPhoto * boostedPhoto2 = [[IMMPhoto alloc] init];
    boostedPhoto2.url = [NSURL URLWithString:@"//b2"];
    boostedPhoto2.date = [[NSDate alloc] init];
    boostedPhoto2.boost = 1;
    boostedPhoto2.rank = 1;
    [boostedPhotos addObject:boostedPhoto2];
    
    IMMPhoto * boostedPhoto3 = [[IMMPhoto alloc] init];
    boostedPhoto3.url = [NSURL URLWithString:@"//b3"];
    boostedPhoto3.date = [[NSDate alloc] init];
    boostedPhoto3.boost = 1;
    boostedPhoto3.rank = 1;
    [boostedPhotos addObject:boostedPhoto3];
    
    return boostedPhotos;
}

- (NSMutableArray*) allSearches
{
    NSMutableArray * allSearches = [[NSMutableArray alloc] init];
    CLLocationCoordinate2D coordinate;
    
    coordinate.latitude = 0.0;
    coordinate.longitude = 0.0;
    IMMSearch * allSearch1 = [[IMMSearch alloc] initWithCoordinates:coordinate];
    allSearch1.radius = 111400.0;
    [allSearches addObject:allSearch1];
    
    return allSearches;
}

- (NSMutableArray*) promotedSearches
{
    NSMutableArray * allSearches = [[NSMutableArray alloc] init];
    CLLocationCoordinate2D coordinate;
    
    coordinate.latitude = 0.0;
    coordinate.longitude = 0.0;
    IMMSearch * allSearch1 = [[IMMSearch alloc] initWithCoordinates:coordinate];
    allSearch1.radius = 111400.0;
    allSearch1.rank = 1.0;
    [allSearches addObject:allSearch1];
    
    return allSearches;
}


//  RESULT RANKING
- (void)testOrganic
{
    _searchEngineMock.organicPhotosMock = [self organicPhotos];
    _searchManagerMock.promotedSearchesMock = [[NSMutableArray alloc] init];
    _searchManagerMock.allSearchesMock = [[NSMutableArray alloc] init];

    
    _source = [[IMMSearchResultSource alloc] initWithSearchEngine:_searchEngineMock searchManager:_searchManagerMock photoManager:_photoManagerMock];
    NSMutableDictionary * result = [_source result];
    
    XCTAssertEqual([((IMMPhoto*)result[@"organic"][0]).url absoluteString], @"//o1");
    XCTAssertEqual([((IMMPhoto*)result[@"organic"][1]).url absoluteString], @"//o2");
    XCTAssertEqual([((IMMPhoto*)result[@"organic"][2]).url absoluteString], @"//o3");
}

- (void)testBoosted
{
    _photoManagerMock.boostedPhotosMock = [self boostedPhotos];
    ((IMMPhoto*)_photoManagerMock.boostedPhotosMock[0]).boost = 3;
    ((IMMPhoto*)_photoManagerMock.boostedPhotosMock[1]).boost = 2;
    ((IMMPhoto*)_photoManagerMock.boostedPhotosMock[2]).boost = 1;

    _searchEngineMock.organicPhotosMock = [[NSMutableArray alloc] init];
    _searchManagerMock.promotedSearchesMock = [[NSMutableArray alloc] init];
    _searchManagerMock.allSearchesMock = [self allSearches];
    
    
    
    _source = [[IMMSearchResultSource alloc] initWithSearchEngine:_searchEngineMock searchManager:_searchManagerMock photoManager:_photoManagerMock];
    NSMutableDictionary * result = [_source result];

    XCTAssertEqual([((IMMPhoto*)result[@"promoted"][0]).url absoluteString], @"//b1");
    XCTAssertEqual([((IMMPhoto*)result[@"promoted"][1]).url absoluteString], @"//b2");
    XCTAssertEqual([((IMMPhoto*)result[@"promoted"][2]).url absoluteString], @"//b3");
    
    XCTAssertEqualWithAccuracy(((IMMPhoto*)result[@"promoted"][0]).rank, 1.0, 0.01);
    XCTAssertEqualWithAccuracy(((IMMPhoto*)result[@"promoted"][1]).rank, 1.0, 0.01);
    XCTAssertEqualWithAccuracy(((IMMPhoto*)result[@"promoted"][2]).rank, 1.0, 0.01);
}

- (void)testOrganicPromoted
{
    _photoManagerMock.boostedPhotosMock = [[NSMutableArray alloc] init];
    _searchEngineMock.organicPhotosMock = [self organicPhotos];
    _searchManagerMock.promotedSearchesMock = [self promotedSearches];
    _searchManagerMock.allSearchesMock = [[NSMutableArray alloc] init];
    
    
    
    _source = [[IMMSearchResultSource alloc] initWithSearchEngine:_searchEngineMock searchManager:_searchManagerMock photoManager:_photoManagerMock];
    NSMutableDictionary * result = [_source result];
    
    XCTAssertEqual([((IMMPhoto*)result[@"promoted"][0]).url absoluteString], @"//o1");
    XCTAssertEqual([((IMMPhoto*)result[@"promoted"][1]).url absoluteString], @"//o2");
    XCTAssertEqual([((IMMPhoto*)result[@"promoted"][2]).url absoluteString], @"//o3");
    
    XCTAssertEqualWithAccuracy(((IMMPhoto*)result[@"promoted"][0]).rank, 1.0, 0.01);
    XCTAssertEqualWithAccuracy(((IMMPhoto*)result[@"promoted"][1]).rank, 1.0, 0.01);
    XCTAssertEqualWithAccuracy(((IMMPhoto*)result[@"promoted"][1]).rank, 1.0, 0.01);
}

- (void)testBoostedOrganicPromoted
{
    _photoManagerMock.boostedPhotosMock = [self boostedPhotos];
    _searchEngineMock.organicPhotosMock = [self organicPhotos];
    _searchManagerMock.promotedSearchesMock = [self promotedSearches];
    _searchManagerMock.allSearchesMock = [self allSearches];
    
    
    
    _source = [[IMMSearchResultSource alloc] initWithSearchEngine:_searchEngineMock searchManager:_searchManagerMock photoManager:_photoManagerMock];
    NSMutableDictionary * result = [_source result];
    
    XCTAssertEqual([((IMMPhoto*)result[@"organic"][0]).url absoluteString], @"//o1");
    XCTAssertEqual([((IMMPhoto*)result[@"organic"][1]).url absoluteString], @"//o2");
    XCTAssertEqual([((IMMPhoto*)result[@"organic"][2]).url absoluteString], @"//o3");

    XCTAssertEqual([((IMMPhoto*)result[@"promoted"][0]).url absoluteString], @"//b1");
    XCTAssertEqual([((IMMPhoto*)result[@"promoted"][1]).url absoluteString], @"//b2");
    XCTAssertEqual([((IMMPhoto*)result[@"promoted"][2]).url absoluteString], @"//b3");
    
    XCTAssertEqualWithAccuracy(((IMMPhoto*)result[@"promoted"][0]).rank, 2.0, 0.01);
    XCTAssertEqualWithAccuracy(((IMMPhoto*)result[@"promoted"][1]).rank, 2.0, 0.01);
    XCTAssertEqualWithAccuracy(((IMMPhoto*)result[@"promoted"][2]).rank, 2.0, 0.01);
}

- (void)testBoostedOrganicPromoted2
{
    _photoManagerMock.boostedPhotosMock = [self boostedPhotos];
    [_photoManagerMock.boostedPhotosMock removeObjectAtIndex:2];
    _searchEngineMock.organicPhotosMock = [self organicPhotos];
    _searchManagerMock.promotedSearchesMock = [self promotedSearches];
    _searchManagerMock.allSearchesMock = [self allSearches];
    
    
    
    _source = [[IMMSearchResultSource alloc] initWithSearchEngine:_searchEngineMock searchManager:_searchManagerMock photoManager:_photoManagerMock];
    NSMutableDictionary * result = [_source result];
    
    XCTAssertEqual([((IMMPhoto*)result[@"organic"][0]).url absoluteString], @"//o2");
    XCTAssertEqual([((IMMPhoto*)result[@"organic"][1]).url absoluteString], @"//o3");
    
    XCTAssertEqual([((IMMPhoto*)result[@"promoted"][0]).url absoluteString], @"//b1");
    XCTAssertEqual([((IMMPhoto*)result[@"promoted"][1]).url absoluteString], @"//b2");
    XCTAssertEqual([((IMMPhoto*)result[@"promoted"][2]).url absoluteString], @"//o1");
    
    XCTAssertEqualWithAccuracy(((IMMPhoto*)result[@"promoted"][0]).rank, 2.0, 0.01);
    XCTAssertEqualWithAccuracy(((IMMPhoto*)result[@"promoted"][1]).rank, 2.0, 0.01);
    XCTAssertEqualWithAccuracy(((IMMPhoto*)result[@"promoted"][2]).rank, 1.0, 0.01);
}

//  LIST MAINTENANCE
- (void) testAddPromoted
{
    _photoManagerMock.boostedPhotosMock = [self boostedPhotos];
    _searchEngineMock.organicPhotosMock = [[NSMutableArray alloc] init];
    _searchManagerMock.promotedSearchesMock = [[NSMutableArray alloc] init];
    _searchManagerMock.allSearchesMock = [self allSearches];
    _source = [[IMMSearchResultSource alloc] initWithSearchEngine:_searchEngineMock searchManager:_searchManagerMock photoManager:_photoManagerMock];
    NSMutableDictionary * result = [_source result];
    [_source addPromoted:result[@"promoted"] to:_tableViewMock];
    
    XCTAssertEqual(((NSMutableArray*)_source.promotedList).count, 3);
    XCTAssertEqual(((NSMutableArray*)_source.organicList).count, 0);
    XCTAssertEqual([((IMMPhoto*)_source.promotedList[0]).url absoluteString], @"//b1");
    XCTAssertEqual([((IMMPhoto*)_source.promotedList[1]).url absoluteString], @"//b2");
    XCTAssertEqual([((IMMPhoto*)_source.promotedList[2]).url absoluteString], @"//b3");
    XCTAssertEqual(((NSMutableArray*)_tableViewMock.insertRows).count, 3);
    XCTAssertEqual(((NSMutableArray*)_tableViewMock.deleteRows).count, 0);
    XCTAssertEqual([IMMTableViewMock getLastIndex:0 fromArray:_tableViewMock.insertRows], 0);
    XCTAssertEqual([IMMTableViewMock getLastIndex:1 fromArray:_tableViewMock.insertRows], 1);
    XCTAssertEqual([IMMTableViewMock getLastIndex:2 fromArray:_tableViewMock.insertRows], 2);
    
    
    
    _tableViewMock.insertRows = [[NSMutableArray alloc] init];
    _tableViewMock.deleteRows = [[NSMutableArray alloc] init];
    _photoManagerMock.boostedPhotosMock = [self boostedPhotos];
    ((IMMPhoto*)_photoManagerMock.boostedPhotosMock[0]).url = [NSURL URLWithString:@"//b4"];
    ((IMMPhoto*)_photoManagerMock.boostedPhotosMock[1]).url = [NSURL URLWithString:@"//b5"];
    ((IMMPhoto*)_photoManagerMock.boostedPhotosMock[2]).url = [NSURL URLWithString:@"//b6"];
    result = [_source result];
    [_source addPromoted:result[@"promoted"] to:_tableViewMock];
    XCTAssertEqual(((NSMutableArray*)_source.promotedList).count, 3);
    XCTAssertEqual(((NSMutableArray*)_source.organicList).count, 0);
    XCTAssertEqual([((IMMPhoto*)_source.promotedList[0]).url absoluteString], @"//b4");
    XCTAssertEqual([((IMMPhoto*)_source.promotedList[1]).url absoluteString], @"//b5");
    XCTAssertEqual([((IMMPhoto*)_source.promotedList[2]).url absoluteString], @"//b6");
    XCTAssertEqual(((NSMutableArray*)_tableViewMock.insertRows).count, 3);
    XCTAssertEqual(((NSMutableArray*)_tableViewMock.deleteRows).count, 3);
    XCTAssertEqual([IMMTableViewMock getLastIndex:0 fromArray:_tableViewMock.insertRows], 0);
    XCTAssertEqual([IMMTableViewMock getLastIndex:1 fromArray:_tableViewMock.insertRows], 1);
    XCTAssertEqual([IMMTableViewMock getLastIndex:2 fromArray:_tableViewMock.insertRows], 2);
    XCTAssertEqual([IMMTableViewMock getLastIndex:0 fromArray:_tableViewMock.deleteRows], 0);
    XCTAssertEqual([IMMTableViewMock getLastIndex:1 fromArray:_tableViewMock.deleteRows], 1);
    XCTAssertEqual([IMMTableViewMock getLastIndex:2 fromArray:_tableViewMock.deleteRows], 2);
    
    
    
    _tableViewMock.insertRows = [[NSMutableArray alloc] init];
    _tableViewMock.deleteRows = [[NSMutableArray alloc] init];
    _photoManagerMock.boostedPhotosMock = [self boostedPhotos];
    ((IMMPhoto*)_photoManagerMock.boostedPhotosMock[0]).url = [NSURL URLWithString:@"//b7"];
    [_photoManagerMock.boostedPhotosMock removeObjectAtIndex:2];
    [_photoManagerMock.boostedPhotosMock removeObjectAtIndex:1];
    result = [_source result];
    [_source addPromoted:result[@"promoted"] to:_tableViewMock];
    XCTAssertEqual(((NSMutableArray*)_source.promotedList).count, 1);
    XCTAssertEqual(((NSMutableArray*)_source.organicList).count, 0);
    XCTAssertEqual([((IMMPhoto*)_source.promotedList[0]).url absoluteString], @"//b7");
    XCTAssertEqual(((NSMutableArray*)_tableViewMock.insertRows).count, 1);
    XCTAssertEqual(((NSMutableArray*)_tableViewMock.deleteRows).count, 3);
    XCTAssertEqual([IMMTableViewMock getLastIndex:0 fromArray:_tableViewMock.insertRows], 0);
    XCTAssertEqual([IMMTableViewMock getLastIndex:0 fromArray:_tableViewMock.deleteRows], 0);
    XCTAssertEqual([IMMTableViewMock getLastIndex:1 fromArray:_tableViewMock.deleteRows], 1);
    XCTAssertEqual([IMMTableViewMock getLastIndex:2 fromArray:_tableViewMock.deleteRows], 2);



    _tableViewMock.insertRows = [[NSMutableArray alloc] init];
    _tableViewMock.deleteRows = [[NSMutableArray alloc] init];
    _photoManagerMock.boostedPhotosMock = [[NSMutableArray alloc] init];
    result = [_source result];
    [_source addPromoted:result[@"promoted"] to:_tableViewMock];
    XCTAssertEqual(((NSMutableArray*)_source.promotedList).count, 0);
    XCTAssertEqual(((NSMutableArray*)_source.organicList).count, 0);
    XCTAssertEqual(((NSMutableArray*)_tableViewMock.insertRows).count, 0);
    XCTAssertEqual(((NSMutableArray*)_tableViewMock.deleteRows).count, 1);
    XCTAssertEqual([IMMTableViewMock getLastIndex:0 fromArray:_tableViewMock.deleteRows], 0);
}

- (void) testAddTruncateRemoveOrganic
{
    _photoManagerMock.boostedPhotosMock = [[NSMutableArray alloc] init];
    _searchEngineMock.organicPhotosMock = [self organicPhotos];
    _searchManagerMock.promotedSearchesMock = [[NSMutableArray alloc] init];
    _searchManagerMock.allSearchesMock = [[NSMutableArray alloc] init];
    _source = [[IMMSearchResultSource alloc] initWithSearchEngine:_searchEngineMock searchManager:_searchManagerMock photoManager:_photoManagerMock];
    NSMutableDictionary * result = [_source result];
    [_source addOrganic:result[@"organic"] to:_tableViewMock];
    
    XCTAssertEqual(((NSMutableArray*)_source.promotedList).count, 0);
    XCTAssertEqual(((NSMutableArray*)_source.organicList).count, 3);
    XCTAssertEqual([((IMMPhoto*)_source.organicList[0]).url absoluteString], @"//o1");
    XCTAssertEqual([((IMMPhoto*)_source.organicList[1]).url absoluteString], @"//o2");
    XCTAssertEqual([((IMMPhoto*)_source.organicList[2]).url absoluteString], @"//o3");
    XCTAssertEqual(((NSMutableArray*)_tableViewMock.insertRows).count, 3);
    XCTAssertEqual(((NSMutableArray*)_tableViewMock.deleteRows).count, 0);
    XCTAssertEqual([IMMTableViewMock getLastIndex:0 fromArray:_tableViewMock.insertRows], 0);
    XCTAssertEqual([IMMTableViewMock getLastIndex:1 fromArray:_tableViewMock.insertRows], 1);
    XCTAssertEqual([IMMTableViewMock getLastIndex:2 fromArray:_tableViewMock.insertRows], 2);
    
    
    
    _tableViewMock.insertRows = [[NSMutableArray alloc] init];
    _tableViewMock.deleteRows = [[NSMutableArray alloc] init];
    _searchEngineMock.organicPhotosMock = [self organicPhotos];
    result = [_source result];
    [_source addOrganic:result[@"organic"] to:_tableViewMock];
    XCTAssertEqual(((NSMutableArray*)_source.promotedList).count, 0);
    XCTAssertEqual(((NSMutableArray*)_source.organicList).count, 6);
    XCTAssertEqual([((IMMPhoto*)_source.organicList[0]).url absoluteString], @"//o1");
    XCTAssertEqual([((IMMPhoto*)_source.organicList[1]).url absoluteString], @"//o2");
    XCTAssertEqual([((IMMPhoto*)_source.organicList[2]).url absoluteString], @"//o3");
    XCTAssertEqual([((IMMPhoto*)_source.organicList[3]).url absoluteString], @"//o1");
    XCTAssertEqual([((IMMPhoto*)_source.organicList[4]).url absoluteString], @"//o2");
    XCTAssertEqual([((IMMPhoto*)_source.organicList[5]).url absoluteString], @"//o3");
    XCTAssertEqual(((NSMutableArray*)_tableViewMock.insertRows).count, 3);
    XCTAssertEqual(((NSMutableArray*)_tableViewMock.deleteRows).count, 0);
    XCTAssertEqual([IMMTableViewMock getLastIndex:0 fromArray:_tableViewMock.insertRows], 0);
    XCTAssertEqual([IMMTableViewMock getLastIndex:1 fromArray:_tableViewMock.insertRows], 1);
    XCTAssertEqual([IMMTableViewMock getLastIndex:2 fromArray:_tableViewMock.insertRows], 2);
    
    
    
    _tableViewMock.insertRows = [[NSMutableArray alloc] init];
    _tableViewMock.deleteRows = [[NSMutableArray alloc] init];
    [_source truncateOrganic:_tableViewMock limit:4];
    XCTAssertEqual(((NSMutableArray*)_source.promotedList).count, 0);
    XCTAssertEqual(((NSMutableArray*)_source.organicList).count, 4);
    XCTAssertEqual([((IMMPhoto*)_source.organicList[0]).url absoluteString], @"//o1");
    XCTAssertEqual([((IMMPhoto*)_source.organicList[1]).url absoluteString], @"//o2");
    XCTAssertEqual([((IMMPhoto*)_source.organicList[2]).url absoluteString], @"//o3");
    XCTAssertEqual([((IMMPhoto*)_source.organicList[3]).url absoluteString], @"//o1");
    XCTAssertEqual(((NSMutableArray*)_tableViewMock.insertRows).count, 0);
    XCTAssertEqual(((NSMutableArray*)_tableViewMock.deleteRows).count, 2);
    XCTAssertEqual([IMMTableViewMock getLastIndex:0 fromArray:_tableViewMock.deleteRows], 4);
    XCTAssertEqual([IMMTableViewMock getLastIndex:1 fromArray:_tableViewMock.deleteRows], 5);



    _tableViewMock.insertRows = [[NSMutableArray alloc] init];
    _tableViewMock.deleteRows = [[NSMutableArray alloc] init];
    [_source removeOrganic:result[@"organic"][1] from:_tableViewMock];
    XCTAssertEqual(((NSMutableArray*)_source.promotedList).count, 0);
    XCTAssertEqual(((NSMutableArray*)_source.organicList).count, 3);
    XCTAssertEqual([((IMMPhoto*)_source.organicList[0]).url absoluteString], @"//o1");
    XCTAssertEqual([((IMMPhoto*)_source.organicList[1]).url absoluteString], @"//o3");
    XCTAssertEqual([((IMMPhoto*)_source.organicList[2]).url absoluteString], @"//o1");
    XCTAssertEqual(((NSMutableArray*)_tableViewMock.insertRows).count, 0);
    XCTAssertEqual(((NSMutableArray*)_tableViewMock.deleteRows).count, 1);
    XCTAssertEqual([IMMTableViewMock getLastIndex:0 fromArray:_tableViewMock.deleteRows], 1);
}

- (void)testAddRemoveBoost
{
    _photoManagerMock.boostedPhotosMock = [[NSMutableArray alloc] init];
    _searchEngineMock.organicPhotosMock = [self organicPhotos];
    _searchManagerMock.promotedSearchesMock = [[NSMutableArray alloc] init];
    _searchManagerMock.allSearchesMock = [self allSearches];
    _source = [[IMMSearchResultSource alloc] initWithSearchEngine:_searchEngineMock searchManager:_searchManagerMock photoManager:_photoManagerMock];
    
    
    
    NSMutableDictionary * result = [_source result];
    [_source update:nil result:result];
    XCTAssertEqual(((NSMutableArray*)_source.promotedList).count, 0);
    XCTAssertEqual(((NSMutableArray*)_source.organicList).count, 3);
    XCTAssertEqual([((IMMPhoto*)_source.organicList[0]).url absoluteString], @"//o1");
    XCTAssertEqual([((IMMPhoto*)_source.organicList[1]).url absoluteString], @"//o2");
    XCTAssertEqual([((IMMPhoto*)_source.organicList[2]).url absoluteString], @"//o3");
    XCTAssertEqualWithAccuracy(((IMMPhoto*)_source.organicList[0]).rank, 0.0, 0.01);
    XCTAssertEqualWithAccuracy(((IMMPhoto*)_source.organicList[1]).rank, 0.0, 0.01);
    XCTAssertEqualWithAccuracy(((IMMPhoto*)_source.organicList[2]).rank, 0.0, 0.01);

    IMMPhoto * boostedPhoto1 = [[IMMPhoto alloc] init];
    boostedPhoto1.url = [NSURL URLWithString:@"//o1"];
    boostedPhoto1.date = [[NSDate alloc] init];
    boostedPhoto1.boost = 1;
    boostedPhoto1.rank = 1;
    [_photoManagerMock.boostedPhotosMock addObject:boostedPhoto1];
    _searchEngineMock.organicPhotosMock = [[NSMutableArray alloc] init];
    result = [_source result];
    [_source update:nil result:result];
    XCTAssertEqual(((NSMutableArray*)_source.promotedList).count, 1);
    XCTAssertEqual(((NSMutableArray*)_source.organicList).count, 2);
    XCTAssertEqual([((IMMPhoto*)_source.promotedList[0]).url absoluteString], @"//o1");
    XCTAssertEqual([((IMMPhoto*)_source.organicList[0]).url absoluteString], @"//o2");
    XCTAssertEqual([((IMMPhoto*)_source.organicList[1]).url absoluteString], @"//o3");
    XCTAssertEqualWithAccuracy(((IMMPhoto*)_source.promotedList[0]).rank, 1.0, 0.01);
    XCTAssertEqualWithAccuracy(((IMMPhoto*)_source.organicList[0]).rank, 0.0, 0.01);
    XCTAssertEqualWithAccuracy(((IMMPhoto*)_source.organicList[1]).rank, 0.0, 0.01);

    IMMPhoto * boostedPhoto2 = [[IMMPhoto alloc] init];
    boostedPhoto2.url = [NSURL URLWithString:@"//o2"];
    boostedPhoto2.date = [[NSDate alloc] init];
    boostedPhoto2.boost = 2;
    boostedPhoto2.rank = 2;
    [_photoManagerMock.boostedPhotosMock addObject:boostedPhoto2];
    result = [_source result];
    [_source update:nil result:result];
    XCTAssertEqual(((NSMutableArray*)_source.promotedList).count, 2);
    XCTAssertEqual(((NSMutableArray*)_source.organicList).count, 1);
    XCTAssertEqual([((IMMPhoto*)_source.promotedList[0]).url absoluteString], @"//o2");
    XCTAssertEqual([((IMMPhoto*)_source.promotedList[1]).url absoluteString], @"//o1");
    XCTAssertEqual([((IMMPhoto*)_source.organicList[0]).url absoluteString], @"//o3");
    XCTAssertEqualWithAccuracy(((IMMPhoto*)_source.promotedList[0]).rank, 2.0, 0.01);
    XCTAssertEqualWithAccuracy(((IMMPhoto*)_source.promotedList[1]).rank, 1.0, 0.01);
    XCTAssertEqualWithAccuracy(((IMMPhoto*)_source.organicList[0]).rank, 0.0, 0.01);

    [_photoManagerMock.boostedPhotosMock removeObjectAtIndex:1];
    result = [_source result];
    [_source update:nil result:result];
    XCTAssertEqual(((NSMutableArray*)_source.promotedList).count, 1);
    XCTAssertEqual(((NSMutableArray*)_source.organicList).count, 1);
    XCTAssertEqual([((IMMPhoto*)_source.promotedList[0]).url absoluteString], @"//o1");
    XCTAssertEqual([((IMMPhoto*)_source.organicList[0]).url absoluteString], @"//o3");
    XCTAssertEqualWithAccuracy(((IMMPhoto*)_source.promotedList[0]).rank, 1.0, 0.01);
    XCTAssertEqualWithAccuracy(((IMMPhoto*)_source.organicList[0]).rank, 0.0, 0.01);
    
    [_photoManagerMock.boostedPhotosMock removeObjectAtIndex:0];
    result = [_source result];
    [_source update:nil result:result];
    XCTAssertEqual(((NSMutableArray*)_source.promotedList).count, 0);
    XCTAssertEqual(((NSMutableArray*)_source.organicList).count, 1);
    XCTAssertEqual([((IMMPhoto*)_source.organicList[0]).url absoluteString], @"//o3");
    XCTAssertEqualWithAccuracy(((IMMPhoto*)_source.organicList[0]).rank, 0.0, 0.01);
}

- (void)testAddRemovePromoted
{
    _photoManagerMock.boostedPhotosMock = [[NSMutableArray alloc] init];
    _searchManagerMock.promotedSearchesMock = [[NSMutableArray alloc] init];
    _searchManagerMock.allSearchesMock = [self allSearches];
    _source = [[IMMSearchResultSource alloc] initWithSearchEngine:_searchEngineMock searchManager:_searchManagerMock photoManager:_photoManagerMock];

    _searchEngineMock.organicPhotosMock = [self organicPhotos];
    IMMPhoto * organicPhoto1 = [[IMMPhoto alloc] init];
    organicPhoto1.url = [NSURL URLWithString:@"//o4"];
    organicPhoto1.date = [[NSDate alloc] init];
    [_searchEngineMock.organicPhotosMock addObject:organicPhoto1];
    
    
    
    NSMutableDictionary * result = [_source result];
    [_source update:nil result:result];
    XCTAssertEqual(((NSMutableArray*)_source.promotedList).count, 0);
    XCTAssertEqual(((NSMutableArray*)_source.organicList).count, 4);
    XCTAssertEqual([((IMMPhoto*)_source.organicList[0]).url absoluteString], @"//o1");
    XCTAssertEqual([((IMMPhoto*)_source.organicList[1]).url absoluteString], @"//o2");
    XCTAssertEqual([((IMMPhoto*)_source.organicList[2]).url absoluteString], @"//o3");
    XCTAssertEqual([((IMMPhoto*)_source.organicList[3]).url absoluteString], @"//o4");
    XCTAssertEqualWithAccuracy(((IMMPhoto*)_source.organicList[0]).rank, 0.0, 0.01);
    XCTAssertEqualWithAccuracy(((IMMPhoto*)_source.organicList[1]).rank, 0.0, 0.01);
    XCTAssertEqualWithAccuracy(((IMMPhoto*)_source.organicList[2]).rank, 0.0, 0.01);
    XCTAssertEqualWithAccuracy(((IMMPhoto*)_source.organicList[3]).rank, 0.0, 0.01);
    
    _searchManagerMock.promotedSearchesMock = [self promotedSearches];
    _searchEngineMock.organicPhotosMock = [[NSMutableArray alloc] init];
    result = [_source result];
    [_source update:nil result:result];
    XCTAssertEqual(((NSMutableArray*)_source.promotedList).count, 3);
    XCTAssertEqual(((NSMutableArray*)_source.organicList).count, 1);
    XCTAssertEqual([((IMMPhoto*)_source.promotedList[0]).url absoluteString], @"//o1");
    XCTAssertEqual([((IMMPhoto*)_source.promotedList[1]).url absoluteString], @"//o2");
    XCTAssertEqual([((IMMPhoto*)_source.promotedList[2]).url absoluteString], @"//o3");
    XCTAssertEqual([((IMMPhoto*)_source.organicList[0]).url absoluteString], @"//o4");
    XCTAssertEqualWithAccuracy(((IMMPhoto*)_source.promotedList[0]).rank, 1.0, 0.01);
    XCTAssertEqualWithAccuracy(((IMMPhoto*)_source.promotedList[1]).rank, 1.0, 0.01);
    XCTAssertEqualWithAccuracy(((IMMPhoto*)_source.promotedList[2]).rank, 1.0, 0.01);
    XCTAssertEqualWithAccuracy(((IMMPhoto*)_source.organicList[0]).rank, 1.0, 0.01);

    _searchManagerMock.promotedSearchesMock = [[NSMutableArray alloc] init];
    result = [_source result];
    [_source update:nil result:result];
    XCTAssertEqual(((NSMutableArray*)_source.promotedList).count, 0);
    XCTAssertEqual(((NSMutableArray*)_source.organicList).count, 1);
    XCTAssertEqual([((IMMPhoto*)_source.organicList[0]).url absoluteString], @"//o4");
    XCTAssertEqualWithAccuracy(((IMMPhoto*)_source.organicList[0]).rank, 0.0, 0.01);
}

@end