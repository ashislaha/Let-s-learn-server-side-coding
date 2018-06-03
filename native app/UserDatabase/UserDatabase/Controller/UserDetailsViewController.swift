//
//  UserDetailsViewController.swift
//  UserDatabase
//
//  Created by Ashis Laha on 5/20/18.
//  Copyright © 2018 Ashis Laha. All rights reserved.
//

import UIKit

enum Mode {
    case add
    case update
    case none
}

class UserDetailsViewController: UIViewController {

    @IBOutlet private weak var firstNameTextField: UITextField!
    @IBOutlet private weak var lastNameTextField: UITextField!
    @IBOutlet private weak var addressTextField: UITextField!
    @IBOutlet private weak var saveOutlet: UIBarButtonItem!
    var mode: Mode = .none
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUI()
        fillUserDetailsIfNeeded()
    }
    
    private func updateUI() {
        switch mode {
        case .add:
            saveOutlet.title = "Add"
            title = "New User"
        case .update:
            saveOutlet.title = "Update"
            title = "Update User data"
        default:
            saveOutlet.title = "Dismiss"
        }
    }
    
    private func fillUserDetailsIfNeeded() {
        switch mode {
        case .update:
            firstNameTextField.text = user?.firstName
            lastNameTextField.text = user?.lastName
            addressTextField.text = user?.address
        default: break
        }
    }
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        switch mode {
        case .add: addUserServiceCall()
        case .update: updateUserServiceCall()
        default: break
        }
    }
    private func addUserServiceCall() {
        guard let firstName = firstNameTextField.text, let lastName = lastNameTextField.text, !firstName.isEmpty, !lastName.isEmpty else { return }
        let params = ["first_name": firstName, "last_name": lastName, "address": addressTextField.text ?? "NA"]
        do {
            try NetworkHandler.postCall(operation: .add, params: params) { [weak self] (dict) in
                if let status = dict["success"] as? Bool, status {
                    self?.showAlert(header: "A User has been added successfully", message: "😎", completionHandler: {
                        self?.navigationController?.popViewController(animated: true)
                    })
                } else {
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    private func updateUserServiceCall() {
        guard let firstName = firstNameTextField.text, let lastName = lastNameTextField.text, !firstName.isEmpty, !lastName.isEmpty, let id = user?.id else { return }
        let params: [String: Any] = ["first_name": firstName, "last_name": lastName, "id": id, "address": addressTextField.text ?? "NA"]
        do {
            try NetworkHandler.postCall(operation: .update, params: params) { [weak self] (dict) in
                if let status = dict["success"] as? Bool, status {
                    self?.showAlert(header: "User record updated successfully", message: "😁", completionHandler: {
                         self?.navigationController?.popViewController(animated: true)
                    })
                } else {
                     self?.navigationController?.popViewController(animated: true)
                }
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }
}

extension UIViewController {
    func showAlert(header : String? = "Header", message : String? = "Message", completionHandler: (()->())? = nil )  {
        let alertController = UIAlertController(title: header, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Okay", style: .default) { (_) in
            completionHandler?()
        }
        alertController.addAction(okAction)
        DispatchQueue.main.async { [weak self] in
            if let strongSelf = self {
                strongSelf.present(alertController, animated: true, completion: nil)
            }
        }
    }
}
