//
//  SettingsForm.swift
//  ScoreSender
//
//  Created by Brice Redmond on 5/11/20.
//  Copyright © 2020 Brice Redmond. All rights reserved.
//

import SwiftUI
import CropViewController


struct SettingsFormOverall: View {
    @EnvironmentObject var session: FirebaseSession
    
    @State var username: String = ""
//    @State var currentUsername: String
        
    @State var showingAlert = false
    @State var showingMessageAlert = false
        
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    
    @State var image: UIImage?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            Divider()
            
            Text("Phone Number: " + (session.session?.phoneNumber ?? ""))
                  .fontWeight(.heavy)
                  .font(.system(size: 18))
                   Divider()
            HStack (spacing: 12) {
                TextField(self.session.session?.realName ?? "", text: self.$username)
                .padding(.all, 12)
                .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .strokeBorder(style: StrokeStyle(lineWidth: 1))
                    .foregroundColor(Color(.sRGB, red: 0.1, green: 0.1, blue: 0.1, opacity: 0.2)))
                Button(action: {
                    if self.username != "" {
                        self.showingMessageAlert = true
                    }
                }) {
                    SpanningLabel(color: .green, content: "Change")
                    }.alert(isPresented: $showingMessageAlert) {
                        Alert(title: Text("This should be your real first name"), message: Text("This is used to help people identify you in leagues"), primaryButton: .default(Text("Change")) {
                            self.session.changeUser(realName: self.username, image: nil)
                        }, secondaryButton: .cancel())
                    }
                .frame(width: 70)
            }
            Divider()
           
            GetImage(initialImage: self.session.session?.image ?? Constants.defaultPlayerPhoto, resizePercentage: 0.2, imageViewSize: 120, userChoseImage: { image in
                self.session.changeUser(image: image)
            })
            
            Button(action: {
                self.showingAlert = true
            }) {
                SpanningLabel(color: .red, content: "Log Out")
            }.alert(isPresented: $showingAlert) {
                Alert(title: Text("Log Out"), message: Text("Are you sure you want to log out?"), primaryButton: .destructive(Text("Log Out")) {
                    self.logout()
                }, secondaryButton: .cancel())
            }

           Spacer()
        }.padding(.all, 20)
    }
    
    func finishedCrop() {
        print("Done")
    }
    
    func logout() {
        self.session.logOut()
        self.mode.wrappedValue.dismiss()
    }
}

