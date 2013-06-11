//
//  ViewController.m
//  Ukay
//
//  Created by David Mazzitelli on 4/20/13.
//  Copyright (c) 2013 David Mazzitelli. All rights reserved.
//

#import "LoginViewController.h"
#import "ManifestViewController.h"
#import "FormRepository.h"
#import "ServerConnectionManager.h"
#import "MBProgressHUD.h"

@interface LoginViewController ()

@property (nonatomic, retain) IBOutlet UITextField *usernameTextField;
@property (nonatomic, retain) IBOutlet UITextField *passwordTextField;
@property (nonatomic, retain) IBOutlet UIButton *loginButton;

@end

@implementation LoginViewController

- (void)dealloc
{
    [_usernameTextField release];
    [_passwordTextField release];
    [_loginButton release];
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    self.usernameTextField = nil;
    self.passwordTextField = nil;
    self.loginButton = nil;
    
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions methods

- (IBAction)loginButtonPressed:(id)sender
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    ServerConnectionManager *serverConnectionManager = [[ServerConnectionManager alloc] init];
    [serverConnectionManager loginWithUsername:self.usernameTextField.text andPassword:self.passwordTextField.text withDelegate:self];
}

#pragma mark - ServerConnectionManagerDelegate methods

- (void)serverRespondsWithData:(NSDictionary *)data
{
    NSString *driverId = [data objectForKey:@"id"];
    [FormRepository setDriverId:driverId];
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    ManifestViewController *manifestViewController = [[ManifestViewController alloc] initWithNibName:@"ManifestViewController" bundle:nil];
    [self presentViewController:manifestViewController animated:YES completion:nil];
    [manifestViewController release];
}

- (void)serverRespondsWithErrorCode:(NSInteger)code
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    NSString *message = nil;
    
    if(code == 401) {
        message = @"Invalid username or password.";
    } else {
        message = @"There were problems connecting to the server. Please check your internet connection.";
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}

@end
