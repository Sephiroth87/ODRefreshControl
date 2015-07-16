//
//  ORRefreshControl.swift
//
//  Created by Igor Smirnov on 15/04/15.
//  Copyright (c) 2015 Complex Nymbers. All rights reserved.
//
//  https://github.com/megavolt605/ODRefreshControl
//
//
//  Based on ODRefreshControl
//
//  Created by Fabio Ritrovato on 6/13/12.
//  Copyright (c) 2012 orange in a day. All rights reserved.
//
//  https://github.com/Sephiroth87/ODRefreshControl
//
import UIKit

class ODRefreshControl: UIControl {

    var shapeLayer: CAShapeLayer!
    var arrowLayer: CAShapeLayer!
    var highlightLayer: CAShapeLayer!
    var activity: UIView!
    var refreshing = false
    var canRefresh = false
    var ignoreInset = false
    var ignoreOffset = false
    var didSetInset = false
    var hasSectionHeaders = false
    var lastOffset: CGFloat = 0.0

    var activityIndicatorViewStyle: UIActivityIndicatorViewStyle {
        get {
            if let a = activity as? UIActivityIndicatorView {
                return a.activityIndicatorViewStyle
            }
            return .Gray
        }
        set {
            if let a = activity as? UIActivityIndicatorView {
                a.activityIndicatorViewStyle = newValue
            }
        }
    }
  
    var activityIndicatorViewColor: UIColor? {
        get {
            if let a = activity as? UIActivityIndicatorView {
                return a.color
            }
            return nil
        }
        set {
            if let a = activity as? UIActivityIndicatorView {
                a.color = newValue
            }
        }
    }
    
    // setup
    var kTotalViewHeight   : CGFloat = 400
    var kOpenedViewHeight  : CGFloat = 44
    var kMinTopPadding     : CGFloat = 9
    var kMaxTopPadding     : CGFloat = 5
    var kMinTopRadius      : CGFloat = 12.5
    var kMaxTopRadius      : CGFloat = 16
    var kMinBottomRadius   : CGFloat = 3
    var kMaxBottomRadius   : CGFloat = 16
    var kMinBottomPadding  : CGFloat = 4
    var kMaxBottomPadding  : CGFloat = 6
    var kMinArrowSize      : CGFloat = 2
    var kMaxArrowSize      : CGFloat = 3
    var kMinArrowRadius    : CGFloat = 5
    var kMaxArrowRadius    : CGFloat = 7
    var kMaxDistance       : CGFloat = 53

    var scrollView: UIScrollView!
    var originalContentInset: UIEdgeInsets = UIEdgeInsetsZero
    
    func lerp(a: CGFloat, b: CGFloat, p: CGFloat) -> CGFloat {
        return a + (b - a) * p;
    }

    convenience init(scrollView: UIScrollView) {
        self.init(scrollView: scrollView, activityIndicatorView: nil)
    }
    
