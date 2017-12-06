//
//  ProfileVC.swift
//  ClinicsAndDoctors
//
//  Created by Reinier Isalgue on 04/10/17.
//  Copyright © 2017 InfinixSoft. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import TPKeyboardAvoiding
import PromiseKit
import SwiftMessages
import FBSDKLoginKit

class ProfileVC: UIViewController , UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate {
    @IBOutlet weak var avatarIm:RoundedImageView!
    @IBOutlet weak var nameTf:UITextField!
    @IBOutlet weak var mobileTf:UITextField!
    @IBOutlet weak var emailTf:UITextField!
    @IBOutlet weak var changePasswordBt:UIButton!
    @IBOutlet weak var plusPhotoBtn: UIButton!
    @IBOutlet weak var scroll: TPKeyboardAvoidingScrollView!
    @IBOutlet weak var viewPlusBtn: UIView!
    @IBOutlet weak var fullNameLbl: UILabel!
    @IBOutlet weak var mobileLbl: UILabel!
    @IBOutlet weak var emailLbl: UILabel!

    let imagePicker = UIImagePickerController()

    var enableToEdit: Bool = false {
        didSet{
            nameTf.isEnabled = enableToEdit
            mobileTf.isEnabled = enableToEdit
            emailTf.isEnabled = enableToEdit
            viewPlusBtn.isHidden = !enableToEdit

            let fblogged = (FBSDKAccessToken.current() != nil)

            changePasswordBt.isHidden = (fblogged || enableToEdit == false)
        }
    }

    func translateStaticInterface(){
        self.navigationItem.title = "PROFILE".localized
        fullNameLbl.text = "Full Name".localized
        mobileLbl.text = "Mobile".localized
        emailLbl.text = "Email".localized
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        translateStaticInterface()

        CreateGradienBackGround(view: self.view)
        self.navigationController?.navigationBar.isHidden = false
        avatarIm.layer.cornerRadius = avatarIm.frame.width/2

        self.configureChangePasswordBtn()

        imagePicker.allowsEditing = true
        imagePicker.delegate = self

        self.loadUserData()

        if #available(iOS 11.0, *) {
            scroll.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        scroll.contentInset = UIEdgeInsetsMake(0,0,0,0);

        self.enableToEdit = false
    }

    func loadUserData(){
        self.emailTf.delegate = self
        self.mobileTf.delegate = self
        self.nameTf.delegate = self

        guard let user = UserModel.currentUser else { return }

        self.nameTf.text = user.full_name
        self.mobileTf.text = user.phone_number
        self.emailTf.text = user.email
        if let url = URL(string: user.profile_picture) {
            self.avatarIm.url = url
        }
    }

    func configureChangePasswordBtn(){
        let attribRegBut : [NSAttributedStringKey: Any] = [
            NSAttributedStringKey(rawValue: NSAttributedStringKey.font.rawValue) : UIFont.systemFont(ofSize: 15),
            NSAttributedStringKey(rawValue: NSAttributedStringKey.foregroundColor.rawValue) : UIColor.white,
            NSAttributedStringKey(rawValue: NSAttributedStringKey.underlineStyle.rawValue) : NSUnderlineStyle.styleSingle.rawValue]
        let attributeString = NSMutableAttributedString(string: "Change Password".localized,
                                                        attributes: attribRegBut)
        changePasswordBt.setAttributedTitle(attributeString, for: .normal)
    }

    @IBAction func BackView(_ sender: AnyObject){
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func EditFields(_ sender: AnyObject){

        if self.enableToEdit == false {
            self.enableToEdit = true
            self.navigationItem.rightBarButtonItem?.image = #imageLiteral(resourceName: "ok-green-icon")
        }else{

            send()

        }
    }

    func editSuccess(){
        self.enableToEdit = false
        self.navigationItem.rightBarButtonItem?.image = #imageLiteral(resourceName: "icon_edit")
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.emailTf.textColor = .white
        self.mobileTf.textColor = .white
        self.nameTf.textColor = .white
    }

    func send(){

        self.view.endEditing(true)

        if !(emailTf.text?.isEmpty)! && !isValidEmail(testStr: emailTf.text!){
            self.emailTf.textColor = .red
            self.SwiftMessageAlert(layout: .cardView, theme: .error, title: "", body: "Incorrect Email format".localized)
        }
        else if !isValidPhone(testStr: mobileTf.text!){
            self.mobileTf.textColor = .red
            self.SwiftMessageAlert(layout: .cardView, theme: .error, title: "", body: "Wrong Mobile, it should only be between 6 and 14 numbers".localized)
        }
        else if nameTf.text == nil || nameTf.text!.isEmpty {
            self.nameTf.textColor = .red
            self.SwiftMessageAlert(layout: .cardView, theme: .error, title: "", body: "The Name can not be empty".localized)
        }
        else{

            let user = UserModel.currentUser!

            NVActivityIndicatorPresenter.sharedInstance.startAnimating(loading)

            ISClient.sharedInstance.editProfile(user_id: "\(user.id!)",
                                                fullName: nameTf.text,
                                                phone_number: mobileTf.text,
                                                email: emailTf.text,
                                                password: user.password,
                                                picture: avatarIm.image ?? nil)
                .then {[weak self] user -> Void in

                    self?.SwiftMessageAlert(layout: .cardView, theme: .success, title: "", body: "Successful profile editing".localized)

                    self?.editSuccess()

                }.always {
                    NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
                    self.view.endEditing(true)

                }.catch { error in
                    if let e: LPError = error as? LPError {
                        e.show()
                    }
                }

        }
    }


    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }

