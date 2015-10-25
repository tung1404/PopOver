//
//  ClientTableViewController.swift
//  PocPopOver
//
//  Created by Bertrand Marlier on 25/10/2015.
//  Copyright © 2015 Bertrand Marlier. All rights reserved.
//

import UIKit
import PopOver

class ClientTableViewController: UITableViewController
{
    var popOverController: PopOverController!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let content = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewControllerWithIdentifier("ClientTableViewController") as! PopOverTableViewController

        popOverController = PopOverController(PopOverViewController: content, AtPosition: .Center)
    }
    
    @IBAction func commandShowPopOver(sender: UIButton)
    {
        popOverController.present(InViewController: self)
    }
}
