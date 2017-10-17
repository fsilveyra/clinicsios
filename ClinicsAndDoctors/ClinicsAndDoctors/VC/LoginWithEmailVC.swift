//
//  LoginWithEmailVC.swift
//  ClinicsAndDoctors
//
//  Created by Reinier Isalgue on 30/09/17.
//  Copyright © 2017 InfinixSoft. All rights reserved.
//

import UIKit
import PKHUD
import NVActivityIndicatorView
import SwiftMessages

class LoginWithEmailVC: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var emailTf: UITextField!
    @IBOutlet weak var passwordTf: UITextField!
    @IBOutlet weak var loginBt: UIButton!
    @IBOutlet weak var viewLogin:UIView!
    let loading = ActivityData()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    //MARK: Actions
    @IBAction func Login(_ sender: Any) {
        if emailTf.text=="" || passwordTf.text==""{
            viewLogin.layer.shake(duration: TimeInterval(0.7))
            self.SwiftMessageAlert(layout: .cardView, theme: .error, title: "", body: "Complete all blank fields")
        }
        else if !isValidEmail(testStr: emailTf.text!){
            self.emailTf.textColor = .red
            self.SwiftMessageAlert(layout: .cardView, theme: .error, title: "", body: "Incorrect Email, please check")
            print("Incorrect email")
            
        }
        else{

            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            self.performSegue(withIdentifier: "goHome", sender: nil)
            
//            NVActivityIndicatorPresenter.sharedInstance.startAnimating(loading)
//            ISClient.sharedInstance.Login(email: emailTf.text!, password: passwordTf.text!) { (loggued, error) in
//                if loggued! {
//                    NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
//                    self.performSegue(withIdentifier: "goHome", sender: nil)
//                }
//                else {
//                    NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
//                    self.SwiftMessageAlert(layout: .cardView, theme: .error, title: error!, body: "Check your Email and Password" )
//                }
//            }
        }
    }
    
    @IBAction func ForgotPassword(_ sender: Any) {
        
        
    }
    
    @IBAction func BackView(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        
        CreateGradienBackGround(view: view)
        loginBt.layer.cornerRadius = 5
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }
    /*
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false

    }*/
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.appDelegate.loggout = true
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    func isValidEmail(testStr:String) -> Bool {
        print("validating email: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluate(with: testStr)
        return result
    }
    
    func isValidPhone(testStr:String) -> Bool {
        print("validating phone: \(testStr)")
        let phoneRegEx = "^((\\+)|(00))[0-9]{6,14}$"
        let phoneTest = NSPredicate(format:"SELF MATCHES %@", phoneRegEx)
        let result = phoneTest.evaluate(with: testStr)
        return result
    }
    
    // MARK: - TextField Delegates
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.textColor = .white
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.textColor = .white
    }

}

extension UIViewController {
    func SwiftMessageAlert(layout: MessageView.Layout, theme: Theme, title: String = "", body: String = "", completation: (() -> Void)? = nil){
        let alert = MessageView.viewFromNib(layout: layout)
        alert.configureTheme(theme)
        alert.configureContent(title: title, body: body)
        alert.button?.isHidden = true
        alert.configureDropShadow()
        SwiftMessages.show(view: alert)
        if (completation != nil) {
            DispatchQueue.main.asyncAfter(
                deadline: DispatchTime.now() + Double(Int64(2.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: completation!)
        }
    }
}
