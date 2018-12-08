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
    
    v = [[LPWavyProgressIndicator alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    [self.view addSubview:v];
    v.progress = 0.1;
    
    [self moockDownload];
}

- (void)moockDownload {
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
       
        sleep(1);
        dispatch_async(dispatch_get_main_queue(), ^{
            v.progress += 0.01;
            
            if (v.progress < 1) {
                [self moockDownload];
            }
        });
        
    });
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
