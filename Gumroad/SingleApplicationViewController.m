//
//  LoginViewController.m
//  Gumroad
//
//  Created by Noah Martin on 12/12/13.
//  Copyright (c) 2013 Noah Martin. All rights reserved.
//

#import "SingleApplicationViewController.h"
#import "GumroadConnection.h"

const NSString* client_id = @"ed987833e484f9b573a5925b55711dfaea72a31ccad332ca9ca0059b35b6daec";
const NSString* client_secret = @"c7998ce39ba4e24830dd90ddfbad74e9e4490cbdd1b6f7c57cc7df567f0a8d8c";
const NSString* redirectURL = @"noahmart.in";

@interface SingleApplicationViewController ()

@property (weak, nonatomic) IBOutlet UILabel *downloads;
@property (weak, nonatomic) IBOutlet UILabel *views;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *logout;

@property (strong, nonatomic) GumroadConnection* connection;

@end

@implementation SingleApplicationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:@"token"];
    self.connection = [[GumroadConnection alloc] initWithToken:token];
    
    if(!token)
        [self generateToken];
    
    [self refreshUI];
}

- (IBAction)logout:(UIBarButtonItem *)sender {
    if([sender.title isEqualToString:@"Logout"])
    {
        self.connection.token = nil;
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"token"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self refreshUI];
    }
    else
    {
        [sender setEnabled:NO];
        [self generateToken];
    }
}

-(void) generateToken {
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.bounds.size.height)];
    [webView setDelegate:self];
    
    NSString *urlAddress = [NSString stringWithFormat:@"https://gumroad.com/oauth/authorize?client_id=%@&redirect_uri=http://%@&scope=view_sales", client_id, redirectURL];
    NSURL *url = [NSURL URLWithString:urlAddress];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [webView loadRequest:request];
    
    webView.scrollView.contentInset = UIEdgeInsetsMake(64, 0.0, 0.0, 0.0);
    
    [self.view addSubview:webView];
}

-(void)createTokenWithAuth:(NSString*)code
{
    NSString *urlAddress = @"https://gumroad.com/oauth/token";
    NSURL *url = [NSURL URLWithString:urlAddress];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    NSString *postString = [NSString stringWithFormat:@"code=%@&redirect_uri=http://%@&client_secret=%@&client_id=%@", code, redirectURL, client_secret, client_id];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    NSError *error;
    NSURLResponse *response;
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if(error)
    {
        NSLog(@"error: %@", [error localizedDescription]);
    }
    if(response)
    {
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:returnData options:kNilOptions error:nil];
        NSString* token = [result objectForKey:@"access_token"];
        [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"token"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        self.connection.token = token;
    }
    [self refreshUI];
}

-(void)refreshUI
{
    NSDictionary *applications = [self.connection applicationIds];
    if(applications)
    {
        self.logout.title = @"Logout";
        self.logout.enabled = YES;
    }
    else
        self.logout.title = @"Login";
    // This controller only handles one application
    NSString* title = [[applications allKeys] objectAtIndex:0];
    if(!title)
        title = @"Not Logged In";
    self.title = [[applications allKeys] objectAtIndex:0];
    
    NSDictionary* info = [self.connection infoForApplicationId:[[applications allValues] objectAtIndex:0]];
    self.downloads.text = [NSString stringWithFormat:@"Purchases: %@", [info objectForKey:@"purchases"]];
    self.views.text = [NSString stringWithFormat:@"Views: %@", [info objectForKey:@"views"]];
}
- (IBAction)screenTap:(UITapGestureRecognizer *)sender {
    [self refreshUI];
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL *requestURL = request.URL;
    if([requestURL.host isEqualToString:(NSString*) redirectURL])
    {
        NSArray* result = [requestURL.query componentsSeparatedByString:@"&"];
        [self createTokenWithAuth:[[[result objectAtIndex:0] componentsSeparatedByString:@"="] objectAtIndex:1]];
        [webView removeFromSuperview];
        return NO;
    }
    return YES;
}

@end
