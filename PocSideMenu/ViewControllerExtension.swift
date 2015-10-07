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
        guard let sideMenu = sideMenu() else
        {
            return
        }
        
        log.debug("%f: state = \(recognizer.state.rawValue)")
        
        switch recognizer.state
        {
            case .Possible:
                // the recognizer has not yet recognized its gesture, but may be evaluating touch events. this is the default state
                break
                
            case .Began:
                // the recognizer has received touches recognized as the gesture. the action method will be called at the next turn of the run loop
                sideMenu.show(InViewController: self,
                    AtPosition: SideMenuPosition.RightEdgeAt(recognizer.translationInView(view).x))
            
            case .Changed:
                // the recognizer has received touches recognized as a change to the gesture. the action method will be called at the next turn of the run loop
                sideMenu.move(
                    ToPosition: SideMenuPosition.RightEdgeAt(recognizer.translationInView(view).x),
                    WithAnimation: false)
            
            case .Cancelled: fallthrough
                // the recognizer has received touches resulting in the cancellation of the gesture. the action method will be called at the next turn of the run loop. the recognizer will be reset to UIGestureRecognizerStatePossible
            case .Ended:
                // the recognizer has received touches recognized as the end of the gesture. the action method will be called at the next turn of the run loop and the recognizer will be reset to UIGestureRecognizerStatePossible
                
                /*if let navctrl = navigationController as? SideNavigationViewController
                {
                navctrl.showSideMenu(InViewController: self)
                }
                */
                
                sideMenu.move(ToPosition: SideMenuPosition.RightEdgeAt(recognizer.translationInView(view).x))
                
                sideMenu.drop(WithVelocity: recognizer.velocityInView(view).x)
                
            case .Failed:
                // the recognizer has received a touch sequence that can not be recognized as the gesture. the action method will not be called and the recognizer will be reset to UIGestureRecognizerStatePossible
                
                // Discrete Gestures – gesture recognizers that recognize a discrete event but do not report changes (for example, a tap) do not transition through the Began and Changed states and can not fail or be cancelled
                break
                
        }
    }
    
    func sideMenuPanHandler(recognizer: UIPanGestureRecognizer)
    {
        guard let sideMenu = sideMenu() else
        {
            return
        }
        
        log.debug("%f: state = \(recognizer.state.rawValue)")
        
        switch recognizer.state
        {
            case .Possible:
                break
                
            case .Began:
                
                sideMenu.lockedPanAxis = .Undefined
                
            case .Changed:
            
                let view = sideMenu.clientViewController.view
                
                switch sideMenu.lockedPanAxis
                {
                    case .Undefined:
                        
                        let panningX = abs(recognizer.translationInView(view).x)
                        let panningY = abs(recognizer.translationInView(view).y)
                        
                        if sideMenu.fullyDeployed == false || panningY == 0 || panningX/panningY > 1
                        {
                            sideMenu.lockedPanAxis = PanAxis.Horizontal
                            fallthrough
                        }
                        else
                        {
                            sideMenu.lockedPanAxis = PanAxis.Vertical
                        }
                    case .Horizontal:
                        sideMenu.move(ToPosition: SideMenuPosition.LeftEdgeAt(recognizer.translationInView(view).x), WithAnimation: false)
                        
                    case .Vertical:
                        break
                }
            
            case .Cancelled: fallthrough
            case .Ended:
            
                if case .Horizontal = sideMenu.lockedPanAxis
                {
                    sideMenu.drop(WithVelocity: recognizer.velocityInView(sideMenu.clientViewController.view).x)
                }
                else
                {
                    if sideMenu.fullyDeployed == false
                    {
                        log.error("no endMove call with side menu not fully deployed")
                    }
                }
            
            case .Failed:
            break
        }
    }
    
    func showSideMenu()
    {
        sideMenu()?.show(InViewController: self)
    }
    
    func hideSideMenu(WithAnimation animation: Bool = true)
    {
        sideMenu()?.hide(WithAnimation: animation)
    }
    
    func toggleSideMenu()
    {
        sideMenu()?.toggle(InViewController: self)
    }
    
    func sideMenu() -> SideMenuController?
    {
        return (navigationController as? SideMenuNavigationController)?.sideMenuController
    }
}

