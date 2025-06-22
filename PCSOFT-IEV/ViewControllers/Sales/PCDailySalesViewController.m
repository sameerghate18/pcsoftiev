//
//  PCDailySalesViewController.m
//  ERPMobile
//
//  Created by Sameer Ghate on 07/09/14.
//  Copyright (c) 2014 Sameer Ghate. All rights reserved.
//

#import "PCDailySalesViewController.h"
#import "SVProgressHUD.h"
#import "ConnectionHandler.h"
#import <QuartzCore/QuartzCore.h>
#import "PCDailySalesTableViewCell.h"
#import "PCDailySalesGraphViewController.h"
#import "PCTblGroupModel.h"
#import "PCFinYearsModel.h"
#import "PCDailySalesModel.h"

typedef enum
{
    PickerTypeTblGroup,
    PickerTypeFinYear
}PickerType;

@interface PCDailySalesViewController () <UITableViewDataSource, UITableViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate>
{
    NSMutableArray *finYearsArray;
    PCTblGroupModel *grpMenuItems;
    PCTblGroupModelElement *selectedGroup;
    NSInteger currentIndexOnRoll, userSelectedIndex;
    NSString *currentMonth, *lastMonth, *previousToLastMonth;
    SalesType salesType;
    NSString *lastRefreshTime;
    PCFinYearsModel *selectedFinYear;
    PickerType pickerType;
    BOOL isCheckBoxSelected;
}

@property (nonatomic, strong) IBOutlet UILabel *todaysSales, *totalSales, *lastUpdateLabel;
@property (nonatomic, weak) IBOutlet UIImageView *boxImgView1, *boxImgView2;

@property (nonatomic, weak) IBOutlet UIButton *refreshBtn, *checkBoxButton, *submitButton;
@property (nonatomic, weak) IBOutlet UITextField *groupLabelTextbox;
@property (nonatomic, weak) IBOutlet UITextField *finYearTextbox;

@property (nonatomic, weak) IBOutlet UITableView *salesTable;
@property (nonatomic, strong) UIPickerView *grpMenuPicker;
@property (nonatomic, strong) UIPickerView *finYearPicker;

//@property (nonatomic, strong) NSDictionary *salesData, *exportSalesData, *tableSourceData;
@property (nonatomic, strong) NSMutableArray *domesticSalesData, *exportSalesData, *tableSourceData;
@end

@implementation PCDailySalesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = TRUE;
    
    self.navigationItem.hidesBackButton = YES;
    
    [self setTitle:@"Daily Sales"];
    
    self.domesticSalesData = [[NSMutableArray alloc] init];
    self.exportSalesData = [[NSMutableArray alloc] init];
    
    isCheckBoxSelected = false;
    [self.checkBoxButton setImage:[UIImage imageNamed:@"uncheck.png"] forState:UIControlStateNormal];
    [self.checkBoxButton setImage:[UIImage imageNamed:@"check.png"] forState:UIControlStateSelected];
    
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setImage:[UIImage imageNamed:@"menu-icon.png"] forState:UIControlStateNormal];
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setImage:[UIImage imageNamed:@"dailysales-side-icon.png"] forState:UIControlStateNormal];
    
    UIBarButtonItem *barbtn = [[UIBarButtonItem alloc]  initWithImage:[UIImage imageNamed:@"menu_icon.png"] style:UIBarButtonItemStylePlain target:self action:@selector(showSideMenu)];
    
//    UIBarButtonItem *barbtn = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    
    self.navigationItem.leftBarButtonItem = barbtn;
    
    UIBarButtonItem *rightBarbtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"graph.png"] style:UIBarButtonItemStylePlain target:self action:@selector(displaySalesPieChart:)];
    
//    UIBarButtonItem *rightBarbtn = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    
    self.navigationItem.rightBarButtonItem = rightBarbtn;
    
    salesType = SalesTypeDomestic;
    
    finYearsArray = [[NSMutableArray alloc] init];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([[defaults valueForKey:kSelectedCompanyTbGrp]  isEqual: @1]) {
        [self fetchTableGroups];
        self.groupLabelTextbox.hidden = false;
    } else {
        self.groupLabelTextbox.hidden = true;
        [self getFinYears];
    }
    
    // Do any additional setup after loading the view.
}

