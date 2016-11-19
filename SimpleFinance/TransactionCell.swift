//
//  TransactionCell.swift
//  SimpleFinance
//
//  Created by Nadir Fayazov on 10/4/16.
//  Copyright © 2016 nfayazov. All rights reserved.
//

import UIKit

class TransactionCell: UITableViewCell {
    
    let timeLabel: UILabel = {
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Helvetica Neue", size: 15)
        return label
    }()
    
    let groupLabel: UILabel = {
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Helvetica Neue", size: 15)
        return label
        
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: "cell")
        
        addSubview(timeLabel)
        addSubview(groupLabel)
        
        timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        timeLabel.centerYAnchor.constraint(equalTo: self.topAnchor, constant: 20).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: 70).isActive = true
        timeLabel.heightAnchor.constraint(equalTo: (textLabel?.heightAnchor)!).isActive = true

        
        groupLabel.centerYAnchor.constraint(equalTo: self.topAnchor, constant: 20).isActive = true
        groupLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 20).isActive = true
        groupLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        groupLabel.heightAnchor.constraint(equalTo: (textLabel?.heightAnchor)!).isActive = true

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
