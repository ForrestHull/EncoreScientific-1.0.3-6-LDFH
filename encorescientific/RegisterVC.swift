//
//  RegisterVC.swift
//  EncoreScientific
//
//  Created by Forrest Hull on 5/31/17.
//  Copyright © 2017 Paradigm Creative. All rights reserved.
//

import UIKit
import WebKit

class RegisterVC: UIViewController, WKUIDelegate, WKNavigationDelegate {
    
    
    var webKit: WKWebView!
    @IBOutlet weak var regLabel : UILabel!

    override func viewDidLoad() {
        view.bringSubview(toFront: regLabel)
        regLabel.superview?.bringSubview(toFront: regLabel)
        super.viewDidLoad()


        // Do any additional setup after loading the view.
        
        let url = URL(string: "https://www.encoresci.com/register/")
        fetchWebSite(urlToPass: url!)
        self.navigationItem.title = "Register With Encore"
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        self.view.bringSubview(toFront: regLabel)
        regLabel.superview?.bringSubview(toFront: regLabel)
view.addSubview(regLabel)

    }
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        if (webKit.scrollView.contentOffset.y == 0) {
            
        self.regLabel.isEnabled = false
            
        }
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.webKit.scrollView.contentOffset.y = 390
        view.addSubview(regLabel)

      //  view.insertSubview(webKit, at: 1)

    }
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {

    }
    
    func fetchWebSite(urlToPass: URL) {
        // func to go fetch website based
        
        // create an object for the WKWebview Configurations
        let webConfig = WKWebViewConfiguration()
        let scriptURL = Bundle.main.path(forResource: "hideSections", ofType: "js")
        regLabel.superview?.bringSubview(toFront: regLabel)
        view.addSubview(regLabel)

        do {
            
            let scriptContent = try String.init(contentsOfFile: scriptURL!, encoding: String.Encoding.utf8)
            let script = WKUserScript(source: scriptContent, injectionTime: .atDocumentStart, forMainFrameOnly: true)
            webConfig.userContentController.addUserScript(script)
            // instantiate webKit object from WKWebView with the super views frame and pass in our configuration
            
            webKit = WKWebView.init(frame: view.frame, configuration: webConfig)
            self.view.bringSubview(toFront: regLabel)

            
            //declare delegates for our WKWebKit
            webKit.navigationDelegate = self
            webKit.uiDelegate = self
            
            // set our view to be the webKit to appear in the VC
            view = webKit
            
            // create a request object to handle the HTTP request we want to send with our URL
            let req = URLRequest(url: urlToPass)
            regLabel.superview?.bringSubview(toFront: regLabel)

            
            // load the request to laod the webpage into view of our WKWebKit object to project
            webKit.load(req)
            regLabel.superview?.bringSubview(toFront: regLabel)
            view.addSubview(regLabel)

            print("\nREQ DEBUG:",req.debugDescription)
            
        } catch  {
            
            print("ERROR!")
        }
    }
    

}
