//
//  Tagger.swift
//  Instagrad
//
//  Created by David Wale on 24/04/2023.
//

import SwiftUI

struct Tagger: View {
    @Binding var selectedCeremony: Ceremony?
    
    var body: some View {
        if selectedCeremony?.name == nil{
            Text("Please select a ceremony")
        } else {
            FilteredTagger(filter: selectedCeremony?.code ?? "Unknown")            
        }
    }
}
//
//struct Tagger_Previews: PreviewProvider {
//    static var previews: some View {
//        Tagger()
//    }
//}
