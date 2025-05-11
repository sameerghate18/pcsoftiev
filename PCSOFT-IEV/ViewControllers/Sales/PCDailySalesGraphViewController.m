//
//  PCDailySalesGraphViewController.m
//  ERPMobile
//
//  Created by Sameer Ghate on 04/10/14.
//  Copyright (c) 2014 Sameer Ghate. All rights reserved.
//

#import "PCDailySalesGraphViewController.h"

#import <QuartzCore/QuartzCore.h>
#import "XYPieChart.h"
#import "PCDailySalesModel.h"

@implementation PCSalesGraphCell

@end

@interface PCDailySalesGraphViewController () <UITableViewDataSource, UITableViewDelegate,XYPieChartDelegate, XYPieChartDataSource>

{
    NSMutableArray *colorsArray;
    
    NSArray *valuesArray, *monthsArray;
    
    NSInteger selectedSliceIndex;
}

@property (nonatomic, weak) IBOutlet UITableView *legendTableview;
@property (strong, nonatomic) IBOutlet XYPieChart *pieChart;
@property (strong, nonatomic) IBOutlet UIView *pieContainerView;
@property (nonatomic, weak) IBOutlet UIView *tableHeaderView;

@end

@implementation PCDailySalesGraphViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [_legendTableview setTableHeaderView:_tableHeaderView];
    [self performSelector:@selector(loadGraph) withObject:nil afterDelay:1.0];
    
    UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc]
                                      initWithTarget:self action:@selector(handleSingleTap:)];
    tapper.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapper];
}

- (void)handleSingleTap:(UITapGestureRecognizer *)sender
{
    [self.legendTableview deselectRowAtIndexPath:[NSIndexPath indexPathForRow:selectedSliceIndex inSection:0] animated:YES];
    [self.legendTableview scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionTop animated:YES];
    [self.pieChart setSliceDeselectedAtIndex:selectedSliceIndex];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadGraph
{
    //CURRMTH": "0.00",
    /*"CURRYR": "15902900.23",
    "CURR_AMT": "0.00",
    "LASTMTH": "199708.00",
    "PREVMTH"*/
    
    self.pieChart = [[XYPieChart alloc] initWithFrame:self.pieContainerView.bounds];
    
//    NSNumber *currentMonth = [NSNumber numberWithLongLong:[[_salesData valueForKey:@"CURRMTH"] longLongValue]];
//    NSNumber *lastMonth = [NSNumber numberWithLongLong:[[_salesData valueForKey:@"LASTMTH"] longLongValue]];
//    NSNumber *prevToLastMonth = [NSNumber numberWithLongLong:[[_salesData valueForKey:@"PREVMTH"] longLongValue]];
//    NSNumber *totalYear = [NSNumber numberWithLongLong:[[_salesData valueForKey:@"CURRYR"] longLongValue]];
    
//    NSNumber *remainingAmount = [NSNumber numberWithLongLong:[totalYear longLongValue] - ([currentMonth longLongValue] +[lastMonth longLongValue] + [prevToLastMonth longLongValue])];
    
    valuesArray = _salesData;// @[currentMonth,lastMonth,prevToLastMonth,remainingAmount];
//    valuesArray = @[@10000000,lastMonth,@10000000,remainingAmount];
    monthsArray = _salesData; //@[_currentMonthString,_lastMonthString,_prevToLastMonthString,@"Current year"];
    colorsArray = [[NSMutableArray alloc] initWithCapacity:1];
    
    [self.pieChart setDelegate:self];
    [self.pieChart setDataSource:self];
    [self.pieChart setPieRadius:120];
    [self.pieChart setShowPercentage:NO];
    [self.pieChart setLabelColor:[UIColor colorNamed:kCustomWhite]];
    [self.pieChart setBackgroundColor:[UIColor clearColor]];
    
    for (int i = 0; i < valuesArray.count; i++) {
        UIColor *color = [Utility randomColor];
        [colorsArray addObject:color];
    }
    
    [_legendTableview setTableHeaderView:_tableHeaderView];
    
    [_legendTableview reloadData];
    
    [self.pieContainerView addSubview:self.pieChart];
    [self.pieChart reloadData];
}

-(IBAction)close:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - XYPieChart Data Source

- (NSUInteger)numberOfSlicesInPieChart:(XYPieChart *)pieChart
{
    return valuesArray.count;
}

- (CGFloat)pieChart:(XYPieChart *)pieChart valueForSliceAtIndex:(NSUInteger)index
{
    PCDailySalesModel *model = [valuesArray objectAtIndex:index];
    return [[NSNumber numberWithLongLong:[model.MTHAMT longLongValue]] floatValue];
}

- (UIColor *)pieChart:(XYPieChart *)pieChart colorForSliceAtIndex:(NSUInteger)index
{
    return [colorsArray objectAtIndex:index];
}

- (NSString *)pieChart:(XYPieChart *)pieChart textForSliceAtIndex:(NSUInteger)index
{
    PCDailySalesModel *model = [valuesArray objectAtIndex:index];
    return [Utility stringDateFromServerDateYYYYMM:model.YRMTH];
}

#pragma mark - XYPieChart Delegate
- (void)pieChart:(XYPieChart *)pieChart willSelectSliceAtIndex:(NSUInteger)index
{
    NSLog(@"will select slice at index %lu",(unsigned long)index);
}
- (void)pieChart:(XYPieChart *)pieChart willDeselectSliceAtIndex:(NSUInteger)index
{
    NSLog(@"will deselect slice at index %lu",(unsigned long)index);
}

- (void)pieChart:(XYPieChart *)pieChart didDeselectSliceAtIndex:(NSUInteger)index
{
    NSLog(@"did deselect slice at index %lu",(unsigned long)index);
    
    [self.legendTableview deselectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:YES];
}

- (void)pieChart:(XYPieChart *)pieChart didSelectSliceAtIndex:(NSUInteger)index
{
    NSLog(@"did select slice at index %lu",(unsigned long)index);
    
    selectedSliceIndex = index;
    
    //    self.selectedSliceLabel.text = [NSString stringWithFormat:@"$%@",[self.slices objectAtIndex:index]];
    
    [self.legendTableview selectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];
}

#pragma mark - Tableview

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return 30;
//}
//
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    return _tableHeaderView;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return valuesArray.count + 1;
}


