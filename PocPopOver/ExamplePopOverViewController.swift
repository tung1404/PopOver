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
    weak var popOverController: PopOverController!
    
    @IBAction func commandCancel(sender: UIButton)
    {
        log.debug("%f")
        popOverController.dismiss()
    }
    
    @IBAction func commandDone(sender: UIButton)
    {
        log.debug("%f")
        popOverController.dismiss()
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

    }
}
