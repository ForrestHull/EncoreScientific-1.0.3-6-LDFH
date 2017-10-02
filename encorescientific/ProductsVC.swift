//
//  ProductsVC.swift
//  EncoreScientific
//
//  Created by Forrest Hull on 5/17/17.
//  Copyright © 2017 Paradigm Creative. All rights reserved.
//

import UIKit

class ProductsVC: UIViewController, UISearchBarDelegate {
    
    let link = ComLink()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentBtn: UISegmentedControl!
    
    var serverUrl: URL!
    var arrayCase: ProductCategory!
    var webCaseToSend: WebCase?
    
    var proArray = [Products]()
    static var proArrayAll = [Products]()
    static var proArrayApis = [Products]()
    static var proArrayBases = [Products]()
    static var proArrayExcipients = [Products]()
    
    @IBOutlet weak var barButton: UIBarButtonItem!
    
    @IBOutlet weak var menuDrawerView: UIView!
    
    @IBOutlet var view_popUpLoading: UIView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    static var proObjToSend: Products?
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.tableView.reloadData()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.menuDrawerView.frame.origin.x = -317
        self.navigationController?.navigationBar.setBackgroundImage(#imageLiteral(resourceName: "Bar"), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        self.navigationController?.navigationBar.barTintColor = .white
        
        self.navigationController?.navigationBar.layer.zPosition = 0
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        // fetches data from WC DB and load Products requested and update UI
        
        if arrayCase == ProductCategory.all {
            
            segmentBtn.selectedSegmentIndex = 0
            
            if ProductsVC.proArrayAll.count == 0 {
                
                fetchDatabase()
            } else {
                
                proArray = ProductsVC.proArrayAll
                tableView.reloadData()
            }
        }
        
        if arrayCase == ProductCategory.apis {
            
            segmentBtn.selectedSegmentIndex = 2
            
            if ProductsVC.proArrayApis.count == 0 {
                
                fetchDatabase()
            } else {
                
                proArray = ProductsVC.proArrayApis
                tableView.reloadData()
            }
        }
        
        if arrayCase == ProductCategory.bases {
            
            segmentBtn.selectedSegmentIndex = 1
            
            if ProductsVC.proArrayBases.count == 0 {
                
                fetchDatabase()
            } else {
                
                proArray = ProductsVC.proArrayBases
                tableView.reloadData()
            }
        }
        
        if arrayCase == ProductCategory.excipients {
            
            segmentBtn.selectedSegmentIndex = 3
            
            if ProductsVC.proArrayExcipients.count == 0 {
                
                fetchDatabase()
            } else {
                
                proArray = ProductsVC.proArrayExcipients
                tableView.reloadData()
            }
        }
        
        
        
        
        
    }// end of viewDidLoad()
    
