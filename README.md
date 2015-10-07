### 原作者的话:

*Notice:* There's a new 2.0 branch where I updated the control for iOS7 plus I plan to do some interesting new features. If people could try it out so I can be sure I didn't break anything it'd be great, and report any issue you find, I'd really appreciate that :)



# ODRefreshControl

![refresh gif](https://github.com/wolfcon/ODRefreshControl/blob/master/下拉刷新.gif)

ODRefreshControl is a "pull down to refresh" control for UIScrollView, like the one Apple introduced in iOS6, but available to anyone from iOS4 and up.

## 安装方法(Installation)

- Drag the `ODRefreshControl/ODRefreshControl` folder into your project. 
- Add the **QuartzCore** framework to your project.
- `#import “ODRefreshControl.h"`

***Important note if your project doesn't use ARC***: *you must add the `-fobjc-arc` compiler flag to `ODRefreshControl.m` in Target Settings > Build Phases > Compile Sources.*

## 使用方法(Usage)

(see sample Xcode project in `/Demo`)

### 添加一个下拉刷新控件(Adding a refresh control to your table view)

``` objective-c
ODRefreshControl *refreshControl = [[ODRefreshControl alloc] initInScrollView:self.tableView];
```

给控件添加一个`UIControlEventValueChanged` 事件
(*To know when the refresh operation has started, add an action method to the `UIControlEventValueChanged` event of the control*)

``` objective-c
[refreshControl addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
```

一般不显式的调用程序来开始刷新, 除非你有此需要
(*If you’d like to programmatically start the refresh operation, use*)

``` objective-c
[refreshControl beginRefreshing];
```

Remember to tell the control when the refresh operation has ended

``` objective-c
[refreshControl endRefreshing];
```

#### 可自定义的属性(Customization)

The `ODRefreshControl` can be customized using the following properties:

``` objective-c
@property (nonatomic, strong) UIColor *tintColor;

@property (nonatomic, assign) UIActivityIndicatorViewStyle activityIndicatorViewStyle;

@property (nonatomic, strong) UIColor *activityIndicatorViewColor; // iOS5 or more

@property (nonatomic, strong) UILabel *finishedLabel;
```



## Credits

ODRefreshControl is brought to you by [Fabio Ritrovato](http://orangeinaday.com) and [contributors to the project](https://github.com/Sephiroth87/ODRefreshControl/contributors). If you have feature suggestions or bug reports, feel free to help out by sending pull requests or by [creating new issues](https://github.com/Sephiroth87/ODRefreshControl/issues/new). If you're using ODRefreshControl in your project, attribution would be nice.



