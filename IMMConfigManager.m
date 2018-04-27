//
//  IMMConfigManager.m
//  Moonmasons
//
//  Created by Johan Wiig on 20/11/14.
//  Copyright (c) 2014 Innology. All rights reserved.
//

#import "IMMConfigManager.h"

@implementation IMMConfigManager

+ (id) sharedInstance
{
    static IMMConfigManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      instance = [[self alloc] init];
                  });
    return instance;
}

- (id)init
{
    if (self = [super init])
    {
        [self configureWithKey:@"SCHEME" file:@"Config" defaultEnvironment:@"PROD"];
        return self;
    }
    return nil;
}

- (void) configureWithKey:(NSString*)key file:(NSString*)file defaultEnvironment:(NSString*)defaultEnvironment
{
    NSBundle* bundle = [NSBundle mainBundle];
    NSString* envsPListPath = [bundle pathForResource:file ofType:@"plist"];
    NSDictionary* environmentsFile = [[NSDictionary alloc] initWithContentsOfFile:envsPListPath];
    
    NSDictionary *environmentVariables = [[NSProcessInfo processInfo] environment];
    if (environmentVariables[key])
    {
        _config = environmentsFile[environmentVariables[key]];
    }
    else
    {
        _config = environmentsFile[defaultEnvironment];
    }
}

@end
