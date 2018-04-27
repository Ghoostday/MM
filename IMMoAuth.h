//
//  IMMoAuth.h
//  Moonmasons
//
//  Created by Johan Wiig on 16/09/14.
//  Copyright (c) 2014 Innology. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IMMoAuth : NSObject

+ (NSMutableDictionary *)  requestTokenForKey:(NSString *)key
                            secret:(NSString *)secret
                       callbackUrl:(NSString *)callbackUrl
                        requestUrl:(NSString *)requestUrl;

+ (NSMutableDictionary *)  accessTokenForUrl:(NSString *)url
                          oauth_consumer_key:(NSString *)oauth_consumer_key
                       oauth_consumer_secret:(NSString *)oauth_consumer_secret
                                 oauth_token:(NSString *)oauth_token
                          oauth_token_secret:(NSString *)oauth_token_secret
                              oauth_verifier:(NSString *)oauth_verifier
                                 credentials:(NSMutableDictionary*)credentials;

+ (NSString *) OAuthHeader:(NSMutableURLRequest *)request
                parameters:(NSMutableDictionary *)parameters
        oauth_consumer_key:(NSString *)oauth_consumer_key
     oauth_consumer_secret:(NSString *)oauth_consumer_secret
               oauth_token:(NSString *)oauth_token
        oauth_token_secret:(NSString *)oauth_token_secret;


@end
