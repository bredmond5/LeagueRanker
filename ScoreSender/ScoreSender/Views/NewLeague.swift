//
//  NewLeague.swift
//  ScoreSender
//
//  Created by Brice Redmond on 5/13/20.
//  Copyright © 2020 Brice Redmond. All rights reserved.
//

import SwiftUI

struct NewLeague: View {
    @Binding var isPresented: Bool
    
    var user: User
    
    var didAddLeague: (String, UIImage, String, UIImage) -> ()
    var userLeagueNames: [String]
    
    @State var leagueName: String = ""
    
    @State var leagueImage: UIImage = UIImage()
    @State var isShowingImagePicker = false
    
    @State var showingAlert = false
    
    let width: CGFloat = 110
    
    @State var username = ""
    @State var playerImage = UIImage()
    @State var isPresentingModal = false
    @State var displayNameAndPhoto: DisplayNameAndPhoto?
    
    var body: some View {
        VStack (alignment: .leading, spacing: 16) {
            Text("New League")
                .fontWeight(.heavy)
                .font(.system(size: 32))
                
            Divider()
            
            HStack {
                Spacer()
                  Image(uiImage: leagueImage)
                .resizable()
                .aspectRatio(1, contentMode: .fit)
                .scaledToFill()
                .frame(width: 150, height: 150)
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
                     Text("Select Your League Photo")
                         .fontWeight(.bold)
                         .padding(.all, 8)
                         .background(Color.blue)
                         .foregroundColor(.white)
                         .cornerRadius(4)
                     Spacer()
                 }
             }).sheet(isPresented: $isShowingImagePicker, content: {
               HybridImagePickerController(didAddImage: { i in
                   self.leagueImage = i
                   self.isShowingImagePicker = false
               }, isPresented: self.$isShowingImagePicker)
             })
            
            Divider()
            
            VStack {
                TextField("League Name", text: $leagueName) {
                    UIApplication.shared.endEditing()
                }
                    .padding(.all, 12)
                    .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .strokeBorder(style: StrokeStyle(lineWidth: 1))
                        .foregroundColor(Color(.sRGB, red: 0.1, green: 0.1, blue: 0.1, opacity: 0.2)))
            }
            
            
            Button(action: addButton) {
                SpanningLabel(color: .green, content: "Add")
            }.sheet(isPresented: $isPresentingModal, content: {
                self.displayNameAndPhoto!.navigationBarTitle(self.leagueName)
            })
                        
            Button(action: cancelButton) {
                SpanningLabel(color: .red, content: "Cancel")
            
            }
            
            Spacer()
            
        }.padding(.all, 30)
    
    }
    
    func addButton() {
        if self.leagueName != "" {
            if self.userLeagueNames.contains(self.leagueName) {
                let myAlerts = MyAlerts()
                myAlerts.showMessagePrompt(title: "Error", message: "Duplicate league names by one user are not allowed", callback: {})
                return
            }
            
            self.username = user.displayName!
            self.playerImage = user.image
            
            displayNameAndPhoto = DisplayNameAndPhoto(username: $username, image: $playerImage, isPresented: $isPresentingModal, usedUsernames: [], callback: { userDidCancel in
                if userDidCancel {
                    self.isPresented = false
                }else{
                    self.didAddLeague(self.leagueName, self.leagueImage, self.username, self.playerImage)
                    self.isPresented = false
                }
            })
            self.isPresentingModal = true
            
        }
    }
    
    func cancelButton() {
        self.isPresented = false
    }
}