-(void)getDates
{
    NSDate *currentDate = [NSDate date];
    
    NSDate *lastMonthDate, *previousToLastMonthDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [NSDateComponents new];
    
    comps.month = -1;
    comps.day   = -1;
    
    lastMonthDate = [calendar dateByAddingComponents:comps toDate:[NSDate date] options:0];
    
    previousToLastMonthDate = [calendar dateByAddingComponents:comps toDate:lastMonthDate options:0];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateFormat:@"MMM yyyy"];
    
    currentMonth = [formatter stringFromDate:currentDate];
    lastMonth = [formatter stringFromDate:lastMonthDate];
    previousToLastMonth = [formatter stringFromDate:previousToLastMonthDate];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)checkButtonAction {
    
//    isCheckBoxSelected = !isCheckBoxSelected;
    
    _checkBoxButton.selected = !_checkBoxButton.selected;
    isCheckBoxSelected = _checkBoxButton.selected;
    
//    if (isCheckBoxSelected == true) {
//        [self.checkBoxButton setImage:[UIImage imageNamed:@"check.png"] forState:UIControlStateNormal];
//    } else {
//        [self.checkBoxButton setImage:[UIImage imageNamed:@"uncheck.png"] forState:UIControlStateNormal];
//        
//        self.checkBoxButton image
//    }
}

-(IBAction)showSideMenu
{
    AppDelegate *appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    [appDel.slideViewController showLeftViewControllerAnimated:YES];
}

-(IBAction)displaySalesPieChart:(id)sender
{
    if (!_tableSourceData ) {
        [Utility showAlertWithTitle:@"Data not available" message:@"No sufficient data to present a graph.\nTry refreshing again." buttonTitle:@"OK" inViewController:self];
        return;
    }
    
    PCDailySalesGraphViewController *graphVC = [kStoryboard instantiateViewControllerWithIdentifier:@"PCDailySalesGraphViewController"];
    
    [graphVC setSelectedSalesType:salesType];
    [graphVC setSalesData:_tableSourceData];
    [graphVC setCurrentMonthString:currentMonth];
    [graphVC setLastMonthString:lastMonth];
    [graphVC setPrevToLastMonthString:previousToLastMonth];
    
    graphVC.modalPresentationStyle = UIModalPresentationCurrentContext;
    graphVC.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    
    [self presentViewController:graphVC animated:YES completion:NULL];
}

-(IBAction)toggleSalesType:(id)sender
{
    UISegmentedControl *segment = (UISegmentedControl*)sender;
    
    switch (segment.selectedSegmentIndex) {
        case 0:
        {
            _tableSourceData = _domesticSalesData;
            salesType = SalesTypeDomestic;
        }
            break;
            
        case 1:
        {
            _tableSourceData = _exportSalesData;
            salesType = SalesTypeExport;
        }
            break;
            
        default:
            break;
    }
    
    [_salesTable reloadData];
}

-(void)fetchTableGroups {
    
    AppDelegate *appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    [SVProgressHUD showWithStatus:@"Loading data..." maskType:SVProgressHUDMaskTypeBlack];
    ConnectionHandler *handler = [[ConnectionHandler alloc] init];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *companyCode = [defaults valueForKey:kSelectedCompanyCode];
    
    NSString *url = [NSString stringWithFormat:@"%@/%@",appDel.baseURL,kTblGrpService];
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:companyCode,kScoCodeKey, nil];
    
    [handler fetchDataForGETURL:url body:dict completion:^(id responseData, NSError *error) {
        
        if (error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSString *msg = @"Error details not available.";
                
                if ([error code] == -5000) {
                    msg = noInternetMessage;
                } else {
                    msg = [error localizedDescription];
                }
                
                [SVProgressHUD dismiss];
                [Utility showAlertWithTitle:@"IEV" message:msg buttonTitle:@"OK" inViewController:self];
            });
            return;
        }
        
        self->grpMenuItems = PCTblGroupModelFromData((NSData*)responseData, &error);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [SVProgressHUD dismiss];
            
            if (self->grpMenuItems.count > 0) {
                
                self.submitButton.enabled = true;
                
                PCTblGroupModelElement *allGroup = [[PCTblGroupModelElement alloc] init];
                allGroup.code = @"";
                allGroup.descr = @"All";
                [self->grpMenuItems insertObject:allGroup atIndex:0];
                // Populate menu
                [self createGrpMenu];
                [self getFinYears];
            } else {
                [Utility showAlertWithTitle:@"Daily Sales" message:@"No groups found." buttonTitle:@"Ok" inViewController:self];
                self.submitButton.enabled = false;
            }
        });
    }];
    
}

