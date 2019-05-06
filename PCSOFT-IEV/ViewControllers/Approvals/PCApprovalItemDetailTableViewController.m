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

@end
