//
//  Child2ViewController.swift
//  PocSideMenu
//
//  Created by Bertrand Marlier on 04/10/2015.
//  Copyright © 2015 Bertrand Marlier. All rights reserved.
//

import UIKit

private let log = Logger()

class Child2ViewController: UIViewController {

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        sideMenuEnable()

    }

    @IBAction func toggleSideMenuCommand(sender: UIButton)
    {
        toggleSideMenu()
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        log.debug("%f: animated = \(animated)")
        
        hideSideMenu(WithAnimation: false)
    }
}
