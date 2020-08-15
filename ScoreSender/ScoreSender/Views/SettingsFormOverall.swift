//
//  SettingsForm.swift
//  ScoreSender
//
//  Created by Brice Redmond on 5/11/20.
//  Copyright © 2020 Brice Redmond. All rights reserved.
//

import SwiftUI

struct SettingsFormOverall: View {
    @EnvironmentObject var session: FirebaseSession
    
    @State var isShowingImagePicker = false
    @State var username: String = ""
//    @State var currentUsername: String
        
    @State var showingAlert = false
    @State var showingMessageAlert = false
    
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Divider()
            Text("Phone Number: " + (session.session?.phoneNumber ?? ""))
                  .fontWeight(.heavy)
                  .font(.system(size: 18))
                   Divider()
            HStack (spacing: 12) {
                TextField(self.session.session?.displayName ?? "", text: self.$username)
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
                            self.session.changeUser(displayName: self.username, image: nil)
                        }, secondaryButton: .cancel())
                    }
                .frame(width: 70)
            }
            Divider()
            
//            HStack (spacing: 16) {
//                TextField("Change Name", text: $username) {
//                    UIApplication.shared.endEditing()
//                }
//                    .padding(.all, 12)
//                    .overlay(
//                    RoundedRectangle(cornerRadius: 4)
//                        .strokeBorder(style: StrokeStyle(lineWidth: 1))
//                        .foregroundColor(Color(.sRGB, red: 0.1, green: 0.1, blue: 0.1, opacity: 0.2)))
                            
                
//                Button(action: {
//                    if !self.username.isEmpty {
//                        self.currentUsername = self.username
//                        self.session.changeUser(displayName: self.username, image: nil)
//                    }
//                }, label: {
//                    Text("Change")
//                         .foregroundColor(.white)
//                           .padding(.vertical, 8)
//                           .padding(.horizontal, 12)
//                             .background(Color.green)
//                           .cornerRadius(4)
//
//                })
//                .frame(width: 90, alignment: .leading)
//            }
            
            HStack {
               Spacer()
                Image(uiImage: self.session.session?.image ?? UIImage())
                   
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
                    self.session.changeUser(image: i)
                    
            }, isPresented: self.$isShowingImagePicker)
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
    
    func logout() {
        self.session.logOut()
        self.mode.wrappedValue.dismiss()
    }
}

