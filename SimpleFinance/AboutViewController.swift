//
//  AboutViewController.swift
//  SimpleFinance
//
//  Created by Nadir Fayazov on 12/24/16.
//  Copyright © 2016 nfayazov. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {

    @IBOutlet var aboutLabel: UILabel!
    
    @IBAction func doneButton(_ sender: Any) {
        
        self.performSegue(withIdentifier: "aboutDone", sender: self)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        aboutLabel.numberOfLines = 10
        
        aboutLabel.text = "This app is an experimental project and part of a learning process of a student of iOS development. It is not complete, and it is yet to be determined whether it will be modified again. The app is missing some features that were desgined yet were never implented, such as charts(as indicated), notifications, custom UI, etc. "
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
