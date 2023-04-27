//
//  DataController.swift
//  Instagrad
//
//  Created by David Wale on 24/04/2023.
//

import CoreData
import Foundation

class DataController: ObservableObject {
    let container  = NSPersistentContainer(name: "Instagrad")
    
    init() {
        container.loadPersistentStores {description, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            }
        }
    }
}