-(void)createGrpMenu {
    
    UIToolbar *menuToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(menuBarCancelPressed)];
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(menuBarDonePressed)];
    
    menuToolbar.items = @[cancel,space,done];
    
    self.grpMenuPicker = [[UIPickerView alloc] init];
    self.grpMenuPicker.dataSource = self;
    self.grpMenuPicker.delegate = self;
    self.grpMenuPicker.showsSelectionIndicator = true;
    
    self.groupLabelTextbox.inputAccessoryView = menuToolbar;
    self.groupLabelTextbox.inputView = self.grpMenuPicker;
    
    currentIndexOnRoll = userSelectedIndex = 0;
    selectedGroup = [self->grpMenuItems objectAtIndex:userSelectedIndex];
    self.groupLabelTextbox.text = selectedGroup.descr;
    
    pickerType = PickerTypeTblGroup;
    
//    [self fetchDailySalesData:nil];
    
}

-(void)createFinYearPicker {
    
    UIToolbar *menuToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(menuBarCancelPressed)];
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(menuBarDonePressed)];
    
    menuToolbar.items = @[cancel,space,done];
    self.finYearPicker = [[UIPickerView alloc] init];
    self.finYearPicker.dataSource = self;
    self.finYearPicker.delegate = self;
    self.finYearPicker.showsSelectionIndicator = true;
    
    self.finYearTextbox.inputAccessoryView = menuToolbar;
    self.finYearTextbox.inputView = self.finYearPicker;
    
    currentIndexOnRoll = userSelectedIndex = 0;
    selectedFinYear = [self->finYearsArray objectAtIndex:userSelectedIndex];
    self.finYearTextbox.text = selectedFinYear.CURRYR;
    pickerType = PickerTypeFinYear;

    selectedGroup = [grpMenuItems objectAtIndex:0];
//    [self fetchDailySalesData:nil];
}

-(void)menuBarCancelPressed {
    
    [self.groupLabelTextbox resignFirstResponder];
    [self.finYearTextbox resignFirstResponder];
}

-(void)menuBarDonePressed {
     
    if (pickerType == PickerTypeTblGroup) {
        selectedGroup = [self->grpMenuItems objectAtIndex:currentIndexOnRoll];
        self.groupLabelTextbox.text = selectedGroup.descr;
        [self.groupLabelTextbox resignFirstResponder];
//        [self fetchDailySalesData:nil];
        
    } else if (pickerType == PickerTypeFinYear) {
        selectedFinYear = [self->finYearsArray objectAtIndex:currentIndexOnRoll];
        self.finYearTextbox.text = selectedFinYear.CURRYR;
        [self.finYearTextbox resignFirstResponder];
//        [self fetchDailySalesData:nil];
    }
    
    // fetch sales data for selected group code
}

-(void)getFinYears
{
    AppDelegate *appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    [SVProgressHUD showWithStatus:@"Loading data..." maskType:SVProgressHUDMaskTypeBlack];
    ConnectionHandler *handler = [[ConnectionHandler alloc] init];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *companyCode = [defaults valueForKey:kSelectedCompanyCode];
    
    NSDictionary *postDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              companyCode, kScoCodeKey,
                              nil];
    
    [handler fetchDataForGETURL:[NSString stringWithFormat:@"%@/iev/GetFinYears",appDel.baseURL] body:postDict completion:^(id responseData, NSError *error) {
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&error];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (dict != nil) {

                NSArray *arr = [dict objectForKey:kDataKey];
                
                for (NSDictionary *dict in arr) {
                    PCFinYearsModel *model = [[PCFinYearsModel alloc] init];
                    [model setValuesForKeysWithDictionary:dict];
                    [self->finYearsArray addObject:model];
                }
                
                if (self->finYearsArray.count > 0) {
                    [self createFinYearPicker];
                    self.submitButton.enabled = true;
                } else {
                    self.submitButton.enabled = false;
                }
                
            } else {
                self.submitButton.enabled = false;
            }
            
            [SVProgressHUD dismiss];
        });
    }];
}

