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
        viewModel.blogPostDetailsCompletion = blogPostDetailsCompletion
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
    
    func blogPostDetailsCompletion(_ error: Error?) {
        if let error = error {
            DispatchQueue.main.async {[weak self] in
                self?.present(error)
            }
            return
        }
        DispatchQueue.main.async {[weak self] in
            guard let details = self?.viewModel.details else { return }
            self?.presentAlert(with: "Hello \(details.title)!\nPost is \(details.body)")
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

extension UserListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let user = viewModel.users?[indexPath.row] else { return }
        let params: [String: Any] = ["title" : user.name,
                                     "body": "Apple Developer \(indexPath.row)",
                                     "userId": "\(indexPath.row)"]
        viewModel.getBlogPostDeails(params: params)
    }
}
