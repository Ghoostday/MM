//
//  IMMoAuth.m
//  Moonmasons
//
//  Created by Johan Wiig on 16/09/14.
//  Copyright (c) 2014 Innology. All rights reserved.
//

#import "IMMoAuth.h"
#import <CommonCrypto/CommonHMAC.h>

@interface IMMoAuth ()

@end

@implementation IMMoAuth


+ (NSMutableDictionary *)  requestTokenForKey:(NSString *)key
                            secret:(NSString *)secret
                       callbackUrl:(NSString *)callbackUrl
                        requestUrl:(NSString *)requestUrl;
{
    NSString * signatureMethod = @"HMAC-SHA1";
    NSString * call_method = @"GET";
    NSString * nonce = @"blahblahblahblahblahblahblahblah";
    NSString * timestamp = [NSString stringWithFormat:@"%d",(int)[[NSDate date] timeIntervalSince1970]];
    NSString * version = @"1.0";
    
    NSString * arguments = [[self enconde_rfc3986:@"oauth_callback"] stringByAppendingString:@"="];
    arguments = [arguments stringByAppendingString:[self enconde_rfc3986:callbackUrl]];

    arguments = [arguments stringByAppendingString:@"&"];
    arguments = [arguments stringByAppendingString:[self enconde_rfc3986:@"oauth_consumer_key"]];
    arguments = [arguments stringByAppendingString:@"="];
    arguments = [arguments stringByAppendingString:[self enconde_rfc3986:key]];

    arguments = [arguments stringByAppendingString:@"&"];
    arguments = [arguments stringByAppendingString:[self enconde_rfc3986:@"oauth_nonce"]];
    arguments = [arguments stringByAppendingString:@"="];
    arguments = [arguments stringByAppendingString:[self enconde_rfc3986:nonce]];

    arguments = [arguments stringByAppendingString:@"&"];
    arguments = [arguments stringByAppendingString:[self enconde_rfc3986:@"oauth_signature_method"]];
    arguments = [arguments stringByAppendingString:@"="];
    arguments = [arguments stringByAppendingString:[self enconde_rfc3986:signatureMethod]];

    arguments = [arguments stringByAppendingString:@"&"];
    arguments = [arguments stringByAppendingString:[self enconde_rfc3986:@"oauth_timestamp"]];
    arguments = [arguments stringByAppendingString:@"="];
    arguments = [arguments stringByAppendingString:[self enconde_rfc3986:timestamp]];

    arguments = [arguments stringByAppendingString:@"&"];
    arguments = [arguments stringByAppendingString:[self enconde_rfc3986:@"oauth_version"]];
    arguments = [arguments stringByAppendingString:@"="];
    arguments = [arguments stringByAppendingString:[self enconde_rfc3986:version]];
    
    
    
    
    NSString * base = [self enconde_rfc3986:call_method];
    base = [base stringByAppendingString:@"&"];
    base = [base stringByAppendingString:[self enconde_rfc3986:requestUrl]];
    base = [base stringByAppendingString:@"&"];
    base = [base stringByAppendingString:[self enconde_rfc3986:arguments]];
    
    NSString * signature = [self shaClearText:base secret:[secret stringByAppendingString: @"&"]];

    NSString * url = requestUrl;
    
    url = [url stringByAppendingString:@"?"];
    url = [url stringByAppendingString:[self enconde_rfc3986:@"oauth_callback"]];
    url = [url stringByAppendingString:@"="];
    url = [url stringByAppendingString:[self enconde_rfc3986:callbackUrl]];
    
    url = [url stringByAppendingString:@"&"];
    url = [url stringByAppendingString:[self enconde_rfc3986:@"oauth_consumer_key"]];
    url = [url stringByAppendingString:@"="];
    url = [url stringByAppendingString:[self enconde_rfc3986:key]];
    
    url = [url stringByAppendingString:@"&"];
    url = [url stringByAppendingString:[self enconde_rfc3986:@"oauth_nonce"]];
    url = [url stringByAppendingString:@"="];
    url = [url stringByAppendingString:[self enconde_rfc3986:nonce]];
    
    url = [url stringByAppendingString:@"&"];
    url = [url stringByAppendingString:[self enconde_rfc3986:@"oauth_signature"]];
    url = [url stringByAppendingString:@"="];
    url = [url stringByAppendingString:[self enconde_rfc3986:signature]];

    url = [url stringByAppendingString:@"&"];
    url = [url stringByAppendingString:[self enconde_rfc3986:@"oauth_signature_method"]];
    url = [url stringByAppendingString:@"="];
    url = [url stringByAppendingString:[self enconde_rfc3986:signatureMethod]];
    
    url = [url stringByAppendingString:@"&"];
    url = [url stringByAppendingString:[self enconde_rfc3986:@"oauth_timestamp"]];
    url = [url stringByAppendingString:@"="];
    url = [url stringByAppendingString:[self enconde_rfc3986:timestamp]];
    
    url = [url stringByAppendingString:@"&"];
    url = [url stringByAppendingString:[self enconde_rfc3986:@"oauth_version"]];
    url = [url stringByAppendingString:@"="];
    url = [url stringByAppendingString:[self enconde_rfc3986:version]];
    
    
    NSURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSURLResponse *response = [NSURLResponse alloc];
    NSError *connectionError = [NSError alloc];
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&connectionError];
    NSString * result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    
    return [self parseQueryString:result];
}


