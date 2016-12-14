//
//  GroupViewController.swift
//  SimpleFinance
//
//  Created by Nadir Fayazov on 11/28/16.
//  Copyright © 2016 nfayazov. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import Firebase

class GroupViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var bgImage: UIImageView!
    @IBOutlet var totalButton: UIButton!
    @IBOutlet var tableView: UITableView!
    var createCategoryField = UITextField()
    var goalField = UITextField()
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var changeGoalField = UITextField()
    var changeGroupNameField = UITextField()
    var totalGoal = 0.00
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(GroupCell.self, forCellReuseIdentifier: "groupCell")
        
        showSpinner()
        getGroups()
        getTotalGoal()
        
        //imageView in the background
        tableView.tableFooterView = UIView()
        self.tableView.isOpaque = false;
        let image: UIImage = UIImage(named: "image5.jpg")!
        bgImage = UIImageView(image: image)
        self.tableView.addSubview(bgImage!)
        self.tableView.sendSubview(toBack: bgImage)
        
    }
    
    @IBAction func changeTotal(_ sender: Any) {
        
        let updateTotalAlert = UIAlertController(title: "Change your monthly goal", message: .none, preferredStyle: .alert)
        
        updateTotalAlert.addTextField(configurationHandler: { (textField) -> Void in
            textField.placeholder = "New Goal Amount"
            textField.keyboardType = UIKeyboardType.decimalPad
            self.createCategoryField = textField
            
        })
        
        updateTotalAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        updateTotalAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            
            self.updateTotalGoal(newGoal: Double(self.createCategoryField.text!)!)
            
        }))
        
        self.present(updateTotalAlert, animated: true, completion: nil)
        
    }
    
    func getGroups(){
        
        let user = FIRAuth.auth()?.currentUser
        let ref = FIRDatabase.database().reference(fromURL: "https://simple-finance-b8edc.firebaseio.com/").child("categories").child((user?.uid)!)
        
        ref.observe(.childAdded, with: { (snapshot) -> Void in
            
            let group = Group()
            
            if let dict = snapshot.value as? [String: AnyObject] {
                group.setValuesForKeys(dict)
                groups.append(group)
                groups.sort(by: { (g1, g2) -> Bool in
                    return (g1.name)! < (g2.name)! //sort alphabetically
                })
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })
                
            }
            
        }, withCancel: nil)
        
    }
    
    func showSpinner() {
        
        var dataCount: Int!
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        let user = FIRAuth.auth()?.currentUser
        let transRef = FIRDatabase.database().reference(fromURL: "https://simple-finance-b8edc.firebaseio.com/").child("categories").child((user?.uid)!)
        
        transRef.observe(.value, with: { (snap) -> Void in
            
            dataCount = Int(snap.childrenCount)
            if dataCount == groups.count {
                
                self.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
                
            }
            
        }, withCancel: nil)
        
    }
    
    func getTotalGoal(){
        
        let user = FIRAuth.auth()?.currentUser
        let ref = FIRDatabase.database().reference(fromURL: "https://simple-finance-b8edc.firebaseio.com/").child("users").child((user?.uid)!)
        
        ref.observe(.childAdded, with: { (snap) -> Void in
            
            if snap.key == "totalGoal" {
                
                self.totalGoal = snap.value as! Double
                self.reloadTotalSpent()
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })
                
            }
            
        }, withCancel: nil)
        
    }
    
    func updateTotalGoal(newGoal: Double){
        
        let user = FIRAuth.auth()?.currentUser
        let ref = FIRDatabase.database().reference(fromURL: "https://simple-finance-b8edc.firebaseio.com/").child("users").child((user?.uid)!).child("totalGoal")
        
        ref.setValue(newGoal)
        getTotalGoal()
        
        
    }
    
    func changeName(newName: String, myGroup: Group){
        
        let user = FIRAuth.auth()?.currentUser
        let ref = FIRDatabase.database().reference(fromURL: "https://simple-finance-b8edc.firebaseio.com/").child("categories").child((user?.uid)!)
        
        ref.observe(.childAdded, with: { (snap) -> Void in
            
            let group = Group()
            
            if let dict = snap.value as? [String: AnyObject] {
                group.setValuesForKeys(dict)
                if group.name == myGroup.name {
                    
                    snap.ref.child("name").setValue(String(newName))
                    DispatchQueue.main.async(execute: {
                        self.tableView.reloadData()
                    })
                    
                    //change name in groups array
                    var i = 0
                    for item in groups {
                        
                        if item.name == myGroup.name{
                            groups[i].name = String(newName)
                        }
                        
                        i = i + 1
                        
                    }

                    
                }
                
            }
            
            
        }, withCancel: nil)

        
    }
    
    func updateGroupGoal(newGoal: Double, myGroup: Group){
        
        let user = FIRAuth.auth()?.currentUser
        let ref = FIRDatabase.database().reference(fromURL: "https://simple-finance-b8edc.firebaseio.com/").child("categories").child((user?.uid)!)
        
        ref.observe(.childAdded, with: { (snap) -> Void in
            
            let group = Group()
            
            if let dict = snap.value as? [String: AnyObject] {
                group.setValuesForKeys(dict)
                if group.name == myGroup.name {
                    
                    snap.ref.child("goal").setValue(String(newGoal))
                    DispatchQueue.main.async(execute: {
                        self.tableView.reloadData()
                    })
                    
                    //change goal in groups array
                    var i = 0
                    for item in groups {
                        
                        if item.name == myGroup.name{
                            groups[i].goal = String(newGoal)
                        }
                        
                        i = i + 1
                        
                    }
                    
                }
                
            }

            
        }, withCancel: nil)
        
    }
    
    @IBAction func addGroup(_ sender: Any) {
        
        let addCategoryAlert = UIAlertController(title: "Add a category", message: "\n", preferredStyle: .alert)
        
        //add amount of transactions text field
        addCategoryAlert.addTextField(configurationHandler: { (textField) -> Void in
            textField.placeholder = "Category"
            textField.keyboardType = UIKeyboardType.default
            textField.autocapitalizationType = UITextAutocapitalizationType.words
            textField.autocorrectionType = UITextAutocorrectionType.yes
            self.createCategoryField = textField

        })
        
        addCategoryAlert.addTextField(configurationHandler: { (textField) -> Void in
            self.goalField = textField
            textField.placeholder = "Fiscal goal per month"
            textField.keyboardType = UIKeyboardType.decimalPad
            
        })
        
        addCategoryAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        addCategoryAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            
            var isUnique = true
            
            if self.createCategoryField.text != "" && self.goalField.text != "" {
                
                for item in groups {
                    
                    if self.createCategoryField.text! as String == item.name {
                        
                        isUnique = false
                        
                        let alert = UIAlertController(title: "Pick a different name", message: "A category with this name already exists. Please pick a new name", preferredStyle: .alert)
                        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                        alert.addAction(action)
                        self.present(alert, animated: true, completion: nil)
                        
                    }
                    
                }
                
                if isUnique { //checks for same name groups
                    
                    let user = FIRAuth.auth()?.currentUser
                    let ref = FIRDatabase.database().reference(fromURL: "https://simple-finance-b8edc.firebaseio.com/").child("categories").child((user?.uid)!).childByAutoId()
                    
                    let newCategory = [
                        
                        "name": self.createCategoryField.text as String!,
                        "goal" : self.goalField.text as String!,
                        "total" : 0 as NSNumber
                        
                        ] as [String : Any]
                    
                    ref.updateChildValues(newCategory as [AnyHashable: Any], withCompletionBlock: { (error, ref) -> Void in
                        
                        if (error != nil) {
                            
                            let alert = UIAlertController(title: "Something went wrong!", message: .none, preferredStyle: .alert)
                            let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                            alert.addAction(action)
                            self.present(alert, animated: true, completion: nil)
                            
                        } else {
                            
                            self.reloadTotalSpent()
                            DispatchQueue.main.async(execute: {
                                self.tableView.reloadData()
                            })
                            
                        }
                        
                    })
                }
            }
        }))
        
        self.present(addCategoryAlert, animated: true, completion: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if groups.count != 0 {
            return groups.count
        } else {
            return 1
        }
    }
    
    func reloadTotalSpent() -> Void {
        
        var total: Double = 0
        
        for group in groups {
            
            total += group.total as! Double
            
        }
        
        let totalString = ("Total Spent/Monthly Goal:         \(String(total))/\(String(describing: self.totalGoal))")
        
        self.totalButton.setTitle(totalString, for: .normal)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "groupCell" , for: indexPath) as! GroupCell
        
            if groups.count != 0{
                
                cell.textLabel?.text = groups[indexPath.row].name
                cell.textLabel?.font = UIFont(name: "Helvetica Neue", size: 17)
                
                
                let goal = Double(groups[indexPath.row].goal!)
                let total = Double(groups[indexPath.row].total!)
                let goalString = String(format: "%.2f", goal!)
                let totalString = String(format: "%.2f", total)
                cell.progressLabel.text = "\(totalString)/\(goalString)"
                
                let percent = (total/goal!) * 100
                cell.detailTextLabel?.text = ("\(String(format: "%.2f", percent))%")
                cell.detailTextLabel?.textColor = UIColor.lightGray
                
                
                
            } else {
                
                cell.textLabel?.text = ""
                cell.detailTextLabel?.text = ""
                cell.progressLabel.text = ""
                
            }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let deleteGroupAlert = UIAlertController(title: "Are you sure you want to delete this category and all of its transactions?", message: .none, preferredStyle: .alert)
            
            deleteGroupAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            deleteGroupAlert.addAction(UIAlertAction(title: "YES", style: .default, handler: { (action) -> Void in

                let group = groups[indexPath.row]
                self.deleteGroup(group)
            
            }))
            
            self.present(deleteGroupAlert, animated: true, completion: nil)
            
        }

        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let addTotalAlert = UIAlertController(title: "Change goal", message: "What is your goal for this month?", preferredStyle: .alert)
        
        addTotalAlert.addTextField(configurationHandler: { (textField) -> Void in
            self.changeGroupNameField = textField
            textField.placeholder = "New Name"
            textField.autocapitalizationType = UITextAutocapitalizationType.words
            textField.autocorrectionType = UITextAutocorrectionType.yes
            
        })
        
        addTotalAlert.addTextField(configurationHandler: { (textField) -> Void in
            self.changeGoalField = textField
            textField.placeholder = "$$"
            textField.keyboardType = UIKeyboardType.decimalPad
            
        })

        
        addTotalAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        addTotalAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            
            if self.changeGoalField.text != "" {
                
                self.updateGroupGoal(newGoal: Double(self.changeGoalField.text!)!, myGroup: groups[indexPath.row])
                
            }
            
            if self.changeGroupNameField.text != ""{
                
                self.changeName(newName: self.changeGroupNameField.text!, myGroup: groups[indexPath.row])
                
            }
            
        }))
        
        self.present(addTotalAlert, animated: true, completion: nil)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        self.reloadTotalSpent()
    }
    
    func deleteGroup(_ myGroup: Group){
        
        let user = FIRAuth.auth()?.currentUser
        let catRef = FIRDatabase.database().reference(fromURL: "https://simple-finance-b8edc.firebaseio.com/").child("categories").child((user?.uid)!)
        
        catRef.observe(.childAdded, with: { (snapshot) -> Void in
            
            let group = Group()
            
            if let dict = snapshot.value as? [String: AnyObject] {
                group.setValuesForKeys(dict)
                
                if ( myGroup.name == group.name) {
                    
                    snapshot.ref.removeValue()
                    
                    var i = 0
                    
                    for goal in groups {
                        
                        if goal.name == group.name {
                            
                            groups.remove(at: i)
                            
                        }
                        
                        i += 1
                        
                    }
                    DispatchQueue.main.async(execute: {
                        self.tableView.reloadData()
                    })
                    
                }
                
            }
            
        }, withCancel: nil)
        
        //delete all transactions in the category
        
        let transRef = FIRDatabase.database().reference(fromURL: "https://simple-finance-b8edc.firebaseio.com/").child("transactions").child((user?.uid)!)
        
        transRef.observe(.childAdded, with: { (snapshot) -> Void in
            
            //find transactions in the category
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                
                let transaction = Transaction()
                transaction.setValuesForKeys(dictionary)
                
                if transaction.category == myGroup.name {
                    
                    snapshot.ref.removeValue()
                    
                    let timestamp = transaction.timestamp
                    var i = 0
                    
                    for item in transactions {
                        
                        if timestamp == item.timestamp{
                            transactions.remove(at: i)
                        }
                        
                        i += 1
                        
                    }
                    
                }
                
            }
            
        }, withCancel: nil)
        
    }
    
}
