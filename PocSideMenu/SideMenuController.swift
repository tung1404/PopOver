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

class SideMenuController
{
    struct Constants
    {
        static let MarginWidth: CGFloat = 50
        static let SlideDuration: NSTimeInterval = 0.4
    }
    
    weak var navigationController: SideMenuNavigationController!
    weak var clientViewController: UIViewController!
    
    var maskView: SideMenuMaskView!
    var sideView: UIView!
    var sideViewController: UIViewController!
    
    var triggerActionContinuation: CGFloat = 0.5
    
    init()
    {
        maskView = SideMenuMaskView()
        maskView.sideMenuController = self
        
        sideViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("SideViewController") as UIViewController
        
        SideViewController()
        
        sideView = sideViewController.view
    }
    
    func hideSideMenu(WithDuration duration: NSTimeInterval = Constants.SlideDuration)
    {
        guard clientViewController != nil else
        {
            return
        }
        
        let currentFrame = sideView.frame
        
        UIView.animateWithDuration(duration, animations:
            {
                self.sideView.frame = CGRect(
                    x: -currentFrame.width,
                    y: currentFrame.origin.y,
                    width: currentFrame.width,
                    height: currentFrame.height)
            },
            completion:
            {
                if ($0)
                {
                    log.debug("%f")
                    
                    self.sideViewController.willMoveToParentViewController(nil)
                    self.sideViewController.removeFromParentViewController()
                    self.sideView.removeFromSuperview()
                    self.maskView.removeFromSuperview()
                    
                    self.clientViewController = nil
                }
            })
    }
    
    func moveSideMenu(ToPosition position: SideMenuPosition)
    {
        guard clientViewController != nil else
        {
            log.warning("%f: side menu is not active")
            return
        }
        
        let currentFrame = sideView.frame
        
        let frameOriginX: CGFloat
        
        switch position
        {
            case .RightEdgeAt(let xRightEdge):
                frameOriginX =  xRightEdge - currentFrame.width
                triggerActionContinuation = 0.75
            
            case .LeftEdgeAt(let xLeftEdge):
                frameOriginX = xLeftEdge
                triggerActionContinuation = 0.25
            
        }
        
        UIView.animateWithDuration(Constants.SlideDuration / 10, animations:
        {
            self.sideView.frame = CGRect(
                x: frameOriginX,
                y: currentFrame.origin.y,
                width: currentFrame.width,
                height: currentFrame.height)
        })
    }
    
    func endMoveSideMenu()
    {
        guard clientViewController != nil else
        {
            log.warning("%f: side menu is not active")
            return
        }
        
        if sideView.frame.origin.x < (-clientViewController.view.frame.width + Constants.MarginWidth)*triggerActionContinuation
        {
            hideSideMenu(WithDuration: Constants.SlideDuration * Double(1-triggerActionContinuation))
        }
        else
        {
            let currentFrame = sideView.frame
            
            UIView.animateWithDuration(Constants.SlideDuration/2, animations:
            {
                self.sideView.frame = CGRect(
                    x: 0,
                    y: currentFrame.origin.y,
                    width: currentFrame.width,
                    height: currentFrame.height)
            })
        }
    }
    
    func showSideMenu(InViewController viewController: UIViewController, AtPosition position: CGFloat? = nil)
    {
        guard viewController.view.subviews.contains(sideView) == false else
        {
            // Side Menu is already inserted
            return
        }
        
        hideSideMenu()
        
        log.debug("%f: show side menu")
        
        maskView.frame = viewController.view.frame
        viewController.view.addSubview(maskView)
        
        let navbarHeight = navigationController.navigationBar.frame.height
        
        if navigationController.navigationBar.hidden
        {
            
        }
        
        sideView.frame = CGRect(
            x: -viewController.view.frame.width + Constants.MarginWidth,
            y: navbarHeight,
            width: viewController.view.frame.width - Constants.MarginWidth,
            height: viewController.view.frame.height - navbarHeight)
        
        viewController.view.addSubview(sideView)
        viewController.addChildViewController(sideViewController)
        sideViewController.didMoveToParentViewController(viewController)
        
        clientViewController = viewController
        
        UIView.animateWithDuration(Constants.SlideDuration, animations:
        {
            self.sideView.frame = CGRect(
                x: position == nil ? 0 : position! - (viewController.view.frame.width - Constants.MarginWidth),
                y: navbarHeight,
                width: viewController.view.frame.width - Constants.MarginWidth,
                height: viewController.view.frame.height - navbarHeight)
        })
    }
    
    func toggleSideMenu(InViewController viewController: UIViewController)
    {
        if viewController.view.subviews.contains(sideView)
        {
            hideSideMenu()
        }
        else
        {
            showSideMenu(InViewController: viewController)
        }
    }
    

}