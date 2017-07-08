//
//  PCAboutAppViewController.m
//  ERPMobile
//
//  Created by Sameer Ghate on 26/11/14.
//  Copyright (c) 2014 Sameer Ghate. All rights reserved.
//

#import "PCAboutAppViewController.h"

@interface PCAboutAppViewController () <UITableViewDelegate>

{
    NSArray *cells;
}
@property (nonatomic, weak) IBOutlet UITableView *tableview;

//@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *cells;

@property (strong, nonatomic) IBOutlet UIView *headerView;

@property (strong, nonatomic) IBOutlet UITableViewCell *topImageCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *coverTextCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *aboutappCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *aboutcompanyHeaderCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *aboutCompanyInfoCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *contactDetailsHeaderCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *contactDetailsCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *callCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *email1Cell;
@property (strong, nonatomic) IBOutlet UITableViewCell *email2Cell;
@property (strong, nonatomic) IBOutlet UITableViewCell *websiteCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *companylogoCell;

@end

@implementation PCAboutAppViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    cells = @[_topImageCell,
//              _coverTextCell,
//              _aboutappCell,
//              _aboutcompanyHeaderCell,
//              _aboutCompanyInfoCell,
//              _contactDetailsHeaderCell,
//              _contactDetailsCell,
//              _callCell,
//              _email1Cell,
//              _email2Cell,
//              _websiteCell,
//              _companylogoCell];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)showSideMenu
{
    AppDelegate *appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    [appDel.slideViewController showLeftViewControllerAnimated:YES];
}

//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    return cells.count;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
//{
//    return cells[indexPath.row];
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
