//
//  DisplayNameAndPhoto.swift
//  ScoreSender
//
//  Created by Brice Redmond on 7/4/20.
//  Copyright © 2020 Brice Redmond. All rights reserved.
//

import SwiftUI
import FirebaseDatabase

struct DisplayNameAndPhoto: View {    
    @State var username: String = ""
    @State var image: UIImage?        
    @State var isShowingImagePicker = false
    
    @State var showingAlert = false
    @State var alertMessage = "" {
        didSet {
            showingAlert = true
        }
    }
    
    @Binding var isPresented: Bool
    let title: String

    var userFinished: (String, UIImage?, @escaping (Error?) -> ()) -> ()
            
    var body: some View {
        VStack (alignment: .leading, spacing: 16) {
            Text(title)
                .fontWeight(.heavy)
                .font(.system(size: 32))
            GetImage(initialImage: self.image ?? Constants.defaultPlayerPhoto, resizePercentage: 0.2, imageViewSize: 120, userChoseImage: { image in
                self.image = image
            })
            HStack {
            Text("Username: ")
            TextField(self.username, text: $username) {
                 UIApplication.shared.endEditing()
             }
                 .padding(.all, 12)
                 .overlay(
                 RoundedRectangle(cornerRadius: 4)
                     .strokeBorder(style: StrokeStyle(lineWidth: 1))
                     .foregroundColor(Color(.sRGB, red: 0.1, green: 0.1, blue: 0.1, opacity: 0.2)))
                //Spacer()
            }
            
            Button(action: addButton) {
                SpanningLabel(color: .green, content: "Go")
            }
           
            Spacer()
            
        }.padding(.all, 16)
        .alert(isPresented: $showingAlert, content: {
            Alert(title: Text(alertMessage))
        })
         .navigationBarItems(trailing: Button(action: addButton) {
             Text("Go")
         })
        
        
    }
    
    func addButton() {
        userFinished(self.username, self.image) { error in
            if let error = error {
                self.alertMessage = error.localizedDescription
                return
            }
            self.isPresented = false
        }
    }
}
