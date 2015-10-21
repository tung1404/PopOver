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

class ClientViewController: UIViewController
{
    var popOverController: PopOverController!
    var content: ExamplePopOverViewController!
    var recognizer: UIScreenEdgePanGestureRecognizer!
    
    @IBAction func configureLeft(sender: UIButton)
    {
        popOverController = PopOverController(PopOverViewController: content, AtPosition: .Left)

        content.popOverController = popOverController
        
        view.addGestureRecognizer(recognizer)
    }
    
    @IBAction func configureCenter(sender: UIButton)
    {
        content.view.frame = CGRect(x: 0,y: 0,width: 320,height: 202)
        
        popOverController = PopOverController(PopOverViewController: content, AtPosition: .Center)

        content.popOverController = popOverController
        
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
            .instantiateViewControllerWithIdentifier("Example2") as! ExamplePopOverViewController
        
        recognizer = UIScreenEdgePanGestureRecognizer(target: self, action: "screenEdgePanHandler:")
        
        recognizer.edges = UIRectEdge.Left
        edgesForExtendedLayout = UIRectEdge.None;
    }

    func screenEdgePanHandler(recognizer: UIScreenEdgePanGestureRecognizer)
    {
        popOverController.onScreenEdgePanEvent(InViewController: self, recognizer: recognizer)
    }
}
