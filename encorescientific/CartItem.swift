//
//  CartItem.swift
//  EncoreScientific
//
//  Created by Bryan Neuberger on 7/5/17.
//  Copyright © 2017 Paradigm Creative. All rights reserved.
//

import UIKit

class CartItem: NSObject {

    var cartKey: String!
    var product_id: String!
    var line_total: String!
    var variation_id: String!
    var quantity: String!
    
    var product: Products!
}
