//
//  CartVC.swift
//  EncoreScientific
//
//  Created by Bryan Neuberger on 5/19/17.
//  Copyright © 2017 Paradigm Creative. All rights reserved.
//

import UIKit
import WebKit

class CartVC: UIViewController {
    
    //Product array to hold products added to cart
    var cartProductsArray = [CartItem]()
    
    
    var urlToSend: URL?
    var caseToSend: ProductCategory?
    
    let link = ComLink()
    
    @IBOutlet weak var returnToProducts: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var cartTotal_lbl: UILabel!
    
    var totalCartAmount: Int!
    
//    override func viewWillAppear(_ animated: Bool) {
//        
//        self.tableView.reloadData()
//        //ComLink object to handle function for going and getting the users session cart contents
//        link.getCartContents(username: LoginVC.user.username, password: LoginVC.user.password)
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //set attributes of the Navigation Bar
        self.navigationController?.navigationBar.setBackgroundImage(#imageLiteral(resourceName: "Bar"), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        self.navigationController?.navigationItem.title = "My Cart"
        
        tableView.delegate = self
        tableView.dataSource = self
        
        totalCartAmount = 0
        //ComLink object to handle function for going and getting the users session cart contents
//        link.getCartContents(username: LoginVC.user.username, password: LoginVC.user.password)
      
        print("COUNT: \(LoginVC.user.cartItemsList.count)")
        
        for item in LoginVC.user.cartItemsList {
            
            print(item.variation_id)
            fetchDatabase(idToPass: item.variation_id, priceToPass: item.line_total, cartItemToPass: item)
        
        }
    }
    
    // MARK: - Shipping Method Change
    
    // Not index based
    var selectedShippingMethod = 1
    
    // Colors for UI Buttons
    let green: UIColor = #colorLiteral(red: 0.4469839931, green: 0.7501077056, blue: 0.267737031, alpha: 1)
    let grey: UIColor = #colorLiteral(red: 0.4078096151, green: 0.4078620076, blue: 0.4077917933, alpha: 1)
    
    // Outlets to reference actual buttons for properties like Background Color
    @IBOutlet weak var ground: UIButton!
    @IBOutlet weak var twoDay: UIButton!
    @IBOutlet weak var overnight: UIButton!
    
    // Individual actions when any button is pressed
    @IBAction func changeToGroundShipping(_ sender: UIButton) {
        changeBackgroundColor(button: sender)
    }
    
    @IBAction func changeToTwoDayShipping(_ sender: UIButton) {
        changeBackgroundColor(button: sender)
    }
    
    @IBAction func changeToNextDay(_ sender: UIButton) {
        changeBackgroundColor(button: sender)
    }
    
