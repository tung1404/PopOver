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
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        let content = ExamplePopOverViewController()
        //content.preferredContentSize = CGSize(width: 200,height: 200)
        
        popOverController = PopOverController(PopOverViewController: content)
    }

}