    init(scrollView: UIScrollView, activityIndicatorView activityView: UIView?) {
        super.init(frame: CGRectMake(0, -(kTotalViewHeight + scrollView.contentInset.top), scrollView.frame.size.width, kTotalViewHeight))
        self.scrollView = scrollView;
        originalContentInset = scrollView.contentInset;
    
        self.autoresizingMask = .FlexibleWidth;
        scrollView.addSubview(self)
        // NSKeyValueObservingOption
        scrollView.addObserver(self, forKeyPath: "contentOffset", options: .New, context: nil)
        scrollView.addObserver(self, forKeyPath: "contentInset", options: .New, context: nil)
    
        activity = activityView != nil ? activityView : UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        activity.center = CGPointMake(floor(self.frame.size.width / 2), floor(self.frame.size.height / 2))
        activity.autoresizingMask = .FlexibleLeftMargin | .FlexibleRightMargin
        activity.alpha = 0
        if let a = activity as? UIActivityIndicatorView {
            a.startAnimating()
        }
        addSubview(activity)
    
        refreshing = false
        canRefresh = true
        ignoreInset = false
        ignoreOffset = false
        didSetInset = false
        hasSectionHeaders = false
    
        shapeLayer = CAShapeLayer()
        shapeLayer.fillColor = tintColor.CGColor
        shapeLayer.strokeColor = UIColor.darkGrayColor().colorWithAlphaComponent(0.5).CGColor
        shapeLayer.lineWidth = 0.5
        shapeLayer.shadowColor = UIColor.blackColor().CGColor
        shapeLayer.shadowOffset = CGSizeMake(0, 1)
        shapeLayer.shadowOpacity = 0.4
        shapeLayer.shadowRadius = 0.5
        layer.addSublayer(shapeLayer)

        tintColor = UIColor(red:155.0 / 255.0, green: 162.0 / 255.0, blue: 172.0 / 255.0, alpha: 1.0)
        
        arrowLayer = CAShapeLayer()
        arrowLayer.strokeColor = UIColor.darkGrayColor().colorWithAlphaComponent(0.5).CGColor
        arrowLayer.lineWidth = 0.5
        arrowLayer.fillColor = UIColor.whiteColor().CGColor
        shapeLayer.addSublayer(arrowLayer)
        
        highlightLayer = CAShapeLayer()
        highlightLayer.fillColor = UIColor.whiteColor().colorWithAlphaComponent(0.2).CGColor
        shapeLayer.addSublayer(highlightLayer)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        scrollView.removeObserver(self, forKeyPath: "contentOffset")
        scrollView.removeObserver(self, forKeyPath: "contentInset")
        scrollView = nil
    }

    override var enabled: Bool {
        didSet {
            shapeLayer.hidden = !enabled
        }
    }

    override func willMoveToSuperview(newSuperview: UIView?) {
        super.willMoveToSuperview(newSuperview)
        if newSuperview == nil {
            scrollView.removeObserver(self, forKeyPath: "contentOffset")
            scrollView.removeObserver(self, forKeyPath: "contentInset")
            scrollView = nil;
        }
    }
    
    override var tintColor: UIColor! {
        didSet {
            shapeLayer.fillColor = tintColor.CGColor
        }
    }

    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if keyPath == "contentInset" {
            if !ignoreInset {
                originalContentInset = (change["new"] as! NSValue).UIEdgeInsetsValue()
                frame = CGRectMake(0, -(kTotalViewHeight + self.scrollView.contentInset.top), self.scrollView.frame.size.width, kTotalViewHeight)
            }
            return
        }
    
        if !enabled || ignoreOffset {
            return
        }
    
        let offset = (change["new"] as! NSValue).CGPointValue().y + originalContentInset.top;
    
        if refreshing {
            if offset != 0 {
                // Keep thing pinned at the top
    
                CATransaction.begin()
                CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
                shapeLayer.position = CGPointMake(0, kMaxDistance + offset + kOpenedViewHeight)
                CATransaction.commit()
    
                activity.center = CGPointMake(floor(frame.size.width / 2.0), min(offset + frame.size.height + floor(kOpenedViewHeight / 2.0), frame.size.height - kOpenedViewHeight / 2.0))
    
                ignoreInset = true
                ignoreOffset = true
    
                if offset < 0 {
                    // Set the inset depending on the situation
                    if offset >= -kOpenedViewHeight {
                        if !scrollView.dragging {
                            if !didSetInset {
                                didSetInset = true
                                hasSectionHeaders = false
                                if let tv = scrollView as? UITableView {
                                    for i in 0..<tv.numberOfSections() {
                                        if tv.rectForHeaderInSection(i).size.height != 0 {
                                            hasSectionHeaders = true
                                            break
                                        }
                                    }
                                }
                            }
                            
                            if hasSectionHeaders {
                                scrollView.contentInset = UIEdgeInsetsMake(min(-offset, kOpenedViewHeight) + originalContentInset.top, originalContentInset.left, originalContentInset.bottom, originalContentInset.right)
                            } else {
                                scrollView.contentInset = UIEdgeInsetsMake(kOpenedViewHeight + originalContentInset.top, originalContentInset.left, originalContentInset.bottom, originalContentInset.right)
                            }
                        } else if didSetInset && hasSectionHeaders {
                            scrollView.contentInset = UIEdgeInsetsMake(-offset + originalContentInset.top, originalContentInset.left, originalContentInset.bottom, originalContentInset.right)
                        }
                    }
                } else if hasSectionHeaders {
                    scrollView.contentInset = originalContentInset
                }
                ignoreInset = false
                ignoreOffset = false
            }
            return
        } else {
            // Check if we can trigger a new refresh and if we can draw the control
            var dontDraw = false
            if !canRefresh {
                if offset >= 0 {
                    // We can refresh again after the control is scrolled out of view
                    canRefresh = true
                    didSetInset = false
                } else {
                    dontDraw = true
                }
            } else {
                if offset >= 0 {
                    // Don't draw if the control is not visible
                    dontDraw = true
                }
            }
            if offset > 0 && (lastOffset > offset) && !scrollView.tracking {
                // If we are scrolling too fast, don't draw, and don't trigger unless the scrollView bounced back
                canRefresh = false
                dontDraw = true
            }
            if dontDraw {
                shapeLayer.path = nil
                shapeLayer.shadowPath = nil
                arrowLayer.path = nil
                highlightLayer.path = nil
                lastOffset = offset
                return
            }
        }
    
