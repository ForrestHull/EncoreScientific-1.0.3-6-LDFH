//
//  Customer.swift
//  EncoreScientific
//
//  Created by Bryan Neuberger on 5/17/17.
//  Copyright © 2017 Paradigm Creative. All rights reserved.
//

import UIKit

class Customer: NSObject {

    
    var username: String!
    var password: String!
    
    var userId: String?
    
    var billingAddress: [String:AnyObject]?
    var shippingAddress: [String:AnyObject]?
    
    var cartKeys = [String]()
    var cookies: String?
    
    var favoritesList = [String]()
    
    var cartItemsList = [CartItem]()
    
    var cart_contents: [String:AnyObject]?
    
}
