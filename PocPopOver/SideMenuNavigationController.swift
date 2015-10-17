//
//  SideNavigationViewController.swift
//  PocSideMenu
//
//  Created by Bertrand Marlier on 04/10/2015.
//  Copyright © 2015 Bertrand Marlier. All rights reserved.
//

import UIKit

@IBDesignable
public class SideMenuNavigationController: UINavigationController
{
    @IBInspectable
    public var sideMenuBundleName: String!;
    
    @IBInspectable
    public var sideMenuViewControllerIdentifier: String!;
    
    var sideMenuController: SideMenuController!
    
    override public func viewDidLoad()
    {
        super.viewDidLoad()

        sideMenuController = SideMenuController(
            InBundle: sideMenuBundleName,
            WithIdentifier: sideMenuViewControllerIdentifier,
            WithNavigationController: self)
    }
}
