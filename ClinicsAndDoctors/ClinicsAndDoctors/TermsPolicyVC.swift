//
//  TermsPolicyVC.swift
//  ClinicsAndDoctors
//
//  Created by Osmely Fernandez on 5/11/17.
//  Copyright © 2017 InfinixSoft. All rights reserved.
//

import Foundation
import UIKit
import NVActivityIndicatorView


class TermsPolicyVC: UIViewController {


    @IBOutlet weak var textView:UITextView!

    var isTerms = true

    func translateStaticInterface(){


    }

    override func viewDidLoad() {
        super.viewDidLoad()
        translateStaticInterface()

        self.navigationItem.title = isTerms ? "Terms Of Use".localized : "Privacy Policy".localized
        self.navigationItem.leftBarButtonItem?.title = "Back".localized
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        NVActivityIndicatorPresenter.sharedInstance.startAnimating(loading)

        ISClient.sharedInstance.getTermsOrPrivacy(endPoint: isTerms ? "get_terms_of_use" : "get_privacy_policy")
            .then { data -> Void in
                self.textView.text = data

            }.always {
                NVActivityIndicatorPresenter.sharedInstance.stopAnimating()

            }.catch { error in
                if let e: LPError = error as? LPError { e.show() }

            }

    }

}
