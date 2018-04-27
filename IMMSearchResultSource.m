//
//  IMMSearchResultSource.m
//  Moonmasons
//
//  Created by Johan Wiig on 11/11/14.
//  Copyright (c) 2014 Innology. All rights reserved.
//

#import "IMMSearchResultSource.h"

@implementation IMMSearchResultSource


- (id) initWithSearchEngine:(IMMSearchEngine*)searchEngine searchManager:(IMMSearchManager*)searchManager photoManager:(IMMPhotoManager*)photoManager
{
    if (self = [super init])
    {
        _searchEngine = searchEngine;
        _searchManager = searchManager;
        _photoManager = photoManager;

        _organicList = [[NSMutableArray alloc] init];
        _promotedList = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSMutableDictionary*) result
{
    //  Get organic results
    NSMutableArray * organicPhotos = [_searchEngine organicPhotos];
    NSLog(@"newOrganicPhotos = %lu", (unsigned long)organicPhotos.count);
    
    
//  Get boosted list and assign rank to boosted photos
    NSMutableArray * boostedPhotos = [_photoManager boostedPhotos];
    NSLog(@"boostedPhotos = %lu", (unsigned long)boostedPhotos.count);
    
    
//  Remove boosted photos from organic list
    organicPhotos = [self removeArray:boostedPhotos fromArray:organicPhotos];


//  Get copy of old promoted results, but without boosted photos from new bossted list, and reset rank
    NSMutableArray * oldPromotedPhotos = [_promotedList mutableCopy];
    oldPromotedPhotos = [self removeArray:boostedPhotos fromArray:oldPromotedPhotos];
    for (IMMPhoto * photo in oldPromotedPhotos)
    {
        photo.rank = 0;
    }
    NSLog(@"oldPromotedPhotos = %lu", (unsigned long)oldPromotedPhotos.count);
    
    
//  Get copy of old organic results, but without boosted photos from new boosted list, and reset rank
    NSMutableArray * oldOrganicPhotos = [_organicList mutableCopy];
    oldOrganicPhotos = [self removeArray:boostedPhotos fromArray:oldOrganicPhotos];
    for (IMMPhoto * photo in oldOrganicPhotos)
    {
        photo.rank = 0;
    }
    NSLog(@"oldOrganicPhotos = %lu", (unsigned long)oldOrganicPhotos.count);
    
    
//  Create list containing all boosted, new organic, old organic photos and old promoted, without doubles
    NSMutableArray * allPhotos = [[NSMutableArray alloc] init];
    allPhotos = [[allPhotos arrayByAddingObjectsFromArray:boostedPhotos] mutableCopy];
    allPhotos = [[allPhotos arrayByAddingObjectsFromArray:organicPhotos] mutableCopy];
    allPhotos = [[allPhotos arrayByAddingObjectsFromArray:oldPromotedPhotos] mutableCopy];
    allPhotos = [[allPhotos arrayByAddingObjectsFromArray:oldOrganicPhotos] mutableCopy];
    
    
//  Get promoted searches and add zone rank to all photos within promoted searches
    NSMutableArray * promotedSearches = [_searchManager promotedSearches];
    NSLog(@"promotedSearches = %lu", (unsigned long)promotedSearches.count);
    for (IMMSearch * search in promotedSearches)
    {
        for (IMMPhoto * photo in allPhotos)
        {
            if ([search isCoveringPhoto:photo])
            {
                photo.rank += search.rank;
            }
        }
    }


//  Sort by rank
    [allPhotos sortUsingComparator:^NSComparisonResult(IMMPhoto * obj1, IMMPhoto * obj2)
     {
         if (obj1.rank > obj2.rank)
         {
             return NSOrderedAscending;
         }
         else if (obj1.rank < obj2.rank)
         {
             return NSOrderedDescending;
         }
         return NSOrderedSame;
     }];
    
    
//  Keep top 3 entries
    allPhotos = [[allPhotos subarrayWithRange:NSMakeRange(0, MIN(3, allPhotos.count))] mutableCopy];
    
    
//  Move any entry with rank larger than zero to promoted list, and set label field
    NSMutableArray * promotedPhotos = [[NSMutableArray alloc] init];
    for (IMMPhoto *  photo in allPhotos)
    {
        if (photo.rank > 0)
        {
            photo.label = [NSString stringWithFormat:@"RANK: %ld", (long) (photo.rank * 1000.0)];
            [promotedPhotos addObject:photo];
//            NSLog(@"Promoted: %@, rank = %f, url = %@", photo.label, photo.rank, photo.url);
        }
    }
    

//  Remove promoted photos from organic results
    organicPhotos = [self removeArray:promotedPhotos fromArray:organicPhotos];

    
//  Prepare result structure
    NSMutableDictionary * result = [[NSMutableDictionary alloc] init];
    result[@"organic"] = organicPhotos;
    result[@"promoted"] = promotedPhotos;
    
    return result;
}

- (NSMutableArray*) removeArray:(NSMutableArray*)small fromArray:(NSMutableArray*)big
{
    for (IMMPhoto * photo in small)
    {
        big = [self remove:photo fromArray:big];
    }
    return big;
}

- (NSMutableArray*) remove:(IMMPhoto*)photo fromArray:(NSMutableArray*)array
{
    NSMutableArray * remove = [[NSMutableArray alloc] init];
    for (IMMPhoto * element in array)
    {
        if ([[photo.url absoluteString] isEqual:[element.url absoluteString]])
        {
            [remove addObject:element];
        }
    }
    for (IMMPhoto * element in remove)
    {
        [array removeObject:element];
    }
    return array;
}

long previousPromoted = 0;
- (void)addPromoted:(NSMutableArray*)promoted to:(UITableView*) tableView
{
    NSMutableArray * rowsToRemove = [[NSMutableArray alloc] init];
    NSMutableIndexSet * indicesToRemove = [[NSMutableIndexSet alloc] init];
    
    long maxLength = (previousPromoted > promoted.count) ? previousPromoted : promoted.count;
    for (int i = 0 ; i < maxLength ; i++)
    {
        if (i < previousPromoted && i < promoted.count)         //  Inside both previous and current promoted list
        {
            if (![[((IMMPhoto*)promoted[i]).url absoluteString] isEqualToString:[((IMMPhoto*)_promotedList[i]).url absoluteString]])   //  Photos are different
            {
                NSIndexPath * indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                [tableView beginUpdates];
                [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationTop];
                [_promotedList removeObjectAtIndex:i];
//                [tableView endUpdates];
//                [tableView beginUpdates];
                [_promotedList insertObject:promoted[i] atIndex:i];
                [tableView insertRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationTop];
                [tableView endUpdates];
            }
        }
        else if (i >= previousPromoted && i < promoted.count)    //  Current result set is longer, need to add rows
        {
            [_promotedList insertObject:promoted[i] atIndex:i];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:i inSection:0], nil] withRowAnimation:UITableViewRowAnimationTop];
        }
        else if (i < previousPromoted && i >= promoted.count)    //  Current result set is shorter, need to remove rows
        {
            [rowsToRemove addObject:[NSIndexPath indexPathForRow:i inSection:0]];
            [indicesToRemove addIndex:i];
        }
    }
        
    [tableView beginUpdates];
    [_promotedList removeObjectsAtIndexes:indicesToRemove];
    [tableView deleteRowsAtIndexPaths:rowsToRemove withRowAnimation:UITableViewRowAnimationTop];
    [tableView endUpdates];
    
    previousPromoted = promoted.count;
}

