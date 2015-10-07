//
//  SideNavigationViewController.swift
//  PocSideMenu
//
//  Created by Bertrand Marlier on 04/10/2015.
//  Copyright © 2015 Bertrand Marlier. All rights reserved.
//

import UIKit

private let log = Logger()

@IBDesignable
class SideMenuNavigationController: UINavigationController
{
    @IBInspectable var sideMenuBundleName: String!;
    @IBInspectable var sideMenuViewControllerIdentifier: String!;
    
    var sideMenuController: SideMenuController!
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        log.debug("%f")
        
        sideMenuController = SideMenuController(
            InBundle: sideMenuBundleName,
            WithIdentifier: sideMenuViewControllerIdentifier,
            WithNavigationController: self)
    }
}
