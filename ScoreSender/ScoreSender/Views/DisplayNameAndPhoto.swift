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
    
    @Binding var username: String
    @Binding var image: UIImage
    @Binding var isPresented: Bool
    
//    var usedUsernames: [String]
    
    @State var isShowingImagePicker = false
    
    @State var showingAlert = false
    @State var alertMessage = "" {
        didSet {
            showingAlert = true
        }
    }
    
    var leagueID: String?
        
    let callback: (Bool) -> ()
        
    var body: some View {
        
        VStack (alignment: .leading, spacing: 16) {
            HStack (spacing: 16) {
                Text("Username: ")
                 TextField("User1234", text: $username) {
                     UIApplication.shared.endEditing()
                 }
                     .padding(.all, 12)
                     .overlay(
                     RoundedRectangle(cornerRadius: 4)
                         .strokeBorder(style: StrokeStyle(lineWidth: 1))
                         .foregroundColor(Color(.sRGB, red: 0.1, green: 0.1, blue: 0.1, opacity: 0.2)))
                    //Spacer()
             }
             
             HStack {
                Spacer()
                 Image(uiImage: image)
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
                     //self.session.changeUser(image: i)
                self.image = i
             }, isPresented: self.$isShowingImagePicker)
            })
            
            Button(action: addButton) {
               SpanningLabel(color: .green, content: "Add")
            }.alert(isPresented: $showingAlert, content: {
                Alert(title: Text(alertMessage))
            })
           
            Button(action: cancelButton) {
               SpanningLabel(color: .red, content: "Cancel")
            }
            
        }.padding(.all, 30)
    }
    
    func addButton() {
        if username == "" {
            self.alertMessage = "You cant have a blank username"
        } else if username.count > Constants.maxCharacterDisplayName {
            self.alertMessage = "Usernames must be less than \(Constants.maxCharacterDisplayName) characters"
        }else{
            // get another reference to league right before we upload so we can check that the displayname
            // is still unique
            if let leagueID = self.leagueID {
                League.getLeagueFromFirebase(forLeagueID: leagueID, forDisplay: false, shouldGetGames: false, callback: { league in
                    if let league = league {
                        for player in league.returnPlayers() {
                            if player.displayName == self.username {
                                self.alertMessage = "\(self.username) is taken"
                                return
                            }
                        }
                        // no errors, send back that the user didnt cancel
                        self.callback(false)
                        self.isPresented = false
                    }else{
                        self.alertMessage = "Try again later"
                        return
                    }
                })
            } else {
                self.callback(false)
                self.isPresented = false
            }
        }
    }
    
    func cancelButton() {
        self.callback(true)
        self.isPresented = false
    }
    
}