static NSString *reuseIdentifier = @"PCSalesGraphCell";
static NSString *reuseIdentifierForAmount = @"amountCell";

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == valuesArray.count) {
        UITableViewCell *amtCell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifierForAmount];
        
        if (amtCell == nil) {
            amtCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifierForAmount];
            amtCell.contentView.backgroundColor = [UIColor clearColor];
            amtCell.backgroundColor = [UIColor clearColor];
            amtCell.textLabel.font = [UIFont boldSystemFontOfSize:13];
            amtCell.textLabel.textAlignment = NSTextAlignmentCenter;
        }
        
        PCDailySalesModel *model = [valuesArray objectAtIndex:0];
        amtCell.textLabel.text = [NSString stringWithFormat:@"Total Yearly: %@", [Utility stringWithCurrencySymbolForValue:model.CURRYR forCurrencyCode:self.currencyCode]];
        
        amtCell.textLabel.textColor = [UIColor colorNamed:kCustomBlack];
        
        return amtCell;
    }
    
    PCSalesGraphCell *cell = (PCSalesGraphCell*)[tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    
    PCDailySalesModel *model = [valuesArray objectAtIndex:indexPath.row];
    
    cell.monthLabel.text = [Utility stringDateFromServerDateYYYYMM:model.YRMTH];
    cell.salesAmountLabel.text = [Utility stringWithCurrencySymbolForValue:model.MTHAMT forCurrencyCode:self.currencyCode];
    [cell.legendView setBackgroundColor:[colorsArray objectAtIndex:indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedSliceIndex = indexPath.row;
    [self.pieChart setSliceSelectedAtIndex:indexPath.row];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.pieChart setSliceDeselectedAtIndex:indexPath.row];
}

@end
