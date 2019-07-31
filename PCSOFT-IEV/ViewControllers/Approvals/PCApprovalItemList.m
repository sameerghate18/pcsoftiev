//
//  PCApprovalItemList.m
//  ERPMobile
//
//  Created by Sameer Ghate on 30/10/14.
//  Copyright (c) 2014 Sameer Ghate. All rights reserved.
//

#import "PCApprovalItemList.h"
#import "POSOSingleTransactionCell.h"
#import "PCSingleTransactionViewController.h"
#import "PCTransactionDetailModel.h"
#import "PCApprovalItemDetailTableViewController.h"

@interface PCApprovalItemList ()

@end

@implementation PCApprovalItemList

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = FALSE;
    self.title = @"Items in this Order";
    
    self.view.layer.cornerRadius = 10.0;
    self.view.layer.masksToBounds = YES;
    self.view.layer.borderWidth = 1.0;
    self.view.layer.borderColor = [UIColor blackColor].CGColor;
    
    self.tableView.layer.cornerRadius = 10.0;
    self.tableView.layer.masksToBounds = YES;
    self.tableView.layer.borderWidth = 1.0;
    self.tableView.layer.borderColor = [UIColor blackColor].CGColor;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    return _itemsListArray.count;
    
}

static NSString *cellIdentifier = @"POSOSingleTransactionCell";


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    POSOSingleTransactionCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    [self configureCell:cell forIndexPath:indexPath];
    
    return cell;
}

-(void)configureCell:(POSOSingleTransactionCell*)cell forIndexPath:(NSIndexPath*)indexPath
{
    PCTransactionDetailModel *model = [_itemsListArray objectAtIndex:indexPath.row];
    
    cell.titleLabel.text = model.descr;
    cell.descriptionLabel.text = [Utility stringWithCurrencySymbolPrefix:[NSString stringWithFormat:@"%@", model.value] forCurrencySymbol:model.cursymbl];
}

-(CGFloat)heightForCellAtIndexPath:(NSIndexPath*)indexPath
{
    static POSOSingleTransactionCell *sizingCell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sizingCell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    });
    
    [self configureCell:sizingCell forIndexPath:indexPath];
    
    return [self calculateHeightForConfiguredSizingCell:sizingCell];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return 75.0;//[self heightForCellAtIndexPath:indexPath];
}

-(CGFloat)calculateHeightForConfiguredSizingCell:(UITableViewCell*)cell
{
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    
    CGSize size = [cell systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    
    return size.height;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PCApprovalItemDetailTableViewController *detail = [kStoryboard instantiateViewControllerWithIdentifier:@"PCApprovalItemDetailTableViewController"];
    PCTransactionDetailModel *selectedItem = [_itemsListArray objectAtIndex:indexPath.row];
    [detail setSelectedModel:selectedItem];
    [detail setSelectedDoctype:self.selectedDoctype];
    [self.navigationController pushViewController:detail animated:YES];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
