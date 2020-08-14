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
    
    let curLeague: League
    let player: PlayerForm
    
    @State var displayName: String = ""
    
    var width: CGFloat = 80
    
    @State var showingAlert = false
    @State var alertMessage = "" {
        didSet {
            showingAlert = true
        }
    }
    @State var isShowingImagePicker = false
    
    @State var didUploadUsername = false
    @State var uploadedImage: UIImage?
    
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>

    
    var body: some View {
        
        VStack (alignment: .leading, spacing: 16) {
            HStack {
                Spacer()
                Image(uiImage: uploadedImage ?? self.player.image)
                    
                .resizable()
                .scaledToFill()
               .frame(width: 120, height: 120)
                .overlay(
                    RoundedRectangle(cornerRadius: 80)
                        .strokeBorder(style: StrokeStyle(lineWidth: 2))
                        .foregroundColor(Color(.sRGB, red: 0.1, green: 0.1, blue: 0.1, opacity: 1)))
                .cornerRadius(80)
                Spacer()
            }
            
            Button(action: {
                self.isShowingImagePicker.toggle()
            }, label: {
                HStack {
                    Spacer()
                    Text("Select Your Photo")
                        .fontWeight(.bold)
                        .padding(.all, 8)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(4)
                    Spacer()
                }
            }).sheet(isPresented: $isShowingImagePicker, content: {
             HybridImagePickerController(didAddImage: { i in
                self.uploadedImage = i
                     
             }, isPresented: self.$isShowingImagePicker)
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
        if self.displayName != "" {
            changeDisplayName(callback: { success in
                if success {
                    self.changeImage(callback: { imageSuccess in
                        self.mode.wrappedValue.dismiss()
                    })
                }
            })
        } else {
            self.changeImage(callback: { imageSuccess in
                self.mode.wrappedValue.dismiss()
            })
        }
    }
    
    func changeImage(callback: @escaping (Bool) -> ()) {
        if let image = uploadedImage {
            self.curLeague.changePlayerImage(player: self.player, newImage: image, callback: { didUploadImage in
                if didUploadImage {
                    self.player.image = image
                    callback(true)
                } else {
                    self.alertMessage = "Could not upload photo"
                    callback(false)
                    return
                }
            })
        } else {
            callback(true)
        }
    }
    
    func changeDisplayName(callback: @escaping (Bool) -> ()) {
        if displayName == "" {
            alertMessage = "You cant have a blank username"
            callback(false)
            return
        }
            
        if displayName.count > Constants.maxCharacterDisplayName {
            alertMessage = "Usernames must be less than \(Constants.maxCharacterDisplayName)"
            callback(false)
            return
        }
        
        //Redownload league just to make sure no one else has changed their display name to what we are trying
        League.getLeagueFromFirebase(forLeagueID: curLeague.id.uuidString, forDisplay: false, callback: { league in
            if let league = league {
                for player in league.returnPlayers() {
                    if player.displayName == self.displayName {
                        self.alertMessage = "\(self.displayName) is taken"
                        callback(false)
                        return
                    }
                }
                // no one has the name so tell the league to change the display name
                self.curLeague.changePlayerDisplayName(phoneNumber: self.player.phoneNumber, newDisplayName: self.displayName, callback: { success, errorMessage in
                    if success {
                        self.player.displayName = self.displayName
                        callback(true)
                    } else {
                        self.alertMessage = errorMessage
                        self.showingAlert = true
                        return
                    }
                })
            } else {
                self.alertMessage = "Try again later"
            }
        })
    }
}

