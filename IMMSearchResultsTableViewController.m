//
//  IMMSearchResultsTableViewController.m
//  Moonmasons
//
//  Created by Johan Wiig on 07/10/14.
//  Copyright (c) 2014 Innology. All rights reserved.
//

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

#import "IMMSearchResultsTableViewController.h"
#import "IMMPhoto.h"
#import "IMMPhotoViewController.h"
#import "IMMPictureTableViewCell.h"
#import "IMMSearchResultsHeader.h"
#import "IMMSearchManager.h"
#import "IMMSearchEngine.h"
#import "IMMAppDelegate.h"
#import "IMMSearchResultSource.h"

@interface IMMSearchResultsTableViewController ()

@property long selectIndex;


@end

bool loading = false;
IMMSearchResultsHeader * header;
NSTimer * timer;
IMMAppDelegate * appDelegate;
IMMSearchResultSource * searchResultSource;

@implementation IMMSearchResultsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    header = (IMMSearchResultsHeader*) self.tableView.tableHeaderView;
    [header loadState];

    appDelegate = (IMMAppDelegate *)[[UIApplication sharedApplication] delegate];

    if(!searchResultSource)
    {
        searchResultSource = [[IMMSearchResultSource alloc] initWithSearchEngine:appDelegate.searchEngine searchManager:appDelegate.searchManager photoManager:appDelegate.photoManager];
    }

    [self startTimer];
    [self search:nil];

    NSLog(@"IMMSearchResultsTableViewController::viewDidLoad");
}

- (void)search:(NSTimer*)timer
{
    NSLog(@"IMMSearchResultsTableViewController::search");
    [header loadState];
    if (loading)
    {
        NSLog(@"IMMSearchResultsTableViewController::search - aborting, search already in progress");
        return;
    }
    loading = true;
    
    dispatch_async(kBgQueue, ^
    {
        NSMutableDictionary * result = [searchResultSource result];
        dispatch_async(dispatch_get_main_queue(), ^
        {
            @try
            {
                [searchResultSource update:self.tableView result:result];
            }
            @catch (NSException *exception)
            {
                NSLog(@"Search result update error: %@", exception);
            }
            
            [header normalState];
            loading = false;
        });
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 0 ? searchResultSource.promotedList.count : searchResultSource.organicList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    IMMPictureTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"searchResultPrototype" forIndexPath:indexPath];
    
    IMMPhoto * photo = (indexPath.section == 0) ? [searchResultSource.promotedList objectAtIndex:indexPath.row] : [searchResultSource.organicList objectAtIndex:indexPath.row];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    cell.timeLabel.text = [dateFormatter stringFromDate:photo.date];
    cell.photoView.image = nil;
    cell.star.hidden = (indexPath.section != 0);
    
    if (photo.image != nil)
    {
        cell.photoView.image = photo.image;
        return cell;
    }
    
    dispatch_async(kBgQueue, ^
    {
        NSData *data = [NSData dataWithContentsOfURL:photo.url];
        if (data)
        {
            UIImage *image = [UIImage imageWithData:data];
            if (image)
            {
                dispatch_async(dispatch_get_main_queue(), ^
                {
                    IMMPictureTableViewCell * cell = (id)[tableView cellForRowAtIndexPath:indexPath];
                    if (cell)
                    {
                        photo.image = image;
                        cell.photoView.image = image;
                        cell.photoView.contentMode = UIViewContentModeScaleAspectFill;
                    }
                });
            }
        }
    });
    
    return cell;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView.contentOffset.y < -150.0f)
    {
        NSLog(@"Scroll event %f", scrollView.contentOffset.y);
        [self search:nil];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"IMMSearchResultsTableViewController::prepareForSegue: %@", segue.identifier);

    if([segue.identifier isEqualToString:@"segueOpenPhoto"])
    {
        IMMPhotoViewController * view = (IMMPhotoViewController*) segue.destinationViewController;
        _selectIndex = ([[_photoTableView indexPathForSelectedRow] section] == 0) ?
            [[_photoTableView indexPathForSelectedRow] row] : [[_photoTableView indexPathForSelectedRow] row] + searchResultSource.promotedList.count;
        view.index =  _selectIndex;
        view.photos = [[NSMutableArray alloc] init];
        view.photos = [[view.photos arrayByAddingObjectsFromArray:searchResultSource.promotedList] mutableCopy];
        view.photos = [[view.photos arrayByAddingObjectsFromArray:searchResultSource.organicList] mutableCopy];
    }
    if (timer)
    {
        NSLog(@"Stopping search result timer");
        [timer invalidate];
        timer = nil;
        [header normalState];
    }
}

- (IBAction)unwindToSearchResultView:(UIStoryboardSegue *)segue
{
    NSLog(@"IMMSearchResultsTableViewController::unwindToSearchResultView: %@", segue);
    [self startTimer];
}

- (void) startTimer
{
    if(!timer)
    {
        NSLog(@"Starting search result timer");
        timer = [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(search:) userInfo:@"" repeats:YES];
    }
}


@end
