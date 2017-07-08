//
//  PCApprovalItemDetailTableViewController.m
//  ERPMobile
//
//  Created by Sameer Ghate on 30/10/14.
//  Copyright (c) 2014 Sameer Ghate. All rights reserved.
//

#import "PCApprovalItemDetailTableViewController.h"
#import "POSOSingleTransactionCell.h"
#import "PCTransactionDetailModel.h"

@interface PCApprovalItemDetailTableViewController ()

{
    NSArray *titles_details;
    NSNumber *doctype;
    BOOL specialCase;
    NSDictionary *tableDataDictionary;
}

@end

@implementation PCApprovalItemDetailTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.layer.cornerRadius = 10.0;
    self.view.layer.masksToBounds = YES;
    self.view.layer.borderWidth = 1.0;
    self.view.layer.borderColor = [UIColor blackColor].CGColor;
    
    self.tableView.layer.cornerRadius = 10.0;
    self.tableView.layer.masksToBounds = YES;
    self.tableView.layer.borderWidth = 1.0;
    self.tableView.layer.borderColor = [UIColor blackColor].CGColor;
    
    if([self.selectedDoctype containsString:@"3E"])
    {
        //show quantity,desc,code
        titles_details = @[@"Description",
                           @"Code",
                           @"Quantity"];
        
        tableDataDictionary = @{@"Description":self.selectedModel.descr,
                                @"Code":self.selectedModel.code,
                                @"Quantity":[NSString stringWithFormat:@"%@",self.selectedModel.qty]};
    }
    else
    {
        doctype = [NSNumber numberWithInt:[self.selectedDoctype intValue]];
        
        if (!([doctype compare:@30] == NSOrderedAscending) && ([doctype compare:@23] != NSOrderedSame))
        {
            //show quantity and rate
            titles_details = @[@"Description",
                               @"Code",
                               @"Quantity",
                               @"Rate"];
            
            tableDataDictionary = @{@"Description":self.selectedModel.descr,
                                    @"Code":self.selectedModel.code,
                                    @"Quantity":[NSString stringWithFormat:@"%@",self.selectedModel.qty],
                                    @"Rate":[Utility stringWithCurrencySymbolForValue: [NSString stringWithFormat:@"%@",self.selectedModel.rate] forCurrencyCode:DEFAULT_CURRENCY_CODE]};
        }
        else {
            titles_details = @[@"Description",
                               @"Sub A/c Description",
                               @"Code",
                               @"Value"];
            
            tableDataDictionary = @{@"Description":self.selectedModel.descr,
                                    @"Sub A/c Description":self.selectedModel.subdesc.length>0?self.selectedModel.subdesc:@"Not Available",
                                    @"Code":self.selectedModel.code,
                                    @"Value":[Utility stringWithCurrencySymbolForValue: [NSString stringWithFormat:@"%@",self.selectedModel.value] forCurrencyCode:DEFAULT_CURRENCY_CODE]};
        }
        //show basic value
    }
    
    if(![self.selectedDoctype isEqualToString:@"3E"])
    {
        if (([doctype compare:@15] != NSOrderedSame) && !([doctype compare:@16] != NSOrderedSame))
        {
            //show line taxes
            titles_details = @[@"Description",
                               
                               @"Code",
                               @"Quantity",
                               @"Rate",
                               @"Value",
                               @"Line Taxes"];
            
            tableDataDictionary = @{@"Description":self.selectedModel.descr,
                                    
                                    @"Code":self.selectedModel.code,
                                    @"Quantity":[NSString stringWithFormat:@"%@",self.selectedModel.qty],
                                    @"Rate":[Utility stringWithCurrencySymbolForValue: [NSString stringWithFormat:@"%@",self.selectedModel.rate] forCurrencyCode:DEFAULT_CURRENCY_CODE],
                                    @"Value":[Utility stringWithCurrencySymbolForValue: [NSString stringWithFormat:@"%@",self.selectedModel.value] forCurrencyCode:DEFAULT_CURRENCY_CODE],
                                    @"Line Taxes":[Utility stringWithCurrencySymbolForValue: [NSString stringWithFormat:@"%@",self.selectedModel.line_taxes] forCurrencyCode:DEFAULT_CURRENCY_CODE]};
        }
    }
    
    /*
     
     !((doctype)<30 && (doctype)!=23))
     
     if (doctype is more than 30 and doctype is 23)    {
            desc,code,rate,qty,val,line taxes
     }
     else if(doctype is 15,16 or 3E)  {
            desc,code,qty,rate,value
     }
     else {
            what rows to display?
     }
     
     if (auth type is purchase indent)  {
            desc,code,qty,line taxes
     }
     else {
            what rows to display?
     }
     
     */
    
    
    /*
    //15,16,3E
    
    if ([self.selectedModel.rdoc_type isEqualToString:@"15"] ||
        [self.selectedModel.rdoc_type isEqualToString:@"16"] ||
        [self.selectedModel.rdoc_type isEqualToString:@"3E"]) {
        titles_details = @[@"Description",
                           @"Code",
                           @"Quantity",
                           @"Rate",
                           @"Value"];
        
        tableDataDictionary = @{@"Description":self.selectedModel.descr,
                                @"Code":self.selectedModel.code,
                                @"Quantity":[NSString stringWithFormat:@"%@",self.selectedModel.qty],
                                @"Rate":[Utility stringWithCurrencySymbolForValue: [NSString stringWithFormat:@"%@",self.selectedModel.rate] forCurrencyCode:DEFAULT_CURRENCY_CODE],
                                @"Value":[Utility stringWithCurrencySymbolForValue: [NSString stringWithFormat:@"%@",self.selectedModel.value] forCurrencyCode:DEFAULT_CURRENCY_CODE]};
    }//
    else {
        titles_details = @[@"Description",
                           @"Code",
                           @"Quantity",
                           @"Rate",
                           @"Value",
                           @"Line Taxes"];
        
        tableDataDictionary = @{@"Description":self.selectedModel.descr,
                                @"Code":self.selectedModel.code,
                                @"Quantity":[NSString stringWithFormat:@"%@",self.selectedModel.qty],
                                @"Rate":[Utility stringWithCurrencySymbolForValue: [NSString stringWithFormat:@"%@",self.selectedModel.rate] forCurrencyCode:DEFAULT_CURRENCY_CODE],
                                @"Value":[Utility stringWithCurrencySymbolForValue: [NSString stringWithFormat:@"%@",self.selectedModel.value] forCurrencyCode:DEFAULT_CURRENCY_CODE],
                                @"Line Taxes":[Utility stringWithCurrencySymbolForValue: [NSString stringWithFormat:@"%@",self.selectedModel.line_taxes] forCurrencyCode:DEFAULT_CURRENCY_CODE]};
    }
    
    doctype = [NSNumber numberWithInt:[self.selectedModel.rdoc_type intValue]];
    
     !((doctype)<30 && (doctype)!=23))
    // more than 30 and not 23
    
    if (!([doctype compare:@30] == NSOrderedAscending) && !([doctype compare:@23] == NSOrderedSame)) {
        
        
        
        
        titles_details = @[@"Description",
                           @"Code",
                           @"Value",
                           @"Line Taxes"];
        
        tableDataDictionary = @{@"Description":self.selectedModel.descr,
                                @"Code":self.selectedModel.code,
                                @"Value":[Utility stringWithCurrencySymbolForValue: [NSString stringWithFormat:@"%@",self.selectedModel.value] forCurrencyCode:DEFAULT_CURRENCY_CODE],
                                @"Line Taxes":[Utility stringWithCurrencySymbolForValue: [NSString stringWithFormat:@"%@",self.selectedModel.line_taxes] forCurrencyCode:DEFAULT_CURRENCY_CODE]};
        
        specialCase = YES;
    }
    else    {
        specialCase = NO;
    }
    
    if (self.txtype == TXTypePI) {
        
        titles_details = @[@"Description",
                           @"Code",
                           @"Quantity",
                           @"Line Taxes"];
        
        tableDataDictionary = @{@"Description":self.selectedModel.descr,
                                @"Code":self.selectedModel.code,
                                @"Quantity":[NSString stringWithFormat:@"%@",self.selectedModel.qty],
                                @"Line Taxes":[Utility stringWithCurrencySymbolForValue: [NSString stringWithFormat:@"%@",self.selectedModel.line_taxes] forCurrencyCode:DEFAULT_CURRENCY_CODE]};
    }
    */
    