+ (NSMutableDictionary *)  accessTokenForUrl:(NSString *)url
                          oauth_consumer_key:(NSString *)oauth_consumer_key
                       oauth_consumer_secret:(NSString *)oauth_consumer_secret
                                 oauth_token:(NSString *)oauth_token
                          oauth_token_secret:(NSString *)oauth_token_secret
                              oauth_verifier:(NSString *)oauth_verifier
                                 credentials:(NSMutableDictionary*)credentials
{
    
    NSString * signatureMethod = @"HMAC-SHA1";
    NSString * call_method = @"GET";
    NSString * nonce = @"5392f9df0a3987e0a13ceb9eecc954d5";
    NSString * timestamp = [NSString stringWithFormat:@"%d",(int)[[NSDate date] timeIntervalSince1970]];
    NSString * version = @"1.0";
    
    NSString * arguments = [self enconde_rfc3986:@"oauth_consumer_key"];
    arguments = [arguments stringByAppendingString:@"="];
    arguments = [arguments stringByAppendingString:[self enconde_rfc3986:oauth_consumer_key]];
    
    arguments = [arguments stringByAppendingString:@"&"];
    arguments = [arguments stringByAppendingString:[self enconde_rfc3986:@"oauth_nonce"]];
    arguments = [arguments stringByAppendingString:@"="];
    arguments = [arguments stringByAppendingString:[self enconde_rfc3986:nonce]];
    
    arguments = [arguments stringByAppendingString:@"&"];
    arguments = [arguments stringByAppendingString:[self enconde_rfc3986:@"oauth_signature_method"]];
    arguments = [arguments stringByAppendingString:@"="];
    arguments = [arguments stringByAppendingString:[self enconde_rfc3986:signatureMethod]];
    
    arguments = [arguments stringByAppendingString:@"&"];
    arguments = [arguments stringByAppendingString:[self enconde_rfc3986:@"oauth_timestamp"]];
    arguments = [arguments stringByAppendingString:@"="];
    arguments = [arguments stringByAppendingString:[self enconde_rfc3986:timestamp]];

    arguments = [arguments stringByAppendingString:@"&"];
    arguments = [arguments stringByAppendingString:[self enconde_rfc3986:@"oauth_token"]];
    arguments = [arguments stringByAppendingString:@"="];
    arguments = [arguments stringByAppendingString:[self enconde_rfc3986:oauth_token]];

    arguments = [arguments stringByAppendingString:@"&"];
    arguments = [arguments stringByAppendingString:[self enconde_rfc3986:@"oauth_verifier"]];
    arguments = [arguments stringByAppendingString:@"="];
    arguments = [arguments stringByAppendingString:[self enconde_rfc3986:oauth_verifier]];

    arguments = [arguments stringByAppendingString:@"&"];
    arguments = [arguments stringByAppendingString:[self enconde_rfc3986:@"oauth_version"]];
    arguments = [arguments stringByAppendingString:@"="];
    arguments = [arguments stringByAppendingString:[self enconde_rfc3986:version]];
    
    
    NSString * base = [self enconde_rfc3986:call_method];
    base = [base stringByAppendingString:@"&"];
    base = [base stringByAppendingString:[self enconde_rfc3986:url]];
    base = [base stringByAppendingString:@"&"];
    base = [base stringByAppendingString:[self enconde_rfc3986:arguments]];
    
    NSLog(@"base = %@", base);
    NSString * key = [[oauth_consumer_secret stringByAppendingString: @"&"] stringByAppendingString:oauth_token_secret];
    NSLog(@"key = %@", key);
    NSString * signature = [self shaClearText:base secret:key];
    NSLog(@"signature = %@", signature);
    
    
    url = [url stringByAppendingString:@"?"];
    url = [url stringByAppendingString:[self enconde_rfc3986:@"oauth_consumer_key"]];
    url = [url stringByAppendingString:@"="];
    url = [url stringByAppendingString:[self enconde_rfc3986:oauth_consumer_key]];
    
    url = [url stringByAppendingString:@"&"];
    url = [url stringByAppendingString:[self enconde_rfc3986:@"oauth_nonce"]];
    url = [url stringByAppendingString:@"="];
    url = [url stringByAppendingString:[self enconde_rfc3986:nonce]];
    
    url = [url stringByAppendingString:@"&"];
    url = [url stringByAppendingString:[self enconde_rfc3986:@"oauth_signature"]];
    url = [url stringByAppendingString:@"="];
    url = [url stringByAppendingString:[self enconde_rfc3986:signature]];
    
    url = [url stringByAppendingString:@"&"];
    url = [url stringByAppendingString:[self enconde_rfc3986:@"oauth_signature_method"]];
    url = [url stringByAppendingString:@"="];
    url = [url stringByAppendingString:[self enconde_rfc3986:signatureMethod]];
    
    url = [url stringByAppendingString:@"&"];
    url = [url stringByAppendingString:[self enconde_rfc3986:@"oauth_timestamp"]];
    url = [url stringByAppendingString:@"="];
    url = [url stringByAppendingString:[self enconde_rfc3986:timestamp]];
    
    url = [url stringByAppendingString:@"&"];
    url = [url stringByAppendingString:[self enconde_rfc3986:@"oauth_token"]];
    url = [url stringByAppendingString:@"="];
    url = [url stringByAppendingString:[self enconde_rfc3986:oauth_token]];
    
    url = [url stringByAppendingString:@"&"];
    url = [url stringByAppendingString:[self enconde_rfc3986:@"oauth_verifier"]];
    url = [url stringByAppendingString:@"="];
    url = [url stringByAppendingString:[self enconde_rfc3986:oauth_verifier]];
    
    url = [url stringByAppendingString:@"&"];
    url = [url stringByAppendingString:[self enconde_rfc3986:@"oauth_version"]];
    url = [url stringByAppendingString:@"="];
    url = [url stringByAppendingString:[self enconde_rfc3986:version]];

    
    NSURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSURLResponse *response = [NSURLResponse alloc];
    NSError *connectionError = [NSError alloc];
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&connectionError];
    NSString * result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    return [self parseQueryString:result withKeyStore:credentials];
}


