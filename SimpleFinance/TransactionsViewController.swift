//
//  TransactionsViewController.swift
//  SimpleFinance
//
//  Created by Nadir Fayazov on 8/11/16.
//  Copyright © 2016 nfayazov. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

var groups = [Group]()
var transactions = [Transaction]()
var hasGroups = false
var hasTransactions = false //don't need this

class TransactionsViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    let groupPicker = UIPickerView()
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    var groupField = UITextField()
    var createCategoryField = UITextField()
    var amountField = UITextField()
    var descriptionField = UITextField()

    
    //picker methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView,
        numberOfRowsInComponent component: Int) -> Int{
        return groups.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        groupField.text = groups[row].name
        return groups[row].name
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        groupPicker.delegate = self
        groupPicker.dataSource = self
        
        tableView.register(TransactionCell.self, forCellReuseIdentifier: "cell")
        
        
            getTransactionsWithSpinner()
            getTransactions()
        
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
        
    }

    func getTransactions(){
        
        //transactions.removeAll()
        
            let user = FIRAuth.auth()?.currentUser
            let transRef = FIRDatabase.database().reference(fromURL: "https://simple-finance-b8edc.firebaseio.com/").child("transactions").child((user?.uid)!)
            
            transRef.observe(.childAdded, with: { (snap) -> Void in
                
                //get group of the transaction
                
                let transaction = Transaction()
                
                if let dictionary = snap.value as? [String: AnyObject] {
                    transaction.setValuesForKeys(dictionary)
                    if self.isCurrTransaction(transaction: transaction) { //add this month's transaction
                        
                        transactions.append(transaction)
                        hasTransactions = true
                        transactions.sort(by: { (t1, t2) -> Bool in
                            return (t1.timestamp?.int32Value)! < (t2.timestamp?.int32Value)! //sort by date
                        })
                        
                        DispatchQueue.main.async(execute: {
                            self.tableView.reloadData()
                        })
                    }
                
                }

            }, withCancel: nil)
        
    }
    
    func isCurrTransaction(transaction: Transaction) -> Bool{
        
        let date = Date()
        let calendar = NSCalendar.current
        let month = calendar.component(.month, from: date)
        
        let transDate = Date(timeIntervalSince1970: transaction.timestamp as! TimeInterval)
        let transMonth = calendar.component(.month, from: transDate)
        
        if month == transMonth {
        
            return true
            
        }
        return false
        
    }
    
    func getTransactionsWithSpinner() {
        
        var dataCount: Int!
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        let user = FIRAuth.auth()?.currentUser
        let transRef = FIRDatabase.database().reference(fromURL: "https://simple-finance-b8edc.firebaseio.com/").child("transactions").child((user?.uid)!)
        
        transRef.observe(.value, with: { (snap) -> Void in
            
            dataCount = Int(snap.childrenCount)
            if dataCount == transactions.count {
                
                self.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
                
            }
            
        }, withCancel: nil)
        
        
        
    }
    
    @IBAction func addTransaction(_ sender: UIBarButtonItem) {
        
        let addTransAlert = UIAlertController(title: "Add a transaction", message: "\n", preferredStyle: .alert)
        
        //add amount of transactions text field
        addTransAlert.addTextField(configurationHandler: { (textField) -> Void in
            self.amountField = textField
            textField.placeholder = "$$ spent"
            textField.keyboardType = UIKeyboardType.decimalPad
            var frameRect: CGRect = textField.frame;
            frameRect.size.height = 300
            textField.frame = frameRect
            
            
        })
        
        addTransAlert.addTextField(configurationHandler: { (textField) -> Void in
            self.groupField = textField
            textField.placeholder = "Choose category"
            textField.inputView = self.groupPicker
            var frameRect: CGRect = textField.frame;
            frameRect.size.height = 300
            textField.frame = frameRect
            
            })
        
        addTransAlert.addTextField { (textField) -> Void in
            self.descriptionField = textField
            textField.placeholder = "Description"
            var frameRect: CGRect = textField.frame;
            frameRect.size.height = 300
            textField.frame = frameRect
        }
        
        addTransAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        
        //grab the value from the text field, and print it when the user clicks OK.
        addTransAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
    
            let amountField = addTransAlert.textFields![0] as UITextField
            let groupField = addTransAlert.textFields![1] as UITextField
            let descriptionField = addTransAlert.textFields![2] as UITextField

            
            if groupField.text != "" && amountField.text != "" && descriptionField.text != "" {
                
                let user = FIRAuth.auth()?.currentUser
                
                //add to category total
                let catRef = FIRDatabase.database().reference(fromURL: "https://simple-finance-b8edc.firebaseio.com/").child("categories").child((user?.uid)!)
                
                catRef.observe(.childAdded, with: { snapshot in
                    
                    let group = Group()
                    
                    if let dict = snapshot.value as? [String: AnyObject] {
                        group.setValuesForKeys(dict)

                        if group.name == groupField.text {
                            
                            let myDouble = Double(amountField.text!)
                            let total = group.total! as Double
                            group.total = (total + myDouble!) as NSNumber!
                            
                            let newCategory = [
                                
                                "name": group.name as String!,
                                "goal" : group.goal as String!,
                                "total" : group.total! as NSNumber
                                
                                ] as [String : Any]
                            
                            catRef.child(snapshot.key as String!).updateChildValues(newCategory as [AnyHashable: Any], withCompletionBlock: { (error, ref) -> Void in
                                
                                if (error != nil) {
                                    
                                    print(error)
                                    
                                } else {
                                    var i = 0
                                    
                                    //change local gorups array
                                    for groupItem in groups {
                                        
                                        //TODO: used to be by total - why?
                                        if groupItem.name == group.name {
                                            
                                            groups[i].total = (Double(groupItem.total!) + Double(amountField.text!)!) as NSNumber!
                                            
                                        }
                                        
                                        i = i + 1
                                    }
                                }
                            })
                        }
                           }
                }, withCancel: nil)
                
                let ref = FIRDatabase.database().reference(fromURL: "https://simple-finance-b8edc.firebaseio.com/").child("transactions").child((user?.uid)!).childByAutoId()
                let timestamp: NSNumber = NSNumber(value: Int(Date().timeIntervalSince1970))
                let newTransaction: [String: AnyObject] = ["amount" : amountField.text as String! as AnyObject, "reason" : descriptionField.text as String! as AnyObject, "timestamp": timestamp, "category" : groupField.text as String! as AnyObject]
                ref.updateChildValues(newTransaction) { (error, ref) -> Void in
                    
                    if (error != nil) {
                    
                        print(error)
                        
                    } else {
                        
                        DispatchQueue.main.async(execute: {
                            self.tableView.reloadData()
                        })
                        
                    }
                    
                 }
            
            } else {
            
            let alert = UIAlertController(title: "No data found", message: "Please fill in all the boxes", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
                
            }

            
        }))

        self.present(addTransAlert, animated: true, completion: nil)
        
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
        
        //only checking for tranactions
        
        if transactions.count == 0 {
            return 1
        } else {
            return transactions.count
        }
        
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell" , for: indexPath) as! TransactionCell
        
        //TODO: organize by timestamp
        
        if transactions.count != 0 {
            

                let transaction = transactions[(transactions.count-1) - indexPath.row]
        
                cell.textLabel?.text = "$\(transaction.amount!)"
                cell.textLabel?.font = UIFont(name: "Helvetica Neue", size: 17)
            
                cell.detailTextLabel?.text = "\(transaction.reason!)"
                cell.detailTextLabel?.textColor = UIColor.lightGray
                cell.detailTextLabel?.font = UIFont(name: "Helvetica Neue", size: 12)
            
                //set timestamp
                    
                let timestampDate = Date(timeIntervalSince1970: TimeInterval(transaction.timestamp!))
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = DateFormatter.Style.short
            
                cell.timeLabel.text = dateFormatter.string(from: timestampDate)
                cell.timeLabel.textColor = UIColor.lightGray
            
                //set category indicator
                cell.groupLabel.text = transaction.category
                cell.groupLabel.textColor = UIColor.lightGray
                

            
        } else {
            
            cell.textLabel?.text = ""
            
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let transaction = transactions[(transactions.count-1) - indexPath.row]
            deleteTransaction(transaction)
            
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    func deleteTransaction(_ myTransaction: Transaction) {
        
        let timestamp = myTransaction.timestamp
        let category = myTransaction.category
        
        let user = FIRAuth.auth()?.currentUser
        let transRef = FIRDatabase.database().reference(fromURL: "https://simple-finance-b8edc.firebaseio.com/").child("transactions").child((user?.uid)!)
        
        transRef.observe(.value, with: { (snapshot) -> Void in
            
            //find the transaction in database
            
            var i = 0
            
            for child in snapshot.children.allObjects {
                let snap = child as! FIRDataSnapshot
                if let dictionary = snap.value as? [String: AnyObject] {
                    let transaction = Transaction()
                    transaction.setValuesForKeys(dictionary)
                    if transaction.timestamp == timestamp{
                        
                        (child as AnyObject).ref.removeValue()
                        
                        for transaction in transactions {
                            
                            if timestamp == transaction.timestamp{
                                transactions.remove(at: i)
                            }
                            
                            i += 1
                            
                        }
                        DispatchQueue.main.async(execute: {
                            self.tableView.reloadData()
                        })
                    }
                }
            }

        }, withCancel: nil)
        
        
        
        //update total in categories
        var n = 0
        let myDouble = Double(myTransaction.amount!)
        for group in groups {
            
            if category! == group.name {
                groups[n].total = (Double(group.total!) - Double(myTransaction.amount!)!) as NSNumber!
                
                let user = FIRAuth.auth()?.currentUser
                
                let catRef = FIRDatabase.database().reference(fromURL: "https://simple-finance-b8edc.firebaseio.com/").child("categories").child((user?.uid)!)
                
                catRef.observe(.childAdded, with: { snap in
                    
                    let group = Group()
                    
                    if let dict = snap.value as? [String: AnyObject] {
                        group.setValuesForKeys(dict)
                        
                        if group.name == category {
                            
                            let total = group.total! as Double
                            group.total = (total - myDouble!) as NSNumber!
                            
                            let newCategory = [
                                
                                "name": group.name as String!,
                                "goal" : group.goal as String!,
                                "total" : group.total! as NSNumber
                                
                                ] as [String : Any]
                            
                            catRef.child(snap.key as String!).updateChildValues(newCategory as [AnyHashable: Any], withCompletionBlock: { (error, ref) -> Void in
                                
                                if (error != nil) {
                                    print(error)
                                }
                            })
                        }
                    }
                })
            }
            n = n + 1
        }
    }
}
