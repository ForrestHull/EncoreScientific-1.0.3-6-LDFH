//
//  ViewController.swift
//  EncoreScientific
//
//  Created by Bryan Neuberger on 5/17/17.
//  Copyright © 2017 Paradigm Creative. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class LoginVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var popUpCoverView: UIView!
    static var user: Customer!
    let link = ComLink()
    var webCaseToSend: WebCase?
    
    @IBOutlet weak var txtF_username: UITextField!
    @IBOutlet weak var txtF_password: UITextField!
    
    override func viewDidLoad() {
        self.navigationController?.navigationBar.setBackgroundImage(#imageLiteral(resourceName: "Bar"), for: UIBarMetrics.default)

        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        LoginVC.user = Customer()
        
        txtF_username.delegate = self
        txtF_password.delegate = self
        
txtF_username.text =  "forrest.hull@paradigmappdev.com"
txtF_password.text = "ForrestHull2017"
        
        
        
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        animateViewMoving(up: true, moveValue: 150)
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        animateViewMoving(up: false, moveValue: 150)
    }
    
    func animateViewMoving (up:Bool, moveValue :CGFloat){
        let movementDuration:TimeInterval = 0.3
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        UIView.beginAnimations( "animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration )
        self.view.frame = self.view.frame.offsetBy(dx: 0,  dy: movement)
        UIView.commitAnimations()
    }

    @IBAction func loginBtnPressed(_ sender: Any) {
        //login btn was pressed
        
        popUpCoverView.center = view.center
        self.view.addSubview(popUpCoverView)
        
        guard let username = txtF_username.text else { return print("no text in field") }
        guard let password = txtF_password.text else { return print("no text in field") }
        
        link.login(username: username, password: password, vc: self, view: popUpCoverView)
        
        
        //BRYAN TEST RECREATING SIMULATION OF LOGGING IN LIKE A BROWSER
        //DEBUG TEST
//        link.getCartContents(username: "forrest.hull@paradigmappdev.com", password: "ForrestHull2017")
        
    }
    
   
    @IBAction func aboutUsWasPressed(_ sender: Any) {
        
        webCaseToSend = WebCase.AboutUs
        
        // segue to WebHandlerVC
        self.performSegue(withIdentifier: "showWebHandlerVC", sender: self)
    }
    
    @IBAction func registerPressed(_ sender: Any) {
        
        webCaseToSend = WebCase.Register
        
        // segue to WebHandlerVC
        self.performSegue(withIdentifier: "showWebHandlerVC", sender: self)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
    }
    
    // handles anything we need to send to a VC before we complete segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // check segue
        
        if segue.identifier == "showWebHandlerVC" {
            
            let vc = segue.destination as! WebHandlerVC
            
            vc.webCaseReceived = webCaseToSend
        }
    }
    
}

