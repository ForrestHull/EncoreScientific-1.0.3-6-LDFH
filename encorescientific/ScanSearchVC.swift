//
//  ScanSearchVC.swift
//  EncoreScientific
//
//  Created by Forrest Hull on 5/18/17.
//  Copyright © 2017 Paradigm Creative. All rights reserved.
//

import UIKit
import AVFoundation

class ScanSearchVC:  UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    @IBOutlet weak var barCodeLabel: UILabel!
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    var productToSend: Products!
    var skuToPass: String!
    
    override func viewDidLoad() {
        self.navigationController?.navigationBar.setBackgroundImage(#imageLiteral(resourceName: "Bar"), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        self.navigationController?.navigationBar.barTintColor = .white
        
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()
        
        let videoCaptureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed();
            return;
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypePDF417Code,AVMetadataObjectTypeUPCECode,
                                                  AVMetadataObjectTypeCode39Code,AVMetadataObjectTypeCode39Mod43Code,AVMetadataObjectTypeEAN13Code,AVMetadataObjectTypeEAN8Code,AVMetadataObjectTypeCode93Code,AVMetadataObjectTypeCode128Code,AVMetadataObjectTypePDF417Code,AVMetadataObjectTypeQRCode,AVMetadataObjectTypeAztecCode, AVMetadataObjectTypeFace, AVMetadataObjectTypeInterleaved2of5Code, AVMetadataObjectTypeITF14Code,AVMetadataObjectTypeDataMatrixCode]
        } else {
            failed()
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession);
        previewLayer.frame = view.layer.bounds;
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        view.layer.addSublayer(previewLayer);
        
        captureSession.startRunning();
        barCodeLabel.layer.zPosition = 2
        
    }
    
    func failed() {
        let ac = UIAlertController(title: "Scanning Barcode", message: "Please hold your device still, and make sure to frame the entire barcode.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession.startRunning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (captureSession?.isRunning == false) {
            captureSession.startRunning();
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning();
        }
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        captureSession.stopRunning()
        
        if let metadataObject = metadataObjects.first {
            
            if let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject {
                
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                found(code: readableObject.stringValue);
                dismiss(animated: true)
                
            } else {
                
                failed()
            }
            
            
        }
        
//        dismiss(animated: true)
    }
    
    func found(code: String) {
        barCodeLabel.layer.zPosition = 2
        print(code)
        barCodeLabel.text = code
        
        skuToPass = String(code.characters.prefix(5))
        print("\nsku: \(skuToPass)")
        
        fetchProduct(skuToPass: skuToPass)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showProductVC" {
            
            let vc = segue.destination as! ProductVC
            
            vc.proObj = productToSend
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    
    func fetchProduct(skuToPass: String) {
        //Fetches products from the WC database
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
                            
                            proObj.variationsArray = self.getVariations(product: proObj)
                            
                            // load proObj into HomeVC.proArray
                            self.productToSend = proObj
                            
                            
                            // call UI thread to load table view with [Products]
                            DispatchQueue.main.async{
                                
                                if self.productToSend != nil {
                                    
                                    self.performSegue(withIdentifier: "showProductVC", sender: self)
                                    print("\nSegue to productVC")
                                }
                                
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
                        
                        // call UI thread to load table view with [Products]
                        DispatchQueue.main.async{
                            
                            
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









