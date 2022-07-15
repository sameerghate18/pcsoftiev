//
//  PCRejectionsTableViewController.m
//  ERPMobile
//
//  Created by Sameer Ghate on 07/09/14.
//  Copyright (c) 2014 Sameer Ghate. All rights reserved.
//

#import "PCRejectionsTableViewController.h"
#import "PCRejectionModel.h"
#import "ConnectionHandler.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "SVProgressHUD.h"
#import "PCRejectionsTableViewCell.h"
#import "PCRejectionsGraphViewController.h"


@interface PCRejectionsTableViewController () <ConnectionHandlerDelegate, UITextFieldDelegate>

{
    NSMutableArray *rejectionsArray;
    UIRefreshControl *refreshControl;
    NSString *searchText;
    NSString *lastRefreshTime;
    BOOL isKeyboardRefresh;
    NSMutableDictionary *selectedIndexes;
}

- (BOOL)cellIsSelected:(NSIndexPath *)indexPath;

@property (nonatomic, weak) UITextField *valueTextfield;
@property (nonatomic, weak) NSString *rejectionValue;

@end

#define kCellHeight 60.0

@implementation PCRejectionsTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)setSearchBox
{
    UIView *searchView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 80)];
    [searchView setBackgroundColor:[UIColor colorWithRed:0.988 green:0.741 blue:0.192 alpha:1.0]];
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 320, 25)];
    lbl.font = [UIFont boldSystemFontOfSize:15];
    lbl.textColor = [UIColor blackColor];
    lbl.textAlignment = NSTextAlignmentCenter;
    lbl.text = @"Provide a search value";
    [searchView addSubview:lbl];
    
    UITextField *tf = [[UITextField alloc] init];
    tf.delegate = self;
    [tf setFrame:CGRectMake(90, 45, 140, 30)];
    [tf setBorderStyle:UITextBorderStyleLine];
    [tf setBackgroundColor:[UIColor whiteColor]];
    [tf setKeyboardType:UIKeyboardTypeAlphabet];
    [tf setReturnKeyType:UIReturnKeySearch];
    [tf setTextAlignment:NSTextAlignmentCenter];
    [searchView addSubview:tf];
    
    self.tableView.tableHeaderView = searchView;
    
    CALayer *layer = self.tableView.tableHeaderView.layer;
    layer.borderWidth = 1.0f;
    layer.borderColor = (__bridge CGColorRef)([UIColor blackColor]);
    layer.cornerRadius = 5.0f;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    selectedIndexes = [[NSMutableDictionary alloc] init];
    
    [self setTitle:@"Rejections"];
    
    UIBarButtonItem *barbtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu_icon.png"] style:UIBarButtonItemStylePlain target:self action:@selector(showSideMenu)];

    self.navigationItem.leftBarButtonItem = barbtn;
    
    UIBarButtonItem *rightBarbtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"graph.png"] style:UIBarButtonItemStylePlain target:self action:@selector(displayPieChart:)];
    self.navigationItem.rightBarButtonItem = rightBarbtn;
    
    [self.tableView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]]];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"PCRejectionsTableViewCell" bundle:nil] forCellReuseIdentifier:reuseIdent];
    
//    [self.tableView registerClass:[PCRejectionsTableViewCell class] forCellReuseIdentifier:reuseIdent];
    
    [self setSearchBox];
    
    isKeyboardRefresh = YES;
}

-(void)showSideMenu
{
    AppDelegate *appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    [appDel.slideViewController showLeftViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)searchRejections:(id)sender
{
    if ([_valueTextfield isFirstResponder]) {
        [_valueTextfield resignFirstResponder];
    }
    
    if (searchText.length == 0) {
        return;
    }
    
    if (isKeyboardRefresh) {
        [SVProgressHUD showWithStatus:@"Searching..." maskType:SVProgressHUDMaskTypeBlack];
    }
    
    AppDelegate *appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    NSString *rejectionURL = [NSString stringWithFormat:@"%@/GetRejection?scocd=%@&Xvalue=%@",appDel.baseURL,appDel.selectedCompany.CO_CD,searchText];
    
    ConnectionHandler *handler = [[ConnectionHandler alloc] init];
    handler.delegate = self;

    [handler fetchDataForURL:rejectionURL body:nil];
}

-(void)connectionHandler:(ConnectionHandler*)conHandler didRecieveData:(NSData*)data
{
    NSError *error = nil;
    NSArray *arr = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    
    rejectionsArray = [[NSMutableArray alloc] init];
    
    if (arr.count > 0) {
        
        for (NSDictionary *dict in arr) {
            PCRejectionModel *model = [[PCRejectionModel alloc] init];
            [model setValuesForKeysWithDictionary:dict];
            [rejectionsArray addObject:model];
        }
        lastRefreshTime = [Utility lastRefreshString];
        
        if (!refreshControl) {
            refreshControl = [[UIRefreshControl alloc] init];
            [refreshControl addTarget:self action:@selector(searchRejections:) forControlEvents:UIControlEventValueChanged];
            
            [self setRefreshControl:refreshControl];
        }
    }
    else {
        
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        [refreshControl endRefreshing];
        if (isKeyboardRefresh) {
            [SVProgressHUD dismiss];
            isKeyboardRefresh = NO;
        }
    });
    
}

