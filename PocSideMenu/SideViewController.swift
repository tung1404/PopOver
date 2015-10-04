//
//  SideViewController.swift
//  PocSideMenu
//
//  Created by Bertrand Marlier on 04/10/2015.
//  Copyright © 2015 Bertrand Marlier. All rights reserved.
//

import UIKit

private let log = Logger()

class SideViewController: UIViewController {

    override func viewDidLoad()
    {
        super.viewDidLoad()

        let recognizer = UISwipeGestureRecognizer(target: self, action: "swipeHandler:")
        
        recognizer.direction = UISwipeGestureRecognizerDirection.Left
        
        view.addGestureRecognizer(recognizer)
        
        let panRecognizer = UIPanGestureRecognizer(target: self, action: "panHandler:")
        
        view.addGestureRecognizer(panRecognizer)
    }
    
    func panHandler(recognizer: UIPanGestureRecognizer)
    {
        log.debug("%f: state = \(recognizer.state.rawValue)")

        switch recognizer.state
        {
        case .Possible:
            break
        case .Began:
            break
        case .Changed:
            if let navctrl = navigationController as? SideNavigationViewController
            {
                navctrl.moveSideMenu(ToPosition: recognizer.translationInView(navctrl.maskView.viewController.view).x)
            }
            break
        case .Cancelled:
            fallthrough
        case .Ended:
            if let navctrl = navigationController as? SideNavigationViewController
            {
                navctrl.endMoveSideMenu()
            }
            break
        case .Failed:
            break
        }
    }
    
    func swipeHandler(recognizer: UISwipeGestureRecognizer)
    {
        log.debug("%f: state = \(recognizer.state)")
        
        (navigationController as? SideNavigationViewController)?.hideSideMenu()
    }
    
    @IBAction func pressVC1(sender: UIButton)
    {
        log.debug("%f")
    }
    
    @IBAction func pressVC2(sender: UIButton)
    {
        log.debug("%f")
    }
    
    override func didReceiveMemoryWarning() {
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
