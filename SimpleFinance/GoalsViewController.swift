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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(GroupCell.self, forCellReuseIdentifier: "groupCell")
        if !hasGroups {
            getGroups()
        }
        
        if !hasTransactions{
            getTransactions()
        }
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
        
        
    }
    

    
    func getGroups(){
        
        let user = FIRAuth.auth()?.currentUser
        let ref = FIRDatabase.database().reference(fromURL: "https://simple-finance-b8edc.firebaseio.com/").child("categories").child((user?.uid)!)
        
        ref.observe(.childAdded, with: { (snapshot) -> Void in
            
            let group = Group()
            
            if let dict = snapshot.value as? [String: AnyObject] {
                group.setValuesForKeys(dict)
                groups.append(group)
                hasGroups = true
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })
                
            }
            
            }, withCancel: nil)
        
    }

        
    func isCurrTransaction(_ transaction: Transaction) -> Bool{
        //TODO: change back to months
        
        let date = Date(timeIntervalSince1970: TimeInterval(transaction.timestamp!))
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components([.day , .month , .year], from: date)
        let day = components.day
        //let month = components.month
        
        
        let currDate = Date()
        let currCalendar = Calendar.current
        let currComponents = (currCalendar as NSCalendar).components([.day , .month , .year], from: currDate)
        //let currMonth = currComponents.month
        let currDay = currComponents.day

        if (day == currDay) { //change to month
            return true
        }
        
        return false
    }
    
    func getTransactions(){
        
        let user = FIRAuth.auth()?.currentUser
        let transRef = FIRDatabase.database().reference(fromURL: "https://simple-finance-b8edc.firebaseio.com/").child("transactions").child((user?.uid)!)
        
        transRef.observe(.childAdded, with: { (snap) -> Void in
            
            //get group of the transaction
            
            let transaction = Transaction()
            
            if let dictionary = snap.value as? [String: AnyObject] {
                transaction.setValuesForKeys(dictionary)
                transactions.append(transaction)
                hasTransactions = true
                //sort by date
                transactions.sort(by: { (t1, t2) -> Bool in
                    return (t1.timestamp?.int32Value)! < (t2.timestamp?.int32Value)!
                })
                
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })
                
            }
            
            }, withCancel: nil)
        
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
                textField.keyboardType = UIKeyboardType.numbersAndPunctuation
            
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
            return groups.count
        } else {
            return 1
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let group = groups[indexPath.row]
            deleteGroup(group)
            
        }
        
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
