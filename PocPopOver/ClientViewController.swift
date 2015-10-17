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
    
    @IBAction func showPopOverCommand(sender: UIButton)
    {
        popOverController.show(InViewController: self)//, AtPosition: .RightEdgeAt(200) )
    }
    
    @IBAction func buttonCommand(sender: UIButton)
    {
        log.debug("view.frame = \(view.frame)")
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        let content =
        UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("Example2") as UIViewController

        popOverController = PopOverController(PopOverViewController: content)
    }

}
