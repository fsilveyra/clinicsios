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
import TPKeyboardAvoiding

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
    
    let imagePicker = UIImagePickerController()
    var imagePlayer = UIImage()
    let loading = ActivityData()
    @IBOutlet weak var keyboard:TPKeyboardAvoidingScrollView!

    // MARK: - Actions
    @IBAction func BackView(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func SelectAvatar(_ sender: Any) {
        let alert = UIAlertController.init(title: "Picture", message: "Select the source of your picture", preferredStyle: .alert)
        let cameraSource = UIAlertAction.init(title: "From Camera", style: .default) { _ in
            self.shootPhoto()
        }
        let galery = UIAlertAction.init(title: "From Galery", style: .default) { _ in
            self.photoFromLibrary()
        }
        
        alert.addAction(cameraSource)
        alert.addAction(galery)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func Register(_ sender: Any) {
        passwordTf.resignFirstResponder()
        if passwordTf.text=="" || full_nameTf.text=="" || passwordCheckTf.text=="" || phone_numberTf.text==""{
            viewRegister.layer.shake(duration: TimeInterval(0.7))
            self.SwiftMessageAlert(layout: .CardView, theme: .error, title: "", body: "Complete all blank fields")
        }
        else if !(emailTf.text?.isEmpty)! && !isValidEmail(testStr: emailTf.text!){
            self.emailTf.textColor = .red
            self.SwiftMessageAlert(layout: .CardView, theme: .error, title: "", body: "Incorrect Email, the correct format is email@email.com")
            print("Incorrect email")
            
        }
        else if !isValidPhone(testStr: phone_numberTf.text!){
            //self.phone_numberTf.textColor = .red
            self.SwiftMessageAlert(layout: .CardView, theme: .error, title: "", body: "Wrong Movile, it should only be between 6 and 14 numbers")
            print("Incorrect Phone")

        }
        else if passwordTf.text != passwordCheckTf.text{
            self.SwiftMessageAlert(layout: .CardView, theme: .error, title: "", body: "The password and Re-Type Password are not same, please check")
            self.passwordCheckTf.textColor = .yellow
        }
        else{
            NVActivityIndicatorPresenter.sharedInstance.startAnimating(loading)
            ISClient.sharedInstance.RegisterWhitEmail(fullName: full_nameTf.text!, phone_number: phone_numberTf.text!, email: emailTf.text!, password: passwordTf.text!, picture: avatarImage.image!) { (register, error) in
                if register! {
                    NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
                    self.SwiftMessageAlert(layout: .CardView, theme: .success, title: "", body: "Register Success.")
                    self.performSegue(withIdentifier: "goLoginMobile", sender: nil)
                }
                else {
                    self.HideKeyboard()
                    NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
                    self.SwiftMessageAlert(layout: .CardView, theme: .error, title: "", body: error!)
                }
            }
        }
    }
    //MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()
        CreateGradienBackGround(view: view)
        //self.navigationController?.navigationBar.isHidden = false
        avatarImage.layer.cornerRadius = avatarImage.frame.width/2
        plussImage.layer.cornerRadius = plussImage.frame.width/2
        registerBt.layer.cornerRadius = 5
        
        imagePicker.allowsEditing = true;
        imagePicker.delegate = self
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

       // return !testStr.isEmpty

        print("validating phone: \(testStr)")
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
        //imagePicker.popoverPresentationController?.barButtonItem = sender
    }
    
    func shootPhoto() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.allowsEditing = true
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.cameraCaptureMode = .photo
            imagePicker.modalPresentationStyle = .fullScreen
            present(imagePicker,animated: true,completion: nil)
        } else {
            noCamera()
        }
    }
    func noCamera(){
        let alertVC = UIAlertController(
            title: "No Camera",
            message: "Sorry, this device has no camera",
            preferredStyle: .alert)
        let okAction = UIAlertAction(
            title: "OK",
            style:.default,
            handler: nil)
        alertVC.addAction(okAction)
        present(
            alertVC,
            animated: true,
            completion: nil)
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
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! LoginWithEmailVC
        vc.phone = phone_numberTf.text!
        vc.password = passwordTf.text!
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
