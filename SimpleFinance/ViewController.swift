//
//  ViewController.swift
//  SimpleFinance
//
//  Created by Nadir Fayazov on 8/7/16.
//  Copyright © 2016 nfayazov. All rights reserved.
//

import UIKit
import FirebaseAuth

var login = false

class ViewController: UIViewController, UIPageViewControllerDataSource {
    
    @IBAction func loginButton(_ sender: AnyObject) {
        
        login = true
        
    }

    var pageViewcontroller: UIPageViewController!
    var pageTitles: NSArray!
    var pageImages: NSArray!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageTitles = NSArray(objects: "Know where your money is going", "Set limits", "Keep track of your money safely")
        
        pageImages = NSArray(objects: "image1", "image2", "image3")
        
        self.pageViewcontroller = self.storyboard?.instantiateViewController(withIdentifier: "PageViewController") as! UIPageViewController
        
        self.pageViewcontroller.dataSource = self
        
        let startVC = viewControllerAtIndex(0)
        let viewControllers = NSArray(object: startVC)
        
        self.pageViewcontroller.setViewControllers(viewControllers as? [UIViewController], direction: .forward, animated: true, completion: nil)
        
        self.pageViewcontroller.view.frame = CGRect(x: 0,y: 30, width: self.view.frame.width, height: self.view.frame.size.height - 100)
        
        self.addChildViewController(self.pageViewcontroller)
        self.view.addSubview(self.pageViewcontroller.view)
        self.pageViewcontroller.didMove(toParentViewController: self)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if FIRAuth.auth()?.currentUser != nil{
            
            performSegue(withIdentifier: "alreadyLoggedIn", sender: self)
            
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    func viewControllerAtIndex(_ index: Int) -> ContentViewController {
        
        if ((self.pageTitles.count == 0) || index >= self.pageTitles.count) {
            
            return ContentViewController()
            
        }
        
        let vc: ContentViewController = self.storyboard?.instantiateViewController(withIdentifier: "ContentViewController") as! ContentViewController
        
        vc.imageFile = self.pageImages[index] as! String
        vc.titleText = self.pageTitles[index] as! String
        vc.pageIndex = index
        
        return vc
        
    }
    
    //MARK: - Page View Controller Data Source
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        let vc = viewController as! ContentViewController
        var index = vc.pageIndex as Int
        
        if (index == 0 || index == NSNotFound){
            
            return nil
            
        }
        
        index -= 1
        return self.viewControllerAtIndex(index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        let vc = viewController as! ContentViewController
        var index = vc.pageIndex as Int
        
        if (index == NSNotFound){
            
            return nil
            
        }
        
        index += 1
        
        if (index == self.pageTitles.count){
            
            return nil
        }
        
        return self.viewControllerAtIndex(index)
        
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        
        return self.pageTitles.count
        
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        
        return 0
        
    }
    
}