//    tableDataDictionary = 
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

static NSString *cellIdentifier = @"POSOSingleTransactionCell";

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    // Return the number of sections.
    return 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // Return the number of rows in the section.
    return titles_details.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    POSOSingleTransactionCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    [self configureCell:cell forIndexPath:indexPath];
    
    return cell;
}

-(void)configureCell:(POSOSingleTransactionCell*)cell forIndexPath:(NSIndexPath*)indexPath
{
    
    cell.titleLabel.text = titles_details[indexPath.row];
    cell.descriptionLabel.text = [tableDataDictionary objectForKey:titles_details[indexPath.row]];
    
    /*
    switch (indexPath.row) {
        case 0:
            
            cell.titleLabel.text = [titles_details objectAtIndex:indexPath.row];
            cell.descriptionLabel.text = self.selectedModel.descr;
            
            break;
            
        case 1:
            
            cell.titleLabel.text = [titles_details objectAtIndex:indexPath.row];
            cell.descriptionLabel.text = self.selectedModel.code;
            
            break;
            
        case 2:
            
            cell.titleLabel.text = [titles_details objectAtIndex:indexPath.row];
            
            if (specialCase) {
                
                cell.descriptionLabel.text = [NSString stringWithFormat:@"%@",self.selectedModel.value];
            }
            else {
                cell.descriptionLabel.text = [NSString stringWithFormat:@"%@",self.selectedModel.qty];
            }

            break;
            
        case 3:
            
            cell.titleLabel.text = [titles_details objectAtIndex:indexPath.row];
            
            
            if (specialCase) {
                cell.descriptionLabel.text = [Utility stringWithCurrencySymbolForValue: [NSString stringWithFormat:@"%@",self.selectedModel.line_taxes] forCurrencyCode:DEFAULT_CURRENCY_CODE];
            }
            else {
                cell.descriptionLabel.text = [Utility stringWithCurrencySymbolForValue: [NSString stringWithFormat:@"%@",self.selectedModel.rate] forCurrencyCode:DEFAULT_CURRENCY_CODE];
            }
            
            
            
            break;
            
        case 4:
            
            cell.titleLabel.text = [titles_details objectAtIndex:indexPath.row];
            cell.descriptionLabel.text = [Utility stringWithCurrencySymbolForValue: [NSString stringWithFormat:@"%@",self.selectedModel.value] forCurrencyCode:DEFAULT_CURRENCY_CODE];
            
            break;
            
        case 5: // Line Taxes
            
            cell.titleLabel.text = [titles_details objectAtIndex:indexPath.row];
            cell.descriptionLabel.text = [Utility stringWithCurrencySymbolForValue: [NSString stringWithFormat:@"%@",self.selectedModel.line_taxes] forCurrencyCode:DEFAULT_CURRENCY_CODE];
            
            break;
            
        default:
            break;
    }
    */
    
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
    return [self heightForCellAtIndexPath:indexPath];
}

-(CGFloat)calculateHeightForConfiguredSizingCell:(UITableViewCell*)cell
{
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    
    CGSize size = [cell systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    
    return size.height;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return TRUE;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

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
