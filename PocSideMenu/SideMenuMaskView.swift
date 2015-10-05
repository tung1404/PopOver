//
//  SideMenuMaskView.swift
//  PocSideMenu
//
//  Created by Bertrand Marlier on 04/10/2015.
//  Copyright © 2015 Bertrand Marlier. All rights reserved.
//

import UIKit

private let log = Logger()

class SideMenuMaskView: UIView
{
    //weak var navigationController: SideNavigationViewController!
    //weak var viewController: UIViewController!
    weak var sideMenuController: SideMenuController!
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        log.debug("%f")
        
        sideMenuController.hideSideMenu()
    }
}
