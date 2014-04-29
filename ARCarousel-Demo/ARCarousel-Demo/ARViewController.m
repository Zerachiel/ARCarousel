//
//  ARViewController.m
//  ARCarousel-Demo
//
//  Created by Huy Le on 4/29/14.
//  Copyright (c) 2014 Ares. All rights reserved.
//

#import "ARViewController.h"
#import "FPCarouselNonXIBViewController.h"

@interface ARViewController ()

@property (strong,nonatomic) FPCarouselNonXIBViewController *carouselController;

@end

@implementation ARViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.carouselController = [[FPCarouselNonXIBViewController alloc] initWithFrame:CGRectMake(0, 0, 768, 400)];
    [self.view addSubview:self.carouselController.view];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
