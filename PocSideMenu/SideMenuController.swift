//
//  SideMenuController.swift
//  PocSideMenu
//
//  Created by Bertrand Marlier on 05/10/2015.
//  Copyright © 2015 Bertrand Marlier. All rights reserved.
//

import UIKit

private let log = Logger()

enum SideMenuPosition
{
    case RightEdgeAt(CGFloat)
    case LeftEdgeAt(CGFloat)
}

enum PanAxis
{
    case Undefined
    case Horizontal
    case Vertical
}

class SideMenuController: NSObject, UIGestureRecognizerDelegate
{
    struct Constants
    {
        static let MarginWidth: CGFloat = 100 // points
        static let MinVelocity: CGFloat = 600 // points/s
        static let ZeroVelocityTrigger: CGFloat = 50 // points/s
    }
    
    weak var navigationController: SideMenuNavigationController!
    weak var clientViewController: UIViewController!
    
    var maskView: SideMenuMaskView!
    var sideView: UIView!
    var sideViewController: UIViewController!

    var fullyDeployed: Bool
    {
        return sideView.frame.origin.x == 0
    }

    var lockedPanAxis: PanAxis = .Undefined
    
    init(InBundle bundle: String, WithIdentifier identifier: String, WithNavigationController navigationController: SideMenuNavigationController)
    {
        super.init()
        
        self.navigationController = navigationController
        
        maskView = SideMenuMaskView()
        maskView.sideMenuController = self
        
        sideViewController = UIStoryboard(name: bundle,
            bundle: nil).instantiateViewControllerWithIdentifier(identifier) as UIViewController
        
        sideView = sideViewController.view
        
        sideView.layer.shadowRadius  = 5;
        sideView.layer.shadowOpacity = 1;
        
        let panRecognizer = UIPanGestureRecognizer(target: sideViewController, action: "sideMenuPanHandler:")
        
        panRecognizer.delegate = self
        
        sideView.addGestureRecognizer(panRecognizer)
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    @objc func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool
    {
        return fullyDeployed
    }
    
    // MARK: - API
    
    func detach()
    {
        guard clientViewController != nil else
        {
            log.info("%f: side menu is not active")
            return
        }
        
        log.debug("%f")
        
        sideViewController.willMoveToParentViewController(nil)
        sideViewController.removeFromParentViewController()
        sideView.removeFromSuperview()
        maskView.removeFromSuperview()
        
        clientViewController = nil
    }
    
    func hide(WithVelocity velocity: CGFloat? = nil, WithAnimation animation: Bool = true)
    {
        let detachAction: (Bool)->Void =
        {
            if ($0)
            {
                self.detach()
            }
        }
        
        if animation
        {
            move(ToPosition: SideMenuPosition.RightEdgeAt(0), WithVelocity: velocity, WithCompletion: detachAction)
        }
        else
        {
            detachAction(true)
        }
    }
    
    func move(
        ToPosition position: SideMenuPosition,
        WithAnimation animation: Bool = true,
        WithVelocity velocity: CGFloat? = nil,
        WithCompletion completion: ((Bool)->Void)? = nil)
    {
        guard clientViewController != nil else
        {
            log.info("%f: side menu is not active")
            return
        }
        
        let currentFrame = sideView.frame
        
        var frameOriginX: CGFloat
        
        switch position
        {
            case .RightEdgeAt(let xRightEdge):
                frameOriginX =  xRightEdge - currentFrame.width
                
            case .LeftEdgeAt(let xLeftEdge):
                frameOriginX = xLeftEdge
        }
        
        if frameOriginX > 0
        {
            frameOriginX = 0
        }
        
        let translation = frameOriginX - currentFrame.origin.x
        let duration = abs(translation) / max(Constants.MinVelocity, abs(velocity ?? Constants.MinVelocity))
        
        let animate =
        {
            self.sideView.frame = CGRect(
                x: frameOriginX,
                y: currentFrame.origin.y,
                width: currentFrame.width,
                height: currentFrame.height)
        }
        
        if animation
        {
            UIView.animateWithDuration(
                NSTimeInterval(duration),
                delay: 0,
                options: UIViewAnimationOptions.CurveEaseOut,
                animations: animate,
                completion: completion)
        }
        else
        {
            animate()
            completion?(true)
        }
    }

    func drop(var WithVelocity velocity: CGFloat)
    {
        guard clientViewController != nil else
        {
            log.warning("%f: side menu is not active")
            return
        }
        
        log.debug("%f: given velocity = \(velocity)")
        
        if abs(velocity) < Constants.ZeroVelocityTrigger
        {
            velocity = 0
        }
        
        if velocity < 0 || (velocity == 0 && sideView.frame.origin.x < -sideView.frame.width * 0.5)
        {
            hide(WithVelocity: velocity)
        }
        else
        {
            move(ToPosition: SideMenuPosition.LeftEdgeAt(0), WithVelocity: velocity)
        }
    }

    func show(InViewController viewController: UIViewController, AtPosition position: SideMenuPosition = SideMenuPosition.LeftEdgeAt(0))
    {
        guard viewController.view.subviews.contains(sideView) == false else
        {
            log.info("%f: side Menu is already inserted")
            return
        }
        
        detach()
        
        log.debug("%f: show side menu")
        
        maskView.frame = viewController.view.frame
        
        sideView.frame = CGRect(
            x: -viewController.view.frame.width + Constants.MarginWidth,
            y: 0,
            width: viewController.view.frame.width - Constants.MarginWidth,
            height: viewController.view.frame.height)
        
        viewController.view.addSubview(maskView)
        viewController.view.addSubview(sideView)
        viewController.addChildViewController(sideViewController)
        sideViewController.didMoveToParentViewController(viewController)
        
        clientViewController = viewController
        
        if let scrollView = sideView as? UIScrollView
        {
            log.debug("reset scroll view")
            scrollView.contentOffset = CGPointZero
        }
        
        move(ToPosition: position)
    }
    
    func toggle(InViewController viewController: UIViewController)
    {
        if viewController.view.subviews.contains(sideView)
        {
            hide()
        }
        else
        {
            show(InViewController: viewController)
        }
    }
}