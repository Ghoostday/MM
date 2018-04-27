//
//  IMMConfigManager.h
//  Moonmasons
//
//  Created by Johan Wiig on 20/11/14.
//  Copyright (c) 2014 Innology. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IMMConfigManager : NSObject

+ (id) sharedInstance;
- (void) configureWithKey:(NSString*)key file:(NSString*)file defaultEnvironment:(NSString*)defaultEnvironment;

@property NSDictionary * config;

@end
