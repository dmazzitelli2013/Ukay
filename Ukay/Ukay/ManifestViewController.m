//
//  ManifestViewController.m
//  Ukay
//
//  Created by David Mazzitelli on 4/20/13.
//  Copyright (c) 2013 David Mazzitelli. All rights reserved.
//

#import "ManifestViewController.h"
#import "ManifestCell.h"
#import "ManifestCellHeader.h"
#import "FormViewController.h"
#import "FormRepository.h"
#import "Form.h"
#import "FormGroup.h"

@interface ManifestViewController ()

@property (nonatomic, retain) IBOutlet UITableView *table;
@property (nonatomic, retain) NSArray *formsGroups;

@end

@implementation ManifestViewController

- (void)dealloc
{
    [_table release];
    
    if(_formsGroups) {
        [_formsGroups release];
    }
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    FormRepository *repository = [[FormRepository alloc] init];
    NSArray *forms = [repository getAllForms];
    self.formsGroups = [repository getAllFormGroupsForForms:forms];
    [repository release];
}

- (void)viewDidUnload
{
    self.table = nil;
    
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.table reloadData];
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
    FormGroup *formGroup = [self.formsGroups objectAtIndex:indexPath.section];
    Form *form = [formGroup getFormAtIndex:indexPath.row];
    formViewController.form = form;
    
    [self presentViewController:formViewController animated:YES completion:nil];
    [formViewController release];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    ManifestCellHeader *header = [[[NSBundle mainBundle] loadNibNamed:@"ManifestCellHeader" owner:self options:nil] objectAtIndex:0];
    header.formGroup = [self.formsGroups objectAtIndex:section];
    [header fillManifestHeader];
    
    return header;
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.formsGroups count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    FormGroup *formGroup = [self.formsGroups objectAtIndex:section];
    return [formGroup getFormsCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ManifestCell";
    ManifestCell *cell = (ManifestCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(!cell) {
		cell = [[[NSBundle mainBundle] loadNibNamed:@"ManifestCell" owner:self options:nil] objectAtIndex:0];
	}
    
    FormGroup *formGroup = [self.formsGroups objectAtIndex:indexPath.section];
    Form *form = [formGroup getFormAtIndex:indexPath.row];
    cell.form = form;
    [cell fillManifestCell];
    
	return cell;
}

@end
