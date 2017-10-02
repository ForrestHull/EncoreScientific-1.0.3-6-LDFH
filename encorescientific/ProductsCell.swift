//
//  ProductsCell.swift
//  EncoreScientific
//
//  Created by Bryan Neuberger on 5/17/17.
//  Copyright © 2017 Paradigm Creative. All rights reserved.
//

import UIKit

class ProductsCell: UITableViewCell {
    
    @IBOutlet weak var imgV_productImage: UIImageView!
    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var lbl_price: UILabel!
    @IBOutlet weak var lbl_sku: UILabel!
    
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
