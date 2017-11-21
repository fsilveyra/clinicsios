//
//  RegisterVC.swift
//  ClinicsAndDoctors
//
//  Created by Reinier Isalgue on 30/09/17.
//  Copyright © 2017 InfinixSoft. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import TPKeyboardAvoiding
import PromiseKit
import SwiftMessages
import MapKit

class RegisterVC: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var plussImage: UIButton!
    @IBOutlet weak var registerBt: UIButton!
    @IBOutlet weak var full_nameTf: UITextField!
    @IBOutlet weak var phone_numberTf: UITextField!
    @IBOutlet weak var emailTf: UITextField!
    @IBOutlet weak var passwordTf: UITextField!
    @IBOutlet weak var passwordCheckTf: UITextField!
    @IBOutlet weak var viewRegister:UIStackView!

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var fullNameLbl: UILabel!
    @IBOutlet weak var mobileLbl: UILabel!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var passwordLbl: UILabel!
    @IBOutlet weak var retypePasswordLbl: UILabel!


    let imagePicker = UIImagePickerController()
    var imagePlayer = UIImage()
    let loading = ActivityData()
    var futureVC = ""
    var futureClinicId:String?
    var futureDoctorId:String?

    @IBOutlet weak var keyboard:TPKeyboardAvoidingScrollView!

    // MARK: - Actions
    @IBAction func BackView(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func SelectAvatar(_ sender: Any) {

        if isCameraAvailable() {
            let alert = UIAlertController(title: "Picture", message: "Select the source of your picture".localized, preferredStyle: .alert)
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
    
    @IBAction func Register(_ sender: Any) {
        passwordTf.resignFirstResponder()
        if passwordTf.text=="" || full_nameTf.text=="" || passwordCheckTf.text=="" || phone_numberTf.text==""{
            viewRegister.layer.shake(duration: TimeInterval(0.7))
            self.SwiftMessageAlert(layout: .cardView, theme: .error, title: "", body: "Complete all blank fields".localized)
        }
        else if !(emailTf.text?.isEmpty)! && !isValidEmail(testStr: emailTf.text!){
            self.emailTf.textColor = .red
            self.SwiftMessageAlert(layout: .cardView, theme: .error, title: "", body: "Wrong Email format".localized)
        }
        else if !isValidPhone(testStr: phone_numberTf.text!){
            //self.phone_numberTf.textColor = .red
            self.SwiftMessageAlert(layout: .cardView, theme: .error, title: "", body: "Wrong Movile, it should only be between 6 and 14 numbers".localized)
        }
        else if passwordTf.text != passwordCheckTf.text{
            self.SwiftMessageAlert(layout: .cardView, theme: .error, title: "", body: "The password and Re-Type Password are not same, please check".localized)
            self.passwordCheckTf.textColor = .yellow
        }
        else{

            NVActivityIndicatorPresenter.sharedInstance.startAnimating(loading)

            ISClient.sharedInstance.registerWhitEmail(fullName: full_nameTf.text!, phone_number: phone_numberTf.text!, email: emailTf.text!, password: passwordTf.text!, picture: avatarImage.image!)

                .then {[weak self] user in
                    self?.loadClinics(radius: UserModel.radiusLocationMeters)

                }.then {[weak self] clinics in
                    self?.loadDoctors(specialityId:nil, clinicId: nil)

                }.then {[weak self] docs -> Void in

                    self?.SwiftMessageAlert(layout: .cardView, theme: .success, title: "", body: "Successful registration".localized)

                    self?.registerSuccess()

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

    func registerSuccess(){
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {[weak self] in
            if let nav = self?.navigationController{
                let c = nav.viewControllers.count
                if let fvc = self?.futureVC, fvc.isEmpty == false {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: fvc)

                    if let vcRating = vc as? RatingVC {
                        vcRating.clinicId = self?.futureClinicId
                        vcRating.doctorId = self?.futureDoctorId
                    }

                    
                    let c = nav.viewControllers.count
                    nav.viewControllers.insert(vc, at: c - 2)
                    nav.popToViewController(vc, animated: true)
                }else{
                    let backVC = nav.viewControllers[c - 3]
                    nav.popToViewController(backVC, animated: true)
                }
            }
        })
    }


    //MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()
        CreateGradienBackGround(view: view)

        avatarImage.layer.cornerRadius = avatarImage.frame.width / 2
        plussImage.layer.cornerRadius = plussImage.frame.width / 2

        imagePicker.allowsEditing = true
        imagePicker.delegate = self

    }

    func translateStaticInterface(){
        titleLbl.text = "Register".localized
        registerBt.setTitle("REGISTER".localized, for: .normal)
        fullNameLbl.text = "Full Name".localized
        mobileLbl.text = "Mobile".localized
        emailLbl.text = "Email (optional)".localized
        passwordLbl.text = "Password".localized
        retypePasswordLbl.text = "Re-Type Password".localized

    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
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
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.textColor = .white
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.textColor = .white
    }

    func HideKeyboard(){
        full_nameTf.resignFirstResponder()
        emailTf.resignFirstResponder()
        passwordTf.resignFirstResponder()
        passwordCheckTf.resignFirstResponder()
        phone_numberTf.resignFirstResponder()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTage=textField.tag+1;

        let nextResponder=keyboard.viewWithTag(nextTage) as UIResponder!

        if (nextResponder != nil){
            nextResponder?.becomeFirstResponder()
        }
        else
        {
            // Not found, so remove keyboard
            textField.resignFirstResponder()
        }
        return false
    }


    // MARK: - ImagePicker
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
        avatarImage.image = selectedImage
        avatarImage.contentMode = .scaleAspectFit
        imagePlayer = selectedImage
        //self.ShowSourceImageView()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func goBackAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

}




extension RegisterVC {

    func loadClinics(radius: Int, specialityId: String? = nil) -> Promise<Void>{

        let location = UserModel.mylocation ?? CLLocation(latitude: 0, longitude: 0)

        return ISClient.sharedInstance.getClinics(latitude: location.coordinate.latitude,
                                                  longitude: location.coordinate.longitude,
                                                  radius: radius,
                                                  specialty_id: specialityId)
            .then { clist -> Void in
                ClinicModel.clinics = clist
        }
    }

    func loadDoctors(specialityId: String?, clinicId:String?) -> Promise<Void>{
        return ISClient.sharedInstance.getDoctors(specialty_id: specialityId, clinic_id:clinicId)
            .then { doctors -> Void in
                DoctorModel.doctors = doctors
        }
    }

}
