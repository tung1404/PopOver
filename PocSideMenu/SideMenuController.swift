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
        static let MinVelocity: CGFloat = 600 // points/s
    }
    
    weak var navigationController: SideMenuNavigationController!
    weak var clientViewController: UIViewController!
    
    var maskView: SideMenuMaskView!
    var sideView: UIView!
    var sideViewController: UIViewController!
    
    init()
    {
        maskView = SideMenuMaskView()
        maskView.sideMenuController = self
        
        sideViewController = UIStoryboard(name: "Main",
            bundle: nil).instantiateViewControllerWithIdentifier("SideViewController") as UIViewController
        
        sideView = sideViewController.view
    }
    
    func hideSideMenu(WithVelocity velocity: CGFloat? = nil)
    {
        moveSideMenu(ToPosition: SideMenuPosition.RightEdgeAt(0), WithVelocity: velocity, WithCompletion:
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
    
    func moveSideMenu(ToPosition position: SideMenuPosition, WithVelocity velocity: CGFloat? = nil, WithCompletion completion: ((Bool)->Void)? = nil)
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
            
            case .LeftEdgeAt(let xLeftEdge):
                frameOriginX = xLeftEdge
            
        }
        
        let translation = frameOriginX - currentFrame.origin.x
        let duration = abs(translation) / max(Constants.MinVelocity, abs(velocity ?? Constants.MinVelocity))
        
        UIView.animateWithDuration(NSTimeInterval(duration), animations:
            {
                self.sideView.frame = CGRect(
                    x: frameOriginX,
                    y: currentFrame.origin.y,
                    width: currentFrame.width,
                    height: currentFrame.height)
            },
            completion: completion)
    }
    
    func endMoveSideMenu(WithVelocity velocity: CGFloat)
    {
        guard clientViewController != nil else
        {
            log.warning("%f: side menu is not active")
            return
        }
        
        if velocity < 0 || (velocity == 0 && sideView.frame.origin.x < -sideView.frame.width * 0.5)
        {
            hideSideMenu(WithVelocity: velocity)
        }
        else
        {
            moveSideMenu(ToPosition: SideMenuPosition.LeftEdgeAt(0), WithVelocity: velocity)
        }
    }
    
    func showSideMenu(InViewController viewController: UIViewController, AtPosition position: SideMenuPosition = SideMenuPosition.LeftEdgeAt(0))
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
        
        moveSideMenu(ToPosition: position)
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