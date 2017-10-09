//
//  ProductVC.swift
//  EncoreScientific
//
//  Created by Forrest Hull on 5/18/17.
//  Copyright © 2017 Paradigm Creative. All rights reserved.
//

import UIKit

class ProductVC: UIViewController {
    
    let link = ComLink()
    
    @IBOutlet weak var imgV_productImage: UIImageView!
    @IBOutlet weak var lbl_productTitle: UILabel!
    @IBOutlet weak var lbl_productPrice: UILabel!
    @IBOutlet weak var txtV_productDescription: UITextView!
    
    @IBOutlet weak var lbl_productSKU: UILabel!
    @IBOutlet weak var btn_QTY: UIButton!
    @IBOutlet weak var btn_size: UIButton!
    @IBOutlet weak var btn_favorites: UIButton!
    
    @IBOutlet var view_popUpSize: UIView!
    @IBOutlet weak var pickerView: UIPickerView!
    
    @IBOutlet var view_popUpQTY: UIView!
    @IBOutlet weak var txtF_QTY: UITextField!
    
    var proObj: Products!
    
    var sizeSelected: String?
    var skuSelected: String?
    var priceSelected: String?
    var qtySelected: Int?
    var variationIdSelected: Int?
    var sizeIndex: Int?
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        if LoginVC.user.favoritesList.contains(proObj.sku!) == true {
            
            btn_favorites.setImage(#imageLiteral(resourceName: "Favorited Button"), for: .normal)
            
        } else {
            
            btn_favorites.setImage(#imageLiteral(resourceName: "Favorite Button"), for: .normal)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print("\nOpening ProductVC")
        
        self.navigationController?.navigationBar.setBackgroundImage(#imageLiteral(resourceName: "Bar"), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        self.navigationController?.navigationBar.barTintColor = .white
        
        pickerView.delegate = self
        pickerView.dataSource = self
        
        imgV_productImage.image = proObj.img
        lbl_productTitle.text = proObj.title
        lbl_productPrice.text = proObj.variationsArray?[0].price
        lbl_productSKU.text = proObj.sku
        
        let stringToMod: String = proObj.descript!
        let discString = String(stringToMod.characters.dropLast(5))
        let inputString = String(discString.characters.dropFirst(3))
        txtV_productDescription.text = inputString
        self.txtV_productDescription.setContentOffset(.zero, animated: false)
        qtySelected = 1
        priceSelected = proObj.variationsArray?[0].price!
        variationIdSelected = proObj.variationsArray?[0].id!
    }
    
    
    
    @IBAction func sizeBtnPressed(_ sender: Any) {
        
        view_popUpSize.center = view.center
        
        view_popUpSize.transform = CGAffineTransform(scaleX: 1.2, y: 0.6)
        
        view.addSubview(view_popUpSize)
        
        // add animation bounce
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [], animations: {
            // code in here for the views to produce animaiton
            
            self.view_popUpSize.transform = .identity
            
        })
        
    }
    
    @IBAction func exitPopUpSizePressed(_ sender: Any) {
        
        var priceToConvert: Double = 0
        if let qty = qtySelected, let pSel = priceSelected {
            if pSel != "" {
                priceToConvert = Double(qty) * Double(pSel)!
            }
        }
        
        lbl_productPrice.text = String("$\(priceToConvert)0")
        
        lbl_productSKU.text = skuSelected
        
        btn_size.setTitle(sizeSelected, for: .normal)
        
        // add animation bounce
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [], animations: {
            // code in here for the views to produce animaiton
            
            self.view_popUpSize.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            
        }) { (success) in
            // remove views from superView
            self.view_popUpSize.removeFromSuperview()
        }
    }
    
    @IBAction func qtyBtnPressed(_ sender: Any) {
        
        view_popUpQTY.center = view.center
        
        view_popUpQTY.transform = CGAffineTransform(scaleX: 1.2, y: 0.6)
        
        view.addSubview(view_popUpQTY)
        
        // add animation bounce
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [], animations: {
            // code in here for the views to produce animaiton
            
            self.view_popUpQTY.transform = .identity
            
        })
        
        
    }
    
    @IBAction func exitQTYpopUpPressed(_ sender: Any) {
        
        if txtF_QTY.text != "" {
            
            qtySelected = Int(txtF_QTY.text!)
            
            btn_QTY.setTitle(txtF_QTY.text, for: .normal)
            
        } else {
            
            qtySelected = 1
            btn_QTY.setTitle("1", for: .normal)
            
        }
        
        let priceToConvert = Double(qtySelected!) * Double(priceSelected!)!
        
        lbl_productPrice.text = String("$\(priceToConvert)0")
        
        // add animation bounce
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: [], animations: {
            // code in here for the views to produce animaiton
            
            self.view_popUpQTY.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            
        }) { (success) in
            // remove views from superView
            self.view_popUpQTY.removeFromSuperview()
        }
    }
    
    @IBAction func addToCartBtnPressed(_ sender: Any) {
        //add product to the users cart
        
        link.addItemToCart(username: LoginVC.user.username, password: LoginVC.user.password, product_id: proObj.id!, qty: qtySelected!, variation_id: variationIdSelected!, vc: self)
        
        print(LoginVC.user.cartKeys)
    }
    
    @IBAction func addToFavoritesBtnPressed(_ sender: Any) {
        // add product to favorites file written to device
        
        //check to see if sku is already added to master array
        if HomeVC.skuArray.contains(proObj.sku!) == true || LoginVC.user.favoritesList.contains(proObj.sku!) == true {
            
            //it is already in master array
            print("HomeVC.skuArray.contains(proObj.sku!) == true\n")
            
            print("Remove Sku from favorites")
            link.removeDataFromFile(sku: proObj.sku!)
            btn_favorites.setImage(#imageLiteral(resourceName: "Favorite Button"), for: .normal)
            
        } else {
            
            //it has not yet been added to master array
            print("HomeVC.skuArray.contains(proObj.sku!) == FALSE")
            
            btn_favorites.setImage(#imageLiteral(resourceName: "Favorited Button"), for: .normal)
            
            // check to see if it has been added to placeholder array
            if  LoginVC.user.favoritesList.contains(proObj.sku!) == false {
                
                //Sku has not been added to place holder either proceed to writing
                print("LoginVC.user.favoritesList.contains(proObj.sku!) == false\nWrite \(proObj.sku!) sku to CoreData")
                
                //Add sku to placeholder array
                LoginVC.user.favoritesList.append(proObj.sku!)
                
                //write SKU to CoreData
                link.writeDataToFile(sku: proObj.sku!)
                
                
                
            } else {
                
                //sku is already in place holder array dont double add to the master, coreData, or place holder array
                print("sku is already in placeholder Array LoginVC.user.favoritesList Do not double add!")
                
            }
            
        }
        
        
    }
}


//MARK: - EXT: pickerView
extension ProductVC: UIPickerViewDelegate, UIPickerViewDataSource
{
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return proObj.variationsArray!.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return proObj.variationsArray![row].size!
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //code here for what to do with what row is selected = array[row]
        
        sizeSelected = proObj.variationsArray![row].size!
        skuSelected = proObj.variationsArray![row].sku!
        priceSelected = proObj.variationsArray![row].price!
        variationIdSelected = proObj.variationsArray![row].id!
        sizeIndex = row
        
        print("Inside PickerView Func: price: \(priceSelected!)  row: \(row)")
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
        
    }
    
}