-(IBAction)fetchDailySalesData:(id)sender
{
    [self.domesticSalesData removeAllObjects];
    [self.exportSalesData removeAllObjects];
    [self.tableSourceData removeAllObjects];
    
    AppDelegate *appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    [SVProgressHUD showWithStatus:@"Loading data..." maskType:SVProgressHUDMaskTypeBlack];
    ConnectionHandler *handler = [[ConnectionHandler alloc] init];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *companyCode = [defaults valueForKey:kSelectedCompanyCode];
    
    NSString *groupCode = @" ";
    if ([[defaults valueForKey:kSelectedCompanyTbGrp]  isEqual: @1]) {
        groupCode = selectedGroup.code;
    }
    
    NSDictionary *postDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                              companyCode, kScoCodeKey,
                              groupCode, @"tbgrp",
                              selectedFinYear.CURRYR, @"frToDate",
                              [NSNumber numberWithBool:isCheckBoxSelected], @"ShowNetAmt",
                              nil];
    
    [handler fetchDataForGETURL:[NSString stringWithFormat:@"%@/iev/GetTodaysSaleTBN",appDel.baseURL] body:postDict completion:^(id responseData, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (error == nil) {
                
                NSError *error1 = nil;
                
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&error1];
                
                if (error1 == nil) {
                    
                    BOOL status = [[dict objectForKey:@"Status"] boolValue];
                    
                    if (status == true) {
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            NSDictionary *dict1 = [dict objectForKey:@"data2"];
                            
                            NSArray *domesticJson = [dict1 objectForKey:@"Domestic"];
                            NSLog(@"fetchDailySalesData domesticJson- %@",domesticJson);
                            
                            if (domesticJson.count > 0) {
                                
                                for (NSDictionary *dict in domesticJson) {
                                    PCDailySalesModel *model = [[PCDailySalesModel alloc] init];
                                    [model setValuesForKeysWithDictionary:dict];
                                    model.CUR_SYMB = [model.CUR_SYMB stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                                    model.CUR_SYMB = @"₹";
                                    model.CUR_DESC = @"INR";
                                
                                    [self.domesticSalesData addObject:model]; // Domestic Sales
                                }
                            } else {
                                NSLog(@"fetchDailySalesData - error no domesticJson");
                                [SVProgressHUD dismiss];
                                [Utility showAlertWithTitle:@"Daily Sales" message:@"No domestic sales data available for the selected combination." buttonTitle:@"OK" inViewController:self];
                            }
                            
                            NSArray *exportJson = [dict1 objectForKey:@"Export"];
                            NSLog(@"fetchDailySalesData exportJson- %@",exportJson);
                            
                            if (exportJson.count > 0) {
                                
                                for (NSDictionary *dict in exportJson) {
                                    PCDailySalesModel *model = [[PCDailySalesModel alloc] init];
                                    [model setValuesForKeysWithDictionary:dict];
                                    
                                    model.CUR_SYMB = [model.CUR_SYMB stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                                    
                                    if (([model.CUR_SYMB rangeOfString:@"$"].location != NSNotFound)){
                                        model.CUR_DESC = @"USD";
                                    } else if (([model.CUR_DESC rangeOfString:@"₹"].location != NSNotFound)) {
                                        model.CUR_DESC = @"INR";
                                    } else if (model.CUR_DESC.length == 0) {
                                        model.CUR_SYMB = @"₹";
                                        model.CUR_DESC = @"INR";
                                    }
                                    
                                    [self.exportSalesData addObject:model]; // Export Sales
                                }
                            } else {
                                NSLog(@"fetchDailySalesData - error no exportJson");
                                [SVProgressHUD dismiss];
                                [Utility showAlertWithTitle:@"Daily Sales" message:@"No export sales data available for the selected combination." buttonTitle:@"OK" inViewController:self];
                            }
                            
                            self->lastRefreshTime = [Utility lastRefreshString];
                            self->_lastUpdateLabel.text = [NSString stringWithFormat:@"Last updated: %@",self->lastRefreshTime];
                            
                            if (self->salesType == SalesTypeDomestic) {
                                self->_tableSourceData = self->_domesticSalesData;
                            } else {
                                self->_tableSourceData = self->_exportSalesData;
                            }
                            
                            [self->_salesTable reloadData];
                            self->userSelectedIndex = self->currentIndexOnRoll;
                            
                            [SVProgressHUD showSuccessWithStatus:@"Done"];
                        });
                    } else {                        
                        [SVProgressHUD dismiss];
                        [Utility showAlertWithTitle:@"Daily Sales" message:@"Error fetching data." buttonTitle:@"OK" inViewController:self];
                    }
                } else {
                    [SVProgressHUD dismiss];
                    [Utility showAlertWithTitle:@"Daily Sales" message:@"Error fetching data." buttonTitle:@"OK" inViewController:self];
                    NSLog(@"fetchDailySalesData - error dict %@",error1);
                }
                
            } else {
                [SVProgressHUD dismiss];
                [Utility showAlertWithTitle:@"Daily Sales" message:[NSString stringWithFormat:@"Error fetching data. \n%@",error] buttonTitle:@"OK" inViewController:self];
                NSLog(@"fetchDailySalesData - error %@",error);
            }
            
            [self->_salesTable reloadData];
            
        });
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==3) {
        return 40.0f;
    }
    
    return 135.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView   {
    
    if (_tableSourceData.count > 0) {
        return 4;
    } else
        return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return  1;
    }
    
    if (section == 2) {
        return  1;
    }
    
    if (section == 3) {
        return  1;
    }
    
    if (_tableSourceData.count > 0) {
        return _tableSourceData.count;
    } else
        return 0;
}

