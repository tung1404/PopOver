//
//  SideMenuController.swift
//  PocSideMenu
//
//  Created by Bertrand Marlier on 05/10/2015.
//  Copyright © 2015 Bertrand Marlier. All rights reserved.
//

import UIKit
import Logger

private let log = Logger()

public enum SideMenuPosition
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

class PopOverMaskView: UIView
{
    weak var popOverController: PopOverController!
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        log.debug("%f")
        
        popOverController.hide()
    }
    
}

struct Constants
{
    static let MarginWidth: CGFloat = 100 // points
    static let MinVelocity: CGFloat = 600 // points/s
    static let ZeroVelocityTrigger: CGFloat = 50 // points/s
    static let MaskAlpha: CGFloat = 0.2
}

public class PopOverController: NSObject, UIGestureRecognizerDelegate
{
    //weak var navigationController: SideMenuNavigationController!
    weak var clientViewController: UIViewController!
    
    var maskView: PopOverMaskView!
    var popOverView: UIView!
    var clientView: UIView!
    var popOverViewController: UIViewController!

    var fullyDeployed: Bool
    {
        return popOverView.frame.origin.x == 0
    }

    var lockedPanAxis: PanAxis = .Undefined
    
    public init(PopOverViewController popOverViewController: UIViewController)
    {
        super.init()
        
        //self.navigationController = navigationController
        
        maskView = PopOverMaskView()
        maskView.popOverController = self
        
        self.popOverViewController = popOverViewController
        //UIStoryboard(name: bundle,
        //    bundle: nil).instantiateViewControllerWithIdentifier(identifier) as UIViewController
        
        popOverView = popOverViewController.view
        
        popOverView.layer.shadowRadius  = 5;
        popOverView.layer.shadowOpacity = 0.4;
        popOverView.clipsToBounds = false
        
        let panRecognizer = UIPanGestureRecognizer(target: self, action: "sideMenuPanHandler:")
        
        panRecognizer.delegate = self
        
        popOverView.addGestureRecognizer(panRecognizer)
        

    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    @objc public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool
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
        
        popOverViewController.willMoveToParentViewController(nil)
        popOverViewController.removeFromParentViewController()
        popOverView.removeFromSuperview()
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
        
        let currentFrame = popOverView.frame
        
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
            self.popOverView.frame = CGRect(
                x: frameOriginX,
                y: currentFrame.origin.y,
                width: currentFrame.width,
                height: currentFrame.height)
            
            let alpha = (currentFrame.width + frameOriginX)/currentFrame.width * Constants.MaskAlpha
            
            self.maskView.backgroundColor = UIColor(hue: 0, saturation: 0, brightness: 0, alpha: alpha)
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
        
        if velocity < 0 || (velocity == 0 && popOverView.frame.origin.x < -popOverView.frame.width * 0.5)
        {
            hide(WithVelocity: velocity)
        }
        else
        {
            move(ToPosition: SideMenuPosition.LeftEdgeAt(0), WithVelocity: velocity)
        }
    }

    public func show(InViewController viewController: UIViewController, AtPosition position: SideMenuPosition = SideMenuPosition.LeftEdgeAt(0))
    {
        guard viewController.view.subviews.contains(popOverView) == false else
        {
            log.info("%f: side Menu is already inserted")
            return
        }
        
        detach()
        
        log.debug("%f: show side menu")
        
        maskView.frame = CGRect(
            x: 0,
            y: 0,
            width: viewController.view.frame.width,
            height: viewController.view.frame.height)
        
        popOverView.frame = CGRect(
            x: -viewController.view.frame.width + Constants.MarginWidth,
            y: 0,
            width: viewController.view.frame.width - Constants.MarginWidth,
            height: viewController.view.frame.height)
        
        viewController.view.addSubview(maskView)
        viewController.view.addSubview(popOverView)
        viewController.addChildViewController(popOverViewController)
        popOverViewController.didMoveToParentViewController(viewController)
        
        clientView = viewController.view
        clientViewController = viewController
        
        if let scrollView = popOverView as? UIScrollView
        {
            log.debug("reset scroll view")
            scrollView.contentOffset = CGPointZero
        }
        
        move(ToPosition: position)
        
        // TODO: possibly need to move this in side menu and not popover
        /*let recognizer = UIScreenEdgePanGestureRecognizer(target: self, action: "sideMenuSlideScreenEdge:")
        recognizer.edges = UIRectEdge.Left
        viewController.view.addGestureRecognizer(recognizer)
        viewController.edgesForExtendedLayout = UIRectEdge.None;*/
    }
    
    func toggle(InViewController viewController: UIViewController)
    {
        if viewController.view.subviews.contains(popOverView)
        {
            hide()
        }
        else
        {
            show(InViewController: viewController)
        }
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
                show(InViewController: clientViewController,
                    AtPosition: SideMenuPosition.RightEdgeAt(recognizer.translationInView(clientView).x))
                
            case .Changed:
                // the recognizer has received touches recognized as a change to the gesture. the action method will be called at the next turn of the run loop
                move(
                    ToPosition: SideMenuPosition.RightEdgeAt(recognizer.translationInView(clientView).x),
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
                
                move(ToPosition: SideMenuPosition.RightEdgeAt(recognizer.translationInView(clientView).x))
                
                drop(WithVelocity: recognizer.velocityInView(clientView).x)
                
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
                
                lockedPanAxis = .Undefined
                
            case .Changed:
                
                switch lockedPanAxis
                {
                    case .Undefined:
                        
                        let panningX = abs(recognizer.translationInView(clientView).x)
                        let panningY = abs(recognizer.translationInView(clientView).y)
                        
                        if fullyDeployed == false || panningY == 0 || panningX/panningY > 1
                        {
                            lockedPanAxis = PanAxis.Horizontal
                            fallthrough
                        }
                        else
                        {
                            lockedPanAxis = PanAxis.Vertical
                        }
                    case .Horizontal:
                        move(ToPosition: SideMenuPosition.LeftEdgeAt(recognizer.translationInView(clientView).x), WithAnimation: false)
                        
                    case .Vertical:
                        break
                }
                
            case .Cancelled: fallthrough
            case .Ended:
                
                if case .Horizontal = lockedPanAxis
                {
                    drop(WithVelocity: recognizer.velocityInView(clientView).x)
                }
                else
                {
                    if fullyDeployed == false
                    {
                        log.error("no endMove call with side menu not fully deployed")
                    }
                }
                
            case .Failed:
                break
        }
    }
}