        lastOffset = offset
    
        var triggered = false
        
        let path = CGPathCreateMutable()
        
        //Calculate some useful points and values
        let verticalShift = max(0, -((kMaxTopRadius + kMaxBottomRadius + kMaxTopPadding + kMaxBottomPadding) + offset))
        let distance = min(kMaxDistance, fabs(verticalShift))
        let percentage = 1 - (distance / kMaxDistance)
        
        let currentTopPadding = lerp(kMinTopPadding, b: kMaxTopPadding, p: percentage)
        let currentTopRadius = lerp(kMinTopRadius, b: kMaxTopRadius, p: percentage)
        let currentBottomRadius = lerp(kMinBottomRadius, b: kMaxBottomRadius, p: percentage)
        let currentBottomPadding =  lerp(kMinBottomPadding, b: kMaxBottomPadding, p: percentage)
        
        var bottomOrigin = CGPointMake(floor(self.bounds.size.width / 2), self.bounds.size.height - currentBottomPadding - currentBottomRadius)
        var topOrigin = CGPointZero
        if distance == 0 {
            topOrigin = CGPointMake(floor(self.bounds.size.width / 2), bottomOrigin.y)
        } else {
            topOrigin = CGPointMake(floor(self.bounds.size.width / 2), self.bounds.size.height + offset + currentTopPadding + currentTopRadius)
            if percentage == 0 {
                bottomOrigin.y -= (fabs(verticalShift) - kMaxDistance)
                triggered = true
            }
        }
    
        //Top semicircle
        CGPathAddArc(path, nil, topOrigin.x, topOrigin.y, currentTopRadius, 0, CGFloat(M_PI), true)
        
        //Left curve
        let leftCp1 = CGPointMake(
            lerp((topOrigin.x - currentTopRadius), b: (bottomOrigin.x - currentBottomRadius), p: 0.1),
            lerp(topOrigin.y, b: bottomOrigin.y, p: 0.2)
        )
        let leftCp2 = CGPointMake(
            lerp((topOrigin.x - currentTopRadius), b: (bottomOrigin.x - currentBottomRadius), p: 0.9),
            lerp(topOrigin.y, b: bottomOrigin.y, p: 0.2)
        )
        let leftDestination = CGPointMake(bottomOrigin.x - currentBottomRadius, bottomOrigin.y)
        
        CGPathAddCurveToPoint(path, nil, leftCp1.x, leftCp1.y, leftCp2.x, leftCp2.y, leftDestination.x, leftDestination.y)
        
        //Bottom semicircle
        CGPathAddArc(path, nil, bottomOrigin.x, bottomOrigin.y, currentBottomRadius, CGFloat(M_PI), 0, true)
        
        //Right curve
        let rightCp2 = CGPointMake(
            lerp((topOrigin.x + currentTopRadius), b: (bottomOrigin.x + currentBottomRadius), p: 0.1),
            lerp(topOrigin.y, b: bottomOrigin.y, p: 0.2)
        )
        let rightCp1 = CGPointMake(
            lerp((topOrigin.x + currentTopRadius), b: (bottomOrigin.x + currentBottomRadius), p: 0.9),
            lerp(topOrigin.y, b: bottomOrigin.y, p: 0.2)
        )
        let rightDestination = CGPointMake(topOrigin.x + currentTopRadius, topOrigin.y)
        
