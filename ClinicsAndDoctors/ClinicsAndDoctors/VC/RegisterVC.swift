//
//  RegisterVC.swift
//  ClinicsAndDoctors
//
//  Created by Reinier Isalgue on 30/09/17.
//  Copyright © 2017 InfinixSoft. All rights reserved.
//

import UIKit
import SwiftMessages
import NVActivityIndicatorView
class RegisterVC: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var plussImage: UIButton!
    @IBOutlet weak var registerBt: UIButton!
    @IBOutlet weak var full_nameTf: UITextField!
    @IBOutlet weak var phone_numberTf: UITextField!
    @IBOutlet weak var emailTf: UITextField!
    @IBOutlet weak var passwordTf: UITextField!
    @IBOutlet weak var passwordCheckTf: UITextField!
    @IBOutlet weak var viewRegister:UIStackView!
    let loading = ActivityData()
    
    // MARK: - Actions
    @IBAction func BackView(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func Register(_ sender: Any) {
        if emailTf.text=="" || passwordTf.text=="" || full_nameTf.text=="" || passwordCheckTf.text=="" || phone_numberTf.text==""{
            viewRegister.layer.shake(duration: TimeInterval(0.7))
            self.SwiftMessageAlert(layout: .cardView, theme: .error, title: "", body: "Complete all blank fields")
        }
        else if !isValidEmail(testStr: emailTf.text!){
            self.emailTf.textColor = .red
            self.SwiftMessageAlert(layout: .cardView, theme: .error, title: "", body: "Incorrect Email, please check")
            print("Incorrect email")
            
        }
        else if !isValidPhone(testStr: phone_numberTf.text!){
            self.phone_numberTf.textColor = .red
            self.SwiftMessageAlert(layout: .cardView, theme: .error, title: "", body: "Incorrect Phone Number, please check")
            print("Incorrect Phone")

        }
        else if passwordTf.text != passwordCheckTf.text{
            self.SwiftMessageAlert(layout: .cardView, theme: .error, title: "", body: "The password and Re-Type Password are not same, please check")
            self.passwordCheckTf.textColor = .yellow
        }
        else{
            NVActivityIndicatorPresenter.sharedInstance.startAnimating(loading)
            ISClient.sharedInstance.RegisterWhitEmail(fullName: full_nameTf.text!, phone_number: phone_numberTf.text!, email: emailTf.text!, password: passwordTf.text!, picture: #imageLiteral(resourceName: "face4")) { (register, error) in
                if register! {
                    NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
                    self.SwiftMessageAlert(layout: .cardView, theme: .success, title: "", body: "Register Success.")
                    //self.performSegue(withIdentifier: "goHome", sender: nil)
                }
                else {
                    NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
                    self.SwiftMessageAlert(layout: .cardView, theme: .error, title: "", body: error!)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CreateGradienBackGround(view: view)
        //self.navigationController?.navigationBar.isHidden = false
        avatarImage.layer.cornerRadius = avatarImage.frame.width/2
        plussImage.layer.cornerRadius = plussImage.frame.width/2
        registerBt.layer.cornerRadius = 5
        // Do any additional setup after loading the view.
    }

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
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.textColor = .white
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.textColor = .white
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