- (void)addOrganic:(NSMutableArray*)organic to:(UITableView*) tableView
{
    NSMutableArray * indexPaths = [NSMutableArray array];
    [tableView beginUpdates];
    for (long i = 0 ; i < organic.count ; i++)
    {
        [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:1]];
        [_organicList insertObject:organic[i] atIndex:i];
    }
    [tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
    [tableView endUpdates];
}

- (void)truncateOrganic:(UITableView*) tableView limit:(int)limit
{
    NSMutableArray * indexPaths = [NSMutableArray array];
    long itemsToRemove = _organicList.count - limit;
    if (itemsToRemove > 0)
    {
        for (long i = 0 ; i < itemsToRemove ; i++)
        {
            [indexPaths addObject:[NSIndexPath indexPathForRow:(_organicList.count - itemsToRemove + i) inSection:1]];
        }
        [tableView beginUpdates];
        [_organicList removeObjectsInRange:NSMakeRange(_organicList.count - itemsToRemove, itemsToRemove)];
        [tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationBottom];
        [tableView endUpdates];
    }
}

- (void) removeOrganic:(IMMPhoto*)photo from:(UITableView*)tableView
{
    NSMutableArray * removeTableView = [[NSMutableArray alloc] init];
    NSMutableIndexSet * removeOrganicList = [[NSMutableIndexSet alloc] init];
    for (int i = 0 ; i < _organicList.count ; i++)
    {
        if ([[((IMMPhoto*)_organicList[i]).url absoluteString] isEqualToString:[photo.url absoluteString]])
        {
            [removeTableView addObject:[NSIndexPath indexPathForRow:i inSection:1]];
            [removeOrganicList addIndex:i];
        }
    }
    [tableView beginUpdates];
    [tableView deleteRowsAtIndexPaths:removeTableView withRowAnimation:UITableViewRowAnimationBottom];
    [_organicList removeObjectsAtIndexes:removeOrganicList];
    [tableView endUpdates];
}

- (void) update:(UITableView*)tableView result:(NSMutableDictionary*)result
{
    [self addPromoted:result[@"promoted"] to:tableView];
    for (IMMPhoto * photo in result[@"promoted"])
    {
        [self removeOrganic:photo from:tableView];
    }
    [self addOrganic:result[@"organic"] to:tableView];
    [self truncateOrganic:tableView limit:20];
}

@end
