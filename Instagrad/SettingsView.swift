//
//  SettingsView.swift
//  Instagrad
//
//  Created by David Wale on 05/05/2023.
//

import SwiftUI

struct SettingsView: View {
    
    @AppStorage("saveRecordingsFolder") var saveRecordingsFolder = "/Users/Shared/Recordings"
    
    
    var body: some View {
        VStack{
            Text("Save audio recordings to...")
            HStack{
                Text(saveRecordingsFolder)
                Spacer()
                Button("Change folder..."){
                    saveRecordingsFolder = openFolderPicker() ?? "/Users/Shared/Recordings"
                }
            }
            .frame(minWidth: 350, minHeight: 80)
        }
        .padding(30)
    }
    
    func openFolderPicker() -> String? {
        let dialog = NSOpenPanel()
        dialog.title = "Choose a folder"
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.canChooseDirectories = true
        dialog.canCreateDirectories = true
        dialog.allowsMultipleSelection = false
        dialog.canChooseFiles = false

        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            let result = dialog.url // Pathname of the file
            if (result != nil) {
                return result!.path
            }
        }
        return nil
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
