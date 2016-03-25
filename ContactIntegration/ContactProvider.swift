//
//  ContactProvider.swift
//  ContactIntegration
//
//  Created by Internicola, Eric on 3/25/16.
//  Copyright © 2016 iColasoft. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI

class ContactProvider {
    static let instance = ContactProvider()

    lazy var contactStore = CNContactStore()

}

// MARK: - Public API

extension ContactProvider {

    func addContact(contact: CNMutableContact, viewController: UIViewController) {
        var alert: UIAlertController?

        let calendarAccess = CNContactStore.authorizationStatusForEntityType(CNEntityType.Contacts)

        switch calendarAccess {
        case .Denied, .Restricted:
            alert = alertForState(calendarAccess)

        case .Authorized, .NotDetermined:
            saveContact(contact, viewController: viewController)
        }

        if let alert = alert {
            viewController.presentViewController(alert, animated: true, completion: nil)
        }
    }

    /**
    Creates you a contact that does not have social values populated.
     - Returns: A CNMutableContact that does not have a social profile.
    */
    func createNonSocialContact() -> CNMutableContact {
        let contact = CNMutableContact()
        contact.givenName = "Jonny"
        contact.familyName = "Antisocial"

        contact.emailAddresses.append(CNLabeledValue(label: CNLabelHome, value: "John-Appleseed@mac.com"))
        contact.phoneNumbers.append(CNLabeledValue(label: CNLabelHome, value: CNPhoneNumber(stringValue:"888-555-5512")))
        contact.note = "Non-Social Contact\nImported from ContactIntegration"

        return contact
    }

    /**
     Creates you a contact that has Social values populated.
     - Returns: A CNMutableContact that has a social profile (twitter).
    */
    func createSocialContact() -> CNMutableContact {
        let contact = CNMutableContact()
        contact.givenName = "Jonny"
        contact.familyName = "Social"

        contact.emailAddresses.append(CNLabeledValue(label: CNLabelHome, value: "John-Appleseed@mac.com"))
        contact.phoneNumbers.append(CNLabeledValue(label: CNLabelHome, value: CNPhoneNumber(stringValue:"888-555-5512")))
        contact.note = "Social Contact\nImported from ContactIntegration"

        contact.socialProfiles.append(CNLabeledValue(label: "Twitter", value: CNSocialProfile(urlString: nil, username: "@John_E_Social", userIdentifier: nil, service: CNSocialProfileServiceTwitter)))

        return contact
    }
}

// MARK: - Helper Methods

private extension ContactProvider {

    func saveContact(contact: CNMutableContact, viewController: UIViewController) {
        do {
            let saveRequest = CNSaveRequest()
            saveRequest.addContact(contact, toContainerWithIdentifier: nil)
            try contactStore.executeSaveRequest(saveRequest)
            print("Saved \(contact) to the Address Book")

            let contactVC = CNContactViewController(forContact: contact)
            contactVC.contactStore = contactStore
            contactVC.allowsEditing = true
            contactVC.allowsActions = true

            contactVC.delegate = viewController as? CNContactViewControllerDelegate

            if let navigationController = viewController.navigationController {
                navigationController.pushViewController(contactVC, animated: true)
            } else {
                viewController.presentViewController(contactVC, animated: true, completion: nil)
            }
        } catch let error as NSError {
            let message = "Error saving to address book: \(error.localizedDescription)"
            showErrorAlert(message, parentVC: viewController)
            print(message)
            print(error)
        }
    }

    func alertForState(state: CNAuthorizationStatus) -> UIAlertController? {
        var title: String?
        var message: String?

        switch state {
        case .Denied:
            title = "Address Book - Access Denied"
            message = "You previously denied access to the Address Book.  To enable access, please open Settings."

        case .Restricted:
            title = "Address Book - Access Restricted"
            message = "Your device is restricted from accessing the Address Book"

        default:
            break
        }

        if let title = title, message = message {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Open Settings", style: .Default, handler: { _ in
                guard let settingsURL = NSURL(string: UIApplicationOpenSettingsURLString) else {
                    return
                }
                UIApplication.sharedApplication().openURL(settingsURL)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))

            return alert
        }

        return nil
    }

    func showErrorAlert(message: String, parentVC: UIViewController) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
        parentVC.presentViewController(alert, animated: true, completion: nil)
    }

}
