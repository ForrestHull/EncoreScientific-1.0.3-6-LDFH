//
//  HomeVCgetProducts.swift
//  EncoreScientific
//
//  Created by Bryan Neuberger on 5/25/17.
//  Copyright © 2017 Paradigm Creative. All rights reserved.
//

import Foundation
import UIKit

extension HomeVC {
    
    
    //func to fetch database from WC
    func fetchDatabase(skuToPass: String) {
        print("fetching products...")
        
        //create a request with the URL
        let url = URL.init(string: "\(ComLink.encoreWebAddress)/wc-api/v3/products?filter[sku]=\(skuToPass)&consumer_key=ck_63b19089072b793730f4db01733c15a36e1578f9&consumer_secret=cs_077d6d562bfe50f20d83ab0ae5f1d77ae2a42322")
        var request = URLRequest(url: url!)
        request.cachePolicy = .returnCacheDataElseLoad
        
        // set a body for the request to get appropriate response
        request.httpMethod = "GET"
        
        //create a session to handle the request
        let session = URLSession.shared
        
        // Start session task to fetch WC database as JSON
        session.dataTask(with: request) { (data, response, error) in
            // what do we get back?
            print("Request is sent")
            
            if error == nil {
                
                print("No Error!")
                
                let parseResult: [String:AnyObject]!
                
                do {
                    
                    parseResult = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String:AnyObject]
                    //print(parseResult!) //only needed for DEBUG
                    if let products = parseResult ["products"] as? [[String: AnyObject]] {
                        
                        for obj in products {
                            
                            // create an object of Products to load values into when grabbed
                            let proObj = Products()
                            
                            // grab values from JSON
                            let title = obj["title"] as! String
                            let id = obj["id"] as! Int
                            let sku = obj["sku"] as! String
                            // let price = obj["price"] as! String
                            let imgDict = obj["images"] as! [[String: AnyObject]]
                            let imgUrl = imgDict[0]["src"] as! String
                            
                            let descript = obj["description"] as! String!
                            
                            // grab this value as another JSON style array of dict's we will parse in another func getVariations()
                            let vary = obj["variations"] as! [[String: AnyObject]]
                            
                            // load all values into object
                            proObj.title = title
                            proObj.id = id
                            proObj.sku = sku
                            // proObj.price = price
                            proObj.variations = vary
                            proObj.imgUrl = imgUrl
                            proObj.descript = descript
                            
                            self.fetchProductImage(urlString: proObj.imgUrl!, proObj: proObj)
                            
                            // create empty array to load
                            proObj.variationsArray = [Variations]()
                            
                            // load proObj into HomeVC.proArray
                            HomeVC.proArray.append(proObj)
                            
                        }
                        
                        // check to make sure HomeVC.proArray is being loaded
                        if HomeVC.proArray.count > 0 {
                            
                            // loop through each Products obj
                            for test in HomeVC.proArray {
                                
                                // run func getVariations(product: test) to return an [Variations] for the obj
                                test.variationsArray = self.getVariations(product: test)
                            }
                            
                            
                            // call UI thread to load table view with [Products]
                            DispatchQueue.main.async{
                                
                                self.tableView.reloadData()
                            }
                            
                            
                        }// end of if HomeVC.proArray.count > 0
                    }// end of if let products = parseResult["products"] as? [[String: AnyObject]]
                    
                } catch {
                    
                    print("Could not parse data as Json \(String(describing: data))")
                    return
                }
                
                
            } else {
                print("Was An Error of: ",error.debugDescription)
            }
            
            }.resume()
        
    }
    
    //func to get variations for each product
    func getVariations(product: Products) -> [Variations] {
        print("\ngetVariations() for: \(product.title!)")
        
        // create varable just to clean up look of code
        let vari = product.variations
        
        // loop through the array of dict's to dissect
        for vs in vari! {
            
            // create object of Variations to load values into that are grabbed
            let variObj = Variations()
            
            //create var's and grab closest nodes
            let id = vs["id"] as? Int!
            let sku = vs["sku"] as? String!
            var size: String?
            var price: String?
            
            // grab this value as another array of dict's like a JSON db to pull apart
            let attributes = vs["attributes"] as? [[String: AnyObject]]
            
            // loop through arrays of dicts to grab values
            for attri in attributes! {
                
                // grab and set value for size
                size = attri["option"] as? String!
                
            }
            
            // create var as a dict to grab values
            let prices_by_user_roles = vs["prices_by_user_roles"] as? [String: AnyObject]
            
            // grab and set the price var
            if prices_by_user_roles?["pharmacy_list"] != nil {
                
                price = prices_by_user_roles?["pharmacy_list"] as? String!
                
            } else {
                
                price = "0"
            }
            
            // debug and load each value into the variObj object
            variObj.id = id!
            variObj.sku = sku!
            variObj.size = size!
            variObj.price = price!
            
            // once all values are loaded into the object append the object to the products array
            product.variationsArray?.append(variObj)
        }
        
        //once all variObj's are loaded into the array return the array to the Products object
        return product.variationsArray!
    }
    
    func fetchProductImage(urlString: String, proObj: Products) {
        //get product image to load as thumbnail
        
        //convert passed urlString to a URL
        let url = URL(string: urlString)
        
        //create a request with the URL
        let request = URLRequest(url: url!)
        
        //create a session to handle the request
        let session = URLSession.shared
        
        // start session task to download img
        session.dataTask(with: request) { (data, response, error) in
            // The download has finished.
            
            if let e = error {
                print("Error downloading img: \(e)")
                
            } else {
                // No errors found.
                
                // check for response.
                if let res = response as? HTTPURLResponse {
                    print("Downloaded picture with response code \(res.statusCode)")
                    
                    if let imageData = data {
                        // convert that Data into an image.
                        
                        let image = UIImage(data: imageData)
                        
                        // load img into obj
                        proObj.img = image!
                        
                        //reload the tableView to populate the img's
                        // call UI thread to load table view with [Products]
                        DispatchQueue.main.async{
                            
                            self.tableView.reloadData()
                        }
                        
                    } else {
                        print("Couldn't get image: Image is nil")
                    }
                } else {
                    print("Couldn't get response code for some reason")
                }
            }
            }.resume()
        
    }
    
}
