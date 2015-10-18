//
//  Child1ViewController.swift
//  PocSideMenu
//
//  Created by Bertrand Marlier on 04/10/2015.
//  Copyright © 2015 Bertrand Marlier. All rights reserved.
//

import UIKit
import Logger
import PopOver

private let log = Logger()

class ClientViewController: UIViewController
{
    var popOverController: PopOverController!
    var content: UIViewController!
    var recognizer: UIScreenEdgePanGestureRecognizer!
    
    @IBAction func configureLeft(sender: UIButton)
    {
        popOverController = PopOverController(PopOverViewController: content, AtPosition: .Left)
        
        view.addGestureRecognizer(recognizer)
    }
    
    @IBAction func configureRight(sender: UIButton)
    {
        content.view.frame = CGRect(x: 0,y: 0,width: 200,height: 170)
        //let size = content.view.sizeThatFits(CGSize(width: 200,height: 100))
        //content.view.frame = CGRect(x: 0,y: 0,width: size.width,height: size.height)
        
        popOverController = PopOverController(PopOverViewController: content, AtPosition: .Center)
        
        view.removeGestureRecognizer(recognizer)
    }
    
    @IBAction func showPopOverCommand(sender: UIButton)
    {
        popOverController.present(InViewController: self)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        content = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewControllerWithIdentifier("Example2") as UIViewController
        
        //content.view.clipsToBounds = true
        //content.preferredContentSize = CGSize(width: 50,height: 50)
        //content.view.preservesSuperviewLayoutMargins = true
        //content.view.layoutMargins = UIEdgeInsets(top: 8,left: 8,bottom: 8,right: 8)
        
        recognizer = UIScreenEdgePanGestureRecognizer(target: self, action: "screenEdgePanHandler:")
        
        recognizer.edges = UIRectEdge.Left
        edgesForExtendedLayout = UIRectEdge.None;
    }

    func screenEdgePanHandler(recognizer: UIScreenEdgePanGestureRecognizer)
    {
        popOverController.onScreenEdgePanEvent(InViewController: self, recognizer: recognizer)
    }
}
