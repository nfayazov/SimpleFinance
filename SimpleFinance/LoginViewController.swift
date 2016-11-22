//
//  LoginViewController.swift
//  SimpleFinance
//
//  Created by Nadir Fayazov on 8/10/16.
//  Copyright © 2016 nfayazov. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

var noCategories = false

class LoginViewController: UIViewController, UITextFieldDelegate {
    

    @IBOutlet var emailField: UITextField!
    @IBOutlet var passwordField: UITextField!

    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()

    @IBAction func createAction(_ sender: AnyObject) {
        
        if login == false {
            
            emailField.text = ""
            passwordField.text = ""
            signinButton.setTitle("Sign In", for: UIControlState())
            memberLabel.text = "Not a member?"
            createButton.setTitle("Create an account", for: UIControlState())
            login = true
            
        } else {
            
            emailField.text = ""
            passwordField.text = ""
            signinButton.setTitle("Create an Account", for: UIControlState())
            memberLabel.text = "Already registered?"
            createButton.setTitle("Sign In", for: UIControlState())
            login = false
            
        }
        
    }
    
    @IBOutlet var signinButton: UIButton!
    @IBOutlet var memberLabel: UILabel!
    @IBOutlet var createButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.emailField.delegate = self
        self.passwordField.delegate = self

        if login == true {
            
            signinButton.setTitle("Sign In", for: UIControlState())
            memberLabel.text = "Not a member?"
            createButton.setTitle("Create an account", for: UIControlState())
            
        } else {
            
            signinButton.setTitle("Create an Account", for: UIControlState())
            memberLabel.text = "Already registered?"
            createButton.setTitle("Sign In", for: UIControlState())
            
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func singinAction(_ sender: AnyObject) {
        
            if emailField.text == "" || passwordField.text == "" {
                
                let alert = UIAlertController(title: "Something went wrong!", message: "Please enter email and password", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
                
            } else {
                
                //creating an account
                
                if login == false {
                    
                    activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0,y: 0,width: 50,height: 50))
                    activityIndicator.center = self.view.center
                    activityIndicator.hidesWhenStopped = true
                    activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
                    view.addSubview(activityIndicator)
                    activityIndicator.startAnimating()
                    UIApplication.shared.beginIgnoringInteractionEvents()
                    
                    FIRAuth.auth()?.createUser(withEmail: emailField.text!, password: passwordField.text!, completion: { (user: FIRUser?, error) -> Void in
                        
                        guard let uid = user?.uid else{
                            
                            self.activityIndicator.stopAnimating()
                            UIApplication.shared.endIgnoringInteractionEvents()
                            
                            let alert = UIAlertController(title: "Something went wrong!", message: error?.localizedDescription, preferredStyle: .alert)
                            let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                            alert.addAction(action)
                            self.present(alert, animated: true, completion: nil)
                            
                            return
                        }
                        
                        let ref = FIRDatabase.database().reference(fromURL: "https://simple-finance-b8edc.firebaseio.com/")
                        let userReference = ref.child("users")
                        let userRef = userReference.child(uid)
                        let emptyString = " "
                        
                        //get month of last time goal was cut
                        let date = Date()
                        let calendar = Calendar.current
                        let components = (calendar as NSCalendar).components([.day , .month , .year], from: date)
                        let month = components.month
                        
                        let values = ["email" : self.emailField.text as AnyObject, "categories" : emptyString] as [String : Any]
                        
                        userRef.updateChildValues(values as [AnyHashable: Any], withCompletionBlock: { (err, ref) -> Void in
                            
                            if err != nil {
                                
                                noCategories = true
                                
                                self.activityIndicator.stopAnimating()
                                UIApplication.shared.endIgnoringInteractionEvents()
                                
                                let alert = UIAlertController(title: "Something went wrong!", message: err?.localizedDescription, preferredStyle: .alert)
                                let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                                alert.addAction(action)
                                self.present(alert, animated: true, completion: nil)
                                
                            }
                            
                        })
                        
                        
                        self.activityIndicator.stopAnimating()
                        UIApplication.shared.endIgnoringInteractionEvents()
                        
                        if error != nil {
                            
                            let alert = UIAlertController(title: "Something went wrong!", message: error?.localizedDescription, preferredStyle: .alert)
                            let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                            alert.addAction(action)
                            self.present(alert, animated: true, completion: nil)
                            
                        } else {
                            
                            self.performSegue(withIdentifier: "login", sender: self)
                            
                        }
                        
                    })
                    
                } else {
                    
                    activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0,y: 0,width: 50,height: 50))
                    activityIndicator.center = self.view.center
                    activityIndicator.hidesWhenStopped = true
                    activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
                    view.addSubview(activityIndicator)
                    activityIndicator.startAnimating()
                    UIApplication.shared.beginIgnoringInteractionEvents()
                    
                    FIRAuth.auth()?.signIn(withEmail: emailField.text!, password: passwordField.text!, completion: { (user, error) -> Void in
                        
                        self.activityIndicator.stopAnimating()
                        UIApplication.shared.endIgnoringInteractionEvents()
                        
                        if error != nil {
                            
                            let alert = UIAlertController(title: "Something went wrong!", message: error?.localizedDescription, preferredStyle: .alert)
                            let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                            alert.addAction(action)
                            self.present(alert, animated: true, completion: nil)
                            
                        } else {
                            
                            self.performSegue(withIdentifier: "login", sender: self)
                            
                        }
                    })
                    
                }
                
            
            
            }
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.view.endEditing(true)
        
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        emailField.resignFirstResponder()
        
        passwordField.resignFirstResponder()
        
        return true
        
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
