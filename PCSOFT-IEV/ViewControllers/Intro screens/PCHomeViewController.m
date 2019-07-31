//
//  PCHomeViewController.m
//  ERPMobile
//
//  Created by Sameer Ghate on 26/09/14.
//  Copyright (c) 2014 Sameer Ghate. All rights reserved.
//

#import "PCHomeViewController.h"
#import "MKDSlideViewController.h"
#import "UIViewController+MKDSlideViewController.h"
#import "PCDailySalesViewController.h"
#import "PCRejectionsTableViewController.h"
#import "PCAttendanceTableViewController.h"
#import "PCCashFlowProjectionTableViewController.h"
#import "PCInvoicesTableViewController.h"
#import "PCPOSOTransactionsTableViewController.h"
#import "PCTilesCollectionCell.h"
#import "PCPOSOHomeTableViewController.h"
#import "PCRejectionsViewController.h"
#import "AppDelegate.h"

@interface PCHomeViewController () <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate>
{
    NSMutableArray *titles, *images;
    AppDelegate *appDel;
}

@property (nonatomic, weak) IBOutlet UIView *headerview;
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, weak) IBOutlet UILabel *userLabel;

@end

@implementation PCHomeViewController

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
    
    appDel = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    titles = [[NSMutableArray alloc] initWithObjects:@"Daily Sales",@"Cash Flow", @"Rejections",@"Attendance",@"PO/SO Transactions",nil];
    
    images = [[NSMutableArray alloc] initWithObjects:@"dailysales-home",@"cashflow-home", @"rejections-home",@"attendance-home",@"approvals-home",nil];
    
    [_userLabel setText:[NSString stringWithFormat:@"Welcome, %@",appDel.loggedUser.USER_NAME]];
    
    [self.navigationItem setTitle:@"Home"];
    
    [self.navigationController.navigationItem hidesBackButton];
}

-(void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = TRUE;
}

-(void)viewDidDisappear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = FALSE;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (section == 1) {
        return 1;
    }
    return titles.count-1;
}

static NSString *reportsCell = @"reportCell";
static NSString *transactionsCell = @"transactionCell";

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PCTilesCollectionCell *cell;
    
    if (indexPath.section == 1) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:transactionsCell forIndexPath:indexPath];
    }
    else {
        
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:reportsCell forIndexPath:indexPath];
        
        cell.titleLabel.text = [titles objectAtIndex:indexPath.row];
        cell.tileImageview.image = [UIImage imageNamed:[images objectAtIndex:indexPath.row]];
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        return CGSizeMake(225, 85);
    }
    
    if (indexPath.row!=4) {
        return  CGSizeMake(100, 100);
    }
    else {
        return CGSizeMake(225, 85);
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    UINavigationController *mainNavController = (UINavigationController*)appDel.slideViewController.mainViewController;
    
    if (indexPath.section == 1) {
        
        if( [mainNavController.topViewController isKindOfClass:[PCPOSOTransactionsTableViewController class]] )
            [appDel.slideViewController showMainViewControllerAnimated:YES];
        else
        {
            PCPOSOHomeTableViewController * poso = [kStoryboard instantiateViewControllerWithIdentifier:@"PCPOSOHomeTableViewController"];
            [mainNavController popViewControllerAnimated:NO];
            [mainNavController pushViewController:poso animated:NO];
        }
        
        return;
    }
    
    switch (indexPath.row) {
        case 0:
        {
            if( [mainNavController.topViewController isKindOfClass:[PCDailySalesViewController class]] )
                
                [appDel.slideViewController showMainViewControllerAnimated:YES];
            else
            {
                PCDailySalesViewController * dsvc = [kStoryboard instantiateViewControllerWithIdentifier:@"PCDailySalesViewController"];
                [mainNavController popViewControllerAnimated:NO];
                [mainNavController pushViewController:dsvc animated:NO];
            }
        }
            
            break;
            
        case 1:
        {
            if( [mainNavController.topViewController isKindOfClass:[PCCashFlowProjectionTableViewController class]] )
                [appDel.slideViewController showMainViewControllerAnimated:YES];
            else
            {
                PCCashFlowProjectionTableViewController * cfpvc = [kStoryboard instantiateViewControllerWithIdentifier:@"PCCashFlowProjectionTableViewController"];
                [mainNavController popViewControllerAnimated:NO];
                [mainNavController pushViewController:cfpvc animated:NO];
                //                        [appDel.slideViewController setMainViewController:cfpvc animated:YES];
            }
        }
            break;
            
        case 2:
        {
            if( [mainNavController.topViewController isKindOfClass:[PCRejectionsViewController class]] )
                [self.navigationController.slideViewController showMainViewControllerAnimated:YES];
            else
            {
                PCRejectionsTableViewController * rejvc = [kStoryboard instantiateViewControllerWithIdentifier:@"PCRejectionsViewController"];
                [mainNavController popViewControllerAnimated:NO];
                [mainNavController pushViewController:rejvc animated:NO];
                //                        [appDel.slideViewController setMainViewController:rejvc animated:YES];
            }
        }
            break;
            
        case 3:
        {
            if( [mainNavController.topViewController isKindOfClass:[PCAttendanceTableViewController class]] )
                [appDel.slideViewController showMainViewControllerAnimated:YES];
            else
            {
                PCAttendanceTableViewController * attVc = [kStoryboard instantiateViewControllerWithIdentifier:@"PCAttendanceTableViewController"];
                [mainNavController popViewControllerAnimated:NO];
                [mainNavController pushViewController:attVc animated:NO];
                //                        [appDel.slideViewController setMainViewController:attVc animated:YES];
            }
        }
            break;
            
        case 4:
            if( [mainNavController.topViewController isKindOfClass:[PCPOSOTransactionsTableViewController class]] )
                [appDel.slideViewController showMainViewControllerAnimated:YES];
            else
            {
                PCPOSOHomeTableViewController * poso = [kStoryboard instantiateViewControllerWithIdentifier:@"PCPOSOHomeTableViewController"];
                [mainNavController popViewControllerAnimated:NO];
                [mainNavController pushViewController:poso animated:NO];
            }
            
            break;
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    if (section == 1) {
        // Add inset to the collection view if there are not enough cells to fill the width.
        CGFloat cellSpacing = ((UICollectionViewFlowLayout *) collectionViewLayout).minimumLineSpacing;
        CGFloat cellWidth = ((UICollectionViewFlowLayout *) collectionViewLayout).itemSize.width;
        NSInteger cellCount = [collectionView numberOfItemsInSection:section];
        CGFloat inset = (collectionView.bounds.size.width - (cellCount * (cellWidth + cellSpacing))) * 0.5;
        inset = MAX(inset, 0.0);
        
        inset = (collectionView.bounds.size.width*0.4 - cellWidth);
        return UIEdgeInsetsMake(0.0, inset, 0.0, 0.0);
    }
    
    return  UIEdgeInsetsMake(20, 60, 20, 60);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section   {
    
    return 50;
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
