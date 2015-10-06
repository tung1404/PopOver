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
    func sideMenuEnable()
    {
        let recognizer = UIScreenEdgePanGestureRecognizer(target: self, action: "sideMenuSlideScreenEdge:")
        
        recognizer.edges = UIRectEdge.Left
        
        view.addGestureRecognizer(recognizer)
        
        edgesForExtendedLayout = UIRectEdge.None;
    }
    
    func sideMenuSlideScreenEdge(recognizer: UIScreenEdgePanGestureRecognizer)
    {
        log.debug("%f: state = \(recognizer.state.rawValue)")
        
        switch recognizer.state
        {
        case .Possible:
            // the recognizer has not yet recognized its gesture, but may be evaluating touch events. this is the default state
            break
            
        case .Began:
            // the recognizer has received touches recognized as the gesture. the action method will be called at the next turn of the run loop
            if let navctrl = navigationController as? SideMenuNavigationController
            {
                navctrl.sideMenuController.showSideMenu(InViewController: self,
                    AtPosition: SideMenuPosition.RightEdgeAt(recognizer.translationInView(view).x))
            }
            
        case .Changed:
            // the recognizer has received touches recognized as a change to the gesture. the action method will be called at the next turn of the run loop
            if let navctrl = navigationController as? SideMenuNavigationController
            {
                navctrl.sideMenuController.moveSideMenu(
                    ToPosition: SideMenuPosition.RightEdgeAt(recognizer.translationInView(view).x),
                    WithAnimation: false)
            }
            
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
                navctrl.sideMenuController.moveSideMenu(ToPosition: SideMenuPosition.RightEdgeAt(recognizer.translationInView(view).x))
                
                navctrl.sideMenuController.endMoveSideMenu(WithVelocity: recognizer.velocityInView(view).x)
            }
            
        case .Failed:
            // the recognizer has received a touch sequence that can not be recognized as the gesture. the action method will not be called and the recognizer will be reset to UIGestureRecognizerStatePossible
            
            // Discrete Gestures – gesture recognizers that recognize a discrete event but do not report changes (for example, a tap) do not transition through the Began and Changed states and can not fail or be cancelled
            break
            
        }
    }
    
    func sideMenuPanHandler(recognizer: UIPanGestureRecognizer)
    {
        log.debug("%f: state = \(recognizer.state.rawValue)")
        
        switch recognizer.state
        {
        case .Possible:
            break
            
        case .Began:
            
            if let navctrl = navigationController as? SideMenuNavigationController
            {
                navctrl.sideMenuController.lockedPanAxis = .Undefined
            }
            
        case .Changed:
            
            if let navctrl = navigationController as? SideMenuNavigationController
            {
                let sideMenuController = navctrl.sideMenuController
                let view = navctrl.sideMenuController.clientViewController.view
                
                switch sideMenuController.lockedPanAxis
                {
                    case .Undefined:
                        
                        let panningX = abs(recognizer.translationInView(view).x)
                        let panningY = abs(recognizer.translationInView(view).y)
                        
                        if sideMenuController.sideMenuFullyDeployed == false || panningY == 0 || panningX/panningY > 1
                        {
                            sideMenuController.lockedPanAxis = PanAxis.Horizontal
                            fallthrough
                        }
                        else
                        {
                            sideMenuController.lockedPanAxis = PanAxis.Vertical
                            //break
                        }
                    case .Horizontal:
                        sideMenuController.moveSideMenu(ToPosition: SideMenuPosition.LeftEdgeAt(recognizer.translationInView(view).x), WithAnimation: false)
                        
                    case .Vertical:
                        break
                }
            }
            
        case .Cancelled: fallthrough
        case .Ended:
            
            if let navctrl = navigationController as? SideMenuNavigationController
            {
                if case .Horizontal = navctrl.sideMenuController.lockedPanAxis
                {
                    navctrl.sideMenuController.endMoveSideMenu(WithVelocity: recognizer.velocityInView(navctrl.sideMenuController.clientViewController.view).x)
                }
                else
                {
                    if navctrl.sideMenuController.sideMenuFullyDeployed == false
                    {
                        log.error("no endMove call with side menu not fully deployed")
                    }
                }
            }
            
        case .Failed:
            break
        }
    }
    
    /*func detachSideMenu()
    {
        if let navctrl = navigationController as? SideMenuNavigationController
        {
            navctrl.sideMenuController.detachSideMenu()
        }
    }*/

    func showSideMenu()
    {
        if let navctrl = navigationController as? SideMenuNavigationController
        {
            navctrl.sideMenuController.showSideMenu(InViewController: self)
        }
    }
    
    func hideSideMenu(WithAnimation animation: Bool = true)
    {
        if let navctrl = navigationController as? SideMenuNavigationController
        {
            navctrl.sideMenuController.hideSideMenu(WithAnimation: animation)
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

