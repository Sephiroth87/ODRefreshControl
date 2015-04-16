//
//  MainViewController.m
//  ODRefreshControlDemo
//
//  Created by Fabio on 16/04/2015.
//
//

#import "MainViewController.h"
#import "TestViewController.h"

@implementation MainViewController

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    NSString *testTitle;
    switch ((TestType)indexPath.row) {
        case TestTypeFewCells:
            testTitle = @"Few cells";
            break;
        case TestTypeManyCells:
            testTitle = @"Many cells";
            break;
        case TestTypeInset:
            testTitle = @"Inset";
            break;
        case TestTypeSectionHeader:
            testTitle = @"Section header";
            break;
        case TestTypeSectionHeaderAndInset:
            testTitle = @"Section header + Inset";
            break;
    }
    cell.textLabel.text = testTitle;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    TestViewController *viewController = [[TestViewController alloc] initWithType:indexPath.row];
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
