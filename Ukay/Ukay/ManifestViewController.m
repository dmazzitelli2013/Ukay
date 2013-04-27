//
//  ManifestViewController.m
//  Ukay
//
//  Created by David Mazzitelli on 4/20/13.
//  Copyright (c) 2013 David Mazzitelli. All rights reserved.
//

#import "ManifestViewController.h"
#import "ManifestCell.h"
#import "FormViewController.h"
#import "FormRepository.h"
#import "Form.h"

@interface ManifestViewController ()

@property (nonatomic, retain) IBOutlet UITableView *table;
@property (nonatomic, retain) NSArray *formsData;

@end

@implementation ManifestViewController

- (void)dealloc
{
    [_table release];
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    FormRepository *repository = [[FormRepository alloc] init];
    self.formsData = [repository getAllForms];
    [repository release];
}

- (void)viewDidUnload
{
    self.table = nil;
    
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FormViewController *formViewController = [[FormViewController alloc] initWithNibName:@"FormViewController" bundle:nil];
    Form *form = [self.formsData objectAtIndex:indexPath.row];
    formViewController.form = form;
    
    [self presentViewController:formViewController animated:YES completion:nil];
    [formViewController release];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.formsData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ManifestCell";
    ManifestCell *cell = (ManifestCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(!cell) {
		cell = [[[NSBundle mainBundle] loadNibNamed:@"ManifestCell" owner:self options:nil] objectAtIndex:0];
	}
    
    //Form *form = [self.formsData objectAtIndex:indexPath.row];
    
	return cell;
}

@end
