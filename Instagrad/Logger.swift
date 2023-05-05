//
//  Logger.swift
//  Instagrad
//
//  Created by David Wale on 24/04/2023.
//

import SwiftUI

struct Logger: View{
    
//    @Environment(\.managedObjectContext) var moc
//    @FetchRequest(sortDescriptors: []) var ceremonies: FetchedResults<Ceremony>
//    @FetchRequest(sortDescriptors: [SortDescriptor(\.order)]) var students: FetchedResults<Student>
    @Binding var selectedCeremony: Ceremony?
    @AppStorage("saveRecordingsFolder") var saveRecordingsFolder = "/Users/Shared/Recordings"
    
    var body: some View {
        if selectedCeremony?.name == nil{
            Text("Please select a ceremony")
        } else {
            
            FilteredList(filter: (selectedCeremony?.code ?? "Unknown"), rootPath: saveRecordingsFolder, fileName: ((selectedCeremony?.code ?? "Unknown") + ".m4a"))
            
        }
    }
}

//struct Logger_Previews: PreviewProvider {
//    static var previews: some View {
//        Logger(selectedCeremony: "Not known")
//    }
//}
