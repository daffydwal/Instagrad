//
//  FilteredList.swift
//  Instagrad
//
//  Created by David Wale on 24/04/2023.
//

import SwiftUI

struct FilteredList: View {
    @FetchRequest var fetchRequest: FetchedResults<Student>
    @Environment(\.managedObjectContext) var moc
    @State var selectedStudent: Student?
    @State var underway = false
    @FocusState var listFocussed
    @State private var studentSwitchTime = ""
    @State private var studentSwitchTimeFriendly = ""
    @State private var currentTime = ""
    @State private var whereWereWe = 0
    @State private var unknownCount = 1
    @State private var unknownMode = false

    
    var body: some View{
        
        HStack{
            ScrollViewReader{ scrollViewReader in
                    
                ZStack{
                    Button("Log"){
                        logTimes()
                        withAnimation{
                            if let selectedStudent = selectedStudent{
                                scrollViewReader.scrollTo(selectedStudent, anchor: .leading)
                            }
                        }
                    }
                    .keyboardShortcut(.return, modifiers: [])
                    Button("Unknown"){
                        if(!unknownMode && underway){
                            newUnknown()
                            unknownMode = true
                        }
                    }
                    .keyboardShortcut("u", modifiers: [])
                    
                    List(fetchRequest, id: \.self, selection: $selectedStudent) {student in
                        VStack(alignment: .leading){
                                HStack{
                                    Text(String(student.index) + ". ")
                                    Text(student.name ?? "Unknown")
                                        .font(.title2)
                                }
                                HStack{
                                    Spacer()
                                        .frame(width: 40)
                                    Text(student.timeOnFriendly ?? "")
                                    if(student.timeOffFriendly != nil){Text(" -> ")}
                                    Text(student.timeOffFriendly ?? "")
                                }
                            }
                        }
                        .disabled(!underway)
                        .focused($listFocussed)
                        .scrollIndicators(.never)
                    
                    if(!underway){
                        Text("Press enter to begin!")
                            .font(.largeTitle)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.black.opacity(0.75))
                    }
                    
                    }
                    .frame(width:450)
                }
            
            
            
            
            
            Spacer()
            
            VStack{
                if(!underway){
                    Text("Press enter to begin!")
                        .font(.largeTitle)
                }else{
                    Text(selectedStudent?.name ?? "No name")
                        .font(.system(size: 45))
                    Spacer()
                        .frame(height: 40)
                    Image(systemName: "stopwatch")
                        .font(.system(size: 35))
                        .padding()
                    Text(studentSwitchTimeFriendly)
                        .font(.title)
                    Image(systemName: "arrow.down.circle")
                        .font(.system(size: 35))
                        .padding()
                    Text(currentTime)
                        .font(.title)
                        .onAppear{
                            let timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                                let formatter = DateFormatter()
                                formatter.dateFormat = "HH:mm:ss"
                                self.currentTime = formatter.string(from: Date())
                            }
                            timer.fire()
                        }
                        
                }
                    
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
        }
        .padding()
        
        
    }
    
    func logTimes(){
        if(underway){
            selectedStudent?.timeOn = Int32(studentSwitchTime) ?? 0
            selectedStudent?.timeOnFriendly = studentSwitchTimeFriendly
            setStudentSwitchTime()
            selectedStudent?.timeOff = Int32(studentSwitchTime) ?? 0
            selectedStudent?.timeOffFriendly = studentSwitchTimeFriendly
            let selectedStudentInt = selectedStudent?.index ?? 0
            
            if(unknownMode){
                selectedStudent = fetchRequest[whereWereWe - 1]
                unknownMode = false
            } else if (selectedStudentInt >= fetchRequest.count){
                print("End of list, stopping")
            } else {
                selectedStudent = fetchRequest[Int(selectedStudentInt)]
            }
            
            try? moc.save()
        } else {
            setStudentSwitchTime()
            selectedStudent = fetchRequest.first
            underway = true
            listFocussed = true
        }
    }
    
    func setStudentSwitchTime(){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HHmmss"
        
        let dateFormatterFriendly = DateFormatter()
        dateFormatterFriendly.dateFormat = "HH:mm:ss"
        
        let time = dateFormatter.string(from: Date())
        let timeFiendly = dateFormatterFriendly.string(from: Date())
        
        studentSwitchTime = time
        studentSwitchTimeFriendly = timeFiendly
    }
    
    func newUnknown(){
        whereWereWe = (Int(selectedStudent?.index ?? 0))
        
        let newStudent = Student(context: moc)
        newStudent.name = ("Unknown_" + String(unknownCount))
        newStudent.studNum = ("1111111" + String(unknownCount))
        newStudent.ceremonyCode = selectedStudent?.ceremonyCode ?? "Not set"
        newStudent.index = Int16(fetchRequest.count + unknownCount)
        newStudent.attending = "A"
        newStudent.order = Int32(8888888 + unknownCount)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
            selectedStudent = fetchRequest[fetchRequest.count - 1]
        }
        unknownCount += 1
    }
    
    
    
    init(filter: String){
        _fetchRequest = FetchRequest<Student>(sortDescriptors: [SortDescriptor(\.order)], predicate: NSPredicate(format: "ceremonyCode BEGINSWITH %@", filter))
    }
}

//struct FilteredList_Previews: PreviewProvider {
//    static var previews: some View {
//        FilteredList()
//    }
//}
