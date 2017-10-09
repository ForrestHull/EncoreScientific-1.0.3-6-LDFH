//
//  OrderVC.swift
//  EncoreScientific
//
//  Created by Bryan Neuberger on 7/6/17.
//  Copyright © 2017 Paradigm Creative. All rights reserved.
//

import UIKit

class OrderVC: UIViewController {
    
    //Product array to hold products added to cart
    var cartProductsArray: [CartItem]!
    
    let link = ComLink()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lbl_totalOrderAmount: UILabel!
    
    var totalOrderAmount: String!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
        
        print(cartProductsArray.count)
        
        lbl_totalOrderAmount.text = "$\(totalOrderAmount!).00"
    }

    @IBAction func myAccountPressed(_ sender: Any) {
        // send user to myAccount Page
        
        performSegue(withIdentifier: "showWebHandlerVC", sender: self)
    }
   
    @IBAction func placeOrderPressed(_ sender: Any) {
        //create and place order
        
        // construct string body to send
        
        var lines_items = [[String:AnyObject]]()
        
        for item in LoginVC.user.cartItemsList {
            
            var dict = [String:String]()
            
            dict["product_id"] = item.product_id
            dict["variation_id"] = item.variation_id
            dict["quantity"] = item.quantity
            if let price = item.product.price {
                if let iPrice = Double(price) {
                    let total = iPrice * Double(item.quantity)!
                    dict["subtotal"] = price
                    dict["total"] = "\(total)"
                    dict["discount"] = "0"
                }
            }
            
            lines_items.append(dict as [String : AnyObject])
            
        }
        
        let json: [String: Any] = [
            "payment_method": "",
            "payment_method_title": "Custom Payment",
            "set_paid": true,
            "billing": LoginVC.user.billingAddress!,
            "shipping": LoginVC.user.shippingAddress!,
            "customer_id": LoginVC.user.userId!,
            "line_items": lines_items,
            "discount_total": "0"
        ]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        //create a request with the URL
        let url = URL.init(string: "\(ComLink.encoreWebAddress)/wp-json/wc/v2/orders?consumer_key=ck_63b19089072b793730f4db01733c15a36e1578f9&consumer_secret=cs_077d6d562bfe50f20d83ab0ae5f1d77ae2a42322")
        
        var request = URLRequest(url: url!)
        
        // Type of request being sent to server
        request.httpMethod = "POST"
        
        // set the body of the request with the testPostString above
        request.httpBody = jsonData
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        //create a session to handle the request
        let session = URLSession.shared
        
        session.dataTask(with: request) { (data, response, error) in
            // what do we get back?
            print("Request is sent")
            
            if error == nil {
                
                print("No Error!")
                print(data?.description as Any)
                print("Response Debug: ",response.debugDescription)
                
                // verify with a check to create a HTTPURLResponse from the URLResponse given
                if let httpResponse = response as? HTTPURLResponse {
                    
                   let statusResponse = httpResponse.statusCode
                    
                    if statusResponse < 400 {
                        //empty cart and display alert msg
                        
                        
                        for item in self.cartProductsArray {
                            
                            self.link.removeItemFromCart(cartKeyToRemove: item.cartKey)
                        }
                        
                        ComLink.cartKeyCheckArray.removeAll()
                        
                        LoginVC.user.cartItemsList.removeAll()
                        
                        self.alertPopUp(title: "Order Confirmed", message: "Thank you for your order!", clickTitle: "Thank You", vc: self)
                        
                        
                    } else {
                        // status code 400+ means it failed to post. Display error msg
                        self.link.alertPopUp(title: "Order Error", message: "Sorry!\nIt appears there was an error processing this order request.", clickTitle: "Sorry", vc: self)
                    }
                    
                }
                
                let parseResult: [String:AnyObject]!
                do{
                    
                    parseResult = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! [String:AnyObject]
                    print("parseResult: \(parseResult!)")
                    
                    
                } catch {
                    
                    print("Could not parse data as Json \(String(describing: data))")
                    return
                }
                
                
            } else {
                print("Was An Error of: ",error.debugDescription)
            }
            }.resume()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //code to do beofre segue
        
        if segue.identifier == "showWebHandlerVC" {
            
            let vcDestination = segue.destination as! WebHandlerVC
            
            vcDestination.webCaseReceived = WebCase.MyAccount
        }
    }
    
    //reuseable alert message pop up for errors
    func alertPopUp(title: String, message: String, clickTitle: String, vc: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: clickTitle, style: UIAlertActionStyle.default, handler: { action in

            self.performSegue(withIdentifier: "showHomeVC", sender: self)
            
        }))
        vc.present(alert, animated: true, completion: nil)
    }

}

// MARK: - ext: TableView Handles
extension OrderVC: UITableViewDelegate, UITableViewDataSource {
    
    
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
        cell.remove_btn.isHidden = true
        
        // Returning the cell
        return cell
        
    }
}