        CGPathAddCurveToPoint(path, nil, rightCp1.x, rightCp1.y, rightCp2.x, rightCp2.y, rightDestination.x, rightDestination.y)
        CGPathCloseSubpath(path)
    
        if !triggered {
            // Set paths
    
            shapeLayer.path = path;
            shapeLayer.shadowPath = path;
    
            // Add the arrow shape
    
            let currentArrowSize = lerp(kMinArrowSize, b: kMaxArrowSize, p: percentage)
            let currentArrowRadius = lerp(kMinArrowRadius, b: kMaxArrowRadius, p: percentage)
            let arrowBigRadius = currentArrowRadius + (currentArrowSize / 2)
            let arrowSmallRadius = currentArrowRadius - (currentArrowSize / 2)
            let arrowPath = CGPathCreateMutable()
            CGPathAddArc(arrowPath, nil, topOrigin.x, topOrigin.y, arrowBigRadius, 0, CGFloat(3 * M_PI_2), false)
            CGPathAddLineToPoint(arrowPath, nil, topOrigin.x, topOrigin.y - arrowBigRadius - currentArrowSize)
            CGPathAddLineToPoint(arrowPath, nil, topOrigin.x + (2 * currentArrowSize), topOrigin.y - arrowBigRadius + (currentArrowSize / 2))
            CGPathAddLineToPoint(arrowPath, nil, topOrigin.x, topOrigin.y - arrowBigRadius + (2 * currentArrowSize))
            CGPathAddLineToPoint(arrowPath, nil, topOrigin.x, topOrigin.y - arrowBigRadius + currentArrowSize)
            CGPathAddArc(arrowPath, nil, topOrigin.x, topOrigin.y, arrowSmallRadius, CGFloat(3 * M_PI_2), 0, true)
            CGPathCloseSubpath(arrowPath)
            arrowLayer.path = arrowPath
            arrowLayer.fillRule = kCAFillRuleEvenOdd
            //CGPathRelease(arrowPath)
            
            // Add the highlight shape
            
            let highlightPath = CGPathCreateMutable()
            CGPathAddArc(highlightPath, nil, topOrigin.x, topOrigin.y, currentTopRadius, 0, CGFloat(M_PI), true)
            CGPathAddArc(highlightPath, nil, topOrigin.x, topOrigin.y + 1.25, currentTopRadius, CGFloat(M_PI), 0, false)
            
            highlightLayer.path = highlightPath
            highlightLayer.fillRule = kCAFillRuleNonZero
            //CGPathRelease(highlightPath)
    
        } else {
            // Start the shape disappearance animation
    
            let radius = lerp(kMinBottomRadius, b: kMaxBottomRadius, p: 0.2)
            let pathMorph = CABasicAnimation(keyPath: "path")
            pathMorph.duration = 0.15
            pathMorph.fillMode = kCAFillModeForwards
            pathMorph.removedOnCompletion = false
            
            let toPath = CGPathCreateMutable()
            CGPathAddArc(toPath, nil, topOrigin.x, topOrigin.y, radius, 0, CGFloat(M_PI), true)
            CGPathAddCurveToPoint(toPath, nil, topOrigin.x - radius, topOrigin.y, topOrigin.x - radius, topOrigin.y, topOrigin.x - radius, topOrigin.y)
            CGPathAddArc(toPath, nil, topOrigin.x, topOrigin.y, radius, CGFloat(M_PI), 0, true)
            CGPathAddCurveToPoint(toPath, nil, topOrigin.x + radius, topOrigin.y, topOrigin.x + radius, topOrigin.y, topOrigin.x + radius, topOrigin.y)
            CGPathCloseSubpath(toPath)
            pathMorph.toValue = toPath
            shapeLayer.addAnimation(pathMorph, forKey: nil)
            
            let shadowPathMorph = CABasicAnimation(keyPath: "shadowPath")
            shadowPathMorph.duration = 0.15
            shadowPathMorph.fillMode = kCAFillModeForwards
            shadowPathMorph.removedOnCompletion = false
            shadowPathMorph.toValue = toPath
            shapeLayer.addAnimation(shadowPathMorph, forKey: nil)
            //CGPathRelease(toPath);
            
            let shapeAlphaAnimation = CABasicAnimation(keyPath: "opacity")
            shapeAlphaAnimation.duration = 0.1
            shapeAlphaAnimation.beginTime = CACurrentMediaTime() + 0.1
            shapeAlphaAnimation.toValue = NSNumber(float: 0)
            shapeAlphaAnimation.fillMode = kCAFillModeForwards
            shapeAlphaAnimation.removedOnCompletion = false
            shapeLayer.addAnimation(shapeAlphaAnimation, forKey: nil)
            
            let alphaAnimation = CABasicAnimation(keyPath: "opacity")
            alphaAnimation.duration = 0.1
            alphaAnimation.toValue = NSNumber(float: 0)
            alphaAnimation.fillMode = kCAFillModeForwards
            alphaAnimation.removedOnCompletion = false
            arrowLayer.addAnimation(alphaAnimation, forKey: nil)
            highlightLayer.addAnimation(alphaAnimation, forKey: nil)
            
            CATransaction.begin()
            CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
            activity.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1)
            CATransaction.commit()
            UIView.animateWithDuration(0.2, delay:0.15, options: UIViewAnimationOptions.CurveLinear,
                animations: {
                    self.activity.alpha = 1
                    self.activity.layer.transform = CATransform3DMakeScale(1, 1, 1)
                },
                completion: nil
            )
    
