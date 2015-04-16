//
//  TestViewController.h
//  ODRefreshControlDemo
//
//  Created by Fabio on 16/04/2015.
//
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, TestType) {
    TestTypeFewCells,
    TestTypeManyCells,
    TestTypeInset,
    TestTypeSectionHeader,
    TestTypeSectionHeaderAndInset
};

@interface TestViewController : UITableViewController

- (id)initWithType:(TestType)type;

@end