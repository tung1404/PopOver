//
//  ExamplePopOverViewController.swift
//  PocPopOver
//
//  Created by Bertrand Marlier on 17/10/2015.
//  Copyright © 2015 Bertrand Marlier. All rights reserved.
//

import UIKit
import PopOver
import Logger

class ExamplePopOverViewController: UIViewController
{
    @IBAction func commandCancel(sender: UIButton)
    {
        log.debug("%f")
        //PopOverController.getControllerInstance(ForPopOverViewController: self).dismiss()
    }
    
    @IBAction func commandDone(sender: UIButton)
    {
        log.debug("%f")
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

    }
}
