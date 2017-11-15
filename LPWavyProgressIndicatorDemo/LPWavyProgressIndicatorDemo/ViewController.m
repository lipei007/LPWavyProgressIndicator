//
//  ViewController.m
//  aha
//
//  Created by Jack on 2017/11/10.
//  Copyright © 2017年 Jack. All rights reserved.
//

#import "ViewController.h"
#import "LPWavyProgressIndicator.h"

@interface ViewController ()
{
    LPWavyProgressIndicator *v;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    v = [[LPWavyProgressIndicator alloc] initWithFrame:CGRectMake(100, 100, 40, 40)];
    [self.view addSubview:v];
    v.progress = 0.1;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
