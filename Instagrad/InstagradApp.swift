//
//  InstagradApp.swift
//  Instagrad
//
//  Created by David Wale on 24/04/2023.
//

import SwiftUI

@main
struct InstagradApp: App {
    
    @StateObject private var dataController = DataController()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
        }
    }
}
