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
    @IBOutlet weak var mobileLbl: UILabel!
    @IBOutlet weak var textLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!

    //MARK: Actions
    @IBAction func BackView(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func RecoverPassword(_ sender: Any) {
        if  phoneTf.text==""{
            viewRecover.layer.shake(duration: TimeInterval(0.7))
            self.SwiftMessageAlert(layout: .cardView, theme: .error, title: "", body: "Type a Phone Number".localized)
        }
        else if !isValidPhone(testStr: phoneTf.text!){
            self.phoneTf.textColor = .red
            self.SwiftMessageAlert(layout: .cardView, theme: .error, title: "", body: "Incorrect Phone Number, please check".localized)

            
        }
        else{

            NVActivityIndicatorPresenter.sharedInstance.startAnimating(loading)

            ISClient.sharedInstance.forgotPassword(phone_number: phoneTf.text!)
                .then { _ -> Void in
                    self.SwiftMessageAlert(layout: .cardView, theme: .success, title: "", body: "User recovery was successful, wait for sms...".localized)
                    self.navigationController?.popViewController(animated: true)
                    
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
        
        let phoneRegEx = "^((\\+)|(00))[0-9]{6,14}$"
        let phoneTest = NSPredicate(format:"SELF MATCHES %@", phoneRegEx)
        let result = phoneTest.evaluate(with: testStr)
        return result
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        translateStaticInterface()
        CreateGradienBackGround(view: view)
    }

    func translateStaticInterface(){
        mobileLbl.text = "Mobile".localized
        recoverBt.setTitle("RECOVER PASSWORD".localized, for: .normal)
        textLbl.text = "We will send you an sms with a new password".localized
        titleLbl.text = "Forgot Password".localized
    }


    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }


    @IBAction func goBackAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

}
