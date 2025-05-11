//
//  PCRejectionsGraphViewController.m
//  ERPMobile
//
//  Created by Sameer Ghate on 30/09/14.
//  Copyright (c) 2014 Sameer Ghate. All rights reserved.
//

#import "PCRejectionsGraphViewController.h"
#import "PCRejectionModel.h"
#import "TWRCircularChart.h"
#import "TWRChartView.h"
#import "TWRChart.h"

#import <QuartzCore/QuartzCore.h>
#import "XYPieChart.h"

@implementation PCRejectionsGraphCell

@end

@interface PCRejectionsGraphViewController () <XYPieChartDelegate, XYPieChartDataSource, UITableViewDataSource, UITableViewDelegate>

{
    NSMutableArray *rejectionCount, *colorsArray, *itemNamesArray;
    NSInteger selectedSliceIndex;
}

@property (strong, nonatomic) IBOutlet XYPieChart *pieChart;
@property (strong, nonatomic) IBOutlet UIView *pieContainerView;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIView *tableHeaderView;

@end

@implementation PCRejectionsGraphViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self performSelector:@selector(loadGraph) withObject:nil afterDelay:1.0];
    [_tableView setTableHeaderView:_tableHeaderView];
    
    UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc]
                                      initWithTarget:self action:@selector(handleSingleTap:)];
    tapper.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapper];
}

- (void)handleSingleTap:(UITapGestureRecognizer *)sender
{
    [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:selectedSliceIndex inSection:0] animated:YES];
    [self.tableView scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionTop animated:YES];
    [self.pieChart setSliceDeselectedAtIndex:selectedSliceIndex];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)close:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}


-(void)loadGraph
{
    self.pieChart = [[XYPieChart alloc] initWithFrame:self.pieContainerView.bounds];
    
    rejectionCount = [[NSMutableArray alloc] init];
    
    itemNamesArray = [[NSMutableArray alloc] init];
    
    for (PCRejectionModel *model in _rejectionsData) {
        int intVal = [model.IM_QTY intValue];
        NSNumber *one = [NSNumber numberWithInt:intVal];
        [rejectionCount addObject:one];
        
        [itemNamesArray addObject:model.IM_CODE];
    }
    
    colorsArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < rejectionCount.count; i++) {
        UIColor *color = [[Utility randomColor] copy];
        [colorsArray addObject:color];
    }
    
    [self.pieChart setDelegate:self];
    [self.pieChart setDataSource:self];
    [self.pieChart setPieRadius:120.0f];
    [self.pieChart setShowPercentage:NO];
    [self.pieChart setLabelFont:[UIFont boldSystemFontOfSize:12]];
    [self.pieChart setLabelColor:[UIColor colorNamed:kCustomWhite]];
    [self.pieChart setBackgroundColor:[UIColor clearColor]];
    
    [self.pieContainerView addSubview:self.pieChart];
    
    [self.pieChart reloadData];
    [self.tableView reloadData];
}

#pragma mark - XYPieChart Data Source

- (NSUInteger)numberOfSlicesInPieChart:(XYPieChart *)pieChart
{
    return rejectionCount.count;
}

- (CGFloat)pieChart:(XYPieChart *)pieChart valueForSliceAtIndex:(NSUInteger)index
{
    return [[rejectionCount objectAtIndex:index] intValue];
}

- (UIColor *)pieChart:(XYPieChart *)pieChart colorForSliceAtIndex:(NSUInteger)index
{
    return [colorsArray objectAtIndex:index];
}

- (NSString *)pieChart:(XYPieChart *)pieChart textForSliceAtIndex:(NSUInteger)index
{
    return [itemNamesArray objectAtIndex:index];
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
    [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:YES];
}
- (void)pieChart:(XYPieChart *)pieChart didSelectSliceAtIndex:(NSUInteger)index
{
    NSLog(@"did select slice at index %lu",(unsigned long)index);
    
    selectedSliceIndex = index;
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];
}

#pragma mark - Tableview

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _rejectionsData.count;
}

static NSString *reuseIdentifier = @"PCRejectionsGraphCell";

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PCRejectionsGraphCell *cell = (PCRejectionsGraphCell*)[tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    
    PCRejectionModel *model = [_rejectionsData objectAtIndex:indexPath.row];
    
    cell.itemCode.text = [NSString stringWithFormat:@"%@",model.IM_CODE];
    cell.itemQty.text = [NSString stringWithFormat:@"%@",model.IM_QTY];
    [cell.colorBox setBackgroundColor:[colorsArray objectAtIndex:indexPath.row]];

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