    func isValidPhone(testStr:String) -> Bool {
        //let phoneRegEx = "^((\\+)|(00))[0-9]{6,14}$"
        let phoneRegEx = "^[0-9]{6,14}$"
        let phoneTest = NSPredicate(format:"SELF MATCHES %@", phoneRegEx)
        let result = phoneTest.evaluate(with: testStr)
        return result
    }


    @IBAction func changePaswordAction(_ sender: Any) {
        presentPasswordAlert()
    }


}


//=============================================
// MARK: - Password change
//=============================================

extension ProfileVC {

    func validateDataPassword(_ current:String, _ newPass:String, _ retype:String) -> Bool{

        let currentPass = UserModel.currentUser!.password
        if current != currentPass{
            self.SwiftMessageAlert(layout: .cardView, theme: .error, title: "", body: "The current password not match".localized)
            return false
        }

        if newPass != retype{
            self.SwiftMessageAlert(layout: .cardView, theme: .error, title: "", body: "The new password and Re-Type Password are not same, please check".localized)
            return false
        }

        return true
    }

    func presentPasswordAlert() {
        let alertController = UIAlertController(title: "Change Password".localized, message: "Please input your current and new password:".localized, preferredStyle: .alert)

        let confirmAction = UIAlertAction(title: "Confirm".localized, style: .default) {[weak self] (_) in
            if let field1 = alertController.textFields?[0].text, !field1.isEmpty,
                let field2 = alertController.textFields?[1].text, !field2.isEmpty,
                let field3 = alertController.textFields?[2].text, !field3.isEmpty
            {
                if (self?.validateDataPassword(field1, field2, field3))!{

                    let user = UserModel.currentUser!

                    NVActivityIndicatorPresenter.sharedInstance.startAnimating(loading)
                    ISClient.sharedInstance.editProfile(user_id: "\(user.id!)",
                        fullName: nil,
                        phone_number: nil,
                        email: nil,
                        password: field2,
                        picture: nil)
                        .then {[weak self] user -> Void in
                            self?.SwiftMessageAlert(layout: .cardView, theme: .success, title: "", body: "Password changed successful".localized)
                        }.always {
                            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
                        }.catch { error in
                            if let e: LPError = error as? LPError {
                                e.show()
                            }
                    }
                }

            } else {
                self?.SwiftMessageAlert(layout: .cardView, theme: .error, title: "", body: "Complete all blank fields".localized)

            }
        }

        let cancelAction = UIAlertAction(title: "Cancel".localized, style: .cancel) { (_) in }

        alertController.addTextField { (textField) in
            textField.placeholder = "Current password".localized
        }
        alertController.addTextField { (textField) in
            textField.placeholder = "New password".localized
        }
        alertController.addTextField { (textField) in
            textField.placeholder = "Re-type the new password".localized
        }


        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)

        self.present(alertController, animated: true, completion: nil)
    }
}


//=============================================
// MARK: - ImagePicker
//=============================================

extension ProfileVC {

    @IBAction func SelectAvatar(_ sender: Any) {

        if isCameraAvailable() {
            let alert = UIAlertController(title: "Picture".localized, message: "Select the source of your picture".localized, preferredStyle: .alert)
            let cameraSource = UIAlertAction(title: "From Camera".localized, style: .default) { _ in
                self.shootPhoto()
            }
            let galery = UIAlertAction(title: "From Galery".localized, style: .default) { _ in
                self.photoFromLibrary()
            }

            alert.addAction(cameraSource)
            alert.addAction(galery)
            present(alert, animated: true, completion: nil)

        }else{
            self.photoFromLibrary()
        }
    }

    func photoFromLibrary() {
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        imagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        imagePicker.modalPresentationStyle = .popover
        present(imagePicker, animated: true, completion: nil)
    }

    func shootPhoto() {
        if isCameraAvailable() {
            imagePicker.allowsEditing = true
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.cameraCaptureMode = .photo
            imagePicker.modalPresentationStyle = .fullScreen
            present(imagePicker,animated: true,completion: nil)
        }
    }

    func isPhotoAlbumAvailable() -> Bool {
        return UIImagePickerController.isSourceTypeAvailable(.photoLibrary)
    }

    func isCameraAvailable() -> Bool{
        return UIImagePickerController.isSourceTypeAvailable(.camera)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedImage = UIImage()
        selectedImage = info[UIImagePickerControllerEditedImage] as! UIImage
        avatarIm.image = selectedImage
        self.dismiss(animated: true, completion: nil)
    }

}

