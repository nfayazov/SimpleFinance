//
//  GroupCell.swift
//  SimpleFinance
//
//  Created by Nadir Fayazov on 10/4/16.
//  Copyright © 2016 nfayazov. All rights reserved.
//

import UIKit

class GroupCell: UITableViewCell {
    
    let progressLabel: UILabel = {
    
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Helvetica Neue", size: 15)
        return label
        
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: "groupCell")
        
        addSubview(progressLabel)
       
        progressLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        progressLabel.centerYAnchor.constraint(equalTo: self.topAnchor, constant: 20).isActive = true
        progressLabel.widthAnchor.constraint(equalToConstant: 120).isActive = true
        progressLabel.heightAnchor.constraint(equalTo: (textLabel?.heightAnchor)!).isActive = true
        progressLabel.textColor = UIColor.lightGray
        
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
