//
//  CustomPWDAlertView.m
//  DT205
//
//  Created by Gianni on 2018/8/15.
//  Copyright © 2018年 WilsonChen. All rights reserved.
//

#import "CustomPWDAlertView.h"
#import "HomePageViewController.h"
#import <DT205SDK/Header.h>

@interface CustomPWDAlertView () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *txtPIN;
@property (weak, nonatomic) IBOutlet UITextField *txtConfirmPIN;
@property (weak, nonatomic) IBOutlet UITextField *txtContinuationCode;
@property (weak, nonatomic) IBOutlet UIView *viewAlert;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property (weak, nonatomic) IBOutlet UIButton *btnOK;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@end

@implementation CustomPWDAlertView{
    NSString* selectedOption;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    selectedOption = @"First";
    _txtPIN.becomeFirstResponder;
    _txtConfirmPIN.becomeFirstResponder;
    _txtContinuationCode.becomeFirstResponder;
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setupView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setupView{
    [_txtContinuationCode setHidden:true];
    _viewAlert.layer.cornerRadius = 15;
    self.view.backgroundColor = [[UIColor alloc]initWithRed:4.0/255.0 green:4.0/255.0 blue:4.0/255.0 alpha:0.4];
    
}

- (IBAction)btnCancel:(id)sender {
    _txtPIN.canResignFirstResponder;
    [_pwdAlertViewDelegate cancelButtonTapped];
    [self dismissViewControllerAnimated:true completion:nil];
}
- (IBAction)btnOK:(id)sender {
    _txtPIN.canResignFirstResponder;
    [_pwdAlertViewDelegate okButtonTapped:selectedOption :_txtPIN.text :_txtConfirmPIN.text :_txtContinuationCode.text];
    if ([_txtPIN.text isEqualToString:_txtConfirmPIN.text]) {
        
        [[NSUserDefaults standardUserDefaults] setObject:_txtPIN.text forKey:PASSWORD];
        HomePageViewController* pageVC = [self.storyboard instantiateViewControllerWithIdentifier:@"HomePageViewController"];
        [self presentViewController:pageVC animated:YES completion:nil];
//        [self dismissViewControllerAnimated:true completion:nil];
    }
    
}
- (IBAction)onTapSegmentedControl:(id)sender {
    switch ([sender selectedSegmentIndex]) {
        case 0:
            NSLog(@"First option");
            selectedOption = @"First";
            [_txtContinuationCode setHidden:true];
            _txtContinuationCode.text = @"";
            break;
        case 1:
            NSLog(@"Second option");
            selectedOption = @"Second";
            [_txtContinuationCode setHidden:false];
            break;
            
        default:
            break;
    }
}



@end
