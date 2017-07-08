//
//  PCProjectionGraphViewController.m
//  ERPMobile
//
//  Created by Sameer Ghate on 16/09/14.
//  Copyright (c) 2014 Sameer Ghate. All rights reserved.
//

#import "PCProjectionGraphViewController.h"
#import "PCProjectionModel.h"
#import "TWRBarChart.h"
#import "TWRChart.h"
#import "PCGraphTableViewCell.h"

@interface PCProjectionGraphViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UIView *graphView;
@property (strong, nonatomic) TWRChartView *chartView;
@property (nonatomic, weak) IBOutlet UITableView *legendTableview;
@property (nonatomic, weak) IBOutlet UIView *tableHeaderView;

@end

@implementation PCProjectionGraphViewController

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
    // Do any additional setup after loading the view.

    [self loadGraph];
    
    
//    [_legendTableview setTableHeaderView:_tableHeaderView];
}

-(IBAction)close:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)drawBarGraph
{
    NSMutableArray *recievablesArray, *payablesArray, *monthsArray, *inhandArray;
    
    recievablesArray = [[NSMutableArray alloc] init];
    payablesArray = [[NSMutableArray alloc] init];
    monthsArray = [[NSMutableArray alloc] init];
    inhandArray = [[NSMutableArray alloc] initWithObjects:@0,nil];
    
    for (PCProjectionModel *model in _projectionData) {
        [recievablesArray addObject:model.RECEIVABLE];
        [payablesArray addObject:model.PAYABLE];
        [monthsArray addObject:model.MTH];
    }
    
    TWRDataSet *dataSet2 = [[TWRDataSet alloc] initWithDataPoints:recievablesArray
                                                        fillColor:[[UIColor blueColor] colorWithAlphaComponent:0.5]
                                                      strokeColor:[UIColor blackColor]];
    
    TWRDataSet *dataSet1 = [[TWRDataSet alloc] initWithDataPoints:payablesArray
                                                        fillColor:[[UIColor redColor] colorWithAlphaComponent:0.5]
                                                      strokeColor:[UIColor blackColor]];
    
    // Below fix to prevent bar graph showing from lowest available value, rather than starting from zero.
    
    TWRDataSet *dataSet3 = [[TWRDataSet alloc] initWithDataPoints:inhandArray
                                                        fillColor:[[UIColor clearColor] colorWithAlphaComponent:0.5]
                                                      strokeColor:[UIColor clearColor]];
    dataSet3.pointStrokeColor =[UIColor clearColor];
    dataSet3.pointColor = [UIColor clearColor];
    
    TWRBarChart *bar = [[TWRBarChart alloc] initWithLabels:monthsArray
                                                  dataSets:@[dataSet3, dataSet1, dataSet2]
                                                  animated:YES];

    
    
    // Load data
    [_chartView setBackgroundColor:[UIColor clearColor]];
    [_chartView loadBarChart:bar withCompletionHandler:NULL];
//    [_chartView loadLineChart:line];
    
    
}

-(void)loadGraph
{
    
    CGSize size = _graphView.frame.size;
    
    _chartView = [[TWRChartView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, size.height)];
    
    [_graphView addSubview:_chartView];
    
    [self performSelector:@selector(drawBarGraph) withObject:nil afterDelay:0.5];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _projectionData.count + 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return _tableHeaderView;
    }
    return nil;
}

static NSString *reuseIdentifier = @"PCGraphTableViewCell";
static NSString *reuseIdentifierForAmount = @"reuseIdentifierForAmount";

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    if (indexPath.row == _projectionData.count) {
        
        PCProjectionModel *model = [_projectionData objectAtIndex:0];
        
        UITableViewCell *amtCell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifierForAmount];
        
        if (amtCell == nil) {
            amtCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifierForAmount];
            amtCell.contentView.backgroundColor = [UIColor clearColor];
            amtCell.backgroundColor = [UIColor clearColor];
            amtCell.textLabel.font = [UIFont boldSystemFontOfSize:13];
            amtCell.textLabel.textAlignment = NSTextAlignmentCenter;
            amtCell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        amtCell.textLabel.text = [NSString stringWithFormat:@"Amount in-hand : %@", [Utility stringWithCurrencySymbolForValue:model.INHANDAMT forCurrencyCode:DEFAULT_CURRENCY_CODE]];
        
        return amtCell;
    }
    
    PCGraphTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    
    PCProjectionModel *model = [_projectionData objectAtIndex:indexPath.row];
    
    cell.monthLabel.text = model.MTH;
    cell.payableLabel.text =  [Utility stringWithCurrencySymbolForValue:[NSString stringWithFormat:@"%@",model.PAYABLE] forCurrencyCode:DEFAULT_CURRENCY_CODE];
    cell.recievableLabel.text =  [Utility stringWithCurrencySymbolForValue:[NSString stringWithFormat:@"%@",model.RECEIVABLE] forCurrencyCode:DEFAULT_CURRENCY_CODE];
    
    return cell;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