    // Function that runs each time shipping buttion pressed
    func changeBackgroundColor(button: UIButton) {
        if button.tag == 0 {
            selectedShippingMethod = 1
            ground.backgroundColor = green
            twoDay.backgroundColor = grey
            overnight.backgroundColor = grey
        } else if button.tag == 1 {
            selectedShippingMethod = 2
            ground.backgroundColor = grey
            twoDay.backgroundColor = green
            overnight.backgroundColor = grey
        } else {
            selectedShippingMethod = 3
            ground.backgroundColor = grey
            twoDay.backgroundColor = grey
            overnight.backgroundColor = green
        }
    }
    
    
    // MARK: - DB Changes
    //func to fetch database from WC
    func fetchDatabase(idToPass: String, priceToPass: String, cartItemToPass: CartItem) {
        print("fetching products...")
        
        //create a request with the URL
        let url = URL.init(string: "\(ComLink.encoreWebAddress)/wc-api/v3/products/\(idToPass)?consumer_key=ck_63b19089072b793730f4db01733c15a36e1578f9&consumer_secret=cs_077d6d562bfe50f20d83ab0ae5f1d77ae2a42322")
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
                    if let products = parseResult ["product"] as? [String: AnyObject] {
                        
                            print("if let products = parseResult [products] as? [String: AnyObject] {")
                            // create an object of Products to load values into when grabbed
                            let proObj = Products()
                            
                            // grab values from JSON
                            let title = products["title"] as! String
                            let id = products["id"] as! Int
                            let sku = products["sku"] as! String
                        
                        let prices_by_user_roles = products["prices_by_user_roles"] as! [String:AnyObject]
                        
                            let price = prices_by_user_roles["pharmacy_list"] as! String
                            let imgDict = products["images"] as! [[String: AnyObject]]
                            let imgUrl = imgDict[0]["src"] as! String
                            
                            let descript = products["description"] as! String!
                            
                            // load all values into object
                            proObj.title = title
                            proObj.id = id
                            proObj.sku = sku
                            proObj.price = price
                            proObj.imgUrl = imgUrl
                            proObj.descript = descript
                            
                            self.fetchProductImage(urlString: proObj.imgUrl!, proObj: proObj)
                        
                        cartItemToPass.product = proObj
                            // load proObj into HomeVC.proArray
                            self.cartProductsArray.append(cartItemToPass)
    
                        self.totalCartAmount = self.totalCartAmount + Int.init(cartItemToPass.line_total)!
                            // call UI thread to load table view with [Products]
                            DispatchQueue.main.async {
                                
                                self.tableView.reloadData()
                                
                                self.cartTotal_lbl.text = "$\(self.totalCartAmount.description).00"
                            }
                            
                        
                    } // end of do block
                    
                } catch {
                    
                    print("Could not parse data as Json \(String(describing: data))")
                    return
                }
                
                
            } else {
                print("Was An Error of: ",error.debugDescription)
            }
            
            }.resume()
        
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
    
    
    @IBAction func removeFromCartPressed(_ sender: UIButton) {
        
        // create var to get selected row indexPath.row
        var indexPath: IndexPath!
        
        //series of checks to get the btn's row
        if let button = sender as? UIButton {
            if let superview = button.superview {
                if let cell = superview.superview as? CartCell {
                    indexPath = tableView.indexPath(for: cell)
                }
            }
        }
        
        // use indexPath in array to remove item from cart Database
        let item = cartProductsArray[indexPath.row]
        
        totalCartAmount = totalCartAmount - Int.init(item.line_total)!
        
        link.removeItemFromCart(cartKeyToRemove: item.cartKey)
        
        cartProductsArray.remove(at: indexPath.row)
        
        ComLink.cartKeyCheckArray.removeAll()
        
        LoginVC.user.cartItemsList.removeAll()
        
        self.tableView.reloadData()
        
        self.cartTotal_lbl.text = "$\(self.totalCartAmount.description).00"
        
    }
    
    @IBAction func proceedToChecoutPressed(_ sender: Any) {
        //function to handle the proceed to checkout button being pressed
        
        // fetch user information to help place order
        link.getUserInfo(emailToPass: LoginVC.user.username)
        
        // segue to OrderVC
        self.performSegue(withIdentifier: "showOrderVC", sender: self)
    }
    
    @IBAction func returnToProductsPressed(_ sender: Any) {
        
        //set URL to pass as All Product Categories
        urlToSend = URL.init(string: "\(ComLink.encoreWebAddress)/wc-api/v3/products?filter[category]=apis,bases,excipients&consumer_key=ck_63b19089072b793730f4db01733c15a36e1578f9&consumer_secret=cs_077d6d562bfe50f20d83ab0ae5f1d77ae2a42322")!
        
        // set case to send
        caseToSend = ProductCategory.all
        
        // segue to ProductsVC
        self.performSegue(withIdentifier: "showProductsVC", sender: self)
    }
    
// MARK: Prepare For Segue
    
    // handles anything we need to send to a VC before we complete segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // check segue
        if segue.identifier == "showProductsVC" {
            
            // create ViewController obj to handle and requests for data being passed
            let vc = segue.destination as! ProductsVC
            
            // send the correct urlString to query WC database
            vc.serverUrl = urlToSend!
            
            vc.arrayCase = caseToSend!
        }
        
        // check segue
        if segue.identifier == "showOrderVC" {
            
            // create ViewController obj to handle and requests for data being passed
            let vc = segue.destination as! OrderVC
            
            // send the correct urlString to query WC database
            vc.cartProductsArray = cartProductsArray
            
            vc.totalOrderAmount = totalCartAmount.description
        }
        
       
    }
    
    
}//end of CartVC class

// MARK: - ext: TableView Handles
extension CartVC: UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //code to select
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return how many rows to load
        return cartProductsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("SHOW ME ELEMENTS")
        
        // Getting the right element
        let element = cartProductsArray[indexPath.row]
//        let element = cartProductsArray[indexPath.row]
//        let newElement = LoginVC.user.cartItemsList[indexPath.row]
        
        // Instantiate a cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellCart") as! CartCell
        
        // Pass the values from the element to load fields
        cell.proTitle_lbl.text = element.product.title
        cell.productImage_imgV.image = element.product.img
        cell.pricePerUnit_lbl.text = element.product.price
        cell.qty_lbl.text = element.quantity
        cell.totalPrice_lbl.text = "$\(element.line_total!).00"
        
        
        // Returning the cell
        return cell
        
    }
    
    
    
    
    
}
