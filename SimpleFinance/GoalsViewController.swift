//
//  GoalsViewController.swift
//  SimpleFinance
//
//  Created by Nadir Fayazov on 8/22/16.
//  Copyright © 2016 nfayazov. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import Firebase

class GoalsViewController: UITableViewController {
    
    var createCategoryField = UITextField()
    var goalField = UITextField()
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var incomeField = UITextField()
    var totalGoal = 0.00
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(GroupCell.self, forCellReuseIdentifier: "groupCell")
        
        getTotalGoal()
        getGroupsWithSpinner()
        getGroups()
        
        
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
    func getGroupsWithSpinner() {
        
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
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })
                
            }
        
        }, withCancel: nil)
        
    }
    
    func updateGoal(newGoal: Double){
        
        let user = FIRAuth.auth()?.currentUser
        let ref = FIRDatabase.database().reference(fromURL: "https://simple-finance-b8edc.firebaseio.com/").child("users").child((user?.uid)!).child("totalGoal")
        
        ref.setValue(newGoal)
        getTotalGoal()
        
        
    }
    
    @IBAction func addCategory(_ sender: UIBarButtonItem) {
        
            let addCategoryAlert = UIAlertController(title: "Add a category", message: "\n", preferredStyle: .alert)
        
            //add amount of transactions text field
            addCategoryAlert.addTextField(configurationHandler: { (textField) -> Void in
                self.createCategoryField = textField
                textField.placeholder = "Category"
                
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

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if groups.count != 0 {
            return groups.count + 1
        } else {
            return 1
        }
    }

    
    func calculateTotals() -> Double {
        
        var total: Double = 0
        
        for group in groups {
            
            total += group.total as! Double
            
        }
        
        return total
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "groupCell" , for: indexPath) as! GroupCell
        
        if indexPath.row == 0 {
            
            cell.textLabel?.text = "Total Spent/Monthly Goal"
            cell.backgroundColor = UIColor.red
            cell.textLabel?.textAlignment = .center
            cell.progressLabel.text = ("\(String(calculateTotals()))/\(String(describing: totalGoal))")
            
        } else {
        
            if groups.count != 0{
                
                cell.textLabel?.text = groups[indexPath.row-1].name
                cell.textLabel?.font = UIFont(name: "Helvetica Neue", size: 17)
                
                let goal = Double(groups[indexPath.row-1].goal!)
                let total = Double(groups[indexPath.row-1].total!)
                let goalString = String(format: "%.2f", goal!)
                let totalString = String(format: "%.2f", total)
                cell.progressLabel.text = "\(totalString)/\(goalString)"
                
                let percent = (total/goal!) * 100
                cell.detailTextLabel?.text = ("\(String(format: "%.2f", percent))%")
                cell.detailTextLabel?.textColor = UIColor.lightGray
                
            } else {
                cell.textLabel?.text = ""
            }
            
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
                        
            let group = groups[indexPath.row]
            deleteGroup(group)
            
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let addTotalAlert = UIAlertController(title: "Change income/goal", message: "What is your goal for this month?", preferredStyle: .alert)
        
        addTotalAlert.addTextField(configurationHandler: { (textField) -> Void in
            self.incomeField = textField
            textField.placeholder = "$$"
            
        })
        
        addTotalAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        addTotalAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
        
            if self.incomeField.text != "" {
                
                self.updateGoal(newGoal: Double(self.incomeField.text!)!)
                
            }
        
        }))
        
        self.present(addTotalAlert, animated: true, completion: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
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
