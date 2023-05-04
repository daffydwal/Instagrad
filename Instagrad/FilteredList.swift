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
    @State var paused = false
    @FocusState var listFocussed
    @State var timer: Timer?
    @State private var studentSwitchTime = ""
    @State private var studentSwitchTimeRecording = 0.0
    @State private var studentSwitchTimeFriendly = ""
    @State private var currentTime = ""
    @State private var whereWereWe = 0
    @State private var unknownCount = 1
    @State private var unknownMode = false
    @State private var recordDuration = "Ready to record"
    var audioRecorder: AudioControl

    
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
                Spacer()
                if(!underway){
                    Text("Press enter to begin!")
                        .font(.largeTitle)
                }else{
                    VStack{
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
                                let nowTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                                    let formatter = DateFormatter()
                                    formatter.dateFormat = "HH:mm:ss"
                                    self.currentTime = formatter.string(from: Date())
                                }
                                nowTimer.fire()
                            }
                    }
                        
                }
                Spacer()
                HStack{
                    if(underway){
                        if(!paused){
                            Button("Pause"){
                                pauseRecording()
                                paused = true
                            }
                        } else {
                            Button("Resume"){
                                startRecording()
                                setStudentSwitchTime()
                                paused = false
                            }
                        }
                        Button("Finish"){
                            stopRecording()
                        }
                    }
                    Spacer()
                    if(!underway){
                        Image(systemName: "checkmark.circle")
                            .font(.largeTitle)
                            .foregroundColor(.green)
                    }
                    if(underway && !paused){
                        Image(systemName: "record.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.red)
                    }
                    if(paused){
                        Image(systemName: "pause.circle")
                            .font(.largeTitle)
                    }
                    Text(recordDuration)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
        }
        .padding()
        
        
    }
    
    func logTimes(){
        if(underway){
            print("recording time on: \(studentSwitchTimeRecording)")
            selectedStudent?.timeOn = Int32(studentSwitchTime) ?? 0
            selectedStudent?.timeOnFriendly = studentSwitchTimeFriendly
            selectedStudent?.audioTimeOn = studentSwitchTimeRecording
            setStudentSwitchTime()
            print("recording time off: \(studentSwitchTimeRecording)")
            selectedStudent?.timeOff = Int32(studentSwitchTime) ?? 0
            selectedStudent?.timeOffFriendly = studentSwitchTimeFriendly
            selectedStudent?.audioTimeOff = studentSwitchTimeRecording
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
            studentSwitchTimeRecording = 0
            selectedStudent = fetchRequest.first
            startRecording()
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
        studentSwitchTimeRecording = audioRecorder.getTime() - 3
    }
    
    func newUnknown(){
        whereWereWe = (Int(selectedStudent?.index ?? 0))
        
        let newStudent = Student(context: moc)
        newStudent.name = ("Unknown" + String(unknownCount))
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
    
    func getFriendlyTime(){
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = .pad
        let friendlyTime = formatter.string(from: audioRecorder.getTime())
        recordDuration = friendlyTime ?? "00:00:00"
//        print(friendlyTime ?? "Something not right with getting friendly time!")
    }
    
    func startRecording(){
        audioRecorder.startRecord()
        if(!underway){
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true){ timer in
                getFriendlyTime()
            }
        }
//        isRecording = true
    }
    
    func stopRecording(){
        timer!.invalidate()
        audioRecorder.stopRecord()
//        isRecording = false
    }
    
    func pauseRecording(){
        audioRecorder.pauseRecord()
//        isRecording = false
    }
    
//    func pauseCeremony(){
//        paused = true
//        pauseRecording()
//    }
//
//    func endCeremony(){
//
//    }
    
    
    
    init(filter: String, rootPath: String, fileName: String){
        _fetchRequest = FetchRequest<Student>(sortDescriptors: [SortDescriptor(\.order)], predicate: NSPredicate(format: "ceremonyCode BEGINSWITH %@", filter))
        let fullPathString = rootPath + "/" + fileName
        let fullPathURL = URL(filePath: fullPathString)
        audioRecorder = AudioControl(path: fullPathURL)
    }
}

//struct FilteredList_Previews: PreviewProvider {
//    static var previews: some View {
//        FilteredList()
//    }
//}