+ (NSString *) OAuthHeader:(NSMutableURLRequest *)request
                parameters:(NSMutableDictionary *)parameters
        oauth_consumer_key:(NSString *)oauth_consumer_key
     oauth_consumer_secret:(NSString *)oauth_consumer_secret
               oauth_token:(NSString *)oauth_token
        oauth_token_secret:(NSString *)oauth_token_secret
{
    NSString * signatureMethod = @"HMAC-SHA1";
    NSString * nonce = @"cabce75fc4ed43a1577f28f461d9e43e";
    NSString * timestamp = [NSString stringWithFormat:@"%d",(int)[[NSDate date] timeIntervalSince1970]];
    NSString * version = @"1.0";
    
    NSMutableDictionary * args = [[NSMutableDictionary alloc] initWithDictionary:parameters];
    args[@"oauth_consumer_key"] = oauth_consumer_key;
    args[@"oauth_nonce"] = nonce;
    args[@"oauth_signature_method"] = signatureMethod;
    args[@"oauth_timestamp"] = timestamp;
    args[@"oauth_token"] = oauth_token;
    args[@"oauth_version"] = version;
    
    NSString * arguments = @"";
    NSArray * keys = [[args allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    BOOL firstRun = true;
    for (NSString * key in keys)
    {
        if (!firstRun) arguments = [arguments stringByAppendingString:@"&"];
        firstRun = false;
        arguments = [arguments stringByAppendingString:[self enconde_rfc3986:key]];
        arguments = [arguments stringByAppendingString:@"="];
        arguments = [arguments stringByAppendingString:[self enconde_rfc3986:args[key]]];
    }

    
    NSString * base = [self enconde_rfc3986:request.HTTPMethod];
    base = [base stringByAppendingString:@"&"];
    base = [base stringByAppendingString:[self enconde_rfc3986:request.URL.description]];
    base = [base stringByAppendingString:@"&"];
    base = [base stringByAppendingString:[self enconde_rfc3986:arguments]];
    
    NSString * key = [[oauth_consumer_secret stringByAppendingString: @"&"] stringByAppendingString:oauth_token_secret];
    NSString * signature = [self shaClearText:base secret:key];

    NSMutableDictionary * oAuthElements = [[NSMutableDictionary alloc] init];
    oAuthElements[@"oauth_consumer_key"] = [self enconde_rfc3986:oauth_consumer_key];
    oAuthElements[@"oauth_nonce"] = [self enconde_rfc3986:nonce];
    oAuthElements[@"oauth_signature"] = [self enconde_rfc3986:signature];
    oAuthElements[@"oauth_signature_method"] = [self enconde_rfc3986:signatureMethod];
    oAuthElements[@"oauth_timestamp"] = [self enconde_rfc3986:timestamp];
    oAuthElements[@"oauth_token"] = [self enconde_rfc3986:oauth_token];
    oAuthElements[@"oauth_version"] = [self enconde_rfc3986:version];

    NSString * authHeader = @"OAuth ";
    for (NSString * key in oAuthElements)
    {
        if (!firstRun) authHeader = [authHeader stringByAppendingString:@", "];
        firstRun = false;
        authHeader = [authHeader stringByAppendingString:[NSString stringWithFormat:@"%@=\"%@\"", key, oAuthElements[key]]];
    }
    return authHeader;  
}

+ (NSString*) addParameterToHeader:(NSString*)key value:(NSString*)value delimiter:(NSString*)delimiter quotes:(BOOL)quotes toString:(NSString*)string
{
    string = [string stringByAppendingString:delimiter];
    string = [string stringByAppendingString:key];
    string = [string stringByAppendingString:@"="];
    if (quotes) string = [string stringByAppendingString:@"\""];
    string = [string stringByAppendingString:value];
    if (quotes) string = [string stringByAppendingString:@"\""];
    return string;
}

+ (NSMutableDictionary*) parseQueryString:(NSString*)query withKeyStore:(NSMutableDictionary*) withKeyStore
{
    NSArray *urlComponents = [query componentsSeparatedByString:@"&"];
    for (NSString *keyValuePair in urlComponents)
    {
        NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
        NSString *key = [pairComponents objectAtIndex:0];
        NSString *value = [pairComponents objectAtIndex:1];
        [withKeyStore setObject:value forKey:key];
    }
    return withKeyStore;
}

+ (NSMutableDictionary*) parseQueryString:(NSString*)query
{
    NSMutableDictionary *withKeyStore = [[NSMutableDictionary alloc] init];
    return [self parseQueryString:query withKeyStore:withKeyStore];
}


+ (NSString *) shaClearText:(NSString *)clearText
                     secret:(NSString *)secret
{
    NSData *secretData = [secret dataUsingEncoding:NSUTF8StringEncoding];
    NSData *clearTextData = [clearText dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableData* result = [NSMutableData dataWithLength:CC_SHA1_DIGEST_LENGTH ];
    CCHmac(kCCHmacAlgSHA1, secretData.bytes, secretData.length, clearTextData.bytes, clearTextData.length, result.mutableBytes);
    return [result base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}



+ (NSString *)enconde_rfc3986:(NSString *) string
{
    
    CFStringRef yourFriendlyCFString = (__bridge CFStringRef)string;
    NSString *yourFriendlyNSString = (__bridge NSString *) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                           yourFriendlyCFString,
                                                                           NULL,
                                                                           CFSTR("!*'();:@&=+$,/?%#[]"),
                                                                           kCFStringEncodingUTF8);
    return yourFriendlyNSString;
}


@end
