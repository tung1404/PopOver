//
//  SideMenuController.swift
//  PocSideMenu
//
//  Created by Bertrand Marlier on 05/10/2015.
//  Copyright © 2015 Bertrand Marlier. All rights reserved.
//

import UIKit
import Logger

public enum PopOverPosition
{
    case Left
    //case Right
    //case Top
    //case Bottom
    case Center
}

internal let log = Logger(WithName: "PopOver")

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

class PopOverMaskView: UIView
{
    weak var popOverController: PopOverController!
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        log.debug("%f")
        
        popOverController.dismiss()
    }
    
}

struct Constants
{
    static let MarginWidth: CGFloat = 100 // points
    static let MinVelocity: CGFloat = 600 // points/s
    static let ZeroVelocityTrigger: CGFloat = 50 // points/s
    static let MaskAlpha: CGFloat = 0.2
    static let PopOverFadingDuration: NSTimeInterval = 0.25
}

public class PopOverController: NSObject, UIGestureRecognizerDelegate
{
    // before show
    //public let fillEdge = true
    
    
    //weak var navigationController: SideMenuNavigationController!
    weak var clientViewController: UIViewController!
    
    var maskView: PopOverMaskView!
    var popOverView: UIView!
    var clientView: UIView!
    var popOverViewController: UIViewController!
    var popOverPosition: PopOverPosition
    
    var fullyDeployed: Bool
    {
        return popOverView.frame.origin.x == 0
    }

    var lockedPanAxis: PanAxis = .Undefined
    
    // MARK: - API
    
    public init(PopOverViewController popOverViewController: UIViewController, AtPosition position: PopOverPosition)
    {
        self.popOverViewController = popOverViewController
        self.popOverPosition = position
        
        super.init()
        
        maskView = PopOverMaskView()
        maskView.popOverController = self
        
        popOverView = popOverViewController.view
        
        popOverView.layer.shadowRadius  = 5;
        popOverView.layer.shadowOpacity = 0.4;
        popOverView.clipsToBounds = false

        self.maskView.backgroundColor = UIColor(hue: 0, saturation: 0, brightness: 0, alpha: 0)

        switch position
        {
            case .Left:
                let panRecognizer = UIPanGestureRecognizer(target: self, action: "popOverPanHandler:")
                panRecognizer.delegate = self
                popOverView.addGestureRecognizer(panRecognizer)
                
                popOverView.layer.cornerRadius = 0;
            
            case .Center:
                popOverView.layer.cornerRadius = 10;
        }
        
        //popOverView.layer.masksToBounds = true;
        //popOverView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
        //        popOverView.systemLayoutSizeFittingSize(CGSize(width: 300,height: 300), withHorizontalFittingPriority: UILayoutPriorityFittingSizeLevel, verticalFittingPriority: UILayoutPriorityFittingSizeLevel)
        //popOverView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    public func present(InViewController viewController: UIViewController)
    {
        attach(InViewController: viewController)
        
        switch popOverPosition
        {
            case .Left:
                move(ToPosition: SideMenuPosition.LeftEdgeAt(0))
                
            case .Center:
                UIView.animateWithDuration(Constants.PopOverFadingDuration)
                {
                    self.popOverView.alpha = 1
                    self.maskView.backgroundColor = UIColor(hue: 0, saturation: 0, brightness: 0, alpha: Constants.MaskAlpha)
                }
                break
        }
    }
    
    public func dismiss()
    {
        guard clientViewController != nil else
        {
            log.info("%f: pop over is not active")
            return
        }
        
        dismiss(WithVelocity: 0)
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    @objc public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool
    {
        return fullyDeployed
    }
    
    // MARK: - Implementation
    
    func attach(InViewController viewController: UIViewController)
    {
        guard viewController !== clientViewController else
        {
            log.info("%f: side Menu is already inserted")
            return
        }
        
        detach()
        
        log.debug("%f: show side menu")
        
        clientView = viewController.view
        clientViewController = viewController
        
        maskView.frame = CGRect(
            x: 0,
            y: 0,
            width: clientView.frame.width,
            height: clientView.frame.height)
        
        clientView.addSubview(maskView)
        clientView.addSubview(popOverView)
        clientViewController.addChildViewController(popOverViewController)
        popOverViewController.didMoveToParentViewController(viewController)
        
        switch popOverPosition
        {
            case .Left:
                popOverView.alpha = 1
                
                popOverView.frame = CGRect(
                    x: -clientView.frame.width + Constants.MarginWidth,
                    y: 0,
                    width: clientView.frame.width - Constants.MarginWidth,
                    height: clientView.frame.height)
            
            case .Center:
                popOverView.alpha = 0
                
                popOverView.frame = CGRect(
                    x: (clientView.frame.width - popOverView.frame.width)/2,
                    y: (clientView.frame.height - popOverView.frame.height)/2,
                    width: popOverView.frame.width,
                    height: popOverView.frame.height)
        }
        
        
        if let scrollView = popOverView as? UIScrollView
        {
            log.debug("reset scroll view")
            scrollView.contentOffset = CGPointZero
        }
    }
    
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
    
    func dismiss(WithVelocity velocity: CGFloat, WithAnimation animation: Bool = true)
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
            switch popOverPosition
            {
                case .Left:
                    move(ToPosition: SideMenuPosition.RightEdgeAt(0), WithVelocity: velocity, WithCompletion: detachAction)
                
                case .Center:
                    UIView.animateWithDuration(Constants.PopOverFadingDuration, animations:
                    {
                        self.popOverView.alpha = 0
                        self.maskView.backgroundColor = UIColor(hue: 0, saturation: 0, brightness: 0, alpha: 0)
                    }, completion: detachAction)
                
            }
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
        
        //popOverView.layoutIfNeeded()
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
            dismiss(WithVelocity: velocity)
        }
        else
        {
            move(ToPosition: SideMenuPosition.LeftEdgeAt(0), WithVelocity: velocity)
        }
    }

    func present(InViewController viewController: UIViewController, AtPosition position: SideMenuPosition)
    {
        attach(InViewController: viewController)
        
        move(ToPosition: position)
    }
    
    /*func toggle(InViewController viewController: UIViewController)
    {
        if viewController.view.subviews.contains(popOverView)
        {
            hide()
        }
        else
        {
            show(InViewController: viewController)
        }
    }*/
    
    public func onScreenEdgePanEvent(
        InViewController viewController: UIViewController,
        recognizer: UIScreenEdgePanGestureRecognizer)
    {
        log.debug("%f: state = \(recognizer.state.rawValue)")
        
        switch recognizer.state
        {
            case .Possible:
                // the recognizer has not yet recognized its gesture, but may be evaluating touch events. this is the default state
                break
                
            case .Began:
                // the recognizer has received touches recognized as the gesture. the action method will be called at the next turn of the run loop
                present(InViewController: viewController,
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
    
    func popOverPanHandler(recognizer: UIPanGestureRecognizer)
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