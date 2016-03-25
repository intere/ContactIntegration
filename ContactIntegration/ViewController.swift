//
//  ViewController.swift
//  ContactIntegration
//
//  Created by Internicola, Eric on 3/25/16.
//  Copyright © 2016 iColasoft. All rights reserved.
//

import UIKit
import Contacts

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    var nonSocialContact: CNMutableContact {
        return ContactProvider.instance.createNonSocialContact()
    }

    var socialContact: CNMutableContact {
        return ContactProvider.instance.createSocialContact()
    }
}

// MARK: - IBActions

extension ViewController {

    @IBAction func clickedNonSocial(sender: UIButton) {
        ContactProvider.instance.addContact(nonSocialContact, viewController: self)
    }

    @IBAction func clickedSocial(sender: UIButton) {
        ContactProvider.instance.addContact(socialContact, viewController: self)
    }


}
