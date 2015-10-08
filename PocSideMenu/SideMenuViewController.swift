//
//  SideViewController.swift
//  PocSideMenu
//
//  Created by Bertrand Marlier on 04/10/2015.
//  Copyright © 2015 Bertrand Marlier. All rights reserved.
//

import UIKit

private let log = Logger()

class SideMenuViewController: UITableViewController
{
    @IBAction func closeSideMenuCommand(sender: UIButton)
    {
        hideSideMenu()
    }
}