            refreshing = true
            canRefresh = false
            sendActionsForControlEvents(.ValueChanged)
        }
    
        //CGPathRelease(path)
    }
    
    func beginRefreshing() {
        if !refreshing {
            let alphaAnimation = CABasicAnimation(keyPath: "opacity")
            alphaAnimation.duration = 0.0001
            alphaAnimation.toValue = NSNumber(float: 0)
            alphaAnimation.fillMode = kCAFillModeForwards
            alphaAnimation.removedOnCompletion = false
            shapeLayer.addAnimation(alphaAnimation, forKey: nil)
            arrowLayer.addAnimation(alphaAnimation, forKey: nil)
            highlightLayer.addAnimation(alphaAnimation, forKey: nil)
    
            activity.alpha = 1
            activity.layer.transform = CATransform3DMakeScale(1, 1, 1)
    
            let offset = self.scrollView.contentOffset
            ignoreInset = true
            scrollView.contentInset = UIEdgeInsetsMake(kOpenedViewHeight + originalContentInset.top, originalContentInset.left, originalContentInset.bottom, originalContentInset.right)
            ignoreInset = false
            scrollView.setContentOffset(offset, animated: false)
    
            refreshing = true
            canRefresh = false
        }
    }
    
    func endRefreshing() {
        if refreshing {
            refreshing = false
            // Create a temporary retain-cycle, so the scrollView won't be released
            // halfway through the end animation.
            // This allows for the refresh control to clean up the observer,
            // in the case the scrollView is released while the animation is running
            
            //__block UIScrollView *blockScrollView = self.scrollView;
            let sv = scrollView
            UIView.animateWithDuration(0.4,
                animations: { [sv]
                    self.ignoreInset = true
                    sv.contentInset = self.originalContentInset
                    self.ignoreInset = false
                    self.activity.alpha = 0
                    self.activity.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1)
                }, completion: { [sv] finished in
                    self.shapeLayer.removeAllAnimations()
                    self.shapeLayer.path = nil
                    self.shapeLayer.shadowPath = nil
                    self.shapeLayer.position = CGPointZero
                    self.arrowLayer.removeAllAnimations()
                    self.arrowLayer.path = nil
                    self.highlightLayer.removeAllAnimations()
                    self.highlightLayer.path = nil
                    // We need to use the scrollView somehow in the end block,
                    // or it'll get released in the animation block.
                    self.ignoreInset = true
                    sv.contentInset = self.originalContentInset
                    self.ignoreInset = false
                }
            )
        }
    }
}
