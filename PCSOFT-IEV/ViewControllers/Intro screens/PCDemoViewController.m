//
//  PCDemoViewController.m
//  ERPMobile
//
//  Created by Sameer Ghate on 20/11/14.
//  Copyright (c) 2014 Sameer Ghate. All rights reserved.
//

#import "PCDemoViewController.h"

@interface PCDemoViewController ()

@property (nonatomic, strong) IBOutlet UIScrollView *demoScrollView;
@end

@implementation PCDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_demoScrollView setContentSize:CGSizeMake(_demoScrollView.frame.size.width*6, _demoScrollView.frame.size.height)];
    //2240
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)close:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
