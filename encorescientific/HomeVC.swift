//
//  HomeVC.swift
//  EncoreScientific
//
//  Created by Bryan Neuberger on 5/17/17.
//  Copyright © 2017 Paradigm Creative. All rights reserved.
//

import UIKit


class HomeVC: UIViewController {
    
    @IBOutlet weak var menuDrawerView: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    // var created to load a URL to send to ProductsVC
    var urlToSend: URL?
    var caseToSend: ProductCategory?
    
    let link = ComLink()
    
    var array: [Favorites]?
    static var skuArray = [String]()
    static var proArray = [Products]()
    var proObjToSend: Products?
    
    var webCaseToSend: WebCase?
    
    var isFirstStart: Bool?
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.tableView.reloadData()
        
    }
    
    override func viewDidLoad() {
        self.menuDrawerView.frame.origin.x = -317
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // set tint to white so text has white lettering
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        
        // set the navebars background to blue with image literal
        self.navigationController?.navigationBar.setBackgroundImage(#imageLiteral(resourceName: "Bar"), for: UIBarMetrics.default)
        
        if HomeVC.skuArray.count == 0 {
            
            print("isFirstStart = true")
            isFirstStart = true
            
        } else {
            
            print("isFirstStart = false")
            isFirstStart = false
        }
        
        array = link.readDataFromFile()
        
        for fav in array! {
            
            let sku = fav.sku!
            print("Sku from favorites: \(sku)")
            
            if HomeVC.skuArray.contains(sku) == true {
                
                print("HomeVC.skuArray.contains(sku) == true: \(sku)")
                
            } else {
                
                HomeVC.skuArray.append(sku)
                fetchDatabase(skuToPass: sku)
                print("...conatins == false - HomeVC.skuArray.append(sku): \(sku) & featchDatabase!")
            }
            
        }
        
        LoginVC.user.favoritesList = HomeVC.skuArray
        
    }
    
    func addDropShadowToView(targetView:UIView? ){
        targetView!.layer.masksToBounds =  false
        targetView!.layer.shadowColor = UIColor.darkGray.cgColor;
        targetView!.layer.shadowOffset = CGSize(width: 2, height: 2)
        targetView!.layer.shadowOpacity = 1.0
    }
    
    func blur() {
        
        let effectView = UIVisualEffectView()
        effectView.frame = self.view.frame
        self.view.insertSubview(effectView, at: 4)
        
        UIView.animate(withDuration: 0.8) {
            effectView.effect = UIBlurEffect(style: .regular)
            
        }
        
    }
    
    
    @IBAction func MenuDrawer(_ sender: Any) {
        
        self.blur()
        
        //starts animation
        UIView.animate(withDuration: 0.5, animations: {
            // change constraint to 0 of super view
            self.addDropShadowToView(targetView: self.menuDrawerView)
            
            // move menuViews lead edge to place full view onto screen
            self.menuDrawerView.frame.origin.x = 0
            self.view.layoutIfNeeded()
            
        })
        
    }
    
    
    @IBAction func closeDrawer(_ sender: Any) {
        
        
        // self.navigationController?.navigationBar.layer.zPosition = 0
        
        //starts animation
        UIView.animate(withDuration: 0.5, animations: {
            
            
            //reset drawer view to be off the screen
            self.menuDrawerView.frame.origin.x = -317
            self.view.layoutIfNeeded() //Not sure what this does??
            
            
            
        })
        
        for subview in self.view.subviews {
            if subview is UIVisualEffectView {
                subview.removeFromSuperview()
            }
        }
        
    }
    
    @IBAction func menu_myFavoritesPressed(_ sender: Any) {
        
        closeDrawer((Any).self)
    }
    
    @IBAction func goToCartPressed(_ sender: Any) {
        
        link.getCartContents(username: LoginVC.user.username, password: LoginVC.user.password, vc: self)
    }
    
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
        
        if segue.identifier == "showProductVC" {
            
            let vc = segue.destination as! ProductVC
            
            vc.proObj = proObjToSend!
        }
        
        if segue.identifier == "showWebHandlerVC" {
            
            let vc = segue.destination as! WebHandlerVC
            
            vc.webCaseReceived = webCaseToSend
        }
        
        if segue.identifier == "showCartVC" {
            
            //ComLink object to handle function for going and getting the users session cart contents
//            link.getCartContents(username: LoginVC.user.username, password: LoginVC.user.password, vc: self)
        }
    }
    
    @IBAction func menuAllProductsPressed(_ sender: Any) {
        
        closeDrawer((Any).self)
        
        //set URL to pass as All Product Categories
        urlToSend = URL.init(string: "\(ComLink.encoreWebAddress)/wc-api/v3/products?filter[category]=apis,bases,excipients&consumer_key=ck_63b19089072b793730f4db01733c15a36e1578f9&consumer_secret=cs_077d6d562bfe50f20d83ab0ae5f1d77ae2a42322")!
        
        // set case to send
        caseToSend = ProductCategory.all
        
        // segue to ProductsVC
        self.performSegue(withIdentifier: "showProductsVC", sender: self)
    }
    
    @IBAction func menuAPIsPressed(_ sender: Any) {
        
        closeDrawer((Any).self)
        
        //set URL to pass as APIs Product Category
        urlToSend = URL.init(string: "\(ComLink.encoreWebAddress)/wc-api/v3/products?filter[category]=apis&consumer_key=ck_63b19089072b793730f4db01733c15a36e1578f9&consumer_secret=cs_077d6d562bfe50f20d83ab0ae5f1d77ae2a42322")!
        
        // set case to send
        caseToSend = ProductCategory.apis
        
        // segue to ProductsVC
        self.performSegue(withIdentifier: "showProductsVC", sender: self)
    }
    
    @IBAction func menuExcipientsPressed(_ sender: Any) {
        
        closeDrawer((Any).self)
        
        //set URL to pass as Excipients Product Category
        urlToSend = URL.init(string: "\(ComLink.encoreWebAddress)/wc-api/v3/products?filter[category]=excipients&consumer_key=ck_63b19089072b793730f4db01733c15a36e1578f9&consumer_secret=cs_077d6d562bfe50f20d83ab0ae5f1d77ae2a42322")!
        
        // set case to send
        caseToSend = ProductCategory.excipients
        
        // segue to ProductsVC
        self.performSegue(withIdentifier: "showProductsVC", sender: self)
    }
    
    @IBAction func menuBasesPressed(_ sender: Any) {
        
        closeDrawer((Any).self)
        
        //set URL to pass as Bases Product Category
        urlToSend = URL.init(string: "\(ComLink.encoreWebAddress)/wc-api/v3/products?filter[category]=bases&consumer_key=ck_63b19089072b793730f4db01733c15a36e1578f9&consumer_secret=cs_077d6d562bfe50f20d83ab0ae5f1d77ae2a42322")!
        
        // set case to send
        caseToSend = ProductCategory.bases
        
        // segue to ProductsVC
        self.performSegue(withIdentifier: "showProductsVC", sender: self)
    }
    
    @IBAction func menu_aboutUsPressed(_ sender: Any) {
        
        //set case to pass to WebHandlerVC so it can display correct web page
        webCaseToSend = WebCase.AboutUs
        
        // segue to WebHandlerVC
        self.performSegue(withIdentifier: "showWebHandlerVC", sender: self)
    }
    
    @IBAction func menu_myAccountPressed(_ sender: Any) {
        
        //set case to pass to WebHandlerVC so it can display correct web page
        webCaseToSend = WebCase.MyAccount
        
        // segue to WebHandlerVC
        self.performSegue(withIdentifier: "showWebHandlerVC", sender: self)
    }
    
    @IBAction func removeFromFavoritesPressed(_ sender: UIButton) {
        
        // create var to get selected row indexPath.row
        var indexPath: IndexPath!
        
        //series of checks to get the btn's row
        if let button = sender as? UIButton {
            if let superview = button.superview {
                if let cell = superview.superview as? HomeCell {
                    indexPath = tableView.indexPath(for: cell)
                    
                }
            }
        }
        
        print("Remove Sku from favorites")
        link.removeDataFromFile(sku: HomeVC.proArray[indexPath.row].sku!)
        
        //Update table view to change star image
        tableView.reloadData()
        
    }// end of removeFromFavoritesPressed()
    
    
} // End of class

// MARK: - ext: TableView Handles
extension HomeVC: UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //code to select
        
        proObjToSend = HomeVC.proArray[indexPath.row]
        
        if proObjToSend != nil {
            
            self.performSegue(withIdentifier: "showProductVC", sender: self)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return HomeVC.proArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Getting the right element
        let element = HomeVC.proArray[indexPath.row]
        
        // Instantiate a cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellHome") as! HomeCell
        
        // Pass the values from the element to load fields
        cell.lbl_title.text = element.title
        cell.lbl_sku.text = element.sku
        cell.lbl_price.text = element.variationsArray?[0].price
        cell.imgV_proImg.image = element.img
        
        // Returning the cell
        return cell
        
    }
}
