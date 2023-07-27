//
//  ViewController.swift
//  CRUDPelindo_Test
//
//  Created by Hastomi Riduan Munthe on 25/07/23.
//

import UIKit
import CoreData

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    private let userPresenter = UserPresenter()
    private var alert: UIAlertController?
    private var selectedStatus: String = ""
    private var statusTextField: UITextField?
    private var statusPicker = ["Active", "Inactive"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "USER DATA"
        tableView.delegate = self
        tableView.dataSource = self
        
        userPresenter.delegate = self
        userPresenter.fetchData()
        setupButton()
    }
    
    func setupButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(onClickButtonAdd))
    }
    
    @objc func onClickButtonAdd() {
        selectedStatus = ""
        addUser()
    }
    
    func addUser() {
        
        let alert = UIAlertController(title: "Add New User", message: "Please fullfill your data carefully!", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "User ID (number)"
        }
        alert.addTextField { textField in
            textField.placeholder = "Username"
        }
        alert.addTextField { textField in
            textField.placeholder = "Full Name"
        }
        alert.addTextField { textField in
            textField.placeholder = "Password"
            textField.isSecureTextEntry = true
        }
        alert.addTextField { textField in
            textField.placeholder = "Status (Active/Inactive)"
            textField.text = self.selectedStatus
            self.statusTextField = textField
        }
        
        let statusPicker = UIPickerView()
        statusPicker.delegate = self
        statusPicker.dataSource = self
        alert.textFields?[4].inputView = statusPicker
        
        let submitButton = UIAlertAction(title: "Submit", style: .default) { [weak self ] (action) in
            guard let self = self,
                  let userIdText = alert.textFields?[0].text,
                  let userNameText = alert.textFields?[1].text,
                  let fullNameText = alert.textFields?[2].text,
                  let passwordText = alert.textFields?[3].text else {
                return
            }
            
            guard Int64(userIdText) != nil else {
                let errorAlert = UIAlertController(title: "Invalid User ID", message: "User ID must be a number!", preferredStyle: .alert)
                let dismissAction = UIAlertAction(title: "OK", style: .cancel) { _ in
                    self.addUser()
                }
                errorAlert.addAction(dismissAction)
                self.present(errorAlert, animated: true, completion: nil)
                return
            }
            
            guard !userNameText.isEmpty, !fullNameText.isEmpty, !passwordText.isEmpty, !self.selectedStatus.isEmpty else {
                let errorAlert = UIAlertController(title: "Incomplete Data", message: "Please fill in all the required fields.", preferredStyle: .alert)
                let dismissAction = UIAlertAction(title: "OK", style: .cancel) { _ in
                    self.addUser()
                }
                errorAlert.addAction(dismissAction)
                self.present(errorAlert, animated: true, completion: nil)
                return
            }
            
            let newUser = User(context: self.userPresenter.context)
            newUser.userid = Int64(userIdText) ?? 0
            newUser.username = userNameText
            newUser.namalengkap = fullNameText
            newUser.password = passwordText
            newUser.status = self.selectedStatus
            
            do {
                try self.userPresenter.context.save()
            }
            catch {
                print("Failed to save: \(error)")
            }
            self.fetchData()
            
        }
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        cancelButton.setValue(UIColor.red, forKey: "titleTextColor")
        
        alert.addAction(submitButton)
        alert.addAction(cancelButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return statusPicker.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return statusPicker[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedStatus = statusPicker[row]
        statusTextField?.text = selectedStatus
    }
    
    func fetchData() {
        do {
            self.userPresenter.data = try userPresenter.context.fetch(User.fetchRequest())
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        catch {
            print("failed to fetch: \(error)")
        }
    }
    
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userPresenter.data?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath)
        let user = self.userPresenter.data![indexPath.row]
        cell.textLabel?.text = "\(user.userid)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = self.userPresenter.data![indexPath.row]
        let editAlert = UIAlertController(title: "Edit User", message: "Please Click the row to edit user details", preferredStyle: .alert)
        editAlert.addTextField { textField in
            textField.placeholder = "User ID"
            textField.text = "\(user.userid)"
            textField.isEnabled = false
        }
        editAlert.addTextField { textField in
            textField.placeholder = "Username"
            textField.text = user.username
        }
        editAlert.addTextField { textField in
            textField.placeholder = "Full Name"
            textField.text = user.namalengkap
        }
        editAlert.addTextField { textField in
            textField.placeholder = "Password"
            textField.text = user.password
        }
        editAlert.addTextField { textField in
            textField.placeholder = "Status"
            textField.text = user.status
            self.statusTextField = textField
            
        }
        
        let statusPicker = UIPickerView()
        statusPicker.delegate = self
        statusPicker.dataSource = self
        editAlert.textFields?[4].inputView = statusPicker
        
        let saveButton = UIAlertAction(title: "Save", style: .default) { [weak self] action in
            guard let self = self,
                  let userNameText = editAlert.textFields?[1].text,
                  let fullNameText = editAlert.textFields?[2].text,
                  let passwordText = editAlert.textFields?[3].text,
                  let statusText = editAlert.textFields?[4].text else {
                return
            }
            
            user.username = userNameText
            user.namalengkap = fullNameText
            user.password = passwordText
            user.status = statusText
            
            do {
                try self.userPresenter.context.save()
            }
            catch {
                print("failed to save: \(error)")
            }
            self.fetchData()
            
        }
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        cancelButton.setValue(UIColor.red, forKey: "titleTextColor")
        editAlert.addAction(saveButton)
        editAlert.addAction(cancelButton)
        self.present(editAlert, animated: true, completion: nil)
        
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
            let userRemove = self.userPresenter.data![indexPath.row]
            self.userPresenter.context.delete(userRemove)
            
            do {
                try self.userPresenter.context.save()
            }
            catch {
                print("failed to save: \(error)")
            }
            self.fetchData()
        }
        return UISwipeActionsConfiguration(actions: [action])
    }
}

extension ViewController: UserPresenterDelegate {
    func reloadData() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
