//
//  PCOrderTermsViewController.m
//  PCSOFT-IEV
//
//  Created by Harsha Jain on 01/05/25.
//  Copyright © 2025 Sameer Ghate. All rights reserved.
//

#import "PCOrderTermsViewController.h"
#import "POSOSingleTransactionCell.h"
#import "PCTransactionDetailModel.h"

@interface PCOrderTermsModel : NSObject
    
@property (nonatomic, strong) NSString *orderNo;
@property (nonatomic, strong) NSString *termsCategory;
@property (nonatomic, strong) NSString *termsValue;
@property (nonatomic, strong) NSString *termsDescription;

@end

@implementation PCOrderTermsModel  {
    
}

@end

@implementation PCOrderTermsTableViewCell {
    
}

@end

@interface PCOrderTermsViewController () <UITableViewDataSource, UITableViewDelegate>

{
    NSMutableArray *terms_details;
    NSNumber *doctype;
}

@end

@implementation PCOrderTermsViewController

@synthesize selectedModel = _selectedModel;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self makeArrayOfOrderTerms];
    
}

-(void)makeArrayOfOrderTerms {
    
    NSArray *propsArray = [[NSArray alloc] initWithObjects:self.selectedModel.FRT_CD, self.selectedModel.INS_CD, self.selectedModel.EXC_CD, self.selectedModel.SHP_CD, self.selectedModel.STX_CD, self.selectedModel.PKG_CD, self.selectedModel.BKG_CD, self.selectedModel.TPR_CD, self.selectedModel.PAY_CD, nil];
    
    terms_details = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [propsArray count]; i++) {
        NSArray *arr = [[propsArray objectAtIndex:i] componentsSeparatedByString:@"$"];
        
        PCOrderTermsModel *model = [[PCOrderTermsModel alloc] init];
        
        if ([arr objectAtIndex:0] != nil) {
            model.orderNo = arr[0];
        }
        
        if ([arr objectAtIndex:1] != nil) {
            model.termsCategory = arr[1];
        }
        
        if ([arr objectAtIndex:2] != nil) {
            model.termsValue = arr[2];
        }
        
        if ([arr objectAtIndex:3] != nil) {
            model.termsDescription = arr[3];
        }

        [terms_details addObject:model];
    }
    
    [terms_details sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {

        PCOrderTermsModel *obj10 = (PCOrderTermsModel*)obj1;
        PCOrderTermsModel *obj20 = (PCOrderTermsModel*)obj2;
        
        if ([obj10.orderNo intValue] == [obj20.orderNo intValue])
            return NSOrderedSame;

        else if ([obj10.orderNo intValue] < [obj20.orderNo intValue])
            return NSOrderedAscending;

        else
            return NSOrderedDescending;
    }];
    
    [self.orderTermsTableview1 reloadData];
}

-(IBAction)closeButtonAction:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

#pragma mark - Table view data source

static NSString *cellIdentifier = @"PCOrderTermsTableViewCell";

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    // Return the number of sections.
    return 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // Return the number of rows in the section.
    return terms_details.count;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PCOrderTermsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    PCOrderTermsModel *model = [terms_details objectAtIndex:indexPath.row];
    
    cell.orderNo.text = model.orderNo;
    cell.termCategory.text = model.termsCategory;
    cell.termValue.text = model.termsValue;
    cell.termDescription.text = model.termsDescription;
    
    return cell;
}

@end
