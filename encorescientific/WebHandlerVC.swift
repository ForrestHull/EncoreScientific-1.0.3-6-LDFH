//
//  WebHandlerVC.swift
//  EncoreScientific
//
//  Created by Bryan Neuberger on 5/26/17.
//  Copyright © 2017 Paradigm Creative. All rights reserved.
//

import UIKit
import WebKit

class WebHandlerVC: UIViewController, WKUIDelegate, WKNavigationDelegate {
    
    //test for commit
    //comment another line to commit
    
    var webKit: WKWebView!
    var webCaseReceived: WebCase!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        if webCaseReceived == WebCase.AboutUs {
            
            print("Confirm AboutUs recieved")
            let url = URL(string: "https://www.encoresci.com/about-us/")
            fetchWebSite(urlToPass: url!)
            self.navigationItem.title = "About Encore"
        }
        
        if webCaseReceived == WebCase.MyAccount {
            
            let url = URL(string: "\(ComLink.encoreWebAddress)/my-account/")
            fetchWebSite(urlToPass: url!)
            self.navigationItem.title = "My Account"
        }
        
        if webCaseReceived == WebCase.ContactUs {
            
            let url = URL(string: "https://www.encoresci.com/contact-us/")
            fetchWebSite(urlToPass: url!)
            self.navigationItem.title = "Contact Encore"
        }
        
        if webCaseReceived == WebCase.Register {
            
            let url = URL(string: "https://www.encoresci.com/register/")
            fetchWebSite(urlToPass: url!)
            self.navigationItem.title = "Register With Encore"
        }
    }
    
    func fetchWebSite(urlToPass: URL) {
        // func to go fetch website based
        
        // create an object for the WKWebview Configurations
        let webConfig = WKWebViewConfiguration()
        let scriptURL = Bundle.main.path(forResource: "hideSections", ofType: "js")
        
        do {
            
            let scriptContent = try String.init(contentsOfFile: scriptURL!, encoding: String.Encoding.utf8)
            let script = WKUserScript(source: scriptContent, injectionTime: .atDocumentStart, forMainFrameOnly: true)
            webConfig.userContentController.addUserScript(script)
            // instantiate webKit object from WKWebView with the super views frame and pass in our configuration
            webKit = WKWebView.init(frame: view.frame, configuration: webConfig)
            
            //declare delegates for our WKWebKit
            webKit.navigationDelegate = self
            webKit.uiDelegate = self
            
            // set our view to be the webKit to appear in the VC
            view = webKit
            
            // create a request object to handle the HTTP request we want to send with our URL
            var req = URLRequest(url: urlToPass)
            req.httpShouldHandleCookies = true
            req.httpMethod = "GET"
            
            
            // add a body field for our HTTP request to pass in our stored cookies
            if webCaseReceived == WebCase.Register || webCaseReceived == WebCase.AboutUs {
                
                //do nothing
                
            } else {
                
                req.addValue("\(LoginVC.user.cookies!);", forHTTPHeaderField: "Cookie")
                
            }
            
            // load the request to laod the webpage into view of our WKWebKit object to project
            webKit.load(req)
            print("\nREQ DEBUG:",req.debugDescription)
            
        } catch  {
            
            print("ERROR!")
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        decisionHandler(.allow)
    }
    
//    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
//        print("Did recieve challenge")
//        print(challenge.protectionSpace.host.debugDescription)
//        print(challenge.description)
//        
//        
//        if webCaseReceived == WebCase.Register || webCaseReceived == WebCase.AboutUs  {
//            
//            let user = ""
//            let password = ""
//            let credential = URLCredential(user: user, password: password, persistence: URLCredential.Persistence.forSession)
//            
//            // pass credential object into the handler
//            completionHandler(URLSession.AuthChallengeDisposition.useCredential, credential)
//            
//        } else {
//            
//            //set userName and password to place into a URLCredential object to pass in our completionHandler(URLSession.AuthChallengeDisposition.useCredential, credential)
//            let user = LoginVC.user.username!
//            let password = LoginVC.user.password!
//            let credential = URLCredential(user: user, password: password, persistence: URLCredential.Persistence.forSession)
//            
//            print(credential.user!)
//            print(challenge.sender.debugDescription)
//            
//            // pass credential object into the handler
//            completionHandler(URLSession.AuthChallengeDisposition.useCredential, credential)
//        }
//        
//        
//    }
    
}
