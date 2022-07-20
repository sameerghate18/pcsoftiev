//
//  PCAttendanceTableViewController.m
//  ERPMobile
//
//  Created by Sameer Ghate on 07/09/14.
//  Copyright (c) 2014 Sameer Ghate. All rights reserved.
//

#import "PCAttendanceTableViewController.h"
#import "ConnectionHandler.h"
#import "PCAttendanceModel.h"
#import "PCAttendanceTableViewCell.h"
#import "AttendanceDetailCell.h"

static NSString *reuseIdent = @"AttendancePrimaryCell";
static NSString *reuseIdentDetailCell = @"AttendanceDetailCell";
static NSString *identifier1 = @"BlankCell";
static NSString *noitemsCellIdentifier = @"NoItemsCell";
static NSString *lastUpdateCellIdentifier = @"lastUpdateCellIdentifier";

@interface PCAttendanceTableViewController () <ConnectionHandlerDelegate, UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *attendanceArray, *tableDataArray;
    UIRefreshControl *refreshControl;
    NSString *lastRefreshTime;
    NSMutableDictionary *selectedIndexes;
}

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableSet *expandedIndexPaths;

- (BOOL)cellIsSelected:(NSIndexPath *)indexPath;

@end

#define kCellHeight 60.0f;
#define kCellExpandedHeight 215.0f;

@implementation PCAttendanceTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = FALSE;
    
    
    UINib *cellNib = [UINib nibWithNibName:NSStringFromClass([AttendanceDetailCell class])
                                    bundle:nil];
    [self.tableView registerNib:cellNib
         forCellReuseIdentifier:reuseIdentDetailCell];
    
    _expandedIndexPaths = [NSMutableSet set];

    selectedIndexes = [[NSMutableDictionary alloc] init];
    
    self.navigationController.navigationBarHidden = TRUE;
    
    self.navigationItem.hidesBackButton = TRUE;
    
    [self setTitle:@"Attendance"];
    UIBarButtonItem *barbtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu_icon.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(showSideMenu)];
    
    self.navigationItem.leftBarButtonItem = barbtn;
    
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshAttendance:) forControlEvents:UIControlEventValueChanged];
//    [self setRefreshControl:refreshControl];
    
    [self refreshAttendance:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)showSideMenu
{
    AppDelegate *appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    [appDel.slideViewController showLeftViewControllerAnimated:YES];
}


-(IBAction)refreshAttendance:(id)sender
{
    AppDelegate *appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    ConnectionHandler *handler = [[ConnectionHandler alloc] init];
    handler.delegate = self;
    
    [refreshControl beginRefreshing];

    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM-dd-yyyy"];
    NSString *date = [dateFormat stringFromDate:[NSDate date]];
    
    NSString *url = [NSString stringWithFormat:@"%@GetAttendance?scocd=%@&rPerson=%@&sDate=%@",appDel.baseURL,
                     appDel.selectedCompany.CO_CD,
                     appDel.loggedUser.USER_ID,
                     date];

    [handler fetchDataForURL:url body:nil];
}

-(void)connectionHandler:(ConnectionHandler*)conHandler didRecieveData:(NSData*)data
{
    NSError *error = nil;
    NSArray *arr = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    
    if (!attendanceArray) {
        attendanceArray = [[NSMutableArray alloc] init];
    }
    
    if (arr.count > 0) {
        
        [attendanceArray removeAllObjects];
        
        for (NSDictionary *dict in arr) {
            PCAttendanceModel *model = [[PCAttendanceModel alloc] init];
            [model setValuesForKeysWithDictionary:dict];
            [attendanceArray addObject:model];
        }
        
        lastRefreshTime = [Utility lastRefreshString];
    }
    else {
        
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        [refreshControl endRefreshing];
    });
}



-(void)connectionHandler:(ConnectionHandler*)conHandler errorRecievingData:(NSError*)error
{
    if ([error code] == -5000) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [Utility showAlertWithTitle:@"IEV" message:noInternetMessage buttonTitle:@"OK" inViewController:self];
            
        });
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [refreshControl endRefreshing];
    });
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        if (attendanceArray.count > 0) {
            return attendanceArray.count;
        }
        else {
            return 1;
        }
    }
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell1;
    
    if (indexPath.section == 1) {
        
        UITableViewCell *lastUpdateCell = [tableView dequeueReusableCellWithIdentifier:lastUpdateCellIdentifier];
        
        if (lastUpdateCell==nil) {
            lastUpdateCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:lastUpdateCellIdentifier];
            lastUpdateCell.textLabel.font = [UIFont systemFontOfSize:13];
            lastUpdateCell.textLabel.textColor = [UIColor darkGrayColor];
//            lastUpdateCell.textLabel.backgroundColor = [UIColor clearColor];
            lastUpdateCell.textLabel.textAlignment = NSTextAlignmentCenter;
//            lastUpdateCell.contentView.backgroundColor = [UIColor clearColor];
            lastUpdateCell.backgroundColor = [UIColor clearColor];
        }
        
        lastUpdateCell.textLabel.text = [NSString stringWithFormat:@"Last updated : %@",lastRefreshTime];
        lastUpdateCell.selectionStyle = UITableViewCellSelectionStyleNone;
        return lastUpdateCell;
    }
    
    if (attendanceArray.count > 0) {
        
            PCAttendanceModel *model = [attendanceArray objectAtIndex:indexPath.row];
            
            AttendanceDetailCell *detailCell = (id)[tableView dequeueReusableCellWithIdentifier:reuseIdentDetailCell];
            
            detailCell.employeeName.text = [model.NAME stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            detailCell.ofcTimeIn.text = [model.OTIME_IN stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            detailCell.empNumber.text = [model.EMP_NO stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            detailCell.reportingTo.text = [model.REPORTING stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            detailCell.shiftDate.text = [model.SHFT_DATE stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            detailCell.fromDate.text = [model.FR_DATE stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            detailCell.toDate.text = [model.TO_DATE stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            detailCell.reason.text = [model.REASON stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            return detailCell;
    }
    else {
        
        cell1 = [tableView dequeueReusableCellWithIdentifier:noitemsCellIdentifier];
        cell1.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell1;
    }
}

/*
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UILabel *footerLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    footerLbl.textAlignment = NSTextAlignmentCenter;
    footerLbl.font = [UIFont systemFontOfSize:13];
    footerLbl.textColor = [UIColor lightGrayColor];
    footerLbl.backgroundColor = [UIColor clearColor];
    
    if (lastRefreshTime != nil) {
        footerLbl.text = [NSString stringWithFormat:@"Last updated : %@",lastRefreshTime];
    }
    else {
        footerLbl.text = [NSString stringWithFormat:@""];
    }
    
    if (attendanceArray.count > 0) {
        return footerLbl;
    }
    else {
        return nil;
    }
}
 */

/*
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
 */

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if ([self.expandedIndexPaths containsObject:indexPath]) {
         [self.expandedIndexPaths removeObject:indexPath];
    }
    else {
        [self.expandedIndexPaths addObject:indexPath];
    }
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	// If our cell is selected, return double height
    
     if (indexPath.section == 1) {
         return 50.0f;
     }
    
    if (attendanceArray.count > 0) {
        
        if ([self.expandedIndexPaths containsObject:indexPath]) {
            return kCellExpandedHeight;
        }
        // Cell isn't selected so return single height
        return kCellHeight;
    }
    
    return 200;
    
}
@end
