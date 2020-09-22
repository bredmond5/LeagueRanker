//
//  ChangeProfileLeague.swift
//  ScoreSender
//
//  Created by Brice Redmond on 8/13/20.
//  Copyright © 2020 Brice Redmond. All rights reserved.
//

import SwiftUI
import FirebaseDatabase

struct ChangeProfileLeague: View {
    @EnvironmentObject var session: FirebaseSession
        
    @ObservedObject var curLeague: League
    let player: PlayerForm
    
    @State var displayName: String = ""
    
    var width: CGFloat = 80
    
    @State var showingAlert = false
    @State var alertMessage = "" {
        didSet {
            self.showingAlert = true
        }
    }
    @State var isShowingImagePicker = false
    
    @State var didUploadUsername = false
    @State var uploadedImage: UIImage?
    
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>

    
    var body: some View {
        
        VStack (alignment: .leading, spacing: 16) {
            
            GetImage(initialImage: self.player.dbImage.image, resizePercentage: 0.2, imageViewSize: 120, userChoseImage: { image in
                self.uploadedImage = image
            })
            
            
            HStack (spacing: 16) {
                Text("Username: ")
                    .frame(width: width, alignment: .leading)
                TextField(player.displayName, text: self.$displayName)
                    .padding(.all, 12)
                    .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .strokeBorder(style: StrokeStyle(lineWidth: 1))
                        .foregroundColor(Color(.sRGB, red: 0.1, green: 0.1, blue: 0.1, opacity: 0.2)))

            }
            Spacer()
            }.navigationBarTitle("Change Profile")
        .alert(isPresented: self.$showingAlert, content: {
            Alert(title: Text(self.alertMessage))
        }).padding(.all, 16)
            .navigationBarItems(trailing: Button(action: save) {
                Text("Save")
            })
    }
    
    func save() {
        let myGroup = DispatchGroup()
        var errorFound: Error?
        
        if self.displayName != ""  && self.displayName != self.player.displayName {
            myGroup.enter()
            changeDisplayName(self.displayName, callback: { error in
                if let error = error {
                    errorFound = error
                }
                myGroup.leave()
            })
        }
        
        if let image = uploadedImage {
            myGroup.enter()
            self.changeImage(image, callback: { error in
                if let error = error {
                    errorFound = error
                }
                myGroup.leave()
            })
        }
        
        myGroup.notify(queue: .main) {
            if let error = errorFound {
                self.alertMessage = error.localizedDescription
                self.showingAlert = true
            } else {
                self.mode.wrappedValue.dismiss()
            }
        }
    }
    
    func changeImage(_ image: UIImage, callback: @escaping (Error?) -> ()) {
//        session.changePlayerImage(forLeague: curLeague, newImage: image, forPlayer: player, completion: { error in
//            callback(error)
//        })
    }
    
    func changeDisplayName(_ displayName: String, callback: @escaping (Error?) -> ()) {
//        session.changeDisplayName(forLeague: curLeague, newDisplayName: displayName, forPlayer: self.player, completion: { error in
//            callback(error)
//        })
        
    }
}

