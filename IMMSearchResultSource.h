//
//  IMMSearchResultSource.h
//  Moonmasons
//
//  Created by Johan Wiig on 11/11/14.
//  Copyright (c) 2014 Innology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMMSearchEngine.h"
#import "IMMSearchManager.h"
#import "IMMPhotoManager.h"

@interface IMMSearchResultSource : NSObject

@property IMMSearchEngine * searchEngine;
@property IMMSearchManager * searchManager;
@property IMMPhotoManager * photoManager;

@property NSMutableArray * organicList;
@property NSMutableArray * promotedList;

- (id) initWithSearchEngine:(IMMSearchEngine*)searchEngine searchManager:(IMMSearchManager*)searchManager photoManager:(IMMPhotoManager*)photoManager;

- (NSMutableDictionary*) result;
- (void) update:(UITableView*)tableView result:(NSMutableDictionary*)result;

- (void) addPromoted:(NSMutableArray*)promoted to:(UITableView*) tableView;
- (void) addOrganic:(NSMutableArray*)organic to:(UITableView*) tableView;
- (void) truncateOrganic:(UITableView*) tableView limit:(int)limit;
- (void) removeOrganic:(IMMPhoto*)photo from:(UITableView*)tableView;

@end
