//
//  Products.swift
//  EncoreScientific
//
//  Created by Bryan Neuberger on 5/17/17.
//  Copyright © 2017 Paradigm Creative. All rights reserved.
//

import UIKit


enum ProductCategory {
    case all
    case apis
    case bases
    case excipients
}

class Products: NSObject {
    
    var title: String?
    var id: Int?
    var sku: String?
    var price: String?
    var imgUrl: String?
    var img: UIImage?
    var descript: String?
    
    var variations: [[String: AnyObject]]?
    var variationsArray: [Variations]?
    

}
