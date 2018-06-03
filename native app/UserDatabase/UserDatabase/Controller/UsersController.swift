//
//  ViewController.swift
//  UserDatabase
//
//  Created by Ashis Laha on 5/20/18.
//  Copyright © 2018 Ashis Laha. All rights reserved.
//

import UIKit

class UsersViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView!
    var users: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Users"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         getUsers()
    }
    
    private func getUsers() {
        do {
            try NetworkHandler.getUsers { [weak self] (users) in
                self?.users = users
                self?.tableView.reloadData()
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    @IBAction func addUser(_ sender: UIBarButtonItem) {
        initialiseUserDetailsPage(mode: .add)
    }
    
    private func initialiseUserDetailsPage(mode: Mode, userId: Int = -1) {
        guard let navController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UserDetails") as? UINavigationController,
            let userDetailVC = navController.visibleViewController as? UserDetailsViewController else { return }
        userDetailVC.mode = mode
        switch mode {
        case .update: // call a network to retrive the user infomation
            do {
                try NetworkHandler.getUsersById(userId) { [weak self] (user) in
                    userDetailVC.user = user
                    self?.navigationController?.pushViewController(userDetailVC, animated: true)
                    return
                }
            } catch let error {
                print(error.localizedDescription)
            }
        default: navigationController?.pushViewController(userDetailVC, animated: true)
        }
    }
}

extension UsersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") else { return UITableViewCell() }
        cell.textLabel?.text = users[indexPath.row].firstName + " " + users[indexPath.row].lastName
        return cell
    }
}

extension UsersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let userId = users[indexPath.row].id
        initialiseUserDetailsPage(mode: .update, userId: userId)
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let userId = users[indexPath.row].id
            let params: [String: Any] = ["id": userId]
            do {
                try NetworkHandler.postCall(operation: .delete, params: params, completionHandler: { (dict) in
                    if let _ = dict["success"] {
                        try? NetworkHandler.getUsers(completionHandler: { [weak self] (users) in
                            self?.users = users
                            self?.tableView.reloadData()
                        })
                    }
                })
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
}

