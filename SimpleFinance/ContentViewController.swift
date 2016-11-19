//
//  ContentViewController.swift
//  SimpleFinance
//
//  Created by Nadir Fayazov on 8/7/16.
//  Copyright © 2016 nfayazov. All rights reserved.
//

import UIKit

class ContentViewController: UIViewController {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    
    var pageIndex: Int!
    var titleText: String!
    var imageFile: String!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        self.imageView.image = UIImage(named: self.imageFile)
        self.titleLabel.text = self.titleText
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
