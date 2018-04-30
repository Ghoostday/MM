Copyright jdc

#import "IMMAuthViewController.h"
#import "IMMOAuthWebView.h"
#import "IMMTwitterEngine.h"
#import "IMMInstagramEngine.h"
#import "IMMSearchManager.h"

@interface IMMAuthViewController ()

@property IMMSearchManager * searchManager;
@property IMMTwitterEngine * twitter;
@property IMMInstagramEngine * instagram;

@end

@implementation IMMAuthViewController

//- (IBAction)unwindAuthWebView:(UIStoryboardSegue *)segue
//{
//    NSLog(@"IMMAuthViewController::unwindAuthWebView");
//
//    NSLog(@"unwindAuthWebView twitter = %u instagram = %u", _twitter.enabled, _instagram.enabled);
//    
//    if (_twitter.enabled || _instagram.enabled)
//    {
//        [self performSegueWithIdentifier: @"unwindAuthViewController" sender: self];
//    }
//}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"IMMAuthViewController::prepareForSegue: %@", segue.identifier);

    if([segue.identifier isEqualToString:@"segueInstagramOpenAuth"])
    {
        _searchManager.authRequested = _instagram;
    }
    else if([segue.identifier isEqualToString:@"segueTwitterOpenAuth"])
    {
        _searchManager.authRequested = _twitter;
    }
    NSLog(@"_model.authRequested : %@", _searchManager.authRequested);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _searchManager = [IMMSearchManager sharedInstance];
    
    _instagram = [IMMInstagramEngine sharedInstance];
    _twitter = [IMMTwitterEngine sharedInstance];
    
    //[_buttonInstagram

}

- (IBAction)handleButtonClick:(id)sender
{
    NSLog(@"handleButtonClick : %@", sender);
    if (sender == _buttonInstagram)
    {
        _searchManager.authRequested = _instagram;
    }
    else if (sender == _buttonTwitter)
    {
        _searchManager.authRequested = _twitter;
    }
    
    UIViewController * authView = [self.storyboard instantiateViewControllerWithIdentifier:@"OAuthWebViewNavigator"];
    [self presentViewController:authView animated:YES completion:nil];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSLog(@"IMMAuthViewController::viewDidAppear");
    
    NSLog(@"unwindAuthWebView twitter = %u instagram = %u", _twitter.enabled, _instagram.enabled);
    
    if (_twitter.enabled || _instagram.enabled)
    {
        [self performSegueWithIdentifier: @"unwindAuthViewController" sender: self];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



@end
