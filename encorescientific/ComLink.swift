//
//  ComLink.swift
//  EncoreScientific
//
//  Created by Bryan Neuberger on 5/17/17.
//  Copyright © 2017 Paradigm Creative. All rights reserved.
//

import UIKit

enum WebCase {
    
    case MyAccount
    case ContactUs
    case Register
    case AboutUs
    
}

class ComLink: NSObject {
    
    static var cartKeyCheckArray = [String]()
    
    //Static string to use for website name
    static let encoreWebAddress = "https://www.encoresci.com"
    
    let serverUrl: URL = URL.init(string: "\(ComLink.encoreWebAddress)/custom-php/app_authenticate.php")!
    
    
// MARK: LOGIN
    func login(username: String, password: String, vc: UIViewController, view: UIView) {
        //func to log into custom PHP script, WC REST API
        
        // action to send to custom PHP script to fun specific func.
        let action: String = "do_nothing"
        
        //create the keys and values to pass into URL string
        let testPostString = "username=\(username)&password=\(password)&action=\(action)"
        print("PostString DEBUG: \(testPostString)")
        
        // Create request object to send
        var request = URLRequest(url: serverUrl)
        
        // Type of request being made with request
        request.httpMethod = "POST"
        
        // set the body of the request with the testPostString above
        request.httpBody = testPostString.data(using: .utf8)
        
        // Create a session object to manage the request (background threaded)
        let session = URLSession.shared
        
        // start the sessions task to begin (Dont forget to .resume right after dataTask Scope )
        session.dataTask(with: request) { (data, response, error) in
            // what do we get back?
            print("Request is sent")
            
            if error == nil {
                
                print("No Error!")
                print(data?.description as Any)
                print("Response Debug: ",response.debugDescription)
                
                // verify with a check to create a HTTPURLResponse from the URLResponse given
                if let httpResponse = response as? HTTPURLResponse {
                    
                    // instantion was successfull now create an object DICT to access its field values
                    let allHeaders = httpResponse.allHeaderFields as? [String : String]
                    print("\nprinting all headers: \(allHeaders!)")
                    
                    // place value from key "Set-Cookie" into a String object so we can store as userData
                    let cookies = allHeaders?["Set-Cookie"]!
                    print("\nVerifing Cookies grabbed: \(cookies!)\n")
                    
                    let correctedCookes = cookies?.replacingOccurrences(of: ",", with: ";")
                    
                    // place cookies grabbed as String into LoginVC.user to call for later use
                    LoginVC.user.cookies = "\(correctedCookes!);"
                }
                
                let parseResult: [String:AnyObject]!
                do{
                    
                    parseResult = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! [String:AnyObject]
                    print("parseResult: \(parseResult!)")
                    
                    let status = parseResult["auth_status"] as! Bool
                    
                    // check to see if result came back true or false
                    if status == true {
                        //result came back true
                        
                        DispatchQueue.main.async{
                            //call UiThread to segue over to HomeVC
                            vc.performSegue(withIdentifier: "showHomeVC", sender: self)
                            
                            //We know login creds are correct we can now set the static user's info values
                            LoginVC.user.username = username
                            LoginVC.user.password = password
                            
                            view.removeFromSuperview()
                            
                            print("\nTesting cookies placed into obj: \(LoginVC.user.cookies!)\n")
                        }
                    } else {
                        
                        DispatchQueue.main.async {
                            
                            view.removeFromSuperview()
                            self.alertPopUp(title: "Invalid", message: "Username or password are incorrect", clickTitle: "OK", vc: vc)
                        }
                    }
                    
                } catch {
                    
                    print("Could not parse data as Json \(String(describing: data))")
                    return
                }
                
            } else {
                print("Was An Error of: ",error.debugDescription)
            }
            
            //resume the the thread to run above code.
            }.resume()
        
    }
    
// MARK: Add To Cart
    func addItemToCart(username: String, password: String, product_id: Int, qty: Int, variation_id: Int, vc: UIViewController) {
        //func to add items to cart send all info through params
        
        let action = "add_to_cart"
        
        let proIdString = String(product_id)
        let qtyString = String(qty)
        let variationIdString = String(variation_id)
        
        let testPostString = "username=\(username)&password=\(password)&action=\(action)&product_id=\(proIdString)&quantity=\(qtyString)&variation_id=\(variationIdString)"
        
        print("PostString DEBUG: \(testPostString)")
        
        var request = URLRequest(url: serverUrl)
        
        request.httpMethod = "POST"
        
        request.httpBody = testPostString.data(using: .utf8)
        
        let session = URLSession.shared
        
        session.dataTask(with: request) { (data, response, error) in
            // what do we get back?
            print("Request is sent")
            
            if error == nil {
                
                print("No Error!")
                print(data?.description as Any)
                print("Response Debug: ",response.debugDescription)
                
                let parseResult: [String:AnyObject]!
                do{
                    
                    parseResult = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! [String:AnyObject]
                    print("parseResult: \(parseResult!)")
                    
                    let status = parseResult["auth_status"] as! Bool
                    
                    let cartKey = parseResult["req_result"] as? String
                    
                    // check to see if PHP script returned a 1 for true or 0 for false
                    if status == true {
                        
                        //do something here if status is true meaning script ran
//                        print("Cart Key: \(cartKey!)\n------\n")
                        
                        DispatchQueue.main.async{
                            //call UiThread to display msg
                            LoginVC.user.cartKeys.append(cartKey!)
                            self.alertPopUp(title: "Item Added!", message: "Item successfully added to cart!", clickTitle: "Thank You", vc: vc)
                        }
                        
                    } else {
                        
                        DispatchQueue.main.async{
                            //call UiThread to display msg
                            
                            self.alertPopUp(title: "Error!", message: "Could not add item to cart!", clickTitle: "Sorry!", vc: vc)
                        }
                    }
                    
                } catch {
                    
                    print("Could not parse data as Json \(String(describing: data))")
                    return
                }
                
                
            } else {
                print("Was An Error of: ",error.debugDescription)
            }
            }.resume()
        
    }
   
// MARK: Get Users Cart
    func getCartContents(username: String, password: String, vc: UIViewController) {
        
        //action to pass the PHP script sitting on server directory
        let action = "get_cart_contents"
        
        // constructed string to attach to URL request for PHP script to operate
        let testPostString = "username=\(username)&password=\(password)&action=\(action)"
        print("PostString DEBUG: \(testPostString)")
        
        var request = URLRequest(url: serverUrl)
        
        request.httpMethod = "POST"
        
        request.httpBody = testPostString.data(using: .utf8)
        
        let session = URLSession.shared
        
        session.dataTask(with: request) { (data, response, error) in
            // what do we get back?
            print("Request is sent")
            
            if error == nil {
                
                // print("No Error!")
               // print(data?.description as Any)
               // print("Response Debug: ",response.debugDescription)
                
                //return response as a dict so we can navigate its elements
                let parseResult: [String:AnyObject]!
                do{
                     // convert to readable JSON
                    parseResult = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! [String:AnyObject]
                    print("parseResult: \(parseResult!)")
                    
                    // get status if the request was successful
                    let status = parseResult["auth_status"] as! Bool
                    
                    // check to see if PHP script returned a 1 for true or 0 for false
                    if status == true {
                        //do something here if status is true meaning script ran
                    
                        
                        //deconstruct JSON here
                        let req_result = parseResult["req_result"] as! [String:AnyObject]
                        
                        if let cart_contents = req_result["cart_contents"] as? [String:AnyObject] {
                        
                        print("cart_contents: \(cart_contents)")
                        LoginVC.user.cart_contents = cart_contents
                        
                        //loop through diction of cartKeys and their respective properties
                        for (key, answer) in cart_contents {
                            
                            // create CartItem Object tp hold data
                            let cartItemObj = CartItem()
                            
                            //Turn the current element into a dict to access elements burried
                            let cartItem = answer as! [String:AnyObject]
                            
                            print("\nFOR LOOP: \(key)\n\(cartItem)")
                            
                            //create vars for each element extracted to load into an CartItem Obj to store
                            let product_id = cartItem["product_id"] as! NSNumber
                            let line_total = cartItem["line_total"] as! NSNumber
                            let variation_id = cartItem["variation_id"] as! NSNumber
                            
                            if let quantity = cartItem["quantity"] as? NSNumber {
                                
                                cartItemObj.quantity = quantity.stringValue
                                print("Verify QTY: \(quantity.stringValue)")
                                
                            } else if let quantity = cartItem["quantity"] as? String {
                                
                                cartItemObj.quantity = quantity
                                print("Verify QTY: \(quantity)")
                            }
                            
                            
                            //load vars into object to store data
                            cartItemObj.cartKey = key
                            cartItemObj.product_id = product_id.stringValue
                            cartItemObj.line_total = line_total.stringValue
                            cartItemObj.variation_id = variation_id.stringValue
                            
                            
                            print("Verify KEY: \(key)")
                            print("Verify ProID: \(product_id.stringValue)")
                            print("Verify LineTotal: \(line_total.stringValue)")
                            print("Verify VaryID: \(variation_id.stringValue)")
                            
                            
                            //check to see if the cartKey is already in our list so we dont double load
                            if ComLink.cartKeyCheckArray.count > 0 {
                                print("ComLink.cartKeyCheckArray.count > 0 ")
                                
                                if ComLink.cartKeyCheckArray.contains(key) == false {
                                    print("ComLink.cartKeyCheckArray.contains(key) == false")
                                    
                                    //add cart key to a list that we can use to make sure we arent double loading
                                    ComLink.cartKeyCheckArray.append(key)
                                    
                                    //load CartItem Object into an array that we can call from the userObj to access through out apps life cycle
                                    LoginVC.user.cartItemsList.append(cartItemObj)
                                }
                            }
                            
                            if ComLink.cartKeyCheckArray.count == 0 {
                                
                                //add cart key to a list that we can use to make sure we arent double loading
                                ComLink.cartKeyCheckArray.append(key)
                                
                                //load CartItem Object into an array that we can call from the userObj to access through out apps life cycle
                                LoginVC.user.cartItemsList.append(cartItemObj)
                            }
                            
                            
                        }//end of for loop
                        
                        DispatchQueue.main.async {
                            //call UiThread to display msg
                            
                            print("\nVerify cartItemsList: ")
                            
                            for item in LoginVC.user.cartItemsList {
                                
                                print(item.variation_id)
                                
                            }
                            
                            vc.performSegue(withIdentifier: "showCartVC", sender: self)
                        }
                        
                        } else {
                            
                            self.alertPopUp(title: "Empty Cart", message: "Your cart is currently empty, add some items to your cart and try again.", clickTitle: "Empty Cart", vc: vc)
                        }
                    }
                    
                } catch {
                    
                    print("Could not parse data as Json \(String(describing: data))")
                    return
                }
                
                
            } else {
                print("Was An Error of: ",error.debugDescription)
            }
            }.resume()
        
    } // End of getCartContents()
    
    
    func removeItemFromCart(cartKeyToRemove: String) {
        
        // action to send to custom PHP script to fun specific func.
        let action: String = "remove_from_cart"
        
        //create the keys and values to pass into URL string
        let testPostString = "username=\(LoginVC.user.username!)&password=\(LoginVC.user.password!)&action=\(action)&cart_item_key=\(cartKeyToRemove)"
        print("PostString DEBUG: \(testPostString)")
        
        // Create request object to send
        var request = URLRequest(url: serverUrl)
        
        // Type of request being made with request
        request.httpMethod = "POST"
        
        // set the body of the request with the testPostString above
        request.httpBody = testPostString.data(using: .utf8)
        
        // Create a session object to manage the request (background threaded)
        let session = URLSession.shared
        
        session.dataTask(with: request) { (data, response, error) in
            // what do we get back?
            print("Request is sent")
            
            if error == nil {
                
                print("No Error!")
                print(data?.description as Any)
                print("Response Debug: ",response.debugDescription)
                
                let parseResult: [String:AnyObject]!
                do{
                    
                    parseResult = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! [String:AnyObject]
                    print("parseResult: \(parseResult!)")
                    
                    let status = parseResult["auth_status"] as! Bool
                    
                    // check to see if PHP script returned a 1 for true or 0 for false
                    if status == true {
                        
                        //do something here if status is true meaning script ran
                        
                        
                        DispatchQueue.main.async{
                            //call UiThread to display msg
                            
                        }
                        
                    } else {
                        
                        DispatchQueue.main.async{
                            //call UiThread to display msg
                            
                        }
                    }
                    
                } catch {
                    
                    print("Could not parse data as Json \(String(describing: data))")
                    return
                }
                
                
            } else {
                print("Was An Error of: ",error.debugDescription)
            }
            }.resume()
    }
    
// MARK: Get User Info
    func getUserInfo(emailToPass: String) {
        //func used to search customers based on email
        
        print("\nFetching User Info.....")
        
        let urlString = "\(ComLink.encoreWebAddress)/wc-api/v3/customers/email/\(emailToPass)?consumer_key=ck_63b19089072b793730f4db01733c15a36e1578f9&consumer_secret=cs_077d6d562bfe50f20d83ab0ae5f1d77ae2a42322"
        
        let url = URL.init(string: urlString)
        
        var request = URLRequest(url: url!)
        
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
                    
                    let customer = parseResult["customer"] as! [String:AnyObject]
                    
                    let shippingAdd = customer["shipping_address"] as! [String:AnyObject]
                    
                    let billingAdd = customer["billing_address"] as! [String:AnyObject]
                    
                    let uId = customer["id"] as! NSNumber
                    
                    print("SHIPPING: ",shippingAdd)
                    print("BILLING: ",billingAdd)
                    
                    LoginVC.user.billingAddress = billingAdd
                    LoginVC.user.shippingAddress = shippingAdd
                    LoginVC.user.userId = uId.stringValue
                        
                    print("CUST SHIPPING: ",LoginVC.user.shippingAddress!)
                    print("CUST BILLING: ",LoginVC.user.billingAddress!)
                    print("CUST ID: ",LoginVC.user.userId!)
                        
                    // call UI thread to load anything
                    DispatchQueue.main.async {
                            
                            
                    }
                        
                    
                    
                } catch {
                    
                    print("Could not parse data as Json \(String(describing: data))")
                    return
                }
                
                
            } else {
                print("Was An Error of: ",error.debugDescription)
            }
            
            }.resume()
    }
    
    
