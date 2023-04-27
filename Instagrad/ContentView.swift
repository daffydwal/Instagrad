//
//  ContentView.swift
//  Instagrad
//
//  Created by David Wale on 24/04/2023.
//

import SwiftUI
import FilePicker
import SwiftCSV

struct ContentView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(sortDescriptors: []) var ceremonies: FetchedResults<Ceremony>
    @FetchRequest(sortDescriptors: []) var students: FetchedResults<Student>
    @State private var selectedCeremony: Ceremony? = nil
    @State private var showingAddCeremony = false
    @State private var ctaName = ""
    @State private var ctaCode = ""
    @State private var CSVURL = URL(string: "")
    
    
    var body: some View {
        
        NavigationSplitView{
            List{
                NavigationLink{
                    Logger(selectedCeremony: $selectedCeremony)
                } label: {
                    Text("Logger")
                }
                
                NavigationLink{
                    Tagger(selectedCeremony: $selectedCeremony)
                } label: {
                    Text("Tagger")
                    
                }
            }
                
            Spacer()
                
            VStack{
                HStack{
                    Text("Ceremony:")
                    Spacer()
                    Button{
                        showingAddCeremony.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                }

                Picker(selection: $selectedCeremony, label: EmptyView()){
                    ForEach(ceremonies, id: \.self){ceremony in
                        Text(ceremony.name ?? "Unknown").tag(ceremony as Ceremony?)
                    }
                }
                .labelsHidden()
            }
            .frame(minWidth: 150)
            .padding()
            .sheet(isPresented: $showingAddCeremony){
                VStack{
                    TextField("Ceremony Name", text: $ctaName)
                        .frame(minWidth: 150)
                    TextField("Ceremony Code", text: $ctaCode)
                    FilePicker(types: [.commaSeparatedText], allowMultiple: false){ urls in
                        CSVURL = urls[0]
                    } label: {
                        Text("Browse")
                    }
                    Button("Add", action: addCeremony)
                        .disabled(CSVURL?.absoluteURL == nil)
                    Button("Cancel", role: .cancel){
                        ctaCode = ""
                        ctaName = ""
                        CSVURL = nil
                        showingAddCeremony = false
                    }
                }
                .padding(40)
            }
            
        } detail: {
            Image(colorScheme == .dark ? "IG_White" : "IG_Black")
                .resizable()
                .scaledToFit()
                .padding(80)
        }

    }
    
    func addCeremony(){
        let newCeremony = Ceremony(context: moc)
        newCeremony.id = UUID()
        newCeremony.name = ctaName
        newCeremony.code = ctaCode
        
        do{
            let csvFile: CSV = try CSV<Named>(url: CSVURL!)
            var importIndex = 1
            for row in csvFile.rows{
                let orderStr = Int(row["Order0"] ?? "0") ?? 0
                let newStudent = Student(context: moc)
                newStudent.id = UUID()
                newStudent.name = row["Title"]
                newStudent.studNum = row["StudentNumber"]
                newStudent.order = Int32(orderStr)
                newStudent.attending = row["AttendanceStatus"]
                newStudent.ceremonyCode = ctaCode
                newStudent.index = Int16(importIndex)
                
                importIndex += 1
            }
        } catch {
            print("something went wrong importing CSV")
        }
        
        
        try? moc.save()
        ctaCode = ""
        ctaName = ""
        CSVURL = nil
        showingAddCeremony = false
    }
    
    func deleteAllCeremonies(){
        for ceremony in ceremonies {
            moc.delete(ceremony)
        }
        
        for student in students {
            moc.delete(student)
        }

        try? moc.save()
    }
    
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
