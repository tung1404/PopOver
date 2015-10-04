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

    override func hideSideMenu()
    {
        if maskView.viewController != nil
        {
            let currentFrame = sideView.frame
            
            UIView.animateWithDuration(0.5, animations:
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
    
    func showSideMenu(InViewController viewController: UIViewController)
    {
        if viewController.view.subviews.contains(sideView) == false
        {
            hideSideMenu()
            
            log.debug("%f: show side menu")
            
            maskView.frame = viewController.view.frame
            viewController.view.addSubview(maskView)
            
            sideView.frame = CGRect(x: -viewController.view.frame.width+50,y: 80,width: viewController.view.frame.width-50,height: viewController.view.frame.height)
            viewController.view.addSubview(sideView)
            viewController.addChildViewController(sideViewController)
            sideViewController.didMoveToParentViewController(viewController)
            
            maskView.viewController = viewController
            
            UIView.animateWithDuration(0.5, animations:
            {
                self.sideView.frame = CGRect(x: 0,y: 80,width: viewController.view.frame.width-50,height: viewController.view.frame.height)
            })
        }
        
    }
    
    func toggleSideMenu(InViewController viewController: UIViewController)
    {
        //sideViewController.beginAppearanceTransition(true, animated: true)
        
        if viewController.view.subviews.contains(sideView)
        {
            hideSideMenu()
        }
        else
        {
            showSideMenu(InViewController: viewController)
        }
        
        //sideViewController.endAppearanceTransition()
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
