//
//  MoonmasonsTests.m
//  MoonmasonsTests
//
//  Created by Johan Wiig on 16/09/14.
//  Copyright (c) 2014 Innology. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

@interface MoonmasonsTests : XCTestCase

@end

@implementation MoonmasonsTests

id userDefaultsMock;

//- (void)setUp
//{
//    [super setUp];
//    
//    
//    // create a mock for the user defaults
//    userDefaultsMock = OCMClassMock([NSUserDefaults class]);
//    
//    // set it up to return a specific value when stringForKey: is called
//    OCMStub([userDefaultsMock stringForKey:@"MyAppURLKey"]).andReturn(@"http://testurl");
//    
//    // set it up to return the specified value no matter how the method is invoked
//    OCMStub([userDefaultsMock stringForKey:[OCMArg any]]).andReturn(@"http://testurl");
//}
//
//- (void)tearDown
//{
//    // Put teardown code here. This method is called after the invocation of each test method in the class.
//    [super tearDown];
//}
//
//- (void)testExample
//{
////    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
//    NSLog(@"Value = %@", [userDefaultsMock stringForKey:@"MyAppURLKey"]);
//    XCTAssertEqual(@"http://testurl", [userDefaultsMock stringForKey:@"MyAppURLKey"]);
//    
//
//}

@end
