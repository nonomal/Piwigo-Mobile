//
//  ButtonTableViewCell.swift
//  piwigo
//
//  Created by Spencer Baker on 2/2/15.
//  Copyright (c) 2015 bakercrew. All rights reserved.
//
//  Converted to Swift 5 by Eddy Lelièvre-Berna on 12/04/2020.
//

import UIKit

class ButtonTableViewCell: UITableViewCell {

    @IBOutlet weak var buttonLabel: UILabel!
    
    func configure(with title: String) {

        // Background color and aspect
        backgroundColor = .piwigoColorCellBackground()

        // Button title
        buttonLabel.font = .systemFont(ofSize: 21)
        buttonLabel.textColor = .piwigoColorOrange()
        buttonLabel.text = title
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        buttonLabel.text = ""
    }
}