// MARK: - CoreData Funcs
    func writeDataToFile(sku: String)  {
        
        print("writeDataToFile(sku: String)")
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let favorite = Favorites(context: context)
        
        favorite.sku = sku
        
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        
    } //End of writeDataToFile()
    
    func removeDataFromFile(sku: String) {
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        var favoritesArray = [Favorites]()
        var currentIndex = 0
        
        do {
            
            favoritesArray = try context.fetch(Favorites.fetchRequest())
            print("Successful fetchRequest....")
            
            for skuSaved in favoritesArray {
                
                if skuSaved.sku == sku {
                    
                    print("\n\(sku) matches inside skuSaved for sku: \(skuSaved.sku!)\nDelete sku from CoreData")
                    context.delete(skuSaved)
                    
                    if HomeVC.skuArray.contains(sku) {
                        
                        print("Remove sku from Master Sku List...")
                        
                        if HomeVC.skuArray.first == sku {
                            
                            HomeVC.skuArray.remove(at: 0)
                            
                        } else {
                            
                            let toRemoveMaster = HomeVC.skuArray.index(of: sku)
                            HomeVC.skuArray.remove(at: toRemoveMaster!)
                        }
                        
                        print("Sku removed from Master list!")
                    }
                    
                    
                    print("Remove sku from PlaceHolder Sku List...")
                    
                    
                    if LoginVC.user.favoritesList.contains(sku) == true {
                        
                        print("\nSku located in LoginVC.user.favoritesList verify location in list to remove at....")
                        
                        if LoginVC.user.favoritesList.first == sku {
                            
                            print("Was 1st remove at index 0")
                            LoginVC.user.favoritesList.remove(at: 0)
                            
                        } else {
                            
                            if let toRemovePlaceHolder = LoginVC.user.favoritesList.index(of: sku) {
                            
                                print("Was not 1st remove at index \(String(describing: LoginVC.user.favoritesList.index(of: sku)))")
                                
                                LoginVC.user.favoritesList.remove(at: toRemovePlaceHolder)
                                
                            } else {
                                
                                print("if let toRemovePlaceHolder = LoginVC.user.favoritesList.index(of: sku) FAILED....")
                            }
                        }
                        
                    }
                    print("Sku removed from PlaceHolder list!")
                    
                    print("Remove product from Homes Favorites List...")
                    for obj in HomeVC.proArray {
                        
                        
                        if obj.sku == sku {
                            
                            HomeVC.proArray.remove(at: currentIndex)
                            print("Product found and removed from Home Favorites List")
                        }
                        
                        currentIndex = currentIndex + 1
                    }
                    
                    (UIApplication.shared.delegate as! AppDelegate).saveContext()
                }
            }
            
            
        } catch {
            
            print("Oh No Error fetching CoreData: ",error.localizedDescription)
            
        }
        
    } //End of removeDataFromFile()
    
    
    func readDataFromFile() -> [Favorites] {
        
        print("readDataFromFile() -> [Favorites]")
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        var favoritesArray = [Favorites]()
        
        do {
            
            favoritesArray = try context.fetch(Favorites.fetchRequest())
            print("Successful reading....")
            return favoritesArray
            
        } catch {
            
            print("Oh No Error fetching CoreData: ",error.localizedDescription)
            
        }
        
        return favoritesArray
    }//End of readDataFromFile()
    
    
    //reuseable alert message pop up for errors
    func alertPopUp(title: String, message: String, clickTitle: String, vc: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: clickTitle, style: UIAlertActionStyle.default, handler: nil))
        vc.present(alert, animated: true, completion: nil)
    }
}
