//
//  IMMPhotoManager.h
//  Moonmasons
//
//  Created by Johan Wiig on 02/11/14.
//  Copyright (c) 2014 Innology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMMSearchManager.h"
#import "IMMPhoto.h"
#import "IMMConfigManager.h"
@interface IMMPhotoManager : NSObject

@property (nonatomic) NSMutableArray * boostedPhotos;
@property IMMSearchManager* searchManager;
@property NSString * appBase;
@property int timeout;

+ (id) sharedInstance;
- (id) init;

- (void) setBoost:(IMMPhoto*)photo boost:(BOOL)boost;
- (void) isBoosted:(IMMPhoto*)photo callback:(void(^)(BOOL))callback;
- (NSMutableArray*) boostedPhotos;
- (void) clearCache;

@end