    func searchProducts(text: String) {
        
        
            
        
            //search all products
            proArray = ProductsVC.proArrayAll.filter({ (product) -> Bool in
                
                let toReturn = product.title?.lowercased().contains(text.lowercased())
                return toReturn!
            })
            tableView.reloadData()
        
            
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //user is typing in the searchBar
        
        if searchText.isEmpty {
            
            if arrayCase == ProductCategory.all {
                
                proArray = ProductsVC.proArrayAll
                tableView.reloadData()
            }
            
            if arrayCase == ProductCategory.apis {
                
                proArray = ProductsVC.proArrayApis
                tableView.reloadData()
            }
            
            if arrayCase == ProductCategory.bases {
                
                proArray = ProductsVC.proArrayBases
                tableView.reloadData()
            }
            
            if arrayCase == ProductCategory.excipients {
                
                proArray = ProductsVC.proArrayExcipients
                tableView.reloadData()
            }
            
            
        } else {
            searchProducts(text: searchText)
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        
        self.searchBar.endEditing(true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        self.searchBar.endEditing(true)
        
    }
    
    func blur() {
        
        let effectView = UIVisualEffectView()
        effectView.frame = self.view.frame
        self.view.insertSubview(effectView, at: 4)
        
        UIView.animate(withDuration: 0.8) {
            effectView.effect = UIBlurEffect(style: .regular)
        }
        
    }
    
    @IBAction func menuPressed(_ sender: Any) {
        
        self.blur()
        
        //starts animation
        UIView.animate(withDuration: 0.5, animations: {
            // change constraint to 0 of super view
            
            // move menuViews lead edge to place full view onto screen
            self.menuDrawerView.frame.origin.x = 0
            self.view.layoutIfNeeded()
            
        })
        
    }
    
    @IBAction func closeDrawer(_ sender: Any) {
        //starts animation
        UIView.animate(withDuration: 0.5, animations: {
            
            for subview in self.view.subviews {
                if subview is UIVisualEffectView {
                    subview.removeFromSuperview()
                }
            }
            //reset drawer view to be off the screen
            self.menuDrawerView.frame.origin.x = -317
            self.view.layoutIfNeeded() //Not sure what this does??
        })
        
    }
    
    //func to fetch database from WC
    func fetchDatabase() {
        
        view_popUpLoading.center = view.center
        self.view.addSubview(view_popUpLoading)
        
        //remove any previous loaded obj's from the array
        proArray.removeAll()
        
        //create a request with the URL
        var request = URLRequest(url: serverUrl)
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
                print(data?.description as Any)
                print("Response Debug: ",response.debugDescription)
                
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
                            
                            // debug for values grabbed
                            print(title)
                            print(id)
                            print(sku)
                            print(imgUrl)
                            // print(price)
                            
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
                            self.proArray.append(proObj)
                            
                        }
                        
                        // check to make sure HomeVC.proArray is being loaded
                        if self.proArray.count > 0 {
                            
                            // loop through each Products obj
                            for test in self.proArray {
                                
                                // run func getVariations(product: test) to return an [Variations] for the obj
                                test.variationsArray = self.getVariations(product: test)
                            }
                            
                            //load static array with fetched array based on category case
                            if self.arrayCase == ProductCategory.all {
                                
                                ProductsVC.proArrayAll = self.proArray
                            }
                            
                            if self.arrayCase == ProductCategory.apis {
                                
                                ProductsVC.proArrayApis = self.proArray
                            }
                            
                            if self.arrayCase == ProductCategory.bases {
                                
                                ProductsVC.proArrayBases = self.proArray
                            }
                            
                            if self.arrayCase == ProductCategory.excipients {
                                
                                ProductsVC.proArrayExcipients = self.proArray
                            }
                            
                            // call UI thread to load table view with [Products]
                            DispatchQueue.main.async{
                                
                                self.view_popUpLoading.removeFromSuperview()
                                self.tableView.reloadData()
                            }
                            
                            //Debug to make sure 1st array obj loaded with values
                            print("\n\nTesting obj load: ")
                            print("Title: \(self.proArray[0].title!)")
                            print("ID: \(self.proArray[0].id!)")
                            print("SKU: \(self.proArray[0].sku!)")
                            print("imgUrl: \(self.proArray[0].imgUrl!)")
                            // print("PRICE: \(HomeVC.proArray[0].price!)")
                            print("VARY: \(String(describing: self.proArray[0].variationsArray))")
                            
                            // loop through the variations array to make sure values loaded
                            for test in self.proArray[0].variationsArray! {
                                
                                print("\n\(test.id!)")
                                print("\(test.sku!)")
                                print("\(test.size!)")
                                print("\(test.price!)")
                                
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
            print("Running for vs in vari!")
            
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
                print("size in for loop: \(size!)")
            }
            print("size OUT of for loop: \(size!)")
            
            // create var as a dict to grab values
            let prices_by_user_roles = vs["prices_by_user_roles"] as? [String: AnyObject]
            
            // grab and set the price var
            if prices_by_user_roles?["pharmacy_list"] != nil {
                
                price = prices_by_user_roles?["pharmacy_list"] as? String!
                
            } else {
                
                price = "0"
            }
            print("price grabbed: \(price!)")
            
            // debug and load each value into the variObj object
            print("Loading variObj")
            variObj.id = id!
            print("id loaded... >>\(variObj.id!)")
            variObj.sku = sku!
            print("sku loaded... >>\(variObj.sku!)")
            variObj.size = size!
            print("size loaded... >>\(variObj.size!)")
            variObj.price = price!
            print("price loaded... >>\(variObj.price!)")
            
            // once all values are loaded into the object append the object to the products array
            product.variationsArray?.append(variObj)
            
            print("\nvariObj \(variObj.sku!): Loaded Correctly! \n")
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
    
    
    @IBAction func segBtnCasePressed(_ sender: UISegmentedControl) {
        //handle cases for segment control
        
        switch segmentBtn.selectedSegmentIndex
        {
        case 0:
            // List all products
            print("Case 0 pressed")
            serverUrl = URL.init(string: "\(ComLink.encoreWebAddress)/wc-api/v3/products?filter[category]=apis,bases,excipients&consumer_key=ck_63b19089072b793730f4db01733c15a36e1578f9&consumer_secret=cs_077d6d562bfe50f20d83ab0ae5f1d77ae2a42322")!
            
            // check to see if static array is already loaded or is empty waiting to be loaded
            if ProductsVC.proArrayAll.count == 0 {
                
                // array was empty so it has not been grabbed yet go fetch the data to laod array and set case to know which array to load
                print("\nProductsVC.proArrayAll.count == 0\nProductsVC.proArrayAll.count = \(ProductsVC.proArrayAll.count)")
                arrayCase = ProductCategory.all
                fetchDatabase()
                
            } else {
                
                // array is already loaded set our constant array to that of our static array and reload tableView
                proArray.removeAll()
                proArray = ProductsVC.proArrayAll
                arrayCase = ProductCategory.all
                tableView.reloadData()
                
                print("ProductsVC.proArrayAll = \(ProductsVC.proArrayAll.count)")
                print("proArray = \(proArray.count)")
            }
            
            
            break;//remove once code in place
            
        case 1:
            // List Bases products
            print("Case 1 pressed")
            serverUrl = URL.init(string: "\(ComLink.encoreWebAddress)/wc-api/v3/products?filter[category]=bases&consumer_key=ck_63b19089072b793730f4db01733c15a36e1578f9&consumer_secret=cs_077d6d562bfe50f20d83ab0ae5f1d77ae2a42322")!
            
            // check to see if static array is already loaded or is empty waiting to be loaded
            if ProductsVC.proArrayBases.count == 0 {
                
                // array was empty so it has not been grabbed yet go fetch the data to laod array and set case to know which array to load
                print("\nProductsVC.proArrayBases.count == 0\nProductsVC.proArrayBases.count = \(ProductsVC.proArrayBases.count)")
                arrayCase = ProductCategory.bases
                fetchDatabase()
                
            } else {
                
                // array is already loaded set our constant array to that of our static array and reload tableView
                proArray.removeAll()
                proArray = ProductsVC.proArrayBases
                arrayCase = ProductCategory.bases
                tableView.reloadData()
                
                print("ProductsVC.proArrayBases = \(ProductsVC.proArrayBases.count)")
                print("proArray = \(proArray.count)")
            }
            break;//remove once code in place
            
        case 2:
            // List API products
            print("Case 2 pressed")
            serverUrl = URL.init(string: "\(ComLink.encoreWebAddress)/wc-api/v3/products?filter[category]=apis&consumer_key=ck_63b19089072b793730f4db01733c15a36e1578f9&consumer_secret=cs_077d6d562bfe50f20d83ab0ae5f1d77ae2a42322")!
            
            // check to see if static array is already loaded or is empty waiting to be loaded
            if ProductsVC.proArrayApis.count == 0 {
                
                // array was empty so it has not been grabbed yet go fetch the data to laod array and set case to know which array to load
                print("\nProductsVC.proArrayApis.count == 0\nProductsVC.proArrayApis.count = \(ProductsVC.proArrayApis.count)")
                arrayCase = ProductCategory.apis
                fetchDatabase()
                
            } else {
                
                // array is already loaded set our constant array to that of our static array and reload tableView
                proArray.removeAll()
                proArray = ProductsVC.proArrayApis
                arrayCase = ProductCategory.apis
                tableView.reloadData()
                
                print("ProductsVC.proArrayApis = \(ProductsVC.proArrayApis.count)")
                print("proArray = \(proArray.count)")
            }
            
            break;//remove once code in place
            
        case 3:
            // List Excipients products
            print("Case 3 pressed")
            serverUrl = URL.init(string: "\(ComLink.encoreWebAddress)/wc-api/v3/products?filter[category]=excipients&consumer_key=ck_63b19089072b793730f4db01733c15a36e1578f9&consumer_secret=cs_077d6d562bfe50f20d83ab0ae5f1d77ae2a42322")!
            
            // check to see if static array is already loaded or is empty waiting to be loaded
            if ProductsVC.proArrayExcipients.count == 0 {
                
                // array was empty so it has not been grabbed yet go fetch the data to laod array and set case to know which array to load
                print("\nProductsVC.proArrayExcipients.count == 0\nProductsVC.proArrayExcipients.count = \(ProductsVC.proArrayExcipients.count)")
                arrayCase = ProductCategory.excipients
                fetchDatabase()
                
            } else {
                
                // array is already loaded set our constant array to that of our static array and reload tableView
                proArray.removeAll()
                proArray = ProductsVC.proArrayExcipients
                arrayCase = ProductCategory.excipients
                tableView.reloadData()
                
                print("ProductsVC.proArrayExcipients = \(ProductsVC.proArrayExcipients.count)")
                print("proArray = \(proArray.count)")
            }
            
            break;//remove once code in place
            
        default:
            break;
        }
        
    }
    
    
    @IBAction func addToFavoritesPressed(_ sender: UIButton) {
        // add product to favorites file written to device
        
        // create var to get selected row indexPath.row
        var indexPath: IndexPath!
        
        //series of checks to get the btn's row
        if let button = sender as? UIButton {
            if let superview = button.superview {
                if let cell = superview.superview as? ProductsCell {
                    indexPath = tableView.indexPath(for: cell)
                }
            }
        }
        
        //check to see if sku is already added to master array
        if HomeVC.skuArray.contains(proArray[indexPath.row].sku!) == true || LoginVC.user.favoritesList.contains(proArray[indexPath.row].sku!) == true {
            
            //it is already in master array
            print("HomeVC.skuArray.contains(proObj.sku!) == true\nDont write \(proArray[indexPath.row].sku!) sku to CoreData")
            
            print("Remove Sku from favorites")
            link.removeDataFromFile(sku: proArray[indexPath.row].sku!)
            
            //Update table view to change star image
            tableView.reloadData()
            
        } else {
            
            //it has not yet been added to master array
            print("HomeVC.skuArray.contains(proObj.sku!) == FALSE")
            
            // check to see if it has been added to placeholder array
            if  LoginVC.user.favoritesList.contains(proArray[indexPath.row].sku!) == false {
                
                //Sku has not been added to place holder either proceed to writing
                print("LoginVC.user.favoritesList.contains(proObj.sku!) == false\nWrite \(proArray[indexPath.row].sku!) sku to CoreData")
                
                //Add sku to placeholder array
                LoginVC.user.favoritesList.append(proArray[indexPath.row].sku!)
                
                //write SKU to CoreData
                link.writeDataToFile(sku: proArray[indexPath.row].sku!)
                
                //Update table view to change star image
                tableView.reloadData()
                
            } else {
                
                //sku is already in place holder array dont double add to the master, coreData, or place holder array
                print("sku is already in placeholder Array LoginVC.user.favoritesList Do not double add!")
                
            }
            
        }
    }
    
    @IBAction func menu_allProductsPressed(_ sender: Any) {
        
        closeDrawer((Any).self)
        
        segmentBtn.selectedSegmentIndex = 0
        
        segBtnCasePressed(segmentBtn)
    }
    
    @IBAction func menu_apisPressed(_ sender: Any) {
        
        closeDrawer((Any).self)
        
        segmentBtn.selectedSegmentIndex = 2
        
        segBtnCasePressed(segmentBtn)
    }
    
    @IBAction func menu_excipientsPressed(_ sender: Any) {
        
        closeDrawer((Any).self)
        
        segmentBtn.selectedSegmentIndex = 3
        
        segBtnCasePressed(segmentBtn)
    }
    
    @IBAction func menu_basesPressed(_ sender: Any) {
        
        closeDrawer((Any).self)
        
        segmentBtn.selectedSegmentIndex = 1
        
        segBtnCasePressed(segmentBtn)
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
    
    @IBAction func goToCartPressed(_ sender: Any) {
        
        link.getCartContents(username: LoginVC.user.username, password: LoginVC.user.password, vc: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showProductVC" {
            
            let vc = segue.destination as! ProductVC
            
            vc.proObj = ProductsVC.proObjToSend!
        }
        
        if segue.identifier == "showWebHandlerVC" {
            
            let vc = segue.destination as! WebHandlerVC
            
            vc.webCaseReceived = webCaseToSend
        }
    }
    
}

// MARK: - ext: TableView Handles
extension ProductsVC: UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //code to select
        
        ProductsVC.proObjToSend = proArray[indexPath.row]
        
        if ProductsVC.proObjToSend != nil {
            
            self.performSegue(withIdentifier: "showProductVC", sender: self)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.proArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Getting the right element
        let element = self.proArray[indexPath.row]
        
        // Instantiate a cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! ProductsCell
        
        // Pass the values from the element to load fields
        cell.lbl_title.text = element.title
        cell.lbl_sku.text = element.sku
        cell.lbl_price.text = element.variationsArray?[0].price
        cell.imgV_productImage.image = element.img
        
        if LoginVC.user.favoritesList.contains(element.sku!) == true {
            
            cell.btn_favorites.setImage(#imageLiteral(resourceName: "StarGold"), for: .normal)
            
        } else {
            
            cell.btn_favorites.setImage(#imageLiteral(resourceName: "Star"), for: .normal)
            
        }
        
        // Returning the cell
        return cell
        
    }
}



