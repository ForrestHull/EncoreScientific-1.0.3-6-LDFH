//
//  CartCell.swift
//  EncoreScientific
//
//  Created by Bryan Neuberger on 7/5/17.
//  Copyright © 2017 Paradigm Creative. All rights reserved.
//

import UIKit

class CartCell: UITableViewCell {
    
    @IBOutlet weak var productImage_imgV: UIImageView!
    @IBOutlet weak var proTitle_lbl: UILabel!
    @IBOutlet weak var pricePerUnit_lbl: UILabel!
    @IBOutlet weak var qty_lbl: UILabel!
    @IBOutlet weak var totalPrice_lbl: UILabel!
    
    @IBOutlet weak var remove_btn: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    

}
