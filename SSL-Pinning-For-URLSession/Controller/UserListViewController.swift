//
//  UserListViewController.swift
//  SSL-Pinning-For-URLSession
//
//  Created by Mac on 30/09/21.
//

import UIKit

class UserListViewController: UIViewController {
    @IBOutlet weak var usersTableView: UITableView!
    var viewModel: UsersViewModel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Initialization
        viewModel = UsersViewModel()
        // Make Request to Server
        viewModel.getUserList()
        // Response Received From Server
        viewModel.userListCompletion = userListCompletion
    }
    
    private func userListCompletion(_ error: Error?) {
        if let error = error {
            DispatchQueue.main.async {[weak self] in
                self?.present(error)
            }
            return
        }
        DispatchQueue.main.async {[weak self] in
            self?.usersTableView.reloadData()
        }
    }
}

extension UserListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.users?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let users = viewModel.users {
            let cell = UITableViewCell()
            cell.textLabel?.text = users[indexPath.row].name
            return cell
        }else{
            return UITableViewCell()
        }
    }
}
