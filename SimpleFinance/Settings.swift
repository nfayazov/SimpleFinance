//
//  Settings.swift
//  
//
//  Created by Nadir Fayazov on 12/24/16.
//
//

import UIKit
import FirebaseAuth

class Settings: UIViewController {
    
    var cells = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cells  = ["Notifications", "About", "Logout"]
        
    }
    @IBAction func aboutButton(_ sender: Any) {
        
        self.performSegue(withIdentifier: "about", sender: self)
        
    }
    
    @IBAction func logoutButton(_ sender: Any) {
        
        let alert = UIAlertController(title: "Logout", message: "Are you sure you want to log out?", preferredStyle: .alert)
        
        let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        
        let yesAction = UIAlertAction(title: "Yes", style: .destructive) { (action) -> Void in
            
            try! FIRAuth.auth()?.signOut()
            
            self.performSegue(withIdentifier: "logout", sender: self)
            
        }
        
        alert.addAction(noAction)
        alert.addAction(yesAction)
        
        self.present(alert, animated: true, completion: nil)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}