static NSString *cellIdentifier = @"PCDailySalesTableViewCell";
static NSString *noitemsCellIdentifier = @"NoItemsCell";
static NSString *lastUpdateCellIdentifier = @"lastUpdateCellIdentifier";

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 3) {
        
        UITableViewCell *lastUpdateCell = [tableView dequeueReusableCellWithIdentifier:lastUpdateCellIdentifier];
        
        if (lastUpdateCell==nil) {
            lastUpdateCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:lastUpdateCellIdentifier];
            lastUpdateCell.textLabel.font = [UIFont systemFontOfSize:13];
            lastUpdateCell.textLabel.textColor = [UIColor colorNamed:kCustomGray];
            //            lastUpdateCell.textLabel.backgroundColor = [UIColor clearColor];
            lastUpdateCell.textLabel.textAlignment = NSTextAlignmentCenter;
            //            lastUpdateCell.contentView.backgroundColor = [UIColor clearColor];
            lastUpdateCell.backgroundColor = [UIColor clearColor];
            lastUpdateCell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        lastUpdateCell.textLabel.text = [NSString stringWithFormat:@"Last updated : %@",lastRefreshTime];
        
        return lastUpdateCell;
        
    } else if (indexPath.section == 0) {
        
        if (_tableSourceData.count > 0) {
            PCDailySalesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
            PCDailySalesModel *model = [self.tableSourceData objectAtIndex:0];
            
            cell.headerLabel.text = @"Today's Sale";
            cell.subtitleLabel.text = [Utility stringWithCurrencySymbolForValue:model.CURR_AMT forCurrencySymbol:model.CUR_SYMB];
            return cell;
        } else {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:noitemsCellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
        
    } else if (indexPath.section == 2) {
        
        PCDailySalesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        PCDailySalesModel *model = [self.tableSourceData objectAtIndex:0];
        
        cell.headerLabel.text = @"Total Yearly";
        cell.subtitleLabel.text = [Utility stringWithCurrencySymbolForValue:model.CURRYR forCurrencySymbol:model.CUR_SYMB];
        return cell;
        
    } else {
        
        PCDailySalesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        
        PCDailySalesModel *model = [self.tableSourceData objectAtIndex:indexPath.row];
        
        NSString *monthString = [Utility stringDateFromServerDateYYYYMM:model.YRMTH];
        cell.headerLabel.text = monthString;
        cell.subtitleLabel.text = [Utility stringWithCurrencySymbolForValue:model.MTHAMT forCurrencySymbol:model.CUR_SYMB];
        cell.subtitleLabel.textAlignment = NSTextAlignmentCenter;
        return cell;
        
    }
}

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    if (pickerType == PickerTypeTblGroup) {
        PCTblGroupModelElement *item = [grpMenuItems objectAtIndex:row];
        return item.descr;
    } else if (pickerType == PickerTypeFinYear) {
        PCFinYearsModel *item = [finYearsArray objectAtIndex:row];
        return item.CURRYR;
    }
    return @"NA";
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    if (pickerType == PickerTypeTblGroup) {
        return grpMenuItems.count;
    } else if (pickerType == PickerTypeFinYear) {
        return finYearsArray.count;
    }
    return 0;
    
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (pickerType == PickerTypeTblGroup) {
        self->currentIndexOnRoll = row;
    } else if (pickerType == PickerTypeFinYear) {
        self->currentIndexOnRoll = row;
    }
    
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField.tag == 100) {
        pickerType = PickerTypeTblGroup;
    } else if (textField.tag == 101) {
        pickerType = PickerTypeFinYear;
    }
}

@end
