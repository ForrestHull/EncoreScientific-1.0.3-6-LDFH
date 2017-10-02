//
//  HomeCell.swift
//  EncoreScientific
//
//  Created by Bryan Neuberger on 5/25/17.
//  Copyright © 2017 Paradigm Creative. All rights reserved.
//

import UIKit

class HomeCell: UITableViewCell {
    
    @IBOutlet weak var lbl_price: UILabel!
    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var lbl_sku: UILabel!
    @IBOutlet weak var imgV_proImg: UIImageView!
    
    @IBOutlet weak var btn_favorites: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
