//
//  FilteredTagger.swift
//  Instagrad
//
//  Created by David Wale on 25/04/2023.
//

import SwiftUI
import FilePicker

struct ImageFile: Identifiable {
    let id: UUID
    let url: URL
    let createdTime: Int32
    let fileName: String
    var cereCode: String?
    var studName: String?
    var studNum: String?
    let audioOn: Int
}

struct FilteredTagger: View {
    @FetchRequest var fetchRequest: FetchedResults<Student>
    @Environment(\.managedObjectContext) var moc
    @State var allPhotos = [ImageFile]()
    @State var allTaggedPhotos = [ImageFile]()
    @State var photosChosen = false
    @State var renamingInProgress = false
    @State var renamingComplete = false
    @State var renamingProgress = 0.0
    
    var body: some View {
        ZStack{
            HStack{
                
                List(allTaggedPhotos) { Photo in
                    HStack{
                        Text(Photo.fileName)
                        Text(" is of ")
                        Text(Photo.studName ?? "Unknown")
                    }
                }
                .frame(width: 450)
                
                Spacer()
                
                VStack{
                    Image(systemName: "photo.stack")
                        .font(.system(size: 60))
                    FilePicker(types: [.image], allowMultiple: true){urls in
                        for url in urls {
                            addImageFile(fromURL: url)
                        }
                        tagStudentsToImages()
                        
                    } label: {
                        Text("Select photos")
                    }
                    Button("Rename files"){
                        renameFiles()
                    }
                    .disabled(!photosChosen)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .padding()
            
            if(renamingInProgress){
                VStack{
                    if(!renamingComplete){
                        ProgressView("Renaming...", value: renamingProgress, total: Double(allTaggedPhotos.count))
                            .frame(maxWidth: 300)
                            .padding()
                    } else {
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: 60))
                            .padding()
                        Text("Renaming complete")
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(NSColor.windowBackgroundColor))
                .padding()
            }
        }
        
    }
    
    
    
    
    //********************
    //    FUNCTIONS
    //********************
    
    
    
    func tagStudentsToImages(){
        for student in fetchRequest {
            let timeOff = student.timeOff
            let timeOn = student.timeOn
            
            let filteredPhotos = allPhotos.filter {
                $0.createdTime >= timeOn && $0.createdTime <= timeOff
            }
            
            for photo in filteredPhotos {
                let taggedPhoto = ImageFile(id: UUID(), url: photo.url, createdTime: photo.createdTime, fileName: photo.fileName, cereCode: student.ceremonyCode, studName: student.name, studNum: student.studNum, audioOn: Int(student.audioTimeOn))
                allTaggedPhotos.append(taggedPhoto)
            }

        }
        if(allTaggedPhotos.count > 0){photosChosen = true}
    }
    
    func renameFiles () {
        renamingInProgress = true
        let fileManager = FileManager()
        
        for photo in allTaggedPhotos {
            let currentPath = photo.url.path()
            let studName = String(photo.studName ?? "Unknown")
            let studNum = String(photo.studNum ?? "Unknown")
            let cereCode = String(photo.cereCode ?? "Unknown")
            let audioOn = String(photo.audioOn)
            let newPath = (currentPath.replacingOccurrences(of: "IMG_", with: "IMG") + "_" + studName + "_" + studNum + "_" + cereCode + "_" + audioOn + ".JPG")
            
            do{ try fileManager.moveItem(atPath: currentPath, toPath: newPath) } catch let error {print(error.localizedDescription)}
            
            renamingProgress += 1
        }
        
        renamingComplete = true
    }
    
    
    func addImageFile(fromURL url: URL){
        let newName = url.lastPathComponent
        let newTime = getCreatedTime(fromURL: url)
        
        let newImage = ImageFile(id: UUID(), url: url, createdTime: (Int32(newTime) ?? 0), fileName: newName, cereCode: "", audioOn: 0)
        
        allPhotos.append(newImage)
    }
    
    
    func getCreatedTime(fromURL url: URL) -> String{
        let fileAttributes = try? FileManager.default.attributesOfItem(atPath: url.path)
        let creationDate = fileAttributes?[.creationDate] as? Date
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HHmmss"
        
        var timeString = ""
        
        if let creationDate = creationDate {
            timeString = dateFormatter.string(from: creationDate)
        }
        
        return timeString
    }
    
    init(filter: String){
        _fetchRequest = FetchRequest<Student>(sortDescriptors: [SortDescriptor(\.order)], predicate: NSPredicate(format: "ceremonyCode BEGINSWITH %@", filter))
    }
}

//struct FilteredTagger_Previews: PreviewProvider {
//    static var previews: some View {
//        FilteredTagger()
//    }
//}
