//
//  ViewControllerExtension.swift
//  PocSideMenu
//
//  Created by Bertrand Marlier on 04/10/2015.
//  Copyright © 2015 Bertrand Marlier. All rights reserved.
//

import UIKit

private let log = Logger()

extension UIViewController
{
    func sideMenuSupportEnable()
    {
        let recognizer = UIScreenEdgePanGestureRecognizer(target: self, action: "sideMenuSlideScreenEdge:")
        
        recognizer.edges = UIRectEdge.Left
        
        view.addGestureRecognizer(recognizer)
    }
    
    func sideMenuSlideScreenEdge(recognizer: UIScreenEdgePanGestureRecognizer)
    {
        log.debug("%f: state = \(recognizer.state)")
        
        switch recognizer.state
        {
        case .Possible:
            // the recognizer has not yet recognized its gesture, but may be evaluating touch events. this is the default state
            break
            
        case .Began:
            // the recognizer has received touches recognized as the gesture. the action method will be called at the next turn of the run loop
            if let navctrl = navigationController as? SideMenuNavigationController
            {
                navctrl.sideMenuController.showSideMenu(InViewController: self, AtPosition: 0/*recognizer.translationInView(view).x*/)
            }
            break
            
        case .Changed:
            // the recognizer has received touches recognized as a change to the gesture. the action method will be called at the next turn of the run loop
            if let navctrl = navigationController as? SideMenuNavigationController
            {
                navctrl.sideMenuController.moveSideMenuEdge(ToPosition: recognizer.translationInView(view).x)
                //navctrl.showSideMenu(InViewController: self, AtPosition: )
            }
            break
            
        case .Cancelled: fallthrough
            // the recognizer has received touches resulting in the cancellation of the gesture. the action method will be called at the next turn of the run loop. the recognizer will be reset to UIGestureRecognizerStatePossible
        case .Ended:
            // the recognizer has received touches recognized as the end of the gesture. the action method will be called at the next turn of the run loop and the recognizer will be reset to UIGestureRecognizerStatePossible
            
            /*if let navctrl = navigationController as? SideNavigationViewController
            {
            navctrl.showSideMenu(InViewController: self)
            }
            */
            
            if let navctrl = navigationController as? SideMenuNavigationController
            {
                navctrl.sideMenuController.endMoveSideMenu()
            }
            
        case .Failed:
            // the recognizer has received a touch sequence that can not be recognized as the gesture. the action method will not be called and the recognizer will be reset to UIGestureRecognizerStatePossible
            
            // Discrete Gestures – gesture recognizers that recognize a discrete event but do not report changes (for example, a tap) do not transition through the Began and Changed states and can not fail or be cancelled
            break
            
        }
    }
    
    func showSideMenu()
    {
        if let navctrl = navigationController as? SideMenuNavigationController
        {
            navctrl.sideMenuController.showSideMenu(InViewController: self)
        }
    }
    
    func hideSideMenu()
    {
        if let navctrl = navigationController as? SideMenuNavigationController
        {
            navctrl.sideMenuController.hideSideMenu()
        }
    }
    
    func toggleSideMenu()
    {
        if let navctrl = navigationController as? SideMenuNavigationController
        {
            navctrl.sideMenuController.toggleSideMenu(InViewController: self)
        }
    }
}

