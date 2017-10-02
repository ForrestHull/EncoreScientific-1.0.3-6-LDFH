//
//  FinalHomeVC.swift
//  EncoreScientific
//
//  Created by Forrest Hull on 5/30/17.
//  Copyright © 2017 Paradigm Creative. All rights reserved.
//

import UIKit

class FinalHomeVC: UIViewController {
    
    let link = ComLink()
    
    @IBOutlet weak var menuDrawerView: UIView!
    
    var urlToSend: URL?
    var caseToSend: ProductCategory?
    var webCaseToSend: WebCase?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.menuDrawerView.frame.origin.x = -317
        
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
        self.view.insertSubview(effectView, at: 19)
        
        UIView.animate(withDuration: 0.8) {
            effectView.effect = UIBlurEffect(style: .regular)
        }
        
    }
    
    @IBAction func menuButtonPressed(_ sender: Any) {
        
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
    
    @IBAction func goToCartPressed(_ sender: Any) {
        
        link.getCartContents(username: LoginVC.user.username, password: LoginVC.user.password, vc: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // check segue
        if segue.identifier == "showProductsVC" {
            
            // create ViewController obj to handle and requests for data being passed
            let vc = segue.destination as! ProductsVC
            
            // send the correct urlString to query WC database
            vc.serverUrl = urlToSend!
            
            vc.arrayCase = caseToSend!
        }
        
        if segue.identifier == "showWebHandlerVC" {
            
            let vc = segue.destination as! WebHandlerVC
            
            vc.webCaseReceived = webCaseToSend
        }
        
        
        
    }
    
    @IBAction func btn_viewAllProductsPressed(_ sender: Any) {
        
        //set URL to pass as All Product Categories
        urlToSend = URL.init(string: "\(ComLink.encoreWebAddress)/wc-api/v3/products?filter[category]=apis,bases,excipients&consumer_key=ck_63b19089072b793730f4db01733c15a36e1578f9&consumer_secret=cs_077d6d562bfe50f20d83ab0ae5f1d77ae2a42322")!
        
        // set case to send
        caseToSend = ProductCategory.all
        
        // segue to ProductsVC
        self.performSegue(withIdentifier: "showProductsVC", sender: self)
    }
    
    @IBAction func btn_barcodeScannerPressed(_ sender: Any) {
        
        // segue to ScanSearchVC
        self.performSegue(withIdentifier: "showBarcodeScannerVC", sender: self)
    }
   
    @IBAction func btn_myAccountPressed(_ sender: Any) {
        
        //set case to pass to WebHandlerVC so it can display correct web page
        webCaseToSend = WebCase.MyAccount
        
        // segue to WebHandlerVC
        self.performSegue(withIdentifier: "showWebHandlerVC", sender: self)
    }
    
    @IBAction func btn_contactUs(_ sender: Any) {
        
        //set case to pass to WebHandlerVC so it can display correct web page
        webCaseToSend = WebCase.ContactUs
        
        // segue to WebHandlerVC
        self.performSegue(withIdentifier: "showWebHandlerVC", sender: self)
    }
    
    @IBAction func menu_viewAllProductsPressed(_ sender: Any) {
        
        //set URL to pass as All Product Categories
        urlToSend = URL.init(string: "\(ComLink.encoreWebAddress)/wc-api/v3/products?filter[category]=apis,bases,excipients&consumer_key=ck_63b19089072b793730f4db01733c15a36e1578f9&consumer_secret=cs_077d6d562bfe50f20d83ab0ae5f1d77ae2a42322")!
        
        // set case to send
        caseToSend = ProductCategory.all
        
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
    
    @IBAction func menu_apisPressed(_ sender: Any) {
        
        //set URL to pass as APIs Product Category
        urlToSend = URL.init(string: "\(ComLink.encoreWebAddress)/wc-api/v3/products?filter[category]=apis&consumer_key=ck_63b19089072b793730f4db01733c15a36e1578f9&consumer_secret=cs_077d6d562bfe50f20d83ab0ae5f1d77ae2a42322")!
        
        // set case to send
        caseToSend = ProductCategory.apis
        
        // segue to ProductsVC
        self.performSegue(withIdentifier: "showProductsVC", sender: self)
        
    }
    
    @IBAction func menu_excipientsPressed(_ sender: Any) {
        
        //set URL to pass as Excipients Product Category
        urlToSend = URL.init(string: "\(ComLink.encoreWebAddress)/wc-api/v3/products?filter[category]=excipients&consumer_key=ck_63b19089072b793730f4db01733c15a36e1578f9&consumer_secret=cs_077d6d562bfe50f20d83ab0ae5f1d77ae2a42322")!
        
        // set case to send
        caseToSend = ProductCategory.excipients
        
        // segue to ProductsVC
        self.performSegue(withIdentifier: "showProductsVC", sender: self)
        
    }
    
    @IBAction func menu_basesPressed(_ sender: Any) {
        
        //set URL to pass as Bases Product Category
        urlToSend = URL.init(string: "\(ComLink.encoreWebAddress)/wc-api/v3/products?filter[category]=bases&consumer_key=ck_63b19089072b793730f4db01733c15a36e1578f9&consumer_secret=cs_077d6d562bfe50f20d83ab0ae5f1d77ae2a42322")!
        
        // set case to send
        caseToSend = ProductCategory.bases
        
        // segue to ProductsVC
        self.performSegue(withIdentifier: "showProductsVC", sender: self)
    }
    
    @IBAction func menu_myFavorites(_ sender: Any) {
        //linked via storyboard segue.... placed action incase needed
        
    }
    
    
    @IBAction func menu_homePressed(_ sender: Any) {
        // we are already on Home Page so just close the menu here also
        menu_exitMenuPressed((Any).self)
    }
    
    @IBAction func menu_exitMenuPressed(_ sender: Any) {
        // close the menu
        
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
    
}
