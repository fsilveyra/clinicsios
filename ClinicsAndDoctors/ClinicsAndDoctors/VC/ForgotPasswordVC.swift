//
//  ForgotPasswordVC.swift
//  ClinicsAndDoctors
//
//  Created by Reinier Isalgue on 30/09/17.
//  Copyright © 2017 InfinixSoft. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
let loading = ActivityData()

class ForgotPasswordVC: UIViewController {
    @IBOutlet weak var phoneTf: UITextField!
    @IBOutlet weak var recoverBt: UIButton!
    @IBOutlet weak var viewRecover:UIView!
    //MARK: Actions
    @IBAction func BackView(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func RecoverPassword(_ sender: Any) {
        if  phoneTf.text==""{
            viewRecover.layer.shake(duration: TimeInterval(0.7))
            self.SwiftMessageAlert(layout: .cardView, theme: .error, title: "", body: "Type a Phone Number")
        }
        else if !isValidPhone(testStr: phoneTf.text!){
            self.phoneTf.textColor = .red
            self.SwiftMessageAlert(layout: .cardView, theme: .error, title: "", body: "Incorrect Phone Number, please check")
            print("Incorrect Phone")
            
        }
        else{

            NVActivityIndicatorPresenter.sharedInstance.startAnimating(loading)

            ISClient.sharedInstance.forgotPassword(phone_number: phoneTf.text!)
                .then { _ -> Void in
                    self.SwiftMessageAlert(layout: .cardView, theme: .success, title: "", body: "User recovery was successful, wait for sms...")
                }.always {
                    NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
                }.catch { error in
                    if let e: LPError = error as? LPError {
                        e.show()
                    }
            }

        }
    }
    
    func isValidPhone(testStr:String) -> Bool {

        return !testStr.isEmpty
        
        print("validating phone: \(testStr)")
        let phoneRegEx = "^((\\+)|(00))[0-9]{6,14}$"
        let phoneTest = NSPredicate(format:"SELF MATCHES %@", phoneRegEx)
        let result = phoneTest.evaluate(with: testStr)
        return result
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        CreateGradienBackGround(view: view)
        recoverBt.layer.cornerRadius = 5
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


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
