//
//  ViewController.m
//  Ukay
//
//  Created by David Mazzitelli on 4/20/13.
//  Copyright (c) 2013 David Mazzitelli. All rights reserved.
//

#import "LoginViewController.h"
#import "ManifestViewController.h"

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
    ManifestViewController *manifestViewController = [[ManifestViewController alloc] initWithNibName:@"ManifestViewController" bundle:nil];
    [self presentViewController:manifestViewController animated:YES completion:nil];
    [manifestViewController release];
}

@end
