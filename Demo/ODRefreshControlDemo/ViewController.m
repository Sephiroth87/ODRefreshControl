//
//  ViewController.m
//  ODRefreshControlDemo
//
//  Created by Fabio Ritrovato on 7/4/12.
//  Copyright (c) 2012 orange in a day. All rights reserved.
//

#import "ViewController.h"
#import "ODRefreshControl.h"

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[ODRefreshControl setupRefreshForTableViewController:self withRefreshTarget:self action:@selector(dropViewDidBeginRefreshing:)];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (void)dropViewDidBeginRefreshing:(id)refreshControl
{
    double delayInSeconds = 3.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [refreshControl endRefreshing];
    });
}

@end
