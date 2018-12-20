//
//  PostsViewController.swift
//  whyIOS
//
//  Created by Jack Knight on 12/19/18.
//  Copyright © 2018 Jack Knight. All rights reserved.
//

import UIKit

class PostsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    //Source of Truth
    var fetchedPosts: [Post] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func refreshPosts() {
        PostController.fetchPosts { (posts) in
            if let posts = posts {
                self.fetchedPosts = posts
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            }
        }
    }
    
    @IBAction func refreshButtonTapped(_ sender: Any) {
        refreshPosts()
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
        presentAlert()
}
    
    @IBAction func editButtonTapped(_ sender: Any) {
        tableView.isEditing = !tableView.isEditing
    }
    
    
    
    // TableView Datasource Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as? PostTableViewCell else { return UITableViewCell()}
        
        let post = fetchedPosts[indexPath.row]
        
        cell.nameLabel.text = post.name
        cell.cohortLabel.text = post.cohort
        cell.reasonLabel.text = post.reason
        
        return cell
    }
    
    
    func presentAlert() {
        
        let alertController = UIAlertController(title: "Add a post", message: nil, preferredStyle: .alert)
        
        var nameTextField = UITextField()
        var cohortTextField = UITextField()
        var reasonTextField = UITextField()
        
        alertController.addTextField { (textfield) in
            nameTextField = textfield
            nameTextField.placeholder = "Enter name here..."
        }
        alertController.addTextField { (textfield) in
            cohortTextField = textfield
            cohortTextField.placeholder = "Enter cohort here..."
        }
        alertController.addTextField { (textfield) in
            reasonTextField = textfield
            reasonTextField.placeholder = "Enter reason here..."
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let postAction = UIAlertAction(title: "Post", style: .default) { (_) in
            guard let name = nameTextField.text, !name.isEmpty,
                let reason = reasonTextField.text, !reason.isEmpty,
                let cohort = cohortTextField.text, !cohort.isEmpty else {return}
            PostController.createPost(name: name, reason: reason, cohort: cohort, completion: { (success) in
                if success {
                    DispatchQueue.main.async {
                        self.refreshPosts()
                    }
                }
            })
        }
        alertController.addAction(postAction)
        self.present(alertController, animated: true)
    }
}
