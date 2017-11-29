//
//  StartVC.swift
//  ClinicsAndDoctors
//
//  Created by Osmely Fernandez on 28/11/17.
//  Copyright © 2017 InfinixSoft. All rights reserved.
//

import UIKit

class StartVC : UIViewController {


    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }

    override func viewDidLoad() {
        super.viewDidLoad()

        UserModel.currentUser = UserModel.loadSession()

        let sname = UserModel.currentUser != nil ? "toMain" : "toLogin"
        self.performSegue(withIdentifier: sname, sender: nil)

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toLogin" {
            if let vc = segue.destination as? ViewController {
                vc.futureVC = "HomeVC"
            }

        }
    }




}
