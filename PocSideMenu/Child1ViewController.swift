//
//  Child1ViewController.swift
//  PocSideMenu
//
//  Created by Bertrand Marlier on 04/10/2015.
//  Copyright © 2015 Bertrand Marlier. All rights reserved.
//

import UIKit

private let log = Logger()

protocol SideMenuSupportDelegate
{
    
}

class Child1ViewController: UIViewController {

    override func viewDidLoad()
    {
        super.viewDidLoad()

        sideMenuSupportEnable()
    }

    @IBAction func buttonAction(sender: UIButton)
    {
        log.debug("%f")
    }
    
    @IBAction func toggleSideMenu(sender: UIBarButtonItem)
    {
        toggleSideMenu()
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        log.debug("%f")
        
        hideSideMenu()
    }
}
