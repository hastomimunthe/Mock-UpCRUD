//
//  UserPresenter.swift
//  CRUDPelindo_Test
//
//  Created by Hastomi Riduan Munthe on 25/07/23.
//

import UIKit
import CoreData

protocol UserPresenterDelegate: AnyObject {
    func reloadData()
}

class UserPresenter {
    weak var delegate: UserPresenterDelegate?
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var data: [User]?
    
    func fetchData() {
        do {
            self.data = try context.fetch(User.fetchRequest())
            delegate?.reloadData()
        } catch {
            print("Failed to fetch: \(error)")
        }
    }
    
    func addUser(with userIdText: String, userNameText: String, fullNameText: String, passwordText: String, statusText: String) {
        guard let userId = Int64(userIdText) else {
            return
        }
        
        let newUser = User(context: context)
        newUser.userid = userId
        newUser.username = userNameText
        newUser.namalengkap = fullNameText
        newUser.password = passwordText
        newUser.status = statusText
        
        do {
            try context.save()
        } catch {
            print("Failed to save: \(error)")
        }
        
        fetchData()
    }
    
    func updateUser(at indexPath: IndexPath, with userNameText: String, fullNameText: String, passwordText: String, statusText: String) {
        guard let user = data?[indexPath.row] else {
            return
        }
        
        user.username = userNameText
        user.namalengkap = fullNameText
        user.password = passwordText
        user.status = statusText
        
        do {
            try context.save()
        } catch {
            print("Failed to save: \(error)")
        }
        
        fetchData()
    }
    
    func deleteUser(at indexPath: IndexPath) {
        guard let userRemove = data?[indexPath.row] else {
            return
        }
        
        context.delete(userRemove)
        
        do {
            try context.save()
        } catch {
            print("Failed to save")
        }
        
        fetchData()
    }
}
