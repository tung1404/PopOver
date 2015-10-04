//
//  SideNavigationViewController.swift
//  PocSideMenu
//
//  Created by Bertrand Marlier on 04/10/2015.
//  Copyright © 2015 Bertrand Marlier. All rights reserved.
//

import UIKit

private let log = Logger()

class SideNavigationViewController: UINavigationController
{
    struct Constants
    {
        static let MarginWidth: CGFloat = 50
        static let SlideDuration: NSTimeInterval = 0.4
    }
    
    var maskView: SideMenuMaskView!
    var sideView: UIView!
    var sideViewController: UIViewController!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        log.debug("%f")
        
        maskView = SideMenuMaskView()
        maskView.navigationController = self
        
        sideViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("SideViewController") as UIViewController
        
        //self.presentViewController(viewController, animated: false, completion: nil)
        
        SideViewController()
        
        sideView = sideViewController.view
        
        //sideView.backgroundColor = UIColor.blueColor()
    }

    func hideSideMenuNav(WithDuration duration: NSTimeInterval = Constants.SlideDuration)
    {
        if maskView.viewController != nil
        {
            let currentFrame = sideView.frame
            
            UIView.animateWithDuration(duration, animations:
                {
                    self.sideView.frame = CGRect(x: -currentFrame.width, y: currentFrame.origin.y, width: currentFrame.width,height: currentFrame.height)
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
                        
                        self.maskView.viewController = nil
                    }
                })
        }
    }
    
    var triggerActionContinuation: CGFloat = 0.66
    
    func moveSideMenu(ToPosition position: CGFloat)
    {
        guard maskView.viewController != nil else
        {
            log.warning("%f: side menu is not active")
            return
        }
        
        triggerActionContinuation = 0.25
        
        let currentFrame = sideView.frame
        
        UIView.animateWithDuration(Constants.SlideDuration / 10, animations:
        {
            self.sideView.frame = CGRect(x: position, y: currentFrame.origin.y, width: currentFrame.width,height: currentFrame.height)
        })
    }
    
    func moveSideMenuEdge(ToPosition position: CGFloat)
    {
        guard maskView.viewController != nil else
        {
            log.warning("%f: side menu is not active")
            return
        }
        
        triggerActionContinuation = 0.75
        
        let currentFrame = sideView.frame
        
        UIView.animateWithDuration(Constants.SlideDuration / 10, animations:
        {
                self.sideView.frame = CGRect(
                    x: position - currentFrame.width,
                    y: currentFrame.origin.y,
                    width: currentFrame.width,
                    height: currentFrame.height)
        })
    }
    
    func endMoveSideMenu()
    {
        guard maskView.viewController != nil else
        {
            log.warning("%f: side menu is not active")
            return
        }
        
        if sideView.frame.origin.x < (-maskView.viewController.view.frame.width + Constants.MarginWidth)*triggerActionContinuation
        {
            hideSideMenuNav(WithDuration: Constants.SlideDuration * Double(1-triggerActionContinuation))
        }
        else
        {
            let currentFrame = sideView.frame
            
            UIView.animateWithDuration(Constants.SlideDuration/2, animations:
            {
                self.sideView.frame = CGRect(x: 0, y: currentFrame.origin.y, width: currentFrame.width,height: currentFrame.height)
            })
        }
    }
    
    func showSideMenu(InViewController viewController: UIViewController, AtPosition position: CGFloat? = nil)
    {
        if viewController.view.subviews.contains(sideView) == false
        {
            hideSideMenu()
            
            log.debug("%f: show side menu")
            
            maskView.frame = viewController.view.frame
            viewController.view.addSubview(maskView)
            
            let navbarHeight = navigationBar.frame.height
            
            if navigationBar.hidden
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
            
            maskView.viewController = viewController
            
            UIView.animateWithDuration(Constants.SlideDuration, animations:
            {
                self.sideView.frame = CGRect(
                    x: position == nil ? 0 : position! - (viewController.view.frame.width - Constants.MarginWidth),
                    y: navbarHeight,
                    width: viewController.view.frame.width - Constants.MarginWidth,
                    height: viewController.view.frame.height - navbarHeight)
            })
        }
        
    }
    
    func toggleSideMenu(InViewController viewController: UIViewController)
    {
        if viewController.view.subviews.contains(sideView)
        {
            hideSideMenuNav()
        }
        else
        {
            showSideMenu(InViewController: viewController)
        }
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
