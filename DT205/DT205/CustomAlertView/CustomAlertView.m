//
//  CustomAlertView.m
//  DT205
//
//  Created by Gianni on 2018/8/15.
//  Copyright © 2018年 WilsonChen. All rights reserved.
//

#import "CustomAlertView.h"


@interface CustomAlertView ()
@property (weak, nonatomic) IBOutlet UILabel *labTitle;
@property (weak, nonatomic) IBOutlet UILabel *labMessage;
@property (weak, nonatomic) IBOutlet UITextField *txtAlert;
@property (weak, nonatomic) IBOutlet UIView *viewAlert;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property (weak, nonatomic) IBOutlet UIButton *btnOK;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;



@end

@implementation CustomAlertView
{
    NSString* selectedOption;
    UIColor* alertViewGrayColor;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    selectedOption = @"First";
    alertViewGrayColor = [[UIColor alloc]initWithRed:244.0/255.0 green:244.0/255.0 blue:244.0/255.0 alpha:1];
    _txtAlert.becomeFirstResponder;
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setupView];
    [self animateView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupView{
    _viewAlert.layer.cornerRadius = 15;
//    self.view.backgroundColor = UIColor.blackColor;
//    self.view.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = [[UIColor alloc]initWithRed:4.0/255.0 green:4.0/255.0 blue:4.0/255.0 alpha:0.4];
    
}

-(void)animateView{
//    _viewAlert.alpha = 0;
//    self.viewAlert.frame.origin.y = self.viewAlert.frame.origin.y + 50;
}
- (IBAction)btnCancel:(id)sender {
    _txtAlert.canResignFirstResponder;
    [_alertViewDelegate cancelButtonTapped];
    [self dismissViewControllerAnimated:true completion:nil];
}
- (IBAction)btnOK:(id)sender {
    _txtAlert.canResignFirstResponder;
    [_alertViewDelegate okButtonTapped:selectedOption :_txtAlert.text];
    [self dismissViewControllerAnimated:true completion:nil];

}
- (IBAction)onTapSegmentedControl:(id)sender {
    switch ([sender selectedSegmentIndex]) {
        case 0:
            NSLog(@"First option");
            selectedOption = @"First";
            break;
        case 1:
            NSLog(@"Second option");
            selectedOption = @"Second";
            break;
            
        default:
            break;
    }
}




@end