-(void)connectionHandler:(ConnectionHandler*)conHandler errorRecievingData:(NSError*)error
{
    if ([error code] == -5000) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [SVProgressHUD dismiss];
            
            [Utility showAlertWithTitle:@"IEV" message:@"Internet connection appears to be unavailable.\nPlease check your connection and try again." buttonTitle:@"OK" inViewController:self];
            
        });
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (isKeyboardRefresh) {
            [SVProgressHUD dismiss];
            isKeyboardRefresh = NO;
        }
        [refreshControl endRefreshing];
    });
}

-(IBAction)displayPieChart:(id)sender
{
    PCRejectionsGraphViewController *graphVC = [kStoryboard instantiateViewControllerWithIdentifier:@"PCRejectionsGraphViewController"];
    
    if (rejectionsArray.count == 0) {
        
        [Utility showAlertWithTitle:@"Data not available" message:@"No sufficient data to present a graph.\nTry refreshing again." buttonTitle:@"OK" inViewController:self];

        return;
    }
    
    [graphVC setRejectionsData:rejectionsArray];
    
    graphVC.modalPresentationStyle = UIModalPresentationCurrentContext;
    graphVC.modalTransitionStyle   = UIModalTransitionStyleFlipHorizontal;
    
    [self presentViewController:graphVC animated:YES completion:NULL];
}

- (BOOL)cellIsSelected:(NSIndexPath *)indexPath {
	// Return whether the cell at the specified index path is selected or not
	NSNumber *selectedIndex = [selectedIndexes objectForKey:indexPath];
	return selectedIndex == nil ? FALSE : [selectedIndex boolValue];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return rejectionsArray.count>0?rejectionsArray.count:1;
}

static NSString *reuseIdent = @"PCRejectionsTableViewCell";
static NSString *reuseIdent1 = @"CellIdentifier";

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *returningCell;
    
    if (rejectionsArray.count > 0) {
        
        PCRejectionsTableViewCell *cell1 = (PCRejectionsTableViewCell*)[tableView dequeueReusableCellWithIdentifier:reuseIdent];

        PCRejectionModel *model = [rejectionsArray objectAtIndex:indexPath.row];
        
        cell1.itemCodeLabel.text = [NSString stringWithFormat:@"%@",model.IM_CODE];
        cell1.totalQtyLbl.text = [NSString stringWithFormat:@"%@",model.IM_QTY];
//        cell1.totalValueLabel.text = [Utility stringWithCurrencySymbolForValue:[NSString stringWithFormat:@"%@",model.TOTAL_VALUE]];
//        cell1.rateLabel.text = [Utility stringWithCurrencySymbolForValue:[NSString stringWithFormat:@"%@",model.STD_RATE]];
        
        return cell1;
    }
    else {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdent1];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdent1];
        }
        
        cell.textLabel.textColor = [UIColor darkGrayColor];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:13];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.text = @"No rejected items for this value. Refresh again.";
        return cell;
    }
    
    return returningCell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UILabel *footerLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    footerLbl.textAlignment = NSTextAlignmentCenter;
    footerLbl.font = [UIFont systemFontOfSize:13];
    footerLbl.textColor = [UIColor darkGrayColor];
    
    if (lastRefreshTime != nil) {
        footerLbl.text = [NSString stringWithFormat:@"Last updated : %@",lastRefreshTime];
    }
    else {
        footerLbl.text = [NSString stringWithFormat:@""];
    }
    
    footerLbl.backgroundColor = [UIColor clearColor];
    
    return footerLbl;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	// Deselect cell
	[tableView deselectRowAtIndexPath:indexPath animated:TRUE];
	
	// Toggle 'selected' state
	BOOL isSelected = ![self cellIsSelected:indexPath];
	
	// Store cell 'selected' state keyed on indexPath
	NSNumber *selectedIndex = [NSNumber numberWithBool:isSelected];
	[selectedIndexes setObject:selectedIndex forKey:indexPath];
    
	// This is where magic happens...
	[self.tableView beginUpdates];
	[self.tableView endUpdates];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	// If our cell is selected, return double height
	if([self cellIsSelected:indexPath]) {
		return kCellHeight * 2.0;
	}
	
	// Cell isn't selected so return single height
	return kCellHeight;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    searchText = [NSString stringWithString:textField.text];
    
    searchText = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    isKeyboardRefresh = YES;
    [self searchRejections:textField];
    return YES;
}

@end
