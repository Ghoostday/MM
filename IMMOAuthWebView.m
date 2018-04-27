//
//  IMMSearchViewController.m
//  Moonmasons
//
//  Created by Johan Wiig on 16/09/14.
//  Copyright (c) 2014 Innology. All rights reserved.
//

#import "IMMOAuthWebView.h"
#import "IMMSearchManager.h"

@interface IMMOAuthWebView ()

@property IMMSearchManager * searchManager;

@end

@implementation IMMOAuthWebView

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"IMMOAuthWebView::prepareForSegue");
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    NSLog(@"Init NIB!");
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"IMMOAuthWebView: View did load!");
    
    _searchManager = [IMMSearchManager sharedInstance];
    _webView.delegate = self;
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (_searchManager.authRequested == nil)
    {
        NSLog(@"providerAuth not set, exiting");
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    NSURL *urlObj = [NSURL URLWithString:_searchManager.authRequested.authUrl];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:urlObj];
    [_webView loadRequest:requestObj];
}

- (BOOL)               webView:(UIWebView *)webView
    shouldStartLoadWithRequest:(NSURLRequest *)request
                navigationType:(UIWebViewNavigationType)type
{
    NSLog(@"url changed:");
    if ([_searchManager.authRequested checkUrl:request.URL])
    {
        NSLog(@"url changed: closing web view");
        _searchManager.authRequested.enabled = true;
        _searchManager.authRequested = nil;
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
    return true;
}

- (IBAction)cancelPressed:(id)sender
{
    _searchManager.authRequested = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
