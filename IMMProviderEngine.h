//
//  IMMProviderEngine.h
//  Moonmasons
//
//  Created by Johan Wiig on 08/10/14.
//  Copyright (c) 2014 Innology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMMPhoto.h"
#import "IMMSearch.h"

enum IMMSearchProviderIdentifier
{
    IMMSearchProviderIdentifierBase = 0,
    IMMSearchProviderIdentifierInstagram,
    IMMSearchProviderIdentifierTwitter,
    IMMSearchProviderIdentifierLength
};

@interface IMMProviderEngine : NSObject

@property NSMutableDictionary * credentials;
@property BOOL enabled;
@property NSString * prefix;
@property NSString * baseSearchUrl;

- (id)initWithPrefix:(NSString*)prefix;
- (void) save;

- (NSString*)authUrl;
- (BOOL)checkUrl:(NSURL*)url;
- (NSMutableArray*) getResults:(IMMSearch*)search;
- (NSMutableURLRequest*) addAuthHeaders:(NSMutableURLRequest*)request;
- (int) providerIdentifier;
- (NSString*) userId;

extern const NSString * AUTH_PROVIDER_HEADER;

@end
