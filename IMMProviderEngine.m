//
//  IMMProviderEngine.m
//  Moonmasons
//
//  Created by Johan Wiig on 08/10/14.
//  Copyright (c) 2014 Innology. All rights reserved.
//

#import "IMMProviderEngine.h"

@implementation IMMProviderEngine

@synthesize enabled = _enabled;

const NSString * AUTH_PROVIDER_HEADER = @"AuthProvider";

- (id)initWithPrefix:(NSString*)prefix
{
    if (self = [super init])
    {
        _prefix = prefix;
        _credentials = [[NSMutableDictionary alloc] init];
        [self load];
        return self;
    }
    return nil;
}

- (BOOL) enabled
{
    return _enabled;
}

- (void) setEnabled:(BOOL)enabled
{
    _enabled = enabled;
    [self save];
}

- (void)load
{
    _credentials = [[NSUserDefaults standardUserDefaults] valueForKey:[_prefix stringByAppendingString:@"_credentials"]];
    if (_credentials == nil)
    {
        _credentials = [[NSMutableDictionary alloc] init];
    }
    NSLog(@"IMMProviderEngine - loaded credentials %@ for %@", _credentials, _prefix);

    NSNumber * enableNum = [[NSUserDefaults standardUserDefaults] valueForKey:[_prefix stringByAppendingString:@"_enable"]];
    if (enableNum != nil)
    {
        _enabled = [enableNum boolValue];
    }
    else
    {
        _enabled = false;
    }
    NSLog(@"IMMProviderEngine - loaded enable %u for %@", _enabled, _prefix);
}


- (void)save
{
    [[NSUserDefaults standardUserDefaults] setObject:_credentials forKey:[_prefix stringByAppendingString:@"_credentials"]];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:_enabled] forKey:[_prefix stringByAppendingString:@"_enable"]];
}

- (NSMutableArray*) getResults:(IMMSearch*)search
{
    return nil;
}

- (NSString*)authUrl
{
    return nil;
}

- (BOOL)checkUrl:(NSURL*)url
{
    return false;
}

- (NSMutableURLRequest*) addAuthHeaders:(NSMutableURLRequest*)request;
{
    return request;
}

- (int) providerIdentifier
{
    return IMMSearchProviderIdentifierBase;
}

- (NSString*) userId
{
    return nil;
}


@end
