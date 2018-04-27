//
//  IMMPhotoViewController.m
//  Moonmasons
//
//  Created by Johan Wiig on 08/10/14.
//  Copyright (c) 2014 Innology. All rights reserved.
//

#import "IMMPhotoViewController.h"
#import "IMMStreetViewController.h"
#import "IMMPhotoManager.h"

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

@interface IMMPhotoViewController ()

@property IMMPhotoManager * photoManager;

@end

@implementation IMMPhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTap)];
    singleTap.numberOfTapsRequired = 1;
    [_imageView addGestureRecognizer:singleTap];
    [_imageView setMultipleTouchEnabled:YES];
    [_imageView setUserInteractionEnabled:YES];

    _photoManager = [IMMPhotoManager sharedInstance];
    [self load];
}

- (void) load
{
    [_photoManager isBoosted:_photos[_index] callback:^(BOOL isBoosted)
     {
         dispatch_async(dispatch_get_main_queue(), ^
        {
            NSLog(@"isBoosted = %u", isBoosted);
            [_boost setOn:isBoosted];
        });
     }];
    
    NSString * label = ((IMMPhoto*)_photos[_index]).label;
    _likes.text = label;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateStyle:NSDateFormatterNoStyle];
    _time.text = [dateFormatter stringFromDate:((IMMPhoto*)_photos[_index]).date];

    if (((IMMPhoto*)_photos[_index]).image != nil)
    {
        [_spinner stopAnimating];
        _imageView.image = ((IMMPhoto*)_photos[_index]).image;
        return;
    }
    
    dispatch_async(kBgQueue, ^{
        [_spinner startAnimating];
        NSData *data = [NSData dataWithContentsOfURL:((IMMPhoto*)_photos[_index]).url];
        if (data)
        {
            UIImage *image = [UIImage imageWithData:data];
            if (image)
            {
                dispatch_async(dispatch_get_main_queue(), ^
                {
                    [_spinner stopAnimating];
                    ((IMMPhoto*)_photos[_index]).image = image;
                    _imageView.image = image;
                });
            }
        }
    });
}

- (void)imageTap
{
    NSLog(@"Opening url: %@", ((IMMPhoto*)_photos[_index]).username);
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:((IMMPhoto*)_photos[_index]).username]];
}


- (IBAction)buttonPrevious:(id)sender
{
    if (_index > 0)
    {
        _index--;
        _imageView.image = nil;
        [self load];
    }
}

- (IBAction)buttonNext:(id)sender
{
    if (_index < (_photos.count - 1))
    {
        _index++;
        _imageView.image = nil;
        [self load];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)storeBoost:(id)sender
{
    [_photoManager setBoost:((IMMPhoto*)_photos[_index]) boost:[sender isOn]];
    NSLog(@"setBoost boost = %u", [sender isOn]);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"segueStreetView"])
    {
        IMMStreetViewController * view = (IMMStreetViewController*) segue.destinationViewController;
        view.coordinate = ((IMMPhoto*)_photos[_index]).coordinate;
    }
}

- (IBAction)unwindToPhotoView:(UIStoryboardSegue *)segue
{
}

@end
