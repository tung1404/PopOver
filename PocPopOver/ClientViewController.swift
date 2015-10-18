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
    var content: UIViewController!
    
    @IBAction func configureLeft(sender: UIButton)
    {
        //popOverController?.dismiss()
        
        popOverController = PopOverController(PopOverViewController: content, AtPosition: .Left)
        
        //content.view.sizeToFit()
    }
    
    @IBAction func configureRight(sender: UIButton)
    {
        //popOverController?.dismiss()
        
        content.view.frame = CGRect(x: 0,y: 0,width: 200,height: 300)
        //let size = content.view.sizeThatFits(CGSize(width: 200,height: 100))
        //content.view.frame = CGRect(x: 0,y: 0,width: size.width,height: size.height)
        
        popOverController = PopOverController(PopOverViewController: content, AtPosition: .Center)
    }
    
    @IBAction func showPopOverCommand(sender: UIButton)
    {
        popOverController.present(InViewController: self)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        content = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewControllerWithIdentifier("Example2") as UIViewController

        //content.preferredContentSize = CGSize(width: 50,height: 50)
        //content.view.preservesSuperviewLayoutMargins = true
        //content.view.layoutMargins = UIEdgeInsets(top: 8,left: 8,bottom: 8,right: 8)
        
    }

}
