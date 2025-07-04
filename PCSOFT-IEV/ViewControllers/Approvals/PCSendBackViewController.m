//
//  PCSendBackViewController.m
//  PCSOFT-IEV
//
//  Created by Sameer Ghate on 11/01/16.
//  Copyright © 2016 Sameer Ghate. All rights reserved.
//

#import "PCSendBackViewController.h"
#import "ConnectionHandler.h"
#import "SVProgressHUD.h"

@interface PCSendBackViewController () <ConnectionHandlerDelegate, UITextFieldDelegate, UITextViewDelegate>

@property (nonatomic, weak) IBOutlet UILabel *orderLabel;
@property (nonatomic, weak) IBOutlet UITextField *levelNoLabel;
@property (nonatomic, weak) IBOutlet UITextView *remarkTextview;

@end

@implementation PCSendBackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc]
                                      initWithTarget:self action:@selector(handleSingleTap:)];
    tapper.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapper];
    
    self.orderLabel.text = [NSString stringWithFormat:@"%@ - %@",self.selectedTransaction.doc_no,self.selectedTransaction.doc_desc];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleSingleTap:(UITapGestureRecognizer *)sender
{
    [self.levelNoLabel resignFirstResponder];
    [self.remarkTextview resignFirstResponder];
}


-(IBAction)sendbackAction:(id)sender    {
    
    NSNumber *seqno;
    NSString *levelNoStr = [self.levelNoLabel.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    
    if (levelNoStr.length == 0) {
        seqno = @0;
    }
    else {
        seqno = [NSNumber numberWithInt:[levelNoStr intValue]];
    }
    
    if (seqno >= 0) {
        NSLog(@"pass 1");
    }
    
    if ([self.selectedTransaction.seq_no compare:seqno] == NSOrderedDescending) {
        NSLog(@"pass 2");
    }
    
    
    //( [self.selectedTransaction.seq_no compare:seqno] == NSOrderedDescending)
    if ((seqno >= 0)  &&  ([self.selectedTransaction.seq_no compare:seqno] == NSOrderedDescending)) {
        
        [SVProgressHUD showWithStatus:@"Please wait..." maskType:SVProgressHUDMaskTypeBlack];
        
        AppDelegate *appDel = [[UIApplication sharedApplication] delegate];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        ConnectionHandler *sendbackConnection = [[ConnectionHandler alloc] init];
        sendbackConnection.delegate = self;
        
        NSString *remarkStr = self.remarkTextview.text;
        
        NSDictionary *postDict = @{
            kScoCodeKey: [defaults valueForKey:kSelectedCompanyCode],
            @"userid": appDel.loggedUser.USER_ID,
            @"doc_type": [_selectedTransaction.doc_type stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]],
            @"doc_no": [_selectedTransaction.doc_no stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]],
            @"sendto": seqno,
            @"sbremark": remarkStr
        };
        
        [sendbackConnection fetchDataForURL:[NSString stringWithFormat:@"%@/iev/SendBack",appDel.baseURL] body:postDict];
    }
    else {
        
        [Utility showAlertWithTitle:@"Send Back" message:[NSString stringWithFormat:@"Entered level number should be more than 0 and less than %@",self.selectedTransaction.seq_no] buttonTitle:@"OK" inViewController:self];

    }
    
}

-(void)connectionHandler:(ConnectionHandler*)conHandler didRecieveData:(NSData*)data
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSError *error = nil;
        
        NSString *opString = @"";
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        
        BOOL status = [[dict objectForKey:@"Status"] boolValue];
        
        if (status == true) {
            opString = [dict objectForKey:@"SuccessMessage"];
        } else {
            opString = [dict objectForKey:@"ErrorMessage"];
        }
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Send Back" message:opString preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction * okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            [self dismissViewControllerAnimated:YES completion:^{
                
                if ([self->_delegate respondsToSelector:@selector(sendBackDidFinishSendingBackDoc)]) {
                    [self->_delegate sendBackDidFinishSendingBackDoc];
                }
                
            }];
            
        }];
        
        [alert addAction:okAction];
        
        [self presentViewController:alert animated:YES completion:nil];
        
        
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Send Back" message:opString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        alert.delegate = self;
//        alert.tag = 100;
        
        [SVProgressHUD dismiss];
        
//        [alert show];
        
    });
    
}

-(void)connectionHandler:(ConnectionHandler*)conHandler errorRecievingData:(NSError*)error  {
    
    if ([error code] == -5000) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [SVProgressHUD dismiss];
            
            [Utility showAlertWithTitle:@"IEV" message:noInternetMessage buttonTitle:@"OK" inViewController:self];
            
            
        });
        return;
    }
    
    [SVProgressHUD dismiss];
}

-(IBAction)cancelAction:(id)sender  {
    
    [SVProgressHUD dismiss];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

//- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
//{
//    [SVProgressHUD dismiss];
//    
//    switch (alertView.tag) {
//        case 100:
//            if (buttonIndex == 0) {
//                [self dismissViewControllerAnimated:YES completion:^{
//                    
//                    if ([_delegate respondsToSelector:@selector(sendBackDidFinishSendingBackDoc)]) {
//                        
//                        [_delegate sendBackDidFinishSendingBackDoc];
//                    }
//                    
//                }];
//            }
//            break;
//            
//            default:
//            break;
//    }
//}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
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
