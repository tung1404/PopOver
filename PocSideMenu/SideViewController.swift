//
//  SideViewController.swift
//  PocSideMenu
//
//  Created by Bertrand Marlier on 04/10/2015.
//  Copyright © 2015 Bertrand Marlier. All rights reserved.
//

import UIKit

private let log = Logger()

class SideViewController: UIViewController
{
    @IBAction func pressVC1(sender: UIButton)
    {
        log.debug("%f")
    }
    
    @IBAction func pressVC2(sender: UIButton)
    {
        log.debug("%f")
    }
}